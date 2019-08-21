;----------------------------------------------------------------
; constants
;----------------------------------------------------------------

PRG_COUNT		= 1		; 1 = 16KB, 2 = 32KB
MIRRORING		= %0001 ; %0000 = horizontal, %0001 = vertical, %1000 = four-screen

RIGHT_WALL      = $F0	; When a bullet reaches one of these, handle colision.
TOP_WALL        = $20
BOTTOM_WALL     = $E0
LEFT_WALL       = $10

CENTER_SCREEN	= $80

OFFSCREEN		= $FE	; Sprites offscreen will be placed in position (OFFSCREEN, OFFSCREEN)

;----------------------------------------------------------------
; variables
;----------------------------------------------------------------

	.enum $0000

	frame_counter: 		.dsb 1	; Counter the increments each frame (obviously overflows).
	buttons1:			.dsb 1	; Player 1 gamepad buttons, one bit per button.
	buttons2:			.dsb 1  ; Player 2 gamepad buttons, one bit per button.

bullets:
bullet1:						; If the bullet is not currently on screen, x and y will be equal to OFFSCREEN.
	bullet1_x:			.dsb 1	; Horizontal position of bullet.
	bullet1_y:			.dsb 1	; Vertical position of bullet.
	bullet1_direction:	.dsb 1	; Bullet direction from 0 to 31.
	bullet1_slowed:		.dsb 1	; 1 if bullet is currently slowed and 0 otherwise.

bullet2:
	bullet2_x: 			.dsb 1
	bullet2_y:			.dsb 1
	bullet2_direction:	.dsb 1
	bullet2_slowed:		.dsb 1

	.ende

;----------------------------------------------------------------
; sprites
;----------------------------------------------------------------

	.enum $0200

sprite_bullet1: .dsb 4

sprite_bullet2: .dsb 4

	.ende

;----------------------------------------------------------------
; iNES header
;----------------------------------------------------------------

	.db "NES", $1a ;identification of the iNES header
	.db PRG_COUNT ;number of 16KB PRG-ROM pages
	.db $01 ;number of 8KB CHR-ROM pages
	.db $00|MIRRORING ;mapper 0 and mirroring
	.dsb 9, $00 ;clear the remaining bytes

;----------------------------------------------------------------
; program bank(s)
;----------------------------------------------------------------

	.base $10000-(PRG_COUNT*$4000)
reset:
	sei          ; disable IRQs
	cld          ; disable decimal mode
	ldx #$40
	stx $4017    ; disable APU frame IRQ
	ldx #$FF
	txs          ; Set up stack
	inx          ; now X = 0
	stx $2000    ; disable NMI
	stx $2001    ; disable rendering
	stx $4010    ; disable DMC IRQs

vblank_wait1:       ; First wait for vblank to make sure PPU is ready
	bit $2002
	bpl vblank_wait1

clear_memory:
	lda #$00
	sta $0000, x
	sta $0100, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	lda #OFFSCREEN
	sta $0200, x	; Move all sprites off screen.
	inx
	bne clear_memory
	 
vblank_wait2:		; Second wait for vblank, PPU is ready after this
	bit $2002
	bpl vblank_wait2

load_palettes:
	lda $2002    ; read PPU status to reset the high/low latch
	lda #$3F
	sta $2006    ; write the high byte of $3F00 address
	lda #$00
	sta $2006    ; write the low byte of $3F00 address
	ldx #$00
load_palettes_loop:
	lda palette, x        ; load palette byte
	sta $2007             ; write to PPU
	inx                   ; set index to next byte
	cpx #$20            
	bne load_palettes_loop  ;if x = $20, 32 bytes copied, all done

;;; Set starting game state

	lda #CENTER_SCREEN
	sta bullet1_x
	lda #CENTER_SCREEN
	sta bullet1_y

	lda #1
	sta bullet1_slowed

	lda #CENTER_SCREEN
	sta bullet2_x
	lda #CENTER_SCREEN
	sta bullet2_y

	jsr update_sprites

	lda #%10000000   ; enable NMI, sprites from Pattern Table 0
	sta $2000

	lda #%00010000   ; enable sprites
	sta $2001


forever:
	jmp forever			; jump back to forever, infinite loop, waiting for NMI


NMI:
	lda #$00
	sta $2003       ; set the low byte (00) of the RAM address
	lda #$02
	sta $4014       ; set the high byte (02) of the RAM address, start the transfer
		
	; All graphics updates done by here, run game engine next.

	jsr read_controller1
	jsr read_controller2

game_engine:

	jsr update_frame_counter

	lda frame_counter
	and #%00011111
	cmp #$0
	bne after_change_direction

	lda bullet1_direction
	clc
	adc #1
	and #%00011111
	sta bullet1_direction
	lda #CENTER_SCREEN
	sta bullet1_x        ; put sprite 0 in center ($80) of screen vert
	lda #CENTER_SCREEN
	sta bullet1_y        ; put sprite 0 in center ($80) of screen horiz

