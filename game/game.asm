;----------------------------------------------------------------
; constants
;----------------------------------------------------------------

PRG_COUNT		= 1		; 1 = 16KB, 2 = 32KB
MIRRORING		= %0001 ; %0000 = horizontal, %0001 = vertical, %1000 = four-screen

RIGHT_WALL      = $F0	; When a bullet reaches one of these, handle colision.
TOP_WALL        = $20
BOTTOM_WALL     = $D0
LEFT_WALL       = $08

CENTER_SCREEN	= $80

OFFSCREEN		= $FE	; Sprites offscreen will be placed in position (OFFSCREEN, OFFSCREEN)
RANDOM_SEED		= $EB

;----------------------------------------------------------------
; variables
;----------------------------------------------------------------

	.enum $0000

	frame_counter: 		.dsb 1	; Counter that increments each frame (obviously overflows).
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

	random_var:			.dsb 1
	tmp_var:			.dsb 1

	.ende

;----------------------------------------------------------------
; sprites
;----------------------------------------------------------------

	.enum $0200

sprite_bullet1: .dsb 4

sprite_bullet2: .dsb 4

barrels: 		.dsb 64

cactuses: 		.dsb 64

	.ende

;----------------------------------------------------------------
; iNES header
;----------------------------------------------------------------

	.db "NES", $1a		; Identification of the iNES header
	.db PRG_COUNT		; Number of 16KB PRG-ROM pages
	.db $01				; Number of 8KB CHR-ROM pages
	.db $00|MIRRORING	; Mapper 0 and mirroring
	.dsb 9, $00			; Clear the remaining bytes

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

vblank_wait1:	 ; First wait for vblank to make sure PPU is ready
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
	bne load_palettes_loop  ; if x = $20, 32 bytes copied, all done

;;; Set starting game state.

	lda #LEFT_WALL + 8		; Spawning a bullet for test purposes.
	sta bullet1_x
	lda #CENTER_SCREEN
	sta bullet1_y
	lda #0
	sta bullet1_direction
	lda #0
	sta bullet1_slowed

	lda #RIGHT_WALL - 8		; Spawning a bullet for test purposes.
	sta bullet2_x
	lda #CENTER_SCREEN
	sta bullet2_y
	lda #16
	sta bullet2_direction
	lda #0
	sta bullet2_slowed

	lda #CENTER_SCREEN		; Spawning a barrel for test purposes.
	sta barrels + 0 + 0
	lda #CENTER_SCREEN - 70
	sta barrels + 3 + 0

	lda #CENTER_SCREEN + 8
	sta barrels + 0 + 4
	lda #CENTER_SCREEN - 70
	sta barrels + 3 + 4

	lda #CENTER_SCREEN		; Spawning a barrel for test purposes.
	sta barrels + 0 + 8
	lda #CENTER_SCREEN + 70
	sta barrels + 3 + 8

	lda #CENTER_SCREEN + 8
	sta barrels + 0 + 12
	lda #CENTER_SCREEN + 70
	sta barrels + 3 + 12

	lda #CENTER_SCREEN		; Spawning a cactus for test purposes.
	sta cactuses + 0 + 0
	lda #CENTER_SCREEN - 20
	sta cactuses + 3 + 0

	lda #CENTER_SCREEN + 8
	sta cactuses + 0 + 4
	lda #CENTER_SCREEN - 20
	sta cactuses + 3 + 4

	lda #CENTER_SCREEN		; Spawning a cactus for test purposes.
	sta cactuses + 0 + 8
	lda #CENTER_SCREEN + 20 
	sta cactuses + 3 + 8

	lda #CENTER_SCREEN + 8
	sta cactuses + 0 + 12
	lda #CENTER_SCREEN + 20
	sta cactuses + 3 + 12

	lda #RANDOM_SEED
	sta random_var

	jsr update_sprites		; Update the sprites for the first screen.

	lda #%10000000   		; enable NMI, sprites from Pattern Table 0
	sta $2000

	lda #%00010000   		; enable sprites
	sta $2001


