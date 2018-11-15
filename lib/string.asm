; string functions

; compare two null terminated strings
; return ax = 0 if strings match
; call with esi and edi as address of strings
strcmp:
	push ecx
	push esi
	push edi

	; first, see if the lengths match
	call strlen
	mov ecx, eax		; store length
	push esi
	mov esi, edi
	call strlen
	pop esi

	cmp eax, ecx
	jne .nope

	; now, compare the strings byte for byte
	; ecx = length already
	cld

.loop:
	cmpsb
	jne .nope
	dec ecx
	cmp ecx, 0
	jne .loop

.match:
	mov eax, 0
	jmp .done

.nope:
	mov eax, 1
	;jmp done

.done:
	pop edi
	pop esi
	pop ecx
	ret

; returns length of null terminated string in eax
; call with esi = address of string
strlen:
	push esi
	mov eax, 0
.loop:
	cmp byte [esi], 0
	je .done
	inc eax
	inc esi
	jmp .loop

.done:
	pop esi
	ret
