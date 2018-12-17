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

	mov dx, CONFIG_ADDRESS
	out dx, eax

	popa
	push edx
	mov dx, CONFIG_DATA
	in eax, dx
	pop edx

	ret

; Scan all devices on bus and check for valid ones
; Probe devices found
; AH bus number to scan
pci_scan_bus:
	pusha
	
	mov al, 0	; device number
	mov bx, 0	; function and register numbers

.loop:
	call pci_probe_device

	inc al
	cmp al, 32
	jne .loop

.done:
	popa
	ret

; Scan a PCI multifunction device (functions 0-7)
; AH = bus number
; AL = device number
; BH = start function
pci_scan_mf:
	pusha

.loop:
	cmp bh, 7
	ja .done

	call pci_probe_device

	inc bh
	jmp .loop

.done:
	popa
	ret

; Print "PCI 0:1:2 " (bus:device:function)
; AH = bus number
; AL = device number
; BH = function number
pci_print_id:
	push eax
	push ebx
	push edx

	mov edx, ebx		; store function number (BH)
	mov ebx, msgpci
	call kprint

	push eax
	shr ax, 8			; bus number in al
	and eax, 0x000000ff	; throw away everything else
	call kprint_dec		; print bus number
	pop eax

	mov ebx, msgcolon
	call kprint			; print colon

	push eax
	and eax, 0x000000ff	; throw away everything except device number
	call kprint_dec		; print device number
	call kprint			; print colon
	mov eax, 0
	mov al, dh			; function number
	call kprint_dec
	pop eax

	mov ebx, msgspace
	call kprint

	pop edx
	pop ebx
	pop eax
	ret

; Probe a PCI device in detail
; AH = bus number
; AL = device number
; BH = function number
pci_probe_device:
	pusha

	; first, check if this is an actual device
	push eax

	mov bl, 0			; register 0
	call pci_read
	cmp ax, 0xffff		; check vendor id
	jne .continue
	pop eax
	jmp .done			; not a device

.continue:
	pop eax

	call pci_print_id

	; get device class
	push eax
	mov bl, 2			; register 2
	call pci_read
	shr eax, 24			; class code in AL
	push ebx
	mov ebx, msgclass
	call kprint
	call kprint_hexb
	pop ebx
	mov edx, eax		; class code in DL
	pop eax
	call kprint_nl

	cmp dl, 0xff		; skip if it's not an actual device
	je .done

	; pass to handler for this device class
	cmp dl, 6
	jne .next1
	call pci_init_bridge_device
	jmp .done

	; TODO handle class 1, mass storage device

.next1:
	mov ebx, msgunsupported
	call kprint
	call kprint_nl

.done:
	popa
	ret

; Initialise bridge device
; AH = bus number
; AL = device number
; BH = function number
pci_init_bridge_device:
	pusha

	push ebx
	mov ebx, msgbridge
	call kprint
	call kprint_nl
	pop ebx

	; get subclass
	push eax
	mov bl, 2			; register 2
	call pci_read
	shr eax, 16			; subclass in AL
	mov edx, eax		; subclass in DL
	pop eax

	cmp dl, 0
	jne .next1
	call pci_init_bridge_00
	jmp .done

.next1:
	cmp dl, 1
	jne .next2
	call pci_init_bridge_01
	jmp .done

.next2:

.done:
	popa
	ret

; Initialise host bridge
; AH = bus number
; AL = device number
; BH = function number
pci_init_bridge_00:
	pusha

	mov ebx, msghostbridge
	call kprint
	call kprint_nl

	; check if it's multifunction
	push eax
	call pci_is_mf
	cmp al, 1
	jne .notmf
	
	; TODO scan multifunction device

.notmf:
	pop eax

	popa
	ret

; Initialise ISA bridge
; AH = bus number
; AL = device number
; BH = function number
pci_init_bridge_01:
	pusha

	push ebx
	mov ebx, msgisabridge
	call kprint
	call kprint_nl
	pop ebx

	; if this is not function 0, skip multifunction check
	cmp bh, 0
	jne .done

	; check if it's multifunction
	push eax
	call pci_is_mf
	cmp al, 1
	jne .notmf
	
	; check other functions on this multifunction device
	pop eax
	push ebx
	mov bh, 1			; start at function 1
	call pci_scan_mf
	pop ebx
	jmp .done

.notmf:
	pop eax

.done:
	popa
	ret

; Check if a device is multifunction
; AH = bus number
; AL = device number
; return EAX = 1 if MF, 0 otherwise
pci_is_mf:
	push ebx

	mov bx, 0x0003		; function 0, register 3
	call pci_read
	shr eax, 16			; header type in AL
	and al, 10000000b	; keep only MF bit
	cmp al, 10000000b
	je .mf
	mov eax, 0
	jmp .done

.mf:
	mov eax, 1

.done:
	pop ebx
	ret

; scan all pci busses and devices
pci_scan_all:
	pusha

	mov ebx, msgscanning
	call kprint
	call kprint_nl

	mov ah, 0	; bus number

.loop:
	call pci_scan_bus
	inc ah
	cmp ah, 0
	jne .loop

	popa
	ret

msgscanning		db "Scanning for PCI devices...", 0
msgpci			db "PCI ", 0
msgcolon		db ":", 0
msgspace		db " ", 0
msgclass		db "Class: ", 0
msgunsupported	db "  * Unsupported at this time", 0
msgbridge		db "  * Bridge device", 0
msghostbridge	db "  * Host bridge", 0
msgisabridge	db "  * ISA bridge", 0
