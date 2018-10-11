[org 0x7c00]	; boot sector is loaded to this address in memory
[bits 16]		; we start in real mode

; BIOS sets dl to the boot drive, save it
mov	[BOOT_DRIVE], dl		

; set the stack safely away from us
mov bp, 0x9000
mov sp, bp

; Show the boot disk as passed from BIOS
mov bx, MSG_BOOTDISK
call print
call print_hex		; dl = boot disk from bios
mov bx, MSG_NEWLINE
call print

jmp $				; infinite loop

%include "biosprint.asm"

; data
BOOT_DRIVE		db 0	; Place to store boot drive from BIOS
MSG_NEWLINE		db 0x0d, 0x0a, 0
MSG_BOOTDISK	db "Disk from BIOS=", 0

; Fill with 512 zeroes minus the size of the code, minus the signature
times 510-($-$$) db 0
dw 0xaa55	; boot sector signature

