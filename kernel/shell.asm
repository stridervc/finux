; very basic shell

%include "../lib/string.asm"
%include "regdump.asm"

SHELLBUFFERSIZE equ 256

MSGSHELLPROMPT db "> ", 0

MSGHELLOREPLY db "world", 0x0d, 0x0a, 0
MSGSHELLUNKNOWN db ": command not found", 0x0d, 0x0a, 0

CMDHELLO db "hello", 0
CMDREGS db "regs", 0

shellinput resb SHELLBUFFERSIZE+1

; called by kernel
shell_main:
	pusha 

	mov ebx, MSGSHELLPROMPT
	call kprint

	jmp $

	popa
	ret

; called by keyboard interrupt when enter is pressed
shell_input:
	pusha
	
	; print newline
	call kprint_nl

	; get keyboard buffer
	mov ebx, shellinput
	mov ecx, SHELLBUFFERSIZE
	call gets

	; clear keyboard buffer
	call keyboardclear

	; if empty, ignore
	mov esi, ebx
	call strlen
	cmp eax, 0
	je .matched

	; check for some inputs
	;mov esi, ebx
	mov edi, CMDHELLO
	call strcmp
	cmp eax, 0
	jne .next1
	call cmdhello
	jmp .matched

.next1:
	mov edi, CMDREGS
	call strcmp
	cmp eax, 0
	jne .next2
	call regdump
	jmp .matched

.next2:
	call kprint
	mov ebx, MSGSHELLUNKNOWN
	call kprint

.matched:
	mov ebx, MSGSHELLPROMPT
	call kprint

	popa
	ret

cmdhello:
	push ebx
	mov ebx, MSGHELLOREPLY
	call kprint
	pop ebx
	ret

