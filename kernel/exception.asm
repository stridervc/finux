; Exception handler

exception_int:
	pusha

	push ebx
	mov ebx, .msgexception
	call kprint
	call kprint_nl
	pop ebx

	call regdump
	call kprint_nl
	hlt

	popa
	ret

	.msgexception db "Kernel exception!", 0