after_change_direction:

	ldx #$0
	jsr move_bullet

	ldx #$1
	jsr move_bullet

game_engine_done:

	jsr update_sprites	; Set bullet positions from memory.
	rti					; return from interrupt

;----------------------------------------------------------------
; functions
;----------------------------------------------------------------

; Function update_frame_counter.
; Increments the frame counter by one.
update_frame_counter:
	lda frame_counter
	clc
	adc #1
	sta frame_counter

	rts

; Function move_bullet.
; Register X must contain the bullet index (0 or 1).
; This method moves the bullet (if currently on-screen) according to its direction and slowed fields.
; This only updates the bullet variables (not the sprite data).
move_bullet:
	txa					; X = 4*X to get correct pointer increment.
	asl A
	asl A
	tax

	lda bullets + 0, X	; Bullet x.
	cmp #OFFSCREEN
	beq movement_done	; Bullet is offscreen, so don't move.

	lda frame_counter
	and #%00000001
	and bullets + 3, X	; Slowed.
	cmp #$0
	bne movement_done	; If slowed, skip movement on every other frame.

	ldy bullets + 2, X	; Direction.
	lda delta_x_direction, Y
	cmp #$0
	bne negative_delta_x
positive_delta_x:
	lda bullets + 0, X	; Bullet x.
	clc
	adc delta_x, Y
	sta bullets + 0, X	; Bullet x.
	jmp end_delta_x
negative_delta_x:
	lda bullets + 0, X	; Bullet x.
	sec
	sbc delta_x, Y
	sta bullets + 0, X	; Bullet x.
end_delta_x:

	lda delta_y_direction, Y
	cmp #$0
	bne negative_delta_y
positive_delta_y:
	lda bullets + 1, X	; Bullet y.
	clc
	adc delta_y, Y
	sta bullets + 1, X	; Bullet y.
	jmp end_delta_y
negative_delta_y:
	lda bullets + 1, X	; Bullet y.
	sec
	sbc delta_y, Y
	sta bullets + 1, X	; Bullet y.
end_delta_y:

movement_done:
	rts

; Function read_controller1.
; Gets the current button data for player 1 and stores it in the buttons1 variable.
read_controller1:
	lda #$01
	sta $4016
	lda #$00
	sta $4016
	ldx #$08
read_controller1_loop:
	lda $4016
	lsr A            ; bit0 -> Carry
	rol buttons1     ; bit0 <- Carry
	dex
	bne read_controller1_loop
	rts

; Function read_controller2.
; Gets the current button data for player 2 and stores it in the buttons2 variable.
read_controller2:
	lda #$01
	sta $4016
	lda #$00
	sta $4016
	ldx #$08
read_controller2_loop:
	lda $4017
	lsr A            ; bit0 -> Carry
	rol buttons2     ; bit0 <- Carry
	dex
	bne read_controller2_loop
	rts

; Function update_sprites.
; Gets data from variables and updates the sprites needed.
update_sprites:
	lda bullet1_y
	sta sprite_bullet1 + 0
	lda #$75
	sta sprite_bullet1 + 1
	lda #$00
	sta sprite_bullet1 + 2
	lda bullet1_x
	sta sprite_bullet1 + 3

	lda bullet2_y
	sta sprite_bullet2 + 0
	lda #$75
	sta sprite_bullet2 + 1
	lda #$01
	sta sprite_bullet2 + 2
	lda bullet2_x
	sta sprite_bullet2 + 3

	rts

;----------------------------------------------------------------
; static data
;----------------------------------------------------------------	
	
	.org $E000
palette:
	.db $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F
	.db $0F,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C

; Movement logic:
;
; The following points (x,y) were used to define the 32 directions.
; 5,0
; 5,1
; 5,2
; 4,3
; 4,4
; 3,4
; 2,5
; 1,5
; 0,5
;
; There are 32 possible directions.
; For direction i, the i-th entry of the delta_x vector indicates number of pixels to move horizontally.
; The corresponding entry of the delta_x_direction vector is 1 if the movement should be negative.
; Same logic applies for y.
;
; Direction 0 means a 0 degree angle when looking at the screen and imagining the regular x/y axis.
; Directions go counter-clockwise from 0 to 31.

delta_x:
	.db 5,5,5,4,4,3,2,1,0,1,2,3,4,4,5,5,5,5,5,4,4,3,2,1,0,1,2,3,4,4,5,5
delta_x_direction:
	.db 0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
delta_y:
	.db 0,1,2,3,4,4,5,5,5,5,5,4,4,3,2,1,0,1,2,3,4,4,5,5,5,5,5,4,4,3,2,1
delta_y_direction:
	.db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;----------------------------------------------------------------
; interrupt vectors
;----------------------------------------------------------------

	.org $fffa

	.dw NMI
	.dw reset
	.dw 0 ; IRQ not used.

;----------------------------------------------------------------
; CHR-ROM bank
;----------------------------------------------------------------

	.incbin "mario.chr"   ;includes 8KB graphics file from SMB1
