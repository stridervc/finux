; Use PIT to implement a timer
; http://www.osdever.net/bkerndev/Docs/pit.htm
; https://wiki.osdev.org/PIT
; http://www.jamesmolloy.co.uk/tutorial_html/5.-IRQs%20and%20the%20PIT.html

FREQ 	equ 50
DIVISOR equ 1193180 / FREQ

PIT_DATA0	equ 0x40
PIT_CMD		equ 0x43

; Initialise timer
init_timer:
	push ax

	mov al, 0x36		; set channel 0
	out PIT_CMD, al
	
	mov ax, DIVISOR
	out PIT_DATA0, al	; low byte of divisor
	shr ax, 8
	out PIT_DATA0, al	; high byte of divisor

	pop ax
	ret

; Called by kernel/interrupts.asm on IRQ0
timer_interrupt:
	push eax

	mov al, [TICKS]
	inc al
	cmp al, FREQ
	je .second
	mov [TICKS], al
	jmp .ret

; a second has passed
.second:
	mov [TICKS], byte 0
	inc dword [UPTIME]
	;jmp .ret

.ret:
	pop eax
	ret

; data
UPTIME	dd 0		; system uptime in seconds
TICKS	db 0		; tick counter
