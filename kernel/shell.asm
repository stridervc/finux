; very basic shell

SHELLBUFFERSIZE equ 256

MSGSHELLPROMPT db "> ", 0
MSGSHELLNL db 0x0d, 0x0a, 0

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

	; DBG
	call kprint
	mov bx, MSGSHELLNL
	call kprint

	; clear keyboard buffer
	call keyboardclear

	; TODO write strcmp
	; and check for some inputs

	mov bx, MSGSHELLPROMPT
	call kprint

	popa
	ret

