; Handle keyboard interrupt

KEYB_C	equ 0x64	; Keyboard command port
KEYB_D	equ 0x60	; Keyboard data port

; key buffer
BUFFERSIZE 	equ 10				; Max size of keybuffer

; keybuffer, see ringbuffer.asm
keybuffer:
	dw 0			; .index
	db 0			; .full
	dw BUFFERSIZE	; .size
	resb BUFFERSIZE	; .buffer

scancode	db 0				; Store current scancode

; debug current keybuffer as null terminated string
dbgkeybuffer	resb BUFFERSIZE+1	; +1 for null terminated
clear TIMES BUFFERSIZE db 'x'
db 0

MSG_ENTER db 0x0d, 0x0a, "> ", 0
MSG_BACKSPACE db 0x0e, 0

%include "drivers/scancodes.asm"
%include "ringbuffer.asm"

; called when a keyboard interrupt happens
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

	; get key pressed
	mov bx, 0
	mov bl, [scancode]
	cmp bx, scancodes_end-scancodes
	ja .done					; unsupported scancode

	mov dl, [scancodes+bx]		; get human key
	mov bx, keybuffer
	call rb_addbyte				; add to keybuffer

	mov dh, LGRAY_ON_BLACK
	call kprint_char			; print it to screen
	jmp .done

.enter:
	mov bx, MSG_ENTER
	call kprint
	jmp .done

.backspace:
	mov bx, MSG_BACKSPACE
	call kprint					; remove from screen

	mov bx, keybuffer
	call rb_rembyte				; remove from keybuffer

.done:
	; DBG: show keybuffer on screen
	call get_cursor
	push ax		; save cursor offset
	mov ax, 0	; top left
	call set_cursor

	; clear dbgkeybuffer
	mov si, clear
	mov di, dbgkeybuffer
	mov cx, BUFFERSIZE
	cld
.loop
	movsb
	dec cx
	cmp cx, 0
	jne .loop

	mov bx, dbgkeybuffer
	mov cx, BUFFERSIZE
	call gets
	call kprint

	pop ax
	call set_cursor	; restore cursor

	pop dx
	pop bx
	pop ax
	ret

; get current string from keybuffer as null terminated string
; bx = address of area to return string
; cx = size of the user provided string space
gets:
	push ax
	push bx
	push cx

	mov ax, bx	; destination
	mov bx, keybuffer
	; cx set by caller
	call rb_bytes
	
	pop cx
	pop bx
	pop ax
	ret

