; PCI driver
; https://wiki.osdev.org/PCI

CONFIG_ADDRESS	equ 0xCF8
CONFIG_DATA		equ 0xCFC

; AH bus number 		8 bits
; AL device number		5 bits
; BH function number	3 bits
; BL register number	6 bits
; return 32 bits read in eax
pci_read:
	pusha
	
	; bus number
	mov edx, 0
	mov dl, ah
	shl edx, 16

	; device number
	mov ecx, 0
	mov cl, al
	shl	ecx, 11
	or edx, ecx

	; function number
	mov eax, edx
	mov edx, 0
	mov dl, bh
	shl edx, 8
	or eax, edx

	; register number
	mov edx, 0
	mov dl, bl
	shl edx, 2
	or eax, edx
	
	; enable bit 31
	or eax, 0x80000000

	out CONFIG_ADDRESS, eax

	popa
	in eax, CONFIG_DATA

	ret

; Scan all devices on bus and check for valid ones
; AH bus number to scan
pci_scan_bus:
	pusha
	
	mov al, 0	; device number
	mov bx, 0	; function and register numbers

.loop:
	call .print_bus_device

	push eax
	call pci_read

	cmp ax, 0xffff
	je .checkloop

	call kprint_hexw	; print AX (vendor id)
	call kprint_nl

.checkloop:
	pop eax
	inc al
	cmp al, 32
	jne .loop

.done:
	popa
	ret

; helper function to print bus and device number
; ah = bus
; al = device
.print_bus_device:
	push eax
	push ebx
	
	mov ebx, .msgcr
	call kprint			; move cursor to beginning of line

	and eax, 0x0000ffff
	push ax
	shr ax, 8	; bus number in al
	call kprint_dec
	pop ax
	mov ah, 0	; device number in al
	mov ebx, .msgspace
	call kprint
	call kprint_dec
	call kprint

	pop ebx
	pop eax
	ret

.msgspace db " ", 0
.msgcr db 0x0d, 0

; scan all pci busses and devices
pci_scan_all:
	pusha

	mov ebx, .msgscanning
	call kprint
	call kprint_nl

	mov ah, 0	; bus number

.loop:
	call pci_scan_bus
	inc ah
	cmp ah, 0
	jne .loop

	call kprint_nl
	popa
	ret

.msgscanning db "Scanning for PCI devices...", 0
