[org 0x7c00]	; boot sector is loaded to this address in memory
[bits 16]		; we start in real mode

KERNEL_OFFSET	equ 0x1000	; Where we'll load the kernel to

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

; load kernel from disk 
mov bx, KERNEL_OFFSET
mov dh, 32
mov dl, [BOOT_DRIVE]
call disk_load

; switch to protected mode
mov bx, MSG_PM
call print
mov bx, MSG_NEWLINE
call print

; 0x7c24
cli
lgdt [gdt_descriptor]
mov eax, cr0
or eax, 0x01			; set 32-bit mode in cr0
mov cr0, eax
jmp CODE_SEG:init_pm	; far jump by using a different segment

%include "biosprint.asm"
%include "biosdisk.asm"

; data
BOOT_DRIVE		db 0	; Place to store boot drive from BIOS
MSG_NEWLINE		db 0x0d, 0x0a, 0
MSG_BOOTDISK	db "Disk from BIOS=", 0
MSG_PM			db "Entering protected mode...", 0

[bits 32]
init_pm:
mov ax, DATA_SEG		; update segment registers
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax

mov ebp, 0x90000	; update the stack at the top of the free space
mov esp, ebp

; we're in protected mode here, pass control to kernel
jmp KERNEL_OFFSET

%include "gdt.asm"

; Fill with 512 zeroes minus the size of the code, minus the signature
times 510-($-$$) db 0
dw 0xaa55	; boot sector signature

