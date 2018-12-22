;[org 0x1000]	; Kernel will be loaded to this address
global start

MAGIC 			equ 0xE85250D6
ARCHITECTURE 	equ 0
HEADERSIZE 		equ header_end - header_start
CHECKSUM 		equ 0x100000000 - (MAGIC+HEADERSIZE+ARCHITECTURE)

section .multiboot_header
header_start:
	align 4
	dd MAGIC			; multiboot 2 magic number
	dd ARCHITECTURE		; architecture (32-bit protected mode)
	dd HEADERSIZE		; header length
	dd CHECKSUM
	; tags come here
	; end tag
	dw 0				; type
	dw 0				; flags
	dw 8				; size
header_end:

section .text
[bits 32]				; We're in protected mode
start:

cmp eax, 0x36d76289		; check if we were loaded by multiboot2
jne .nope
mov byte [multiboot], 1

.nope:
; load gdt
lgdt [gdt_descriptor]

; update segment registers
mov eax, DATA_SEG
mov ds, eax
mov ss, eax
mov es, eax
mov fs, eax
mov gs, eax

; far jump to fix cs?
jmp CODE_SEG:fixcs

fixcs:
; set up stack
mov ebp, 0x110000
mov esp, ebp

; print kernel version
push ebx				; preserve boot information from grub
mov ebx, MSG_KERNEL
call kprint
call kprint_nl

pop ebx					; restore multiboot information
cmp byte [multiboot], 1
jne .continue
call multiboot_info

.continue:
; load idt
mov ebx, MSG_IDT
call kprint
lidt [idt_reg]
call kprint_nl

; initialise PICs
mov ebx, MSG_PIC
call kprint
call init_pic
call kprint_nl

; initialise timer
mov ebx, MSG_INIT_TIMER
call kprint
call init_timer
call kprint_nl

sti				; Enable interrupts

; test ata identify
test_ata:
mov ebx, MSG_ID_DISK
call kprint
call kprint_nl
mov dx, PRIMARY_ATA_START
mov al, 0xa0	; master disk
mov edi, tmp_drive_id
call ata_identify
cmp al, 0
je .drive_success

; error, print al
call kprint_hexb
jmp .shell

.drive_success:
mov ebx, MSG_DISK_FOUND
call kprint
call kprint_nl

call process_initrd

.shell:
call shell_main

jmp $			; Infinite loop

%include "kprint.asm"
%include "gdt.asm"
%include "interrupts.asm"
%include "idt.asm"
%include "pic.asm"
%include "shell.asm"
%include "multibootinfo.asm"
%include "drivers/ata.asm"
%include "timer.asm"
%include "initrd.asm"

; data
;section .bss
multiboot	db 0	; 1 = multiboot info available
MSG_KERNEL	db "Finux 0.0.2", 0
MSG_IDT		db "Loading IDT...", 0
MSG_PIC		db "Initialising PICs...", 0
MSG_ID_DISK db "Calling ATA Identify on Primary Master...", 0
MSG_DISK_FOUND db "Disk found", 0
MSG_INIT_TIMER	db "Initialising timer...", 0
tmp_drive_id	resw 256

