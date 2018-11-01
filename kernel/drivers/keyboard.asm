; Handle keyboard interrupt

KEYB_C	equ 0x64	; Keyboard command port
KEYB_D	equ 0x60	; Keyboard data port

; key buffer
BUFFERSIZE 	equ 256				; Max size of keybuffer
keybuffer 	resb BUFFERSIZE		; Key buffer
keybufferi 	db 0				; Current key buffer index
scancode	db 0				; Store current scancode

MSG_ENTER db 0x0d, 0x0a, "> ", 0
MSG_BACKSPACE db 0x0e, 0

%include "drivers/scancodes.asm"

keyboard_int:
	push ax
	push bx
	push dx

	in al, KEYB_D				; read scancode

	mov [scancode], al			; store scancode
	cmp al, 128					; check if bit 8 is set
	ja	.done					; ignore if it's a release

	cmp al, 0x1c				; enter pressed
	je .enter

	cmp al, 0x0e
	je .backspace

	; key pressed, add it to keybuffer
	;mov bx, keybufferi
	;mov ax, [scancode]
	;mov [keybuffer+bx], al
	;inc bx						; Todo check against BUFFERSIZE
	;mov [keybufferi], bl

	; and print it to the screen
	mov bx, 0
	mov bl, [scancode]
	cmp bx, scancodes_end-scancodes
	ja .done

	mov dl, [scancodes+bx]
	mov dh, LGRAY_ON_BLACK
	call kprint_char
	jmp .done

.enter:
	mov bx, MSG_ENTER
	call kprint
	;mov byte [keybufferi], 0		; clear keybuffer
	jmp .done

.backspace
	mov bx, MSG_BACKSPACE
	call kprint
	;jmp .done

.done:
	pop dx
	pop bx
	pop ax
	ret

