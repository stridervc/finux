[org 0x1000]	; Kernel will be loaded to this address
[bits 32]		; We're in protected mode

mov bx, MSG_NEWLINE
call kprint
mov bx, MSG_KERNEL
call kprint
mov bx, MSG_NEWLINE
call kprint

; load idt
mov bx, MSG_IDT
call kprint
lidt [idt_reg]
mov bx, MSG_NEWLINE
call kprint

; initialise PICs
mov bx, MSG_PIC
call kprint
call init_pic
mov bx, MSG_NEWLINE
call kprint

; test interrupt
int 0x80

jmp $			; Infinite loop

%include "kprint.asm"
%include "interrupts.asm"
%include "idt.asm"
%include "pic.asm"

; data
MSG_NEWLINE	db 0x0d, 0x0a, 0
MSG_KERNEL	db "Finux 0.0.1", 0
MSG_IDT		db "Loading IDT...", 0
MSG_PIC		db "Initialising PICs...", 0
