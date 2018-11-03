; string functions

; compare two null terminated strings
; return ax = 0 if strings match
; call with bx and dx as addresses of strings
strcmp:
	push cx
	push si
	push di

	; first, see if the lengths match
	call strlen
	mov cx, ax		; store length
	push bx
	mov bx, dx
	call strlen
	pop bx

	cmp ax, cx
	jne .nope

	; now, compare the strings byte for byte
	; cx = length already
	cld
	mov si, bx
	mov di, dx

.loop:
	cmpsb
	jne .nope
	dec cx
	cmp cx, 0
	;je .match
	;jmp .loop
	jne .loop

.match:
	mov ax, 0
	jmp .done

.nope:
	mov ax, 1
	;jmp done

.done:
	pop di
	pop si
	pop cx
	ret

; returns length of null terminated string in ax
; call with bx = address of string
strlen:
	push bx

	mov ax, 0
.loop:
	cmp byte [bx], 0
	je .done
	inc ax
	inc bx
	jmp .loop

.done:
	pop bx
	ret
