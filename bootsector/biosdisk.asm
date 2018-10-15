; load 'dh' sectors from drive 'dl' into ES:BX
disk_load:
	pusha
	push dx

	mov ah, 0x02	; read
	mov al, dh		; number of sectors
	mov cl, 0x02	; start sector, 1 = MBR
	mov ch, 0		; cylinder
	mov dh, 0		; head
	int 0x13		; call BIOS
	jc disk_error
	
	pop dx
	cmp al, dh		; BIOS sets al to num sectors read, compare to requested
	jne sectors_error
	popa
	ret

disk_error:
	mov bx, MSG_DISKERROR
	call print
	mov bx, MSG_NEWLINE
	call print
	mov dh, ah		; ah = error code, dl = disk drive
	call print_hex
	jmp $			; halt

sectors_error:
	mov bx, MSG_SEGTORSERROR
	call print
	mov bx, MSG_NEWLINE
	call print
	jmp $			; halt

MSG_DISKERROR db 'Disk read error', 0
MSG_SEGTORSERROR db 'Incorrect number of sectors read', 0
