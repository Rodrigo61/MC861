;################################################################
; Constants
;################################################################

PRG_COUNT = 1 ;1 = 16KB, 2 = 32KB
MIRRORING = %0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

;################################################################
; Variables
;################################################################

	.enum $0000
var1: .dsb 1
var2: .dsb 1
	.ende

	.enum $00ff
var3: .dsb 1
	.ende

;################################################################
; iNES header
;################################################################

	.db "NES", $1a		; Identification of the iNES header
	.db PRG_COUNT		; Number of 16KB PRG-ROM pages
	.db $01				; Number of 8KB CHR-ROM pages
	.db $00|MIRRORING	; Mapper 0 and mirroring
	.dsb 9, $00			; Clear the remaining bytes

;################################################################
; program bank(s)
;################################################################

	.base $10000-(PRG_COUNT*$4000)

;################################################################
; RESET
;################################################################
reset:
	ldx #$aa

	lda #$8
	sta $0ba1
	lda #$fa
	sta $0ba3
	lda #$80
	sta $0ba5
	lda #$7a
	sta $0ba7
	lda #$8
	sta $0ba9
	lda #$3
	sta $0bab
	lda #$1
	sta $0bad
	lda #$f0
	sta $0baf


	; rol
	lda $0ba1
	rol

	; rol carry flag
	lda $0ba3
	rol

	; rol zero flag
	lda $0ba5
	rol

	; rol negative_flag
	lda $0ba7
	rol

	; ror
	lda $0ba9
	ror

	; ror carry flag
	lda $0bab
	ror

	; ror zero flag
	lda $0bad
	ror

	; ror negative_flag
	lda $0baf
	ror

	brk

;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw 0
	.dw reset
	.dw 0

	.dsb $2000