forever:
	jmp forever		; jump back to forever, infinite loop, waiting for NMI


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

	lda frame_counter		; Auto-reset after 256 frames. TODO: REMOVE THESE 5 LINES OF CODE.
	cmp #0
	bne	skip_auto_reset
	jmp reset
skip_auto_reset:

checking_collisions:

	jsr check_side_collisions
	jsr check_top_collisions
	jsr check_bot_collisions

	jsr check_barrel_collisions

	jsr check_cactus_collisions

collisions_done:

	ldx #$0
	jsr move_bullet		; Move player 1's bullet.

	ldx #$1
	jsr move_bullet		; Move player 2's bullet.

game_engine_done:

	jsr update_sprites
	rti					; return from interrupt

;----------------------------------------------------------------
; functions
;----------------------------------------------------------------

; Function check_side_collisions
; No arguments. ***Uses only register A***.
; Returns in register A a pseudo-random number (not too random, very simple).
gen_random_byte:
	lda random_var
	asl A
	asl A
	clc
	adc random_var
	clc
	adc #03
	sta random_var
	rts

; Function check_side_collisions
; No arguments and no return.
; Checks collisions with the sides of the screen for both bullets and deals with the effects.
check_side_collisions:
	ldx #$0
check_side_collisions_loop:		; loop over the two bullets which are at positions bullets and bullets + 4 in memory.
	cpx #8
	beq check_side_collisions_done

	lda bullets + 0, X	; Bullet x.
	cmp #LEFT_WALL
	bcc check_side_collisions_loop_found ; A < #LEFT_WALL
	cmp #RIGHT_WALL
	bcs check_side_collisions_loop_found ; A >= #RIGHT_WALL
	jmp check_side_collisions_loop_ok

check_side_collisions_loop_found:	; If found a collision bullet goes off-screen.
	lda #OFFSCREEN
	sta bullets + 0, X	; Bullet x.
	lda #OFFSCREEN
	sta bullets + 1, X	; Bullet y.

check_side_collisions_loop_ok:
	inx
	inx
	inx
	inx
	jmp check_side_collisions_loop

check_side_collisions_done:
	rts

; Function check_top_collisions
; No arguments and no return.
; Checks collisions with the top of the screen for both bullets and deals with the effects.
check_top_collisions:
	ldx #$0
check_top_collisions_loop:		; loop over the two bullets which are at positions bullets and bullets + 4 in memory.
	cpx #8
	beq check_top_collisions_done

	lda bullets + 1, X	; Bullet y.
	cmp #TOP_WALL
	bcc check_top_collisions_loop_found ; A < #TOP_WALL
	jmp check_top_collisions_loop_ok

check_top_collisions_loop_found:	; If found a collision bullet bounces.
	lda bullets + 2, X	; Bullet direction.
	cmp #16
	bcs	check_top_collisions_loop_ok	; A >= #16, if already moving down, don't collide.
	cmp #0
	beq check_top_collisions_loop_ok	; A == #0, don't collide.
	lda #32
	sec
	sbc bullets + 2, X
	sta bullets + 2, X	; New direction = 32 - old direction.

check_top_collisions_loop_ok:
	inx
	inx
	inx
	inx
	jmp check_top_collisions_loop

check_top_collisions_done:
	rts

; Function check_bot_collisions
; No arguments and no return.
; Checks collisions with the bottom of the screen for both bullets and deals with the effects.
check_bot_collisions:
	ldx #$0
check_bot_collisions_loop:		; loop over the two bullets which are at positions bullets and bullets + 4 in memory.
	cpx #8
	beq check_bot_collisions_done

	lda bullets + 1, X	; Bullet y.
	cmp #BOTTOM_WALL
	bcs check_bot_collisions_loop_found ; A >= #BOTTOM_WALL
	jmp check_bot_collisions_loop_ok

