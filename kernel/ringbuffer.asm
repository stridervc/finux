; handles ring buffer data structures

; a ring buffer should be structured as follow:
; .start  resw 1 ; current start index
; .end    resw 1 ; current end index
; .size   resw 1 ; size of the following buffer
; .buffer res? ? ; actual ring buffer of size .size

; .index  resw 1 ; current index, start at 0
; .full   resb 1 ; is full? start at 0
; .size   resw 1 ; size of the following buffer
; .buffer res? ? ; actual ring buffer of size .size

; offsets into a ring buffer 
START 	equ 0
END		equ 2
SIZE	equ 4
BUFFER	equ 6

dbgringbuffer	resb	5

; add a byte to a ring buffer
; bx = address of ring buffer
; dl = byte to store
rb_addbyte:
	push ax
	push bx
	push cx

	push bx				; preserve start of ring buffer

	mov ax, [bx+END]	; get current .end
	add bx, BUFFER		; point to buffer
	add bx, ax			; point to .end

	mov [bx], dl		; store byte
	inc ax				; inc .end

	pop bx				; restore start of ring buffer

	cmp ax, [bx+SIZE]	; see if .end is within bounds
	jb .checkstart		

	mov ax, 0			; wrap .end

.checkstart:
	mov [bx+END], ax	; store new .end

	mov cx, [bx+START]	
	cmp cx, ax			; see if we've caught up to .start
	jne .done

	inc cx				; advance .start
	cmp cx, [bx+SIZE]	; should .start wrap?
	jb .done

	mov cx, 0			; wrap .start

.done:
	mov [bx+START], cx	; store updated .start

	pop cx
	pop bx
	pop ax
	ret

; remove byte from end of ring buffer
; bx = address of ringbuffer
rb_rembyte:
	push edx
	
	mov dx, [bx+END]
	cmp [bx+START], dx	; see if there's anything in the buffer
	je	.done

	cmp dx, 0			; should .start wrap back?
	je .wrapback
	dec dx
	mov [bx+END], dx
	jmp .done

.wrapback:
	mov dx, [bx+SIZE]
	dec dx
	mov [bx+END], dx

.done:
	pop edx
	ret

; get content of ringbuffer as bytes
; ax = address of location to store result
; bx = address of ringbuffer
; cx = max number of bytes to return
; return :
; ax = number of bytes returned
rb_bytes:
	pusha
	
	cmp ax, 0
	je	.done	; sanity check

	; check which is smaller, the max requested #bytes or the 
	; current size of our ringbuffer
	mov dx, [bx+END]
	cmp dx, [bx+START]
	je .done		; ringbuffer is empty
	jb .full		; ringbuffer is full
	mov dx, [bx+END]
	sub dx, [bx+START]	; get actual size
	jmp .compare

.full:
	mov dx, [bx+SIZE]

.compare:
	cmp cx, dx
	jbe .continue
	mov cx, dx

.continue:
	mov si, bx
	add si, BUFFER		
	add si, [bx+START]	; point to buffer + start
	mov di, ax			; point to destination
	cld					; clear direction flag
	mov ax, [bx+START]	; keep track of our index

.loop:
	movsb
	inc word [numbytes]
	dec cx
	cmp cx, 0
	je .done

	; see if we should wrap our ring buffer
	inc ax				; keep track of our index in buffer
	cmp ax, [bx+SIZE]
	jb .loop
	mov ax, 0
	mov si, bx
	add si, BUFFER
	jmp .loop

.done:
	popa
	mov ax, [numbytes]
	ret
	numbytes dw 0	; count number of bytes we're returning

; Just print whole ring buffer to top of screen
; bx = address of ringbuffer
rb_dbg:
	pusha
	
	call get_cursor
	push ax		; preserve cursor offset
	mov ax, 0
	call set_cursor	; top left of screen
	mov dh, 0xf		; white

	mov cx, [bx+SIZE]
	add bx, BUFFER
	
.loop:
	mov dl, [bx]
	call kprint_char
	dec cx
	cmp cx, 0
	je .done
	inc bx
	jmp .loop

.done
	pop ax
	call set_cursor

	popa
	ret
	

;
; 1
; se
; 12
; s e
; 1234
; s   e
; 12345
; es     
