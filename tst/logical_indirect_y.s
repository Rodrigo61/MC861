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
	; initial tests
	ldy #10

	ldx #0
	lda #2
	sta $41, Y
	lda #$41
	sta $fe
	lda #1
	sta $53, Y
	lda #$53
	sta $1b
	lda #16
	sta $65, Y
	lda #$65
	sta $cd

	; and flags
	lda #0
	sta $77, Y
	lda #$77
	sta $fb
	ldx #13
	lda #-2
	sta $89, Y
	lda #$89
	sta $1c

	; ora flags
	lda #0
	ldx #16
	sta $9b, Y
	lda #$9b
	sta $ce
	lda #2
	ldx #18
	sta $ad, Y
	lda #$ad
	sta $fc

	; eor flags
	lda #13
	sta $bf, Y
	lda #$bf
	sta $1d
	lda #2
	ldx #11
	sta $80, Y
	lda #$80
	sta $cf

	ldx #0
  lda #3
  and ($fe), Y  ; and #2
  ora ($1b), Y  ; or #1
  eor ($cd), Y  ; xor #16

  lda #3
  and ($fb), Y  ; and zero flag #0
  lda #-1
  ldx $13
  and ($1c), Y ; and negative flag #-2

  lda #0
  ldx #16
  ora ($ce), Y   ; or zero flag #0
  lda #-15
  ldx #18
  ora ($fc), Y   ; or negative flag #2

  lda #13
  eor ($1d), Y   ; eor zero flag #13
  lda #-1
  ldx #11
  eor ($cf), Y   ; eor negative flag #2

	brk

;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw 0
	.dw reset
	.dw 0

	.dsb $2000
