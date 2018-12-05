; print register values to screen

; first arg is register to print
; second argument is 1 for newline, 0 for spaces
; default for second arg is 1
%macro print_reg 1-2 1
	mov eax, %1
	mov ebx, .msg%1
	call kprint
	call kprint_hexd
	%if %2 == 1
		call kprint_nl
	%else
		mov ebx, .msgspaces
		call kprint
	%endif
%endmacro

regdump:
	push eax
	push ebx

	push ebx
	print_reg eax, 0
	pop ebx

	print_reg ebx
	print_reg ecx, 0
	print_reg edx
	print_reg esp, 0
	print_reg ebp
	print_reg esi, 0
	print_reg edi
	;print_reg eip
	;print_reg eflags
	print_reg cs, 0
	print_reg ss
	print_reg ds, 0
	print_reg es
	print_reg fs, 0
	print_reg gs

	pop ebx
	pop eax
	ret
	
	; data
	.msgspaces db "        ", 0
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

