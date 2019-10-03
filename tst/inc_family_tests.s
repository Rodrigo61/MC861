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
    ; Setup the values to be tested
    lda #-2 
    ldx #1
    sta var1
    sta var2
    sta var1, x
    sta var2, x  
    ldx #-2
    ldy #-2  

    ; Decrement once, check for negative flag
    inx
    iny
    ; Decrement again, check for 0
    inx
    iny

    ; Decrement once, check for negative flag
    inc var1
    inc var2
    ; Decrement again, check for 0 flag
    inc var1
    inc var2

    ldx #1
    ; Decrement once, check for negative flag
    inc var1, x
    inc var2, x
    ; Decrement again, check for 0
    inc var1, x
    inc var2, x

    brk

;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw 0
	.dw reset
	.dw 0

	.dsb $2000

    