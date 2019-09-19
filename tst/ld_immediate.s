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
	lda #$fa
	lda #$2b
	lda	#$00

	ldx #$fa
	ldx #$2b
	ldx	#$00

	ldy #$fa
	ldy #$2b
	ldy	#$00

	brk

;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw 0
	.dw reset
	.dw 0
