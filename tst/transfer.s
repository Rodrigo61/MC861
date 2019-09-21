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
	ldx #254
	txa					; txa works
	tay					; tay works
	ldy #4
	tya					; tya works
	tax					; tax works
	ldx #25
	txs					; txs works
	ldx #14
	tsx					; tsx works

	ldx #0
	lda #14
	txa					; txa zero flag
	ldx #14
	tay					; tay zero flag
	lda #14
	tya					; tya zero flag
	ldx #14
	tax					; tax zero flag
	lda #14
	txs					; txs zero flag
	ldx #14
	tsx					; txs zero flag

	ldx #-3
	lda #14
	txa					; txa negative flag
	ldx #14
	tay					; tay negative flag
	lda #14
	tya					; tya negative flag
	ldx #14
	tax					; tax negative flag
	lda #14
	txs					; txs negative flag
	ldx #14
	tsx					; txs negative flag

	brk

;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw 0
	.dw reset
	.dw 0

	.dsb $2000