check_bot_collisions_loop_found:	; If found a collision bullet bounces.
	lda bullets + 2, X	; Bullet direction.
	cmp #17
	bcc	check_bot_collisions_loop_ok	; A < #17, if already moving up, don't collide.
	lda #32
	sec
	sbc bullets + 2, X
	sta bullets + 2, X	; New direction = 32 - old direction.

check_bot_collisions_loop_ok:
	inx
	inx
	inx
	inx
	jmp check_bot_collisions_loop

check_bot_collisions_done:
	rts

; Function check_barrel_collisions
; No arguments and no return.
; Checks collisions with barrels for both bullets and deals with the effects.
check_barrel_collisions:
	ldx #$0
check_barrel_collisions_outer_loop:		; loop over the two bullets which are at positions bullets and bullets + 4 in memory.
	cpx #8
	beq check_barrel_collisions_done

	ldy #$0
check_barrel_collisions_inner_loop:		; Loop over the eight barrels in positions barrels, barrels + 8, ... barrels + 56 in memory.
	cpy #64
	beq check_barrel_collisions_outer_loop_ok

	lda barrels + 0, Y		; Barrel y_min
	sec
	sbc #1
	cmp bullets + 1, X		; Compare with bullet y.
	bcs	check_barrel_collisions_inner_loop_ok	; y_min - 1 >= bullet_y, so no collision

	lda barrels + 0, Y		; Barrel y_min
	clc
	adc #7					; Barrel y_max now.
	cmp bullets + 1, X		; Compare with bullet y.
	bcc	check_barrel_collisions_inner_loop_ok	; y_max < bullet_y, so no collision
	
	lda barrels + 3, Y		; Barrel x_min
	sec
	sbc #1
	cmp bullets + 0, X		; Compare with bullet x.
	bcs	check_barrel_collisions_inner_loop_ok	; x_min - 1 >= bullet_x, so no collision

	lda barrels + 3, Y		; Barrel x_min
	clc
	adc #7					; Barrel x_max now.
	cmp bullets + 0, X		; Compare with bullet x.
	bcc	check_barrel_collisions_inner_loop_ok	; x_max < bullet_x, so no collision

check_barrel_collisions_inner_loop_found:
	lda #1
	sta bullets + 3, X	; Bullet is now slowed.

	lda #OFFSCREEN
	sta barrels + 0, Y		; Send all parts of the barrel offscreen
	sta barrels + 3, Y
	sta barrels + 0 + 4, Y
	sta barrels + 3 + 4, Y

check_barrel_collisions_inner_loop_ok:
	tya
	clc
	adc #8
	tay
	jmp check_barrel_collisions_inner_loop

check_barrel_collisions_outer_loop_ok:
	inx
	inx
	inx
	inx
	jmp check_barrel_collisions_outer_loop

check_barrel_collisions_done:
	rts

; Function check_cactus_collisions
; No arguments and no return.
; Checks collisions with cactuses for both bullets and deals with the effects.
check_cactus_collisions:
	ldx #$0
check_cactus_collisions_outer_loop:		; loop over the two bullets which are at positions bullets and bullets + 4 in memory.
	cpx #8
	beq check_cactus_collisions_done

	ldy #$0
check_cactus_collisions_inner_loop:		; Loop over the eight cactuses in positions cactuses, cactuses + 8, ... cactuses + 56 in memory.
	cpy #64
	beq check_cactus_collisions_outer_loop_ok

	lda cactuses + 0, Y		; Cactus y_min
	sec
	sbc #1
	cmp bullets + 1, X		; Compare with bullet y.
	bcs	check_cactus_collisions_inner_loop_ok	; y_min - 1 >= bullet_y, so no collision

	lda cactuses + 0, Y		; Cactus y_min
	clc
	adc #7					; Cactus y_max now.
	cmp bullets + 1, X		; Compare with bullet y.
	bcc	check_cactus_collisions_inner_loop_ok	; y_max < bullet_y, so no collision
	
	lda cactuses + 3, Y		; Cactus x_min
	sec
	sbc #1
	cmp bullets + 0, X		; Compare with bullet x.
	bcs	check_cactus_collisions_inner_loop_ok	; x_min - 1 >= bullet_x, so no collision

	lda cactuses + 3, Y		; Cactus x_min
	clc
	adc #7					; Cactus x_max now.
	cmp bullets + 0, X		; Compare with bullet x.
	bcc	check_cactus_collisions_inner_loop_ok	; x_max < bullet_x, so no collision

