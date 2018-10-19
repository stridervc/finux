; Handle keyboard interrupts

KEYB_C	equ 0x64	; Keyboard command port
KEYB_D	equ 0x60	; Keyboard data port

keyboard_int:
	push ax
	push bx

	in al, KEYB_D	; read scancode

	cmp al, 0x10	; Q pressed?
	jne .other

	; q pressed
	mov bx, MSG_Q
	call kprint
	jmp .done

.other
	mov bx, MSG_KEYBOARD
	call kprint

.done
	pop bx
	pop ax
	ret

; data
MSG_KEYBOARD db ".", 0
MSG_Q db "Q", 0
