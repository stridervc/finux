; Initialise IDE device
; AH = bus number
; AL = device number
; BH = function number
pci_init_ide:
	pusha

	push ebx
	mov ebx, msgide
	call kprint
	call kprint_nl
	pop ebx

	popa
	ret

msgide			db "  * IDE Controller", 0

