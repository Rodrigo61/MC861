;################################################################
; Constants
;################################################################

PRG_COUNT = 1 ;1 = 16KB, 2 = 32KB
MIRRORING = %0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

;################################################################
; Variables
;################################################################

	.enum $0000

	.ende

	.enum $0100

var1: .dsb 1
var2: .dsb 1

	.ende

	.enum $0200

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
	lda #$f1
	ldx #0
	sta var1, X
	lda #$f2
	ldx #1
	sta var1, X
	lda #$f3
	ldx #255
	sta var2, X

	ldy var1
	ldy var2
	ldy var3


	lda #$d1
	ldy #0
	sta var1, Y
	lda #$d2
	ldy #1
	sta var1, Y
	lda #$d3
	ldy #255
	sta var2, Y

	ldx var1
	ldx var2
	ldx var3

	brk

;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw 0
	.dw reset
	.dw 0
