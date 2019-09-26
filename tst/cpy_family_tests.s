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

	.ende

	.enum $0100


	.ende

	.enum $07fe
var2: .dsb 1
	.ende

	.enum $fefe
debug: .dsb 1
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
    ; Setup the values to be tested for cpy
    lda #1 
    ldy #1
    sta var1
    sta var2

    ; Immediate CPY
    cpy #1
    cpy #0
    cpy #2

    ; Absolute Zeropage CPY
    ldy #1
    cpy var1
    ldy #0
    cpy var1
    ldy #2
    cpy var1

    ; Absolute CPY
    ldy #1
    cpy var2
    ldy #0
    cpy var2
    ldy #2
    cpy var2
;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw 0
	.dw reset
	.dw 0

	.dsb $2000

    