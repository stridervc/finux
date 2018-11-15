; print register values to screen

%macro print_reg 1
	mov eax, %1
	mov ebx, .msg%1
	call kprint
	call kprint_hexd
	mov ebx, .msgnl
	call kprint
%endmacro

regdump:
	push eax
	push ebx

	push ebx
	print_reg eax
	pop ebx

	print_reg ebx
	print_reg ecx
	print_reg edx
	print_reg esp
	print_reg ebp
	print_reg esi
	print_reg edi
	;print_reg eip
	;print_reg eflags
	print_reg cs
	print_reg ss
	print_reg ds
	print_reg es
	print_reg fs
	print_reg gs

	pop ebx
	pop eax
	ret
	
	; data
	.msgnl db  0x0d, 0x0a, 0
	.msgeax db "EAX: ", 0
	.msgebx db "EBX: ", 0
	.msgecx db "ECX: ", 0
	.msgedx db "EDX: ", 0
	.msgesp db "ESP: ", 0
	.msgebp db "EBP: ", 0
	.msgesi db "ESI: ", 0
	.msgedi db "EDI: ", 0
	;.msgeip db "EIP: ", 0
	.msgcs db "CS : ", 0
	.msgss db "SS : ", 0
	.msgds db "DS : ", 0
	.msges db "ES : ", 0
	.msgfs db "FS : ", 0
	.msggs db "GS : ", 0

