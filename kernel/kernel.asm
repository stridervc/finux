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
; TODO set up stack

cmp eax, 0x36d76289		; check if we were loaded by multiboot2
jne .nope
mov byte [0xb8000], 'Y'
jmp .done

.nope:
mov byte [0xb8000], 'X'

.done:
mov ebx, MSG_NEWLINE
call kprint
mov ebx, MSG_KERNEL
call kprint
mov ebx, MSG_NEWLINE
call kprint

hlt

;; load idt
;mov bx, MSG_IDT
;call kprint
;lidt [idt_reg]
;mov bx, MSG_NEWLINE
;call kprint

;; initialise PICs
;mov bx, MSG_PIC
;call kprint
;call init_pic
;mov bx, MSG_NEWLINE
;call kprint

;sti				; Enable interrupts

;call shell_main

;jmp $			; Infinite loop

%include "kprint.asm"
;%include "interrupts.asm"
;%include "idt.asm"
;%include "pic.asm"
;%include "shell.asm"

; data
;section .bss
MSG_NEWLINE	db 0x0d, 0x0a, 0
MSG_KERNEL	db "Finux 0.0.2", 0
MSG_IDT		db "Loading IDT...", 0
MSG_PIC		db "Initialising PICs...", 0
MSG_PROMPT	db "> ", 0

