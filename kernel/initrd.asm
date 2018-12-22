; Process initrd (tar file) passed via grub multiboot2
; https://wiki.osdev.org/Tar

process_initrd:
	pusha
	
	mov ebx, MSGSTART
	call kprint
	call kprint_nl

	; check if a module was passed via grub
	mov al, byte [grub_module_present]
	cmp al, 1
	je .cont1

	; no module passed
	mov ebx, MSGNOMODULE
	call kprint
	call kprint_nl
	jmp .ret

.cont1:
	mov ebx, [grub_module_start]

.loop:
	cmp byte [ebx], 0
	je .ret
	call process_tar_file

	; next header starts on 512 byte boundary 
	; the current header itself is also 512 bytes
	mov edx, 0
	mov ecx, 512
	div ecx			; edx:eax / 512
	cmp dx, 0		; is there a remainder
	je .norem
	inc eax			; extra 512 bytes for remainder
.norem:
	inc eax			; extra 512 bytes for header
	mov dx, 512
	mul dx

	add ebx, eax	; start of next file header
	jmp .loop

.ret:
	popa
	ret

; Process a tar file from memory
; EBX = Start of tar file header
; RETURN
; EAX = size of file processed
process_tar_file:
	push ebx

	; just print the filename for now
	call kprint
	call kprint_nl

	; print size
	add ebx, 100+8*3	; point to file size in header
	mov eax, 11			; sizes are 12 characters (null terminated)
	call process_tar_number	; eax assigned here
	;call kprint_dec
	;call kprint_nl

	pop ebx
	ret

; TAR stores numbers as base 8 in an ascii string
; In
;   EBX = address of string
;   EAX = length of string in characters
; Return
;   EAX = number
process_tar_number:
	push ebx
	push ecx
	push edx
	
	mov ecx, eax	; loop counter

	add ebx, eax
	dec ebx			; move to end of string

	mov [.number], dword 0
	mov eax, 1		; multiplier for oct to dec

.loop:
	mov dl, byte [ebx]
	sub dl, '0'		; ascii to number

	push eax
	mul	dl
	add [.number], eax
	pop eax

	; increase our multiplier
	mov dl, 8
	mul dl

	dec ebx			; next character
	dec ecx
	cmp ecx, 0
	jne .loop

	mov eax, [.number]	; return value

	pop edx
	pop ecx
	pop ebx
	ret

	.number dd 0	; calculated number

MSGSTART	db "Processing initrd...", 0
MSGNOMODULE	db "No initrd provided", 0
