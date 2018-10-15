; Print to screen using video address

VIDEO_ADDRESS 	equ 0xb8000
MAX_ROWS 		equ 25
MAX_COLS 		equ 80
WHITE_ON_BLACK	equ 0x0f

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

; Kernel print, print null terminated string at [bx] to screen
; at current cursor position
kprint:
	pusha
	call get_cursor			; Offset in AX
	
kprint_loop:
	mov dl, [bx]			; Char to print
	cmp dl, 0
	je kprint_done
	
	inc bx					; next char in str
	push bx
	mov ebx, 0
	mov bx, ax				; screen offset into bx
	mov byte [VIDEO_ADDRESS+ebx], dl
	mov byte [VIDEO_ADDRESS+ebx+1], WHITE_ON_BLACK
	add ax, 2				; move offset to next char
	pop bx					; restore bx to index in string
	jmp kprint_loop

kprint_done:
	; update cursor position
	mov dx, 0
	mov bx, 2
	div bx					; divide ax by 2 for char+attr pair

	push ax
	mov dx, SCREEN_CTRL
	mov al, 15
	out dx, al				; low byte

	pop ax
	mov dx, SCREEN_DATA
	out dx, al

	push ax
	mov dx, SCREEN_CTRL
	mov al, 14
	out dx, al				; high byte

	pop ax
	shr ax, 8
	mov dx, SCREEN_DATA
	out dx, al

	popa
	ret

