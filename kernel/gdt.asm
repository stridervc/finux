; Global Descriptor Table
; https://wiki.osdev.org/GDT

gdt_start:
	; GDT starts with 8 zeroes
	dd 0	; 4 bytes
	dd 0	; 4 bytes

; Code segment
; base = 0x0, length = 0xfffff (4G in 4k pages)
gdt_code:
	dw 0xffff		; length, bits 0-15
	dw 0x0			; base, bits 0-15
	db 0x0			; base, bits 16-23
	db 10011010b	; access byte
	db 11001111b	; flags, 4 bits + length, bits 16-19
	db 0x0			; base, bits 24-31

; Data segment
; Same as code segment for now, except for some flags
gdt_data:
	dw 0xffff
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0

gdt_end:

; GDT descriptor
gdt_descriptor:
	; size (16 bit), always 1 less than actual size
	dw gdt_end - gdt_start - 1	
	dd gdt_start	; address (32 bit)

; useful contants
CODE_SEG	equ gdt_code - gdt_start
DATA_SEG	equ gdt_data - gdt_start

