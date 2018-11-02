; Handle keyboard interrupt

KEYB_C	equ 0x64	; Keyboard command port
KEYB_D	equ 0x60	; Keyboard data port

; key buffer
BUFFERSIZE 	equ 5				; Max size of keybuffer
keybuffer 	resb BUFFERSIZE		; Key buffer
.start	 	db 0				; Current key buffer start index
.end		db 0				; Current key buffer end index
scancode	db 0				; Store current scancode

; debug current keybuffer as null terminated string
dbgkeybuffer	resb BUFFERSIZE+1	; +1 for null terminated

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
	mov bx, [keybuffer.end]
	mov ax, [scancode]
	mov [keybuffer+bx], al
	inc bx						
	cmp bx, BUFFERSIZE-1	; check against BUFFERSIZE
	jbe .continue

	; key buffer should wrap round
	; ring buffer
	mov bl, 0				; end to 0
	mov byte [keybuffer.start], 1

.continue:
	mov [keybuffer.end], bl

	; if end has wrapped round to start, inc start
	cmp [keybuffer.start], bl
	jne .print

	mov bx, [keybuffer.start]
	inc bx

	cmp bx, BUFFERSIZE-1	; check it against BUFFERSIZE
	jbe .continue2

	mov byte [keybuffer.start], 0

.continue2:
	mov [keybuffer.start], bl

.print:
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

.backspace:
	mov bx, MSG_BACKSPACE
	call kprint

	; decrement end, unless it's already at start
	mov al, [keybuffer.end]
	cmp [keybuffer.start], al
	jne .done

	cmp al, 0
	je .endatend

	dec ax
	mov [keybuffer.end], al
	jmp .done

.endatend:
	mov byte [keybuffer.end], BUFFERSIZE-1
	;jmp .done

.done:
	pop dx
	pop bx
	pop ax
	ret

; get current string from keybuffer as null terminated string
; ax = size of the user provided string space
; bx = address of area to return string
gets:
	push ax
	push bx
	push cx

	; see which is less, the size of our data or the size
	; requested, use the smallest one
	
	ret
	pop cx
	pop bx
	pop ax

