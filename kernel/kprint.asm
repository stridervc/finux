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
	
.kprint_loop:
	mov dl, [ebx]			; Char to print
	cmp dl, 0
	je .kprint_done
	
	call kprint_char
	inc ebx					; next char in str
	jmp .kprint_loop

.kprint_done:
	popa
	ret

; convenience func to print a newline
kprint_nl:
	push ebx
	mov ebx, .msgnl
	call kprint

	pop ebx
	ret
	.msgnl	db 0x0d, 0x0a, 0

; Print char at current cursor pos, advance cursor
; DL = char
; DH = attr
kprint_char:
	pusha
	call get_cursor		; AX = cursor offset

	cmp dl, 0x0d		; \r
	je .cr

	cmp dl, 0x0a		; \n
	je .newline

	cmp dl, 0x0e		; backspace
	je .backspace

	mov ebx, 0
	mov bx, ax
	mov [VIDEO_ADDRESS+ebx], dx

	; advance cursor
	add ax, 2
	call set_cursor
	jmp .kprint_char_done

; carriage return
; move cursor to start of current line
.cr:
	; everything here is *2 because we're working
	; with char+attr pairs
	mov bl, MAX_COLS*2
	div bl
	mov ah, 0		; remainder was in ah
	mov bl, MAX_COLS*2
	mul bl
	call set_cursor
	jmp .kprint_char_done

; newline
; move cursor to same col in next line
.newline:
	; check if we should scroll
	cmp ax, MAX_COLS*(MAX_ROWS-1)*2
	jae .scroll

	add ax, MAX_COLS*2
	call set_cursor
	jmp .kprint_char_done

; backspace
; move cursor one back and print a space
.backspace:
	sub ax, 2		; move cursor back 1 space
	mov ebx, 0
	mov bx, ax
	mov dl, 0		; char = 0, dh should still be attr
	mov [VIDEO_ADDRESS+ebx], dx
	call set_cursor	; set cursor from ax
	jmp .kprint_char_done

.scroll:
	; we can leave the cursor where it is
	call scroll
	; jmp kprint_char_done

.kprint_char_done:
	popa
	ret

; Scroll screen up 1 line
scroll:
	pusha

	mov ebx, 0		; start at top left of screen

	; count number of movs we're going to do
	; r*2 for char+attr, / 4 because we'll move 4 bytes at a time
	mov ecx, (MAX_ROWS-1)*MAX_COLS*2/4	

.loop:
	mov eax, [VIDEO_ADDRESS+ebx+MAX_COLS*2]
	mov [VIDEO_ADDRESS+ebx], eax
	add ebx, 4
	dec ecx
	jnz .loop

; clear last row
	;mov ebx, MAX_COLS*(MAX_ROWS-1)*2
	mov ecx, MAX_COLS*2/4

.clear_loop:
	mov dword [VIDEO_ADDRESS+ebx], 0x07000700	; no char, gray on black colour
	add ebx, 4
	dec ecx
	jnz .clear_loop

	popa
	ret

; print hex representation of eax
kprint_hexd:
	push eax
	push ebx
	push edi

	mov edi, .hexstr+8
	call tohex
	shr eax, 8
	mov edi, .hexstr+6
	call tohex
	shr eax, 8
	mov edi, .hexstr+4
	call tohex
	shr eax, 8
	mov edi, .hexstr+2
	call tohex
	mov ebx, .hexstr
	call kprint

	pop edi
	pop ebx
	pop eax
	ret
	.hexstr db "0x00000000", 0

; print hex representation of ax
kprint_hexw:
	push eax
	push ebx
	push edi

	mov edi, .hexstr+4
	call tohex
	shr ax, 8
	mov edi, .hexstr+2
	call tohex
	mov ebx, .hexstr
	call kprint

	pop edi
	pop ebx
	pop eax
	ret
	.hexstr db "0x0000", 0

; print hex representation of al
kprint_hexb:
	push ebx
	push edi

	mov edi, .hexstr+2
	call tohex
	mov ebx, .hexstr
	call kprint

	pop edi
	pop ebx
	ret

	.hexstr db "0x00", 0

; convert al to hex representation
; call with edi = address of 2 chars to store result
tohex:
	push eax
	push edi

	push eax
	shr al, 4		; get most significant nibble
	add al, '0'
	cmp al, '9'
	jle .c1
	add al, 'A' - '0' - 10

.c1:
	mov [edi], al
	inc edi
	pop eax
	and al, 00001111b	; get least significant nibble
	add al, '0'
	cmp al, '9'
	jle .c2
	add al, 'A' - '0' - 10

.c2:
	mov [edi], al
	pop edi
	pop eax
	ret

; print eax as decimal value to screen
kprint_dec:
	pusha

	mov dword [.divisor], 1000000000	; divide by this
	mov edi, .msgdec					; where to store digit

	; handle zero as a special case
	cmp eax, 0
	jne .loop
	mov [edi], byte '0'
	inc edi
	mov [edi], byte 0
	jmp .continue

.loop:
	push eax
	mov edx, 0				; high part of dividend, also remainder after div
	div dword [.divisor]	; divide to get most significant digit
	mov edx, eax			; store most significant digit
	add al, '0'				; convert digit to ascii
	mov [edi], al			; store in string
	inc edi					; advance string pos

	; remove most significant digit from number
	mov eax, dword [.divisor]
	mul edx
	mov ebx, eax			; ebx = msd * divisor
	pop eax					; restore number
	sub eax, ebx			; remove msd

	; divide divisor by 10
	push eax
	mov eax, dword [.divisor]
	mov edx, 0				; high part of dividend
	mov ebx, 10
	div ebx
	mov [.divisor], eax
	pop eax

	; see if we're done
	cmp dword [.divisor], 0
	ja .loop

	; 'shift' the number left to remove leading '0's
	mov edi, .msgdec
	mov esi, edi
	inc esi
.loop2:
	cmp byte [edi], '0'
	jne .continue
	call strcpy
	jmp .loop2

.continue:
	; print the number
	mov ebx, .msgdec
	call kprint

.ret:
	popa
	ret
	.msgdec db "4294967296", 0
	.divisor dd 0
