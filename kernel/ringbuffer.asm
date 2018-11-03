; handles ring buffer data structures

; a ring buffer should be structured as follow:
; .index  resw 1 ; current index, start at 0
; .full   resb 1 ; is full? start at 0
; .size   resw 1 ; size of the following buffer
; .buffer res? ? ; actual ring buffer of size .size

; offsets into a ring buffer 
INDEX 	equ 0
FULL	equ 2
SIZE	equ 3
BUFFER	equ 5

dbgringbuffer	resb	5

; add a byte to a ring buffer
; bx = address of ring buffer
; dl = byte to store
rb_addbyte:
	push ax
	push bx
	push cx

	push bx				; preserve start of ring buffer

	mov ax, [bx+INDEX]	; get current .index
	add bx, BUFFER		; point to buffer
	add bx, ax			; point to .end

	mov [bx], dl		; store byte
	inc ax				; inc .end

	pop bx				; restore start of ring buffer

	cmp ax, [bx+SIZE]	; see if .index is within bounds
	jb .done		

	mov ax, 0			; wrap .index
	mov byte [bx+FULL], 1	; set .full flag

.done:
	mov [bx+INDEX], ax	; store new .index

	pop cx
	pop bx
	pop ax
	ret

; remove byte from end of ring buffer
; bx = address of ringbuffer
rb_rembyte:
	push dx
	push bx
	
	mov dx, [bx+INDEX]
	cmp dx, 0			; we might be empty
	jne	.continue
	cmp byte [bx+FULL], 0
	je .done			; we're empty

.continue:
	cmp dx, 0			; should .index wrap back?
	je .wrapback
	dec dx
	mov [bx+INDEX], dx
	jmp .done

.wrapback:
	mov dx, [bx+SIZE]
	dec dx
	mov [bx+INDEX], dx
	mov byte [bx+FULL], 0

.done:
	pop bx
	pop dx
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

	mov word [numbytes], 0

	; check which is smaller, the max requested #bytes or the 
	; current size of our ringbuffer
	cmp byte [bx+FULL], 0
	jne .full

	mov dx, [bx+INDEX]
	cmp dx, 0
	je .done		; ringbuffer is empty
	jmp .compare

.full:
	mov dx, [bx+SIZE]

.compare:
	cmp cx, dx
	jbe .continue
	mov cx, dx

.continue:
	mov di, ax			; point to destination
	cld					; clear direction flag

	; two possible cases
	; ringbuffer is full, start at index+1
	; or, ringbuffer is not full, start at 0
	mov si, bx
	add si, BUFFER		

	mov ax, 0			; keep track of our index
	cmp byte [bx+FULL], 0
	je .loop

	add si, [bx+INDEX]	; point to buffer + index
	mov ax, [bx+INDEX]

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

