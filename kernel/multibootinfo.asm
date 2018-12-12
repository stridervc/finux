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

	cmp eax, 14
	je .acpi1

	; unhandled type
	;call kprint_dec
	;call kprint_nl

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

.acpi1:
	pusha

	push ebx
	mov ebx, .msgacpi
	call kprint
	pop ebx

	; OEM ID
	add ebx, 8+8+1
	; copy vendor chars to null terminated string
	mov esi, ebx
	mov edi, .msgacpivendor
	mov ecx, 6
	rep movsb

	; print vendor
	push ebx
	mov ebx, .msgacpivendor
	call kprint
	pop ebx

	; Revision
	add ebx, 6
	mov al, byte [ebx]
	cmp al, 0
	jne .continue
	push ebx
	mov ebx, .msgacpi1
	call kprint
	pop ebx

	; rsdt address
	add ebx, 1
	mov ebx, [ebx]
	; TODO parse rsdt

.continue:
	call kprint_nl
	popa
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
	.msgacpi db "ACPI Vendor: ", 0
	.msgacpivendor db "      ", 0
	.msgacpi1 db " Version 1.0", 0

