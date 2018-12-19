; Handle ATA PIO (ide drives)
; https://wiki.osdev.org/ATA_PIO_Mode

PRIMARY_ATA_START	equ 0x1F0 ; to 0x1F7
SECONDARY_ATA_START	equ 0x170 ; to 0x177

; Device control registers
PRIMARY_ATA_DCR		equ 0x3F6
SECONDARY_ATA_DCR	equ 0x376

; Identify disk
; Input
;  DX = base port (eg, PRIMARY_ATA_START)
;  AL = drive select (0xA0 = master, 0xB0 = slave)
; Return

ata_identify:
	pusha

	popa
	ret
