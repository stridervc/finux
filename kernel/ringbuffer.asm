; handles ring buffer data structures

; a ring buffer should be structured as follow:
; .windex resw 1 ; current write index, start at 0
; .rindex resw 1 ; current read index, start at 0
; .full   resb 1 ; is full? start at 0
; .size   resw 1 ; size of the following buffer
; .buffer res? ? ; actual ring buffer of size .size

; offsets into a ring buffer 
WINDEX 	equ 0
RINDEX 	equ 2
FULL	equ 4
SIZE	equ 5
BUFFER	equ 7

; data
numbytes dw 0	; count number of bytes we're returning in rb_bytes

; add a byte to a ring buffer
; if not full, write at current w index, then increment 2
; if w == size after incr, set it to 0
; after every w increment, check if w == r, if so, set full = 1
; ebx = address of ring buffer
; dl = byte to store
; return ax = 0 success
;           = -1 buffer full
rb_addbyte:
	; check if ringbuffer is full
	mov al, [ebx+FULL]
	cmp al, 1
	jne .continue
	
	mov ax, -1
	ret

.continue:
	push ebx
	push ecx

	push ebx				; preserve start of ring buffer

	mov eax, 0
	mov ax, [ebx+WINDEX]	; get current .windex
	add ebx, BUFFER			; point to buffer
	add ebx, eax			; point to .windex

	mov [ebx], dl			; store byte
	inc ax					; inc .windex

	pop ebx					; restore start of ring buffer

	cmp ax, [ebx+SIZE]		; see if .index is within bounds
	jb .checkcatchup

	mov ax, 0				; wrap .windex

.checkcatchup:
	; check if .windex has caught up to .rindex
	mov cx, [ebx+RINDEX]
	cmp ax, cx
	jne .done
	mov byte [ebx+FULL], 1	; set .full flag

.done:
	mov [ebx+WINDEX], ax	; store new .windex
	mov ax, 0				; success

	pop ecx
	pop ebx
	ret

; remove byte from end of ring buffer
; ebx = address of ringbuffer
rb_rembyte:
	push eax
	push ebx
	push ecx
	
	; if we're full, we can definitely remove a byte
	mov al, [ebx+FULL]
	cmp al, 1
	je .continue

	; we're not full, we might be empty
	mov ax, [ebx+WINDEX]
	mov cx, [ebx+RINDEX]
	cmp ax, cx
	je .ret		; we're empty, nothing to be done

.continue:
	mov ax, [ebx+WINDEX]
	cmp ax, 0
	jne .done

	; wrapback .windex
	mov ax, [ebx+SIZE]

.done:
	dec ax
	mov [ebx+WINDEX], ax
	mov byte [ebx+FULL], 0

.ret:
	pop ecx
	pop ebx
	pop eax
	ret

; get length of ringbuffer
; ebx = address of ringbuffer
; return eax = length of ringbuffer
rb_len:
	push ecx

	mov eax, 0
	mov ecx, 0

	; if we're full, just return size
	mov al, [ebx+FULL]
	cmp al, 1
	jne .continue
	; we're full
	mov ax, [ebx+SIZE]
	jmp .ret

.continue:
	mov ax, [ebx+WINDEX]
	mov cx, [ebx+RINDEX]
	cmp ax, cx
	je .empty
	jb .wrapped
	; windex greater than rindex
	sub ax, cx
	jmp .ret

.wrapped:
	; windex less than rindex
	add ax, [ebx+SIZE]
	sub ax, cx
	jmp .ret

.empty:
	mov eax, 0
	jmp .ret

.ret:
	pop ecx
	ret

; get content of ringbuffer as bytes
; eax = address of location to store result
; ebx = address of ringbuffer
; ecx = max number of bytes to return
; return :
; eax = number of bytes returned
rb_bytes:
	pusha

	mov edi, eax	; destination

	mov word [numbytes], 0	; in case we return nothing
	; get length of ringbuffer
	call rb_len
	cmp eax, 0
	je .ret			; nothing to return if it's empty

	; check which is less, requested bytes or available bytes
	cmp eax, ecx
	jae .continue
	mov ecx, eax

.continue:
	; store number of bytes to return
	mov [numbytes], cx

	mov ax, [ebx+RINDEX]	; keep track of our rindex
	mov esi, ebx			; source
	add esi, BUFFER
	add esi, eax			; set read index
	cld						; clear direction flag

.loop:
	movsb
	dec ecx
	inc ax					; increment rindex
	cmp ax, [ebx+SIZE]
	jne .c2
	mov ax, 0				; wrap rindex
	mov esi, ebx
	add esi, BUFFER			; also wrap the actual ringbuffer
.c2:
	cmp ecx, 0
	jne .loop

	mov [ebx+RINDEX], ax	; update rindex
	mov byte [edi], 0		; null terminate

.ret:
	popa
	mov eax, 0
	mov ax, [numbytes]
	ret

; empties and resets a ringbuffer
; call with ebx = address of ringbuffer
rb_clear:
	mov word [ebx+RINDEX], 0
	mov word [ebx+WINDEX], 0
	mov byte [ebx+FULL], 0
	ret

