; Interrupt descriptor table

; CODE_SEG is defined in gdt.asm
;CODE_SEG equ 0x08	; the code segment as set in our GDT

%define low_16(handler) (handler-$$+0x1000) & 0xffff 
%define high_16(handler) (handler-$$+0x1000) >> 16

; see https://wiki.osdev.org/Interrupt_Descriptor_Table
; a single IDT entry for a handler with no error code
%macro idt_entry 1
	; low 16 bits of handler address
	dw low_16(interrupt_handler_%1)
	dw CODE_SEG 	; 16 bits segment selector
	db 0			; 5 bits reserved and 3 bits 0s
	db 10001110b	; flags 
	; high 16 bits of handler address
	dw high_16(interrupt_handler_%1)
%endmacro

; a single IDT entry for a handler with an error code
%macro idt_entry_ec 1
	; low 16 bits of handler address
	dw low_16(error_code_interrupt_handler_%1)
	dw CODE_SEG 	; 16 bits segment selector
	db 0			; 5 bits reserved and 3 bits 0s
	db 1001110b		; flags 
	; high 16 bits of handler address
	dw high_16(error_code_interrupt_handler_%1)
%endmacro

; this is passed to the lidt intruction
; to load the idt
idt_reg:
	dw idt_end-idt_start-1		; size of idt - 1
	dd idt_start-$$+0x1000		; address of idt

idt_start:
	idt_entry 0
	idt_entry 1
	idt_entry 2
	idt_entry 3
	idt_entry 4
	idt_entry 5
	idt_entry 6
	idt_entry 7
	idt_entry_ec 8
	idt_entry 9
	idt_entry_ec 10
	idt_entry_ec 11
	idt_entry_ec 12
	idt_entry_ec 13
	idt_entry_ec 14
	idt_entry 15
	idt_entry 16
	idt_entry 17
	idt_entry 18
	idt_entry 19
	idt_entry 20
	idt_entry 21
	idt_entry 22
	idt_entry 23
	idt_entry 24
	idt_entry 25
	idt_entry 26
	idt_entry 27
	idt_entry 28
	idt_entry 29
	idt_entry 30
	idt_entry 31
	idt_entry 32
	idt_entry 33
	idt_entry 34
	idt_entry 35
	idt_entry 36
	idt_entry 37
	idt_entry 38
	idt_entry 39
	idt_entry 40
	idt_entry 41
	idt_entry 42
	idt_entry 43
	idt_entry 44
	idt_entry 45
	idt_entry 46
	idt_entry 47
	idt_entry 48
	idt_entry 49
	idt_entry 50
	idt_entry 51
	idt_entry 52
	idt_entry 53
	idt_entry 54
	idt_entry 55
	idt_entry 56
	idt_entry 57
	idt_entry 58
	idt_entry 59
	idt_entry 60
	idt_entry 61
	idt_entry 62
	idt_entry 63
	idt_entry 64
	idt_entry 65
	idt_entry 66
	idt_entry 67
	idt_entry 68
	idt_entry 69
	idt_entry 70
	idt_entry 71
	idt_entry 72
	idt_entry 73
	idt_entry 74
	idt_entry 75
	idt_entry 76
	idt_entry 77
	idt_entry 78
	idt_entry 79
	idt_entry 80
	idt_entry 81
	idt_entry 82
	idt_entry 83
	idt_entry 84
	idt_entry 85
	idt_entry 86
	idt_entry 87
	idt_entry 88
	idt_entry 89
	idt_entry 90
	idt_entry 91
	idt_entry 92
	idt_entry 93
	idt_entry 94
	idt_entry 95
	idt_entry 96
	idt_entry 97
	idt_entry 98
	idt_entry 99
	idt_entry 100
	idt_entry 101
	idt_entry 102
	idt_entry 103
	idt_entry 104
	idt_entry 105
	idt_entry 106
	idt_entry 107
	idt_entry 108
	idt_entry 109
	idt_entry 110
	idt_entry 111
	idt_entry 112
	idt_entry 113
	idt_entry 114
	idt_entry 115
	idt_entry 116
	idt_entry 117
	idt_entry 118
	idt_entry 119
	idt_entry 120
	idt_entry 121
	idt_entry 122
	idt_entry 123
	idt_entry 124
	idt_entry 125
	idt_entry 126
	idt_entry 127
	idt_entry 128
	idt_entry 129
	idt_entry 130
	idt_entry 131
	idt_entry 132
	idt_entry 133
	idt_entry 134
	idt_entry 135
	idt_entry 136
	idt_entry 137
	idt_entry 138
	idt_entry 139
	idt_entry 140
	idt_entry 141
	idt_entry 142
	idt_entry 143
	idt_entry 144
	idt_entry 145
	idt_entry 146
	idt_entry 147
	idt_entry 148
	idt_entry 149
	idt_entry 150
	idt_entry 151
	idt_entry 152
	idt_entry 153
	idt_entry 154
	idt_entry 155
	idt_entry 156
	idt_entry 157
	idt_entry 158
	idt_entry 159
	idt_entry 160
	idt_entry 161
	idt_entry 162
	idt_entry 163
	idt_entry 164
	idt_entry 165
	idt_entry 166
	idt_entry 167
	idt_entry 168
	idt_entry 169
	idt_entry 170
	idt_entry 171
	idt_entry 172
	idt_entry 173
	idt_entry 174
	idt_entry 175
	idt_entry 176
	idt_entry 177
	idt_entry 178
	idt_entry 179
	idt_entry 180
	idt_entry 181
	idt_entry 182
	idt_entry 183
	idt_entry 184
	idt_entry 185
	idt_entry 186
	idt_entry 187
	idt_entry 188
	idt_entry 189
	idt_entry 190
	idt_entry 191
	idt_entry 192
	idt_entry 193
	idt_entry 194
	idt_entry 195
	idt_entry 196
	idt_entry 197
	idt_entry 198
	idt_entry 199
	idt_entry 200
	idt_entry 201
	idt_entry 202
	idt_entry 203
	idt_entry 204
	idt_entry 205
	idt_entry 206
	idt_entry 207
	idt_entry 208
	idt_entry 209
	idt_entry 210
	idt_entry 211
	idt_entry 212
	idt_entry 213
	idt_entry 214
	idt_entry 215
	idt_entry 216
	idt_entry 217
	idt_entry 218
	idt_entry 219
	idt_entry 220
	idt_entry 221
	idt_entry 222
	idt_entry 223
	idt_entry 224
	idt_entry 225
	idt_entry 226
	idt_entry 227
	idt_entry 228
	idt_entry 229
	idt_entry 230
	idt_entry 231
	idt_entry 232
	idt_entry 233
	idt_entry 234
	idt_entry 235
	idt_entry 236
	idt_entry 237
	idt_entry 238
	idt_entry 239
	idt_entry 240
	idt_entry 241
	idt_entry 242
	idt_entry 243
	idt_entry 244
	idt_entry 245
	idt_entry 246
	idt_entry 247
	idt_entry 248
	idt_entry 249
	idt_entry 250
	idt_entry 251
	idt_entry 252
	idt_entry 253
	idt_entry 254
	idt_entry 255
idt_end:

