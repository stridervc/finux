; FUNC print
; bx should contain the start address of a null terminated string
; use 0x0d, 0x0a for carriage return (\r) and newline (\n)
print:
	pusha
	mov ah, 0x0e	; BIOS print

print_loop:
	mov al, [bx]	; character to print
	cmp al, 0
	je print_done
	
	int 0x10
	inc bx
	jmp print_loop

print_done:
	popa
	ret

; FUNC print_hex
; dx is value to hex print
print_hex:
	pusha
	mov bx, 4	; print 4 characters

hex_loop:
	push dx
	and dx, 0x000f		; keep LS 4 bits
	add dl, 0x30		; 0 - 9 ascii
	cmp dl, 0x39		; if > 9
	jle hex_step2
	add dl, 7			; A - F ascii

hex_step2:
	mov [HEXSTR+bx+1], dl	; put ascii char in our string
	pop dx
	shr dx, 4			; discard processed digit
	dec bx
	jnz hex_loop

hex_done:
	mov bx, HEXSTR
	call print

	popa
	ret

; data
HEXSTR db '0x0000', 0

