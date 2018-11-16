; get multiboot info

; ebx is set by grub to point to boot information
; see: https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Boot-information-format
multiboot_info:
	pusha

	; get size of boot information
	;mov ecx, [ebx]

	; move to first actual entry
	add ebx, 8
	;sub ecx, 8

.loop:
	mov eax, [ebx]		; get type
	;call kprint_hexd
	;call kprint_nl

	mov edx, [ebx+4]	; get size of entry

	; type 0 is end sentinel
	cmp eax, 0
	je .ret

	cmp eax, 1
	je .commandline

	cmp eax, 2
	je .bootloader

	cmp eax, 4
	je .meminfo

.resume:
	; edx is size of entry, next entry is 'size' away but padded to 8 bytes
	mov eax, edx
	mov dl, 8
	div dl
	cmp ah, 0			; check remainder
	je .mul
	inc al				; there was a remainder, so add one to ah
.mul:
	mul dl
	add ebx, eax		; move to next entry
	dec cx
	jmp .loop

.commandline:
	push ebx
	push ebx

	mov ebx, .msgcommandline
	call kprint

	pop ebx
	add ebx, 8
	call kprint
	call kprint_nl

	pop ebx
	jmp .resume

.bootloader:
	push ebx
	push ebx

	mov ebx, .msgbootloader
	call kprint
	pop ebx
	add ebx, 8
	call kprint
	call kprint_nl

	pop ebx
	jmp .resume

.meminfo:
	push ecx
	push edx
	push ebx

	push ebx
	push ebx

	mov ebx, .msglower
	call kprint
	pop ebx
	mov eax, [ebx+8]
	inc eax
	call kprint_dec
	mov ebx, .msglowerpost
	call kprint
	call kprint_nl

	mov ebx, .msgupper
	call kprint
	pop ebx
	mov eax, [ebx+12]
	mov edx, 0			; high part of dividend
	mov ecx, 1024		; to meg
	div ecx
	call kprint_dec
	mov ebx, .msgupperpost
	call kprint
	call kprint_nl

	pop ebx
	pop edx
	pop ecx
	jmp .resume

.ret:
	popa
	ret

	.msglower db "Lower memory: ", 0
	.msglowerpost db "K", 0
	.msgupper db "Upper memory: ", 0
	.msgupperpost db "M", 0
	.msgbootloader db "Bootloader was: ", 0
	.msgcommandline db "Command line: ", 0