check_cactus_collisions_inner_loop_found:
	; Bullet changes direction.

	jsr gen_random_byte
	and #%00000111	; Random number in [0, 7].
	cmp #4			; Direction offset of 4 would be no change, so don't allow it.
	bne check_cactus_collisions_direction_offset
	lda #8
check_cactus_collisions_direction_offset:
	sta tmp_var

	lda bullets + 2, X	; Bullet direction.		
	clc
	adc #32 - 4			; Add 28 equivalent to subtract 4.
	clc
	adc tmp_var
	and #%00011111
	sta bullets + 2, X	; Effect of this is that the bullet's direction win change by one of [-4,-3,-2,-1,1,2,3,4].

	lda #0
	sta bullets + 3, X	; Bullet is now not slowed.

check_cactus_collisions_inner_loop_ok:
	tya
	clc
	adc #8
	tay
	jmp check_cactus_collisions_inner_loop

check_cactus_collisions_outer_loop_ok:
	inx
	inx
	inx
	inx
	jmp check_cactus_collisions_outer_loop

check_cactus_collisions_done:
	rts


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
	tax					; The two bullets are at positions bullets and bullets + 4 in memory.

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
	lda #$03
	sta sprite_bullet1 + 1
	lda #$00
	sta sprite_bullet1 + 2
	lda bullet1_x
	sta sprite_bullet1 + 3

	lda bullet2_y
	sta sprite_bullet2 + 0
	lda #$03
	sta sprite_bullet2 + 1
	lda #$01
	sta sprite_bullet2 + 2
	lda bullet2_x
	sta sprite_bullet2 + 3

	ldx #$0
update_sprites_barrel_loop:			; Shows all barrels. Will need to be changed when barrels have two different sprites.
	cpx #64
	beq update_sprites_barrel_loop_end

	txa
	lsr a
	lsr a
	lsr a
	bcc update_sprites_barrel_is_even
	bcs update_sprites_barrel_is_odd
update_sprites_barrel_is_even:
	lda #$01
	sta barrels + 1, x
	lda #$00
	sta barrels + 2, x
	jmp update_sprites_barrel_end_draw
update_sprites_barrel_is_odd:	
	lda #$11
	sta barrels + 1, x
	lda #$00
	sta barrels + 2, x
update_sprites_barrel_end_draw:
	inx
	inx
	inx
	inx
	jmp update_sprites_barrel_loop
update_sprites_barrel_loop_end:


	ldx #$0
update_sprites_cactus_loop:			; Shows all cactuses. Will need to be changed when cactuses have two different sprites.
	cpx #64
	beq update_sprites_cactus_loop_end

	txa
	lsr a
	lsr a
	lsr a
	bcc update_sprites_cactus_is_even
	bcs update_sprites_cactus_is_odd
update_sprites_cactus_is_even:
	lda #$00
	sta cactuses + 1, x
	lda #$00
	sta cactuses + 2, x
	jmp update_sprites_cactus_end_draw
update_sprites_cactus_is_odd:	
	lda #$10
	sta cactuses + 1, x
	lda #$00
	sta cactuses + 2, x
update_sprites_cactus_end_draw:
	inx
	inx
	inx
	inx
	jmp update_sprites_cactus_loop
update_sprites_cactus_loop_end:

	rts

;----------------------------------------------------------------
; static data
;----------------------------------------------------------------	
	
	.org $E000
palette:
	.db $22,$16,$27,$18,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F
	.db $22,$16,$27,$18,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C

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

	.incbin "sprite_sheet.chr"   ;includes 8KB graphics file from SMB1
