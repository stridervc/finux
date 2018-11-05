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

; add a byte to a ring buffer
; bx = address of ring buffer
; dl = byte to store
rb_addbyte:
	push eax
	push ebx
	push ecx

	push ebx				; preserve start of ring buffer

	mov eax, [ebx+INDEX]	; get current .index
	add ebx, BUFFER		; point to buffer
	add ebx, eax			; point to .end

	mov [ebx], dl		; store byte
	inc eax				; inc .end

	pop ebx				; restore start of ring buffer

	cmp eax, [ebx+SIZE]	; see if .index is within bounds
	jb .done		

	mov eax, 0			; wrap .index
	mov byte [ebx+FULL], 1	; set .full flag

.done:
	mov [ebx+INDEX], ax	; store new .index

	pop ecx
	pop ebx
	pop eax
	ret

; remove byte from end of ring buffer
; bx = address of ringbuffer
rb_rembyte:
	push edx
	push ebx
	
	mov edx, [ebx+INDEX]
	cmp edx, 0			; we might be empty
	jne	.continue
	cmp byte [ebx+FULL], 0
	je .done			; we're empty

.continue:
	cmp edx, 0			; should .index wrap back?
	je .wrapback
	dec edx
	mov [ebx+INDEX], edx
	jmp .done

.wrapback:
	mov edx, [bx+SIZE]
	dec edx
	mov [ebx+INDEX], edx
	mov byte [ebx+FULL], 0

.done:
	pop ebx
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
	
	cmp eax, 0
	je	.done	; sanity check

	mov word [numbytes], 0

	; check which is smaller, the max requested #bytes or the 
	; current size of our ringbuffer
	cmp byte [ebx+FULL], 0
	jne .full

	mov edx, [ebx+INDEX]
	cmp edx, 0
	je .done		; ringbuffer is empty
	jmp .compare

.full:
	mov edx, [ebx+SIZE]

.compare:
	cmp ecx, edx
	jbe .continue
	mov ecx, edx

.continue:
	mov edi, eax			; point to destination
	cld					; clear direction flag

	; two possible cases
	; ringbuffer is full, start at index+1
	; or, ringbuffer is not full, start at 0
	mov esi, ebx
	add esi, BUFFER		

	mov eax, 0			; keep track of our index
	cmp byte [ebx+FULL], 0
	je .loop

	add esi, [ebx+INDEX]	; point to buffer + index
	mov eax, [ebx+INDEX]

.loop:
	movsb
	inc word [numbytes]
	dec ecx
	cmp ecx, 0
	je .done

	; see if we should wrap our ring buffer
	inc eax				; keep track of our index in buffer
	cmp eax, [ebx+SIZE]
	jb .loop
	mov eax, 0
	mov esi, ebx
	add esi, BUFFER
	jmp .loop

.done:
	popa
	mov eax, [numbytes]
	ret
	numbytes dw 0	; count number of bytes we're returning

; empties and resets a ringbuffer
; call with bx = address of ringbuffer
rb_clear:
	mov word [ebx+INDEX], 0
	mov byte [ebx+FULL], 0
	ret

