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
	sta $0ba1, X
	lda #$fa
	sta $0ba3, X
	lda #$80
	sta $0ba5, X
	lda #$7a
	sta $0ba7, X
	lda #$8
	sta $0ba9, X
	lda #$3
	sta $0bab, X
	lda #$1
	sta $0bad, X
	lda #$f0
	sta $0baf, X

	; asl
	asl $0ba1, X

	; asl carry flag
	asl $0ba3, X

	; asl zero flag
	asl $0ba5, X

	; asl negative_flag
	asl $0ba7, X

	; lsr
	lsr $0ba9, X

	; lsr carry flag
	lsr $0bab, X

	; lsr zero flag
	lsr $0bad, X

	; lsr negative_flag
	lsr $0baf, X

	brk

;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw 0
	.dw reset
	.dw 0

	.dsb $2000
