; Handle ATA PIO (ide drives)
; https://wiki.osdev.org/ATA_PIO_Mode

PRIMARY_ATA_START	equ 0x1F0 ; to 0x1F7
SECONDARY_ATA_START	equ 0x170 ; to 0x177

; Device control registers
PRIMARY_ATA_DCR		equ 0x3F6
SECONDARY_ATA_DCR	equ 0x376

; Commands
ATA_CMD_IDENTIFY	equ 0xEC

; Identify disk
; Input
;  DX = base port (eg, PRIMARY_ATA_START)
;  AL = drive select (0xA0 = master, 0xB0 = slave)
;  ES:EDI = address of 512 bytes for return value
; Return
;  AL = 0 success, id in ES:DI
;  AL = 1 no disk
;  AL = 2 error reading from disk
;  ID in [ES:EDI]
ata_identify:
	push ecx
	push edx
	push edi

	add dx, 6		; drive select port
	out dx, al

	xor al, al
	sub dx, 4		; sector count port
	out dx, al
	inc dx			; LBA lo
	out dx, al
	inc dx			; LBA mid
	out dx, al
	inc dx			; LBA hi
	out dx, al

	mov al, ATA_CMD_IDENTIFY
	add dx, 2		; Command port
	out dx, al
	
	; check if disk exists
	in al, dx
	cmp al, 0	; 0 = no disk
	je .nodisk

	; wait for BSY bit to clear
	; BSY is set while drive is preparing to send/receive data
.bsy_loop:
	and al, 10000000b
	cmp al, 0
	je .bsy_done
	in al, dx
	jmp .bsy_loop

.bsy_done:

.drq_loop:
	; wait for bit 3 (DRQ) to be set, or bit 0 (ERR) to be set
	in al, dx
	push ax
	and al, 1000b	; DRQ (Drive ready to send)
	cmp al, 1000b
	je .drive_ready
	pop ax
	and al, 1b		; ERR bit
	cmp al, 1b
	je .drive_error
	jmp .drq_loop

.drive_ready:
	pop ax			; pushed in loop
	; read data from drive to [ES:DI]
	mov cx, 256		; read 256 * 16 bits of data
	sub dx, 7		; data port
.read_loop:
	in ax, dx
	stosw
	dec cx
	cmp cx, 0
	jne .read_loop
	jmp .success

.nodisk:
	mov al, 1
	jmp .ret

.drive_error:
	mov al, 2
	jmp .ret

.success:
	mov al, 0
	;jmp .ret

.ret:
	pop edi
	pop edx
	pop ecx
	ret

