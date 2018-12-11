; very basic shell

%include "../lib/string.asm"
%include "regdump.asm"
%include "drivers/pci.asm"

SHELLBUFFERSIZE equ 256

MSGSHELLPROMPT db "> ", 0

MSGHELLOREPLY db "world", 0x0d, 0x0a, 0
MSGSHELLUNKNOWN db ": command not found", 0x0d, 0x0a, 0

CMDHELLO db "hello", 0
CMDREGS db "regs", 0
CMDPCI db "pci", 0

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

	; CMD hello
	mov edi, CMDHELLO
	call strcmp
	cmp eax, 0
	jne .next1
	call cmdhello
	jmp .matched

.next1:
	; CMD regs
	mov edi, CMDREGS
	call strcmp
	cmp eax, 0
	jne .next2
	call regdump
	jmp .matched

.next2:
	; CMD pci
	mov edi, CMDPCI
	call strcmp
	cmp eax, 0
	jne .next3
	call cmdpci
	jmp .matched

.next3:
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

; loop through bus numbers 0-255 and check for valid (not 0xffff)
; vendor IDs
cmdpci:
	pusha
	mov ah, 1
	mov al, 0
	call pci_check_vendor

	popa
	;ret

	pusha

	mov cl, 0		; loop counter
.loop:
	mov ah, cl		; bus number
	mov al, 0		; device number
	call pci_check_vendor
	cmp eax, 0xffffffff
	je .checkloop
	push eax
	mov eax, 0
	mov al, cl
	call kprint_dec	; print bus number
	pop eax
	call kprint_hexw	; print vendor id
	call kprint_nl

.checkloop:
	cmp cl, 255
	je .done
	inc cl
	jmp .loop

.done:
	popa
	ret
