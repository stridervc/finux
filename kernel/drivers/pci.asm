; PCI driver
; https://wiki.osdev.org/PCI

CONFIG_ADDRESS	equ 0xCF8
CONFIG_DATA		equ 0xCFC

; AH bus number 		8 bits
; AL device number		5 bits
; BH function number	3 bits
; BL register number	6 bits
; return 32 bits read in eax
pci_read:
	pusha
	
	; bus number
	mov edx, 0
	mov dl, ah
	shl edx, 16

	; device number
	mov ecx, 0
	mov cl, al
	shl	ecx, 11
	or edx, ecx

	; function number
	mov eax, edx
	mov edx, 0
	mov dl, bh
	shl edx, 8
	or eax, edx

	; register number
	mov edx, 0
	mov dl, bl
	shl edx, 2
	or eax, edx
	
	; enable bit 31
	or eax, 0x80000000

	out CONFIG_ADDRESS, eax

	popa
	in eax, CONFIG_DATA

	ret

; Check pci vendor
; AH bus number
; AL device number
; return vendor number in eax (ax effectively, vendor is 16bit)
pci_check_vendor:
	push bx
	
	mov bx, 0
	call pci_read

	pop bx
	ret

