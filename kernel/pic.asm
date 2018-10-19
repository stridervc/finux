; Programmable interrupt controller

; PIC ports
PIC1C equ 0x20
PIC1D equ 0x21
PIC2C equ 0xa0
PIC2D equ 0xa1

; Initialise the PICs
; Remap their interrupts from 0x00 .. 0x0f to 0x20 .. 0x2f
; see https://wiki.osdev.org/PIC
init_pic:
	push ax

	mov al, 0x11		; initialisation
	out PIC1C, al		; init pic1
	out PIC2C, al		; init pic2

	mov al, 0x20		; new offset for pic1
	out PIC1D, al		
	mov al, 0x28		; new offset for pic2
	out PIC2D, al

	mov al, 0x04		; tell master that there is a slave
	out PIC1D, al		; at IRQ2 (mask 0000 0100b)

	mov al, 0x02		; tell slave pic it's cascade id
	out PIC2D, al		; (mask 0000 0010b)

	mov al, 0x01		; 8086/88 (MCS-80/85) mode ?
	out PIC1D, al
	out PIC2D, al

	mov al, 0			; set pic masks (allow all interrupts)
	out PIC1D, al
	out PIC2D, al

	pop ax
	ret

; acknowledge PIC
; call with AL = interrupt number
ack_pic:
	push ax

	cmp al, 0x20		; PIC1 start
	jb .ret

	cmp al, 0x2f		; PIC2 end
	ja .ret

	cmp al, 0x28		; PIC2 start
	jb	.ack_pic1

	; ack pic2
	mov al, 0x20
	out PIC2C, al
	;jmp .ret			; Also ack PIC1

.ack_pic1:
	mov al, 0x20
	out PIC1C, al

.ret:
	pop ax
	ret
