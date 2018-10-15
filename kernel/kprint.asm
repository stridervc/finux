; Print to screen using video address

VIDEO_ADDRESS 	equ 0xb8000
MAX_ROWS 		equ 25
MAX_COLS 		equ 80
WHITE_ON_BLACK	equ 0x0f
LGRAY_ON_BLACK	equ 0x07

; screen i/o ports
SCREEN_CTRL		equ 0x3d4
SCREEN_DATA		equ 0x3d5

; Get cursor offset, return in AX
get_cursor:
	push dx

	mov dx, SCREEN_CTRL
	mov al, 14			; request high byte
	out dx, al

	mov dx, SCREEN_DATA
	in al, dx			; read high byte
	shl ax, 8			; mov al to ah

	mov dx, SCREEN_CTRL
	mov al, 15			; request low byte
	out dx, al

	mov dx, SCREEN_DATA
	in al, dx			; read low byte

	; multiply by 2 for character + attribute pairs
	mov dx, 2
	mul dx					

	pop dx
	ret

; set cursor offset from ax
set_cursor:
	pusha

	; divide by 2 for char+attr pairs
	mov dx, 0
	mov cx, 2
	div cx

	push ax
	mov al, 15		; low byte
	mov dx, SCREEN_CTRL
	out dx, al

	pop ax
	mov dx, SCREEN_DATA
	out dx, al

	push ax
	mov al, 14		; high byte
	mov dx, SCREEN_CTRL
	out dx, al

	pop ax
	shr ax, 8
	mov dx, SCREEN_DATA
	out dx, al

	popa
	ret

; Kernel print, print null terminated string at [bx] to screen
; at current cursor position
kprint:
	pusha
	mov dh, LGRAY_ON_BLACK
	
kprint_loop:
	mov dl, [bx]			; Char to print
	cmp dl, 0
	je kprint_done
	
	call kprint_char
	inc bx					; next char in str
	jmp kprint_loop

kprint_done:
	popa
	ret

; Print char at current cursor pos, advance cursor
; DL = char
; DH = attr
kprint_char:
	pusha
	call get_cursor		; AX = cursor offset

	mov ebx, 0
	mov bx, ax
	mov [VIDEO_ADDRESS+ebx], dx

	; advance cursor
	add ax, 2
	call set_cursor

	popa
	ret

