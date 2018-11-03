; very basic shell

%include "../lib/string.asm"

SHELLBUFFERSIZE equ 256

MSGSHELLPROMPT db "> ", 0
MSGSHELLNL db 0x0d, 0x0a, 0

MSGHELLOREPLY db "world", 0x0d, 0x0a, 0
MSGSHELLUNKNOWN db ": command not found", 0x0d, 0x0a, 0

CMDHELLO db "hello", 0

shellinput resb SHELLBUFFERSIZE+1

; called by kernel
shell_main:
	pusha 

	mov bx, MSGSHELLPROMPT
	call kprint

	jmp $

	popa
	ret

; called by keyboard interrupt when enter is pressed
shell_input:
	pusha
	
	; print newline
	mov bx, MSGSHELLNL
	call kprint

	; get keyboard buffer
	mov bx, shellinput
	mov cx, SHELLBUFFERSIZE
	call gets

	; clear keyboard buffer
	call keyboardclear

	; check for some inputs
	mov dx, CMDHELLO
	call strcmp
	cmp ax, 0
	jne .next
	call cmdhello
	jmp .matched

.next:
	call kprint
	mov bx, MSGSHELLUNKNOWN
	call kprint

.matched:
	mov bx, MSGSHELLPROMPT
	call kprint

	popa
	ret

cmdhello:
	push bx
	mov bx, MSGHELLOREPLY
	call kprint
	pop bx
	ret

