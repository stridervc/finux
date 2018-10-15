[org 0x1000]	; Kernel will be loaded to this address
[bits 32]		; We're already in protected mode 

mov bx, MSG_NEWLINE
call kprint
mov bx, MSG_KERNEL
call kprint
mov bx, MSG_NEWLINE
call kprint

jmp $			; Infinite loop

%include "kprint.asm"

; data
MSG_NEWLINE	db 0x0d, 0x0a, 0
MSG_KERNEL	db "Finux 0.0.1", 0
