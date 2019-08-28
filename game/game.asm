;################################################################
; Constants
;################################################################

PRG_COUNT = 1 ;1 = 16KB, 2 = 32KB
MIRRORING = %0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

RIGHT_WALL      = $F4	; When a bullet reaches one of these, handle colision.
TOP_WALL        = $28
BOTTOM_WALL     = $D8
LEFT_WALL       = $06  

OBJECTS_TOP_SCREEN_LIMIT = $20
OBJECTS_BOT_SCREEN_LIMIT = $C0
OBJECTS_LEFT_SCREEN_LIMIT = $30
OBJECTS_RIGHT_SCREEN_LIMIT = $C0

CENTER_SCREEN	= $80
OFFSCREEN		= $FE	; Sprites offscreen will be placed in position (OFFSCREEN, OFFSCREEN)
	
; Players constant X position (minimum x)
PLAYER1_X      = $01
PLAYER2_X      = $EF

; Used to define players' current direction 
UP_DIRECTION = 0
DOWN_DIRECTION = 1

CACTUS_META_SPRITE_SIZE = 2 * 4 ; 2 sprites of 4B
BARREL_META_SPRITE_SIZE = 2 * 4 ; 2 sprites of 4B
PLAYER_META_SPRITE_SIZE = 6 * 4 ; 4 sprites of 4B
BULLET_META_SPRITE_SIZE = 1 * 4 ; 1 sprite of 4B

SPRITES_TOTAL_LEN = (2 * PLAYER_META_SPRITE_SIZE) + (MAX_CACTUSES_COUNT * CACTUS_META_SPRITE_SIZE) + (MAX_BARRELS_COUNT * BARREL_META_SPRITE_SIZE) + (2 * BULLET_META_SPRITE_SIZE)
PALETTE_TOTAL_LEN = 2 * 16; 2 palettes of 16B

; All sprites use 4 bytes in the following order (VERTical pos, TILE number, ATTRIbutes, HORZintol pos)
SPRITE_VERT_BYTE = 0
SPRITE_TILE_BYTE = 1
SPRITE_ATTR_BYTE = 2
SPRITE_HORZ_BYTE = 3

; Gamepad buttons bits
BUTTON_A = %10000000
BUTTON_B = %01000000
BUTTON_SELECT = %00100000
BUTTON_START = %00010000
BUTTON_UP = %00001000
BUTTON_DOWN = %00000100
BUTTON_LEFT = %00000010
BUTTON_RIGHT = %00000001

; Cooldown for gamepad reading
READ_BUTTON_COOLDOWN = $10    ; empirical choice

; Constants about cactuses/Barrels generation behavior
MAX_CACTUSES_COUNT = 8
MAX_BARRELS_COUNT = 8
OBJECTS_MIN_Y_DISTANCE = 16
MIN_COOLDOWN_GEN_OBJECT = $20
MAX_COOLDOWN_GEN_OBJECT = $FF
MIN_COOLDOWN_REMOVE_OBJECT = $20
MAX_COOLDOWN_REMOVE_OBJECT = $FF

RANDOM_SEED		= $EB

CACTUS_COOLDOWN_AMOUNT = 2

;################################################################
; Variables
;################################################################

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
	bullet1_cooldown:	.dsb 1  ; Number of frames until this bullet can collide again with a cactus.

bullet2:
	bullet2_x: 			.dsb 1
	bullet2_y:			.dsb 1
	bullet2_direction:	.dsb 1
	bullet2_slowed:		.dsb 1
	bullet2_cooldown:	.dsb 1 
	
	aux_buttons  .dsb 1

	; Players current y position for the TOP and BOTTOM tiles (diff of 3 tiles)
	; Pos x is constant and hardcoded in graphic_constants
players:
	P1_top_y            .dsb 1
	P1_bottom_y         .dsb 1
	P1_damage_taken		.dsb 1 	; Number of hits player took.
	P1_direction 		.dsb 1 ; Player current direction.
	P1_buttons   		.dsb 1  ; Gamepad buttons, one bit per button in the following order: A, B, Select, Start, Up, Down, Left, Right
	P1_buttons_cooldown .dsb 1 	; Current reading cooldown of gamepad buttons
	P1_x 				.dsb 1  ; Constant in memory to allow looping over players.

	P2_top_y            .dsb 1
	P2_bottom_y         .dsb 1
	P2_damage_taken		.dsb 1
	P2_direction 		.dsb 1
	P2_buttons  		.dsb 1
	P2_buttons_cooldown .dsb 1
	P2_x 				.dsb 1  ; Constant in memory to allow looping over players.

	; Pointers used in Indirect Indexed mode
	pointer_lo  .dsb 1  
	pointer_hi  .dsb 1

	generate_one_cactus_cooldown  .dsb 1
	remove_one_cactus_cooldown    .dsb 1
	generate_one_barrel_cooldown  .dsb 1
	remove_one_barrel_cooldown    .dsb 1
	
	; Variable used as find_available_cactus_index function's return
	available_cactus_index      .dsb 1
	available_barrel_index      .dsb 1

	; Variables used by gen_random_byte_within_range and gen_random_byte functions
	random_min  			.dsb 1      ; arguments to gen_random_byte_within_range function
	random_max  			.dsb 1      ;
	bounded_random_var 	.dsb 1 		; return of gen_random_byte_within_range function
	random_var  			.dsb 1      
	random_mod  			.dsb 1

	tmp_var:			.dsb 1
	
	winner .dsb 1
    p1_score 			.dsb 1 	; Player current score.
    p2_score 			.dsb 1

	.ende

;----------------------------------------------------------------
; sprites
;----------------------------------------------------------------

	.enum $0200

sprite_area:

sprite_bullet1: .dsb BULLET_META_SPRITE_SIZE

sprite_bullet2: .dsb BULLET_META_SPRITE_SIZE

sprite_player1: .dsb PLAYER_META_SPRITE_SIZE

sprite_player2: .dsb PLAYER_META_SPRITE_SIZE

cactuses: 		.dsb MAX_CACTUSES_COUNT * CACTUS_META_SPRITE_SIZE

barrels: 		.dsb MAX_BARRELS_COUNT * BARREL_META_SPRITE_SIZE

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

;--------------------------------------------------------------------------
; Include Graphic constants
.include "graphics_constants.asm"

;################################################################
; RESET
;################################################################
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

; Copy hardcoded background graphics from graphics_constants.asm to the PPU memory
load_palettes:
	lda $2002             ; read PPU status to reset the high/low latch
	lda #$3F
	sta $2006             ; write the high byte of $3F00 address
	lda #$00
	sta $2006             ; write the low byte of $3F00 address
	ldx #$00              ; start out at 0
load_palettes_loop:
	lda palette, x        
	sta $2007             
	inx                   
	cpx #PALETTE_TOTAL_LEN
	bne load_palettes_loop 

; Copy hardcoded background graphics from graphics_constants.asm to the PPU memory
load_background:
	lda $2002             ; read PPU status to reset the high/low latch
	lda #$20
	sta $2006             ; write the high byte of $2000 address
	lda #$00
	sta $2006             ; write the low byte of $2000 address

	lda #$00
	sta pointer_lo       ; put the low byte of the address of background into pointer
	lda #>background
	sta pointer_hi       ; put the high byte of the address into pointer
	
	ldx #$00             ; start at pointer + 0
	ldy #$00
load_background_outside_loop:
load_background_inside_loop:
	lda (pointer_lo), y  ; copy one background byte from address in pointer plus Y
	sta $2007            ; this runs 256 * 4 times
	
	iny                  ; inside loop counter
	cpy #$00
	bne load_background_inside_loop      ; run the inside loop 256 times before continuing down
	
	inc pointer_hi       ; low byte went 0 to 256, so high byte needs to be changed now
 
	inx
	cpx #$04
	bne load_background_outside_loop     ; run the outside loop 256 times before continuing down

; Copy hardcoded sprites graphics from graphics_constants.asm to the DMA area
load_sprites:
	ldx #$00              
load_sprites_loop:
	lda sprites, x        
	sta sprite_area, x    
	inx                   
	cpx #SPRITES_TOTAL_LEN
	bne load_sprites_loop  

;;; Set starting game state.

	; Initial direction
	lda #DOWN_DIRECTION
	sta P1_direction
	lda #UP_DIRECTION
	sta P2_direction

	; Initial position
	lda #$80
	sta P1_top_y
	sta P2_top_y
	lda #$98
	sta P1_bottom_y
	sta P2_bottom_y

	lda #PLAYER1_X
	sta P1_x
	lda #PLAYER2_X
	sta P2_x

	lda #RANDOM_SEED
	sta random_var

	jsr update_sprites		; Update the sprites for the first screen.

;--------------------------------------------------------------------------
; Set some configuration flags to CPU
	lda #%10000000   		; enable NMI, sprites from Pattern Table 0
	sta $2000

	lda #%00010000   		; enable sprites
	sta $2001

;--------------------------------------------------------------------------
forever:
	jmp forever		; jump back to forever, infinite loop, waiting for NMI

;################################################################
; nmi
;################################################################
NMI:
	jsr dma_transfer
	jsr clean_PPU

	; Game loop
	jsr read_P1_controller  
	jsr read_P2_controller

game_engine:

	jsr update_frame_counter

; 	lda frame_counter		; Auto-reset after 256 frames. TODO: REMOVE THESE 5 LINES OF CODE.
; 	cmp #0
; 	bne	skip_auto_reset
; 	jmp reset
; skip_auto_reset:

checking_collisions:

	jsr check_bullet_player_collisions 		; Need to check bullet first, otherwise bullet will collide with sides.

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

	jsr update_game_state

game_engine_done:

	lda P1_damage_taken
	sta p2_score

	lda P2_damage_taken
	sta p1_score

	; jsr draw_score  ; TODO: fix me, currently broken.

	jsr update_sprites
	rti					; return from interrupt

;################################################################
; functions
;################################################################

;--------------------------------------------------------------------------
; Function to call all other update functions related to the game state
update_game_state:  
	jsr P1_controller_handler
	jsr P2_controller_handler
	jsr update_P1_direction_by_wall_collision
	jsr update_P2_direction_by_wall_collision
	jsr update_P1_positions
	jsr update_P2_positions
	jsr update_players_sprites
	jsr generate_one_cactus
	jsr remove_one_cactus
	jsr generate_one_barrel
	jsr remove_one_barrel

	rts

;--------------------------------------------------------------------------
; This function randomly chooses a cactus to "remove" (put offscreen). It has
; a random cooldown.
remove_one_cactus:
	
	; Check if cooldown time has finished
	lda remove_one_cactus_cooldown
	cmp #0
	bne remove_one_cactus_end

	; Generate a random index
	lda #0
	sta random_min
	lda #MAX_CACTUSES_COUNT - 1
	sta random_max
	jsr gen_random_byte_within_range

	; Make a loop to set (X register) = (bounded_random_var * CACTUS_META_SPRITE_SIZE)
	lda #0      ; iterates over cactuses sprites "array", step of CACTUS_META_SPRITE_SIZE
	ldy #0      ; counts until generated random index (i.e. bounded_random_var), step of 1B
multiply_loop_remove_one_cactus:
	cpy bounded_random_var
	beq multiply_loop_remove_one_cactus_end

	clc
	adc #CACTUS_META_SPRITE_SIZE

	iny
	jmp multiply_loop_remove_one_cactus  
multiply_loop_remove_one_cactus_end:
	tax

	; Put chosen cactus offscreen
	lda #OFFSCREEN
	sta cactuses + SPRITE_VERT_BYTE, X
	sta cactuses + SPRITE_HORZ_BYTE, X
	sta cactuses + 4 + SPRITE_VERT_BYTE, X
	sta cactuses + 4 + SPRITE_HORZ_BYTE, X

	; Reset (random) cooldown
	lda #MIN_COOLDOWN_REMOVE_OBJECT
	sta random_min
	lda #MAX_COOLDOWN_REMOVE_OBJECT
	sta random_max
	jsr gen_random_byte_within_range
	lda bounded_random_var
	sta remove_one_cactus_cooldown

remove_one_cactus_end:
	dec remove_one_cactus_cooldown
	rts

;--------------------------------------------------------------------------
; This is equal to remove_one_cactus function, but for barrels
remove_one_barrel:
	
	; Check if cooldown time has finished
	lda remove_one_barrel_cooldown
	cmp #0
	bne remove_one_barrel_end

	; Generate a random index
	lda #0
	sta random_min
	lda #MAX_BARRELS_COUNT - 1
	sta random_max
	jsr gen_random_byte_within_range

	; Make a loop to set (X register) = (bounded_random_var * BARREL_META_SPRITE_SIZE)
	lda #0      ; iterates over barrels sprites "array", step of BARREL_META_SPRITE_SIZE
	ldy #0      ; counts until generated random index (i.e. bounded_random_var), step of 1B
multiply_loop_remove_one_barrel:
	cpy bounded_random_var
	beq multiply_loop_remove_one_barrel_end

	clc
	adc #BARREL_META_SPRITE_SIZE

	iny
	jmp multiply_loop_remove_one_barrel  
multiply_loop_remove_one_barrel_end:
	tax

	; Put chosen barrel offscreen
	lda #OFFSCREEN
	sta barrels + SPRITE_VERT_BYTE, X
	sta barrels + SPRITE_HORZ_BYTE, X
	sta barrels + 4 + SPRITE_VERT_BYTE, X
	sta barrels + 4 + SPRITE_HORZ_BYTE, X

	; Reset (random) cooldown
	lda #MIN_COOLDOWN_REMOVE_OBJECT
	sta random_min
	lda #MAX_COOLDOWN_REMOVE_OBJECT
	sta random_max
	jsr gen_random_byte_within_range
	lda bounded_random_var
	sta remove_one_barrel_cooldown

remove_one_barrel_end:
	dec remove_one_barrel_cooldown
	rts

;--------------------------------------------------------------------------
; This function generates a new cactus if the number of cactus on screen is not greater than
; MAX_CACTUSES_COUNT. This function does not create a new cactus with absolute vertical 
; distance lower than OBJECTS_MIN_Y_DISTANCE from a existent cactus.
; USES:
;   * random_min/random_max: to generate a bounded random number using get_random_byte_within_range function
; EXTRA:
; The cactuses sprites' format are the following:
;    +----+
;    | 0  |
;    |4*0 |
;    +----+
;    | 1  |
;    |4*1 |
;    +----+
generate_one_cactus:
	
	; Check if cooldown time has finished
	lda generate_one_cactus_cooldown
	cmp #0
	bne generate_one_cactus_end

	; Try to find an available cactus position for the new one that will be generated.
	jsr find_available_cactus_index
	lda available_cactus_index
	cmp #1         ; if available_cactus_index == 1 -> there isn't an available index
	beq generate_one_cactus_end

	; To generate Y position, it's used the get_random_byte_within_range function.
	; The idea of the following algorithm is to keep trying to find a new random Y position
	; that not violates the OBJECTS_MIN_Y_DISTANCE rule. In order to decide to weather a new Y
	; position is valid we check all existent cactuses and compare their Y position with the
	; new one. 

	; Set range to call get_random_byte_within_range function
	lda #OBJECTS_TOP_SCREEN_LIMIT
	sta random_min
	lda #OBJECTS_BOT_SCREEN_LIMIT
	sta random_max

generate_random_y_pos:
	jsr gen_random_byte_within_range
	

	; Try to verify if the generated Y is valid by calculating the absolute vertical distance
	; with all other existents cactuses
	
	ldx #0      ; iterates over cactuses sprites "array", step of CACTUS_META_SPRITE_SIZE
	ldy #0      ; counts until MAX_CACTUSES_COUNT, step of 1B

verify_other_cactuses_loop:
	; Check loop condition
	cpy #MAX_CACTUSES_COUNT
	beq found_valid_y     
	
	lda cactuses + SPRITE_VERT_BYTE, X    ;
	sec                                   ;
	sbc #OBJECTS_MIN_Y_DISTANCE          ;
	cmp bounded_random_var                ;
	bcs verify_other_cactuses_loop_step   ;  Y <= Y' - MIN_DISTANCE -> valid Y

	lda cactuses + SPRITE_VERT_BYTE, X    ;
	clc                                   ;
	adc #OBJECTS_MIN_Y_DISTANCE          ;
	cmp bounded_random_var                ;
	bcc verify_other_cactuses_loop_step   ;  Y > Y' + MIN_DISTANCE -> valid Y

	; Invalid Y, have to generate a new one
	jmp generate_random_y_pos

verify_other_cactuses_loop_step:
	; increment CACTUS_META_SPRITE_SIZE to iterator X
	txa         
	clc                             
	adc #CACTUS_META_SPRITE_SIZE     
	tax                              

	iny ; increment 1B to iterator Y
	jmp verify_other_cactuses_loop


found_valid_y:

	; Store the valid y to the new cactus
	ldx available_cactus_index
	lda bounded_random_var
	sta cactuses + SPRITE_VERT_BYTE, X       
	clc         ; remember that each sprite is a 8x8 pixels tile
	adc #8      ;
	sta cactuses + 4 + SPRITE_VERT_BYTE, X       

	; Generate and store a valid X to the new cactus
	lda #OBJECTS_LEFT_SCREEN_LIMIT
	sta random_min
	lda #OBJECTS_RIGHT_SCREEN_LIMIT
	sta random_max
	jsr gen_random_byte_within_range
	lda bounded_random_var
	sta cactuses + SPRITE_HORZ_BYTE, X       
	sta cactuses + 4 * 1 +SPRITE_HORZ_BYTE, X       
	
	; Reset (random) cooldown 
	lda #MIN_COOLDOWN_GEN_OBJECT
	sta random_min
	lda #MAX_COOLDOWN_GEN_OBJECT
	sta random_max
	jsr gen_random_byte_within_range
	lda bounded_random_var
	sta generate_one_cactus_cooldown

generate_one_cactus_end:
	dec generate_one_cactus_cooldown
	rts

;--------------------------------------------------------------------------
; This function is equal to genereate_one_cactus function, but for barrels
generate_one_barrel:
	
	; Check if cooldown time has finished
	lda generate_one_barrel_cooldown
	cmp #0
	bne generate_one_barrel_end

	; Try to find an available barrel position for the new one that will be generated.
	jsr find_available_barrel_index
	lda available_barrel_index
	cmp #1         ; if available_barrel_index == 1 -> there isn't an available index
	beq generate_one_barrel_end

	; To generate Y position, it's used the get_random_byte_within_range function.
	; The idea of the following algorithm is to keep trying to find a new random Y position
	; that not violates the OBJECTS_MIN_Y_DISTANCE rule. In order to decide to weather a new Y
	; position is valid we check all existent barreles and compare their Y position with the
	; new one. 

	; Set range to call get_random_byte_within_range function
	lda #OBJECTS_TOP_SCREEN_LIMIT
	sta random_min
	lda #OBJECTS_BOT_SCREEN_LIMIT
	sta random_max

generate_barrel_random_y_pos:
	jsr gen_random_byte_within_range
	

	; Try to verify if the generated Y is valid by calculating the absolute vertical distance
	; with all other existents barrels
	
	ldx #0      ; iterates over barrel sprites "array", step of BARREL_META_SPRITE_SIZE
	ldy #0      ; counts until MAX_BARRELS_COUNT, step of 1B

verify_other_barrels_loop:
	; Check loop condition
	cpy #MAX_BARRELS_COUNT
	beq found_valid_barrel_y     
	
	lda barrels + SPRITE_VERT_BYTE, X    ;
	sec                                   ;
	sbc #OBJECTS_MIN_Y_DISTANCE          ;
	cmp bounded_random_var                ;
	bcs verify_other_barrels_loop_step   ;  Y <= Y' - MIN_DISTANCE -> valid Y

	lda barrels + SPRITE_VERT_BYTE, X    ;
	clc                                   ;
	adc #OBJECTS_MIN_Y_DISTANCE          ;
	cmp bounded_random_var                ;
	bcc verify_other_barrels_loop_step   ;  Y > Y' + MIN_DISTANCE -> valid Y

	; Invalid Y, have to generate a new one
	jmp generate_barrel_random_y_pos

verify_other_barrels_loop_step:
	; increment BARREL_META_SPRITE_SIZE to iterator X
	txa         
	clc                             
	adc #BARREL_META_SPRITE_SIZE     
	tax                              

	iny ; increment 1B to iterator Y
	jmp verify_other_barrels_loop


found_valid_barrel_y:

	; Store the valid y to the new barrel
	ldx available_barrel_index
	lda bounded_random_var
	sta barrels + SPRITE_VERT_BYTE, X       
	clc         ; remember that each sprite is a 8x8 pixels tile
	adc #8      ;
	sta barrels + 4 + SPRITE_VERT_BYTE, X       

	; Generate and store a valid X to the new barrel
	lda #OBJECTS_LEFT_SCREEN_LIMIT
	sta random_min
	lda #OBJECTS_RIGHT_SCREEN_LIMIT
	sta random_max
	jsr gen_random_byte_within_range
	lda bounded_random_var
	sta barrels + SPRITE_HORZ_BYTE, X       
	sta barrels + 4 +SPRITE_HORZ_BYTE, X       
	
	; Reset (random) cooldown 
	lda #MIN_COOLDOWN_GEN_OBJECT
	sta random_min
	lda #MAX_COOLDOWN_GEN_OBJECT
	sta random_max
	jsr gen_random_byte_within_range
	lda bounded_random_var
	sta generate_one_barrel_cooldown

generate_one_barrel_end:
	dec generate_one_barrel_cooldown
	rts

;--------------------------------------------------------------------------
; This function searches for the first index of the cactuses array that is available.
; An index is considered available when the current cactus is offscreen.
; RETURNS
;   * available_cactus_index: with the available index.
; WARNING
;   * available_cactus_index = 1 when there isn't an index (1 because all index are multiple of CACTUS_META_SPRITE_SIZE)
;
find_available_cactus_index:
	
	ldx #0      ; iterates over cactuses sprites "array", step of CACTUS_META_SPRITE_SIZE
	ldy #0      ; counts until curr_cactuses_count, step of 1B

find_available_cactus_index_loop:
	; Check loop condition
	cpy #MAX_CACTUSES_COUNT
	beq not_found_available_index     
	
	; Check current cactus is OFFSCREEN
	lda cactuses + SPRITE_VERT_BYTE, X
	cmp #OFFSCREEN
	beq found_available_index

	; increment CACTUS_META_SPRITE_SIZE to iterator X
	txa         
	clc                             
	adc #CACTUS_META_SPRITE_SIZE     
	tax                              

	iny ; increment 1B to iterator Y

	jmp find_available_cactus_index_loop

not_found_available_index:
	lda #1    ; NOT FOUND value of this function
	sta available_cactus_index
	rts

found_available_index:
	txa
	sta available_cactus_index
	rts

;--------------------------------------------------------------------------
; This function is equal to find_available_cactus_index function, but for barrels
find_available_barrel_index:
	
	ldx #0      ; iterates over barrels sprites "array", step of BARREL_META_SPRITE_SIZE
	ldy #0      ; counts until curr_barrels_count, step of 1B

find_available_barrel_index_loop:
	; Check loop condition
	cpy #MAX_BARRELS_COUNT
	beq not_found_available_barrel_index     
	
	; Check current barrel is OFFSCREEN
	lda barrels + SPRITE_VERT_BYTE, X
	cmp #OFFSCREEN
	beq found_available_barrel_index

	; increment BARREL_META_SPRITE_SIZE to iterator X
	txa         
	clc                             
	adc #BARREL_META_SPRITE_SIZE     
	tax                              

	iny ; increment 1B to iterator Y

	jmp find_available_barrel_index_loop

not_found_available_barrel_index:
	lda #1    ; NOT FOUND value of this function
	sta available_barrel_index
	rts

found_available_barrel_index:
	txa
	sta available_barrel_index
	rts
;--------------------------------------------------------------------------
update_P1_direction_by_wall_collision:
	; Check for direction and y position
	lda P1_bottom_y
	cmp #BOTTOM_WALL
	bne check_top_wall_collision_P1
	lda P1_direction
	cmp #DOWN_DIRECTION
	bne check_top_wall_collision_P1
	
	; direction == DOWN && Y == BOTTOM -> Had a bottom collision 
	; have to reverse direction
	lda #UP_DIRECTION               
	sta P1_direction
	jmp end_update_P1_direction_by_wall_collision

check_top_wall_collision_P1: 
	; Check for direction and y position
	lda P1_top_y
	cmp #TOP_WALL
	bne end_update_P1_direction_by_wall_collision
	lda P1_direction
	cmp #UP_DIRECTION
	bne end_update_P1_direction_by_wall_collision
	
	; direction == UP && Y == TOP -> Had a top collision 
	; have to reverse direction
	lda #DOWN_DIRECTION           
	sta P1_direction

end_update_P1_direction_by_wall_collision:
	rts

;--------------------------------------------------------------------------
update_P2_direction_by_wall_collision:

	; Check for direction and y position
	lda P2_bottom_y
	cmp #BOTTOM_WALL
	bne check_top_wall_collision_P2
	lda P2_direction
	cmp #DOWN_DIRECTION
	bne check_top_wall_collision_P2

	; direction == DOWN && Y == BOTTOM -> Had a bottom collision 
	; have to reverse direction
	lda #UP_DIRECTION          
	sta P2_direction
	jmp end_update_P2_direction_by_wall_collision

check_top_wall_collision_P2:
	; Check for direction and y position
	lda P2_top_y
	cmp #TOP_WALL
	bne end_update_P2_direction_by_wall_collision
	lda P2_direction
	cmp #UP_DIRECTION
	bne end_update_P2_direction_by_wall_collision

	; direction == UP && Y == TOP -> Had a top collision 
	; have to reverse direction
	lda #DOWN_DIRECTION         
	sta P2_direction

end_update_P2_direction_by_wall_collision:
	rts

;--------------------------------------------------------------------------
update_P1_positions:
	lda P1_direction
	cmp #UP_DIRECTION
	beq P1_move_up_direction

	; direction == DOWN_DIRECTION -> have move down
	inc P1_top_y
	inc P1_bottom_y
	jmp end_update_P1_positions

	; direction == UP_DIRECTION -> so have move up
P1_move_up_direction:
	dec P1_top_y
	dec P1_bottom_y

end_update_P1_positions:
	rts

;--------------------------------------------------------------------------
update_P2_positions:
	lda P2_direction
	cmp #UP_DIRECTION
	beq P2_move_up_direction

	; direction == DOWN_DIRECTION -> have move down
	inc P2_top_y
	inc P2_bottom_y
	jmp end_update_P2_positions

	; direction == UP_DIRECTION -> so have move up
P2_move_up_direction:
	dec P2_top_y
	dec P2_bottom_y

end_update_P2_positions:
	rts

;--------------------------------------------------------------------------
; This function copies the current players' positions into the position's bytes
; in their sprites
update_players_sprites:
	
	; Update P1 sprite
	lda P1_top_y
	sta sprite_player1
	sta sprite_player1 + 4
	clc
	adc #8
	sta sprite_player1 + 8
	sta sprite_player1 + 12
	clc
	adc #8
	sta sprite_player1 + 16
	sta sprite_player1 + 20

	; Update P2 sprite
	lda P2_top_y
	sta sprite_player2
	sta sprite_player2 + 4
	clc
	adc #8
	sta sprite_player2 + 8
	sta sprite_player2 + 12
	clc
	adc #8
	sta sprite_player2 + 16
	sta sprite_player2 + 20
 
	rts
	
;--------------------------------------------------------------------------
; This function reads the P1 controller, but it uses an aux variable to read.
; The value of this aux variable is only copied to P1_buttons variable when
; the player actually pressed a button and the cooldown time has finished.
; This aux variable strategy avoids entering in the cooldown time even without 
; pressing a button.
; The cooldown time is required because the frame rate is too quickly
read_P1_controller:
	; Serial buttons reading 
	lda #$01
	sta $4016
	lda #$00
	sta $4016
	ldx #$08
read_P1_controller_loop:
	lda $4016           ; 4016 is correct port for P2
	lsr A               ; bit0 -> Carry
	rol aux_buttons     ; bit0 <- Carry
	dex
	bne read_P1_controller_loop

	; Check if some button was clicked, i.e. some bit have to be 1
	lda aux_buttons
	cmp #0
	beq P1_button_cooldown_update

	; Check if cooldown time has finished
	lda P1_buttons_cooldown
	cmp #0
	beq apply_reading_P1

	; None button was clicked or cooldown time hasn't finished
	; we just ignore the reading
	jmp P1_button_cooldown_update

apply_reading_P1:
	; Reset cooldown
	lda #READ_BUTTON_COOLDOWN
	sta P1_buttons_cooldown
	; Transfer aux variable
	lda aux_buttons
	sta P1_buttons

P1_button_cooldown_update:
	; if cooldown > 0, decrement it
	; else finish the function
	lda P1_buttons_cooldown
	cmp #0
	beq read_P1_controller_end
	dec P1_buttons_cooldown

read_P1_controller_end:
	rts

;--------------------------------------------------------------------------
; Same function as 'read_P1_controller', but for Player 2
read_P2_controller:
	; Serial buttons reading 
	lda #$01
	sta $4016
	lda #$00
	sta $4016
	ldx #$08
read_P2_controller_loop:
	lda $4017           ; 4017 is correct port for P2
	lsr A               ; bit0 -> Carry
	rol aux_buttons     ; bit0 <- Carry
	dex
	bne read_P2_controller_loop

	; Check if some button was clicked, i.e. some bit have to be 1
	lda aux_buttons
	cmp #0
	beq P2_button_cooldown_update

	; Check if cooldown time has finished
	lda P2_buttons_cooldown
	cmp #0
	beq apply_reading_P2

	; None button was clicked or cooldown time hasn't finished
	; we just ignore the reading
	jmp P2_button_cooldown_update

apply_reading_P2:
	; Reset cooldown
	lda #READ_BUTTON_COOLDOWN
	sta P2_buttons_cooldown
	; Transfer aux variable
	lda aux_buttons
	sta P2_buttons

P2_button_cooldown_update:
	; if cooldown > 0, decrement it
	; else finish the function
	lda P2_buttons_cooldown
	cmp #0
	beq read_P2_controller_end
	dec P2_buttons_cooldown

read_P2_controller_end:
	rts

;--------------------------------------------------------------------------
; This is the PPU clean up section, so rendering the next frame starts properly.
clean_PPU:
	lda #%10010000   ; enable nmi, sprites from Pattern Table 0, background from Pattern Table 1
	sta $2000
	lda #%00011110   ; enable sprites, enable background, no clipping on left side
	sta $2001
	lda #$00        ;;tell the ppu there is no background scrolling
	sta $2005
	sta $2005
	rts

;--------------------------------------------------------------------------
; This function starts the DMA transfer, which copies from $0200 to $0300 (256B)
; from CPU to PPU's sprite memory
dma_transfer:
	lda #$00
	sta $2003       ; (TARGET) dma will copy 256B starting from address $00 of PPU's sprite memory
	lda #$02
	sta $4014       ; (SOURCE) dma will copy the next 256B starting from addres $0200 of CPU's memory
	rts

;--------------------------------------------------------------------------
; This function updates player 1 direction by reversing it if button A was pressed
; and shooting a bullet if button B was pressed
P1_controller_handler:
	lda P1_buttons
	cmp #BUTTON_A
	bne end_P1_button_a_check

	; Reverse Player direction
	lda P1_direction
	cmp #UP_DIRECTION
	beq set_P1_direction_to_down

	; direction == DOWN_DIRECTION, so direction = UP_DIRECTION
	lda #UP_DIRECTION
	sta P1_direction
	jmp end_P1_button_a_check

set_P1_direction_to_down:
	; direction == UP_DIRECTION, so direction = DOWN_DIRECTION
	lda #DOWN_DIRECTION
	sta P1_direction

end_P1_button_a_check:
	; Check B button (shot) was pressed
	lda P1_buttons
	cmp #BUTTON_B
	bne end_P1_controller_handler

	; check if player´s bullet is not already on screen
	lda bullet1 + SPRITE_VERT_BYTE
	cmp #OFFSCREEN
	bne end_P1_controller_handler

	; spawn a bullet from player´s gun
	lda sprite_player1 + SPRITE_HORZ_BYTE
	clc
	adc #16
	sta bullet1_x
	lda sprite_player1 + 8 + SPRITE_VERT_BYTE
	clc
	adc #4
	sta bullet1_y
	lda #0
	sta bullet1_direction
	lda #0
	sta bullet1_slowed

end_P1_controller_handler:
	lda #0
	sta P1_buttons
	rts

;--------------------------------------------------------------------------
; This function updates player 2 direction by reversing it if button A was pressed
; and shooting a bullet if button B was pressed
P2_controller_handler:
	lda P2_buttons
	cmp #BUTTON_A
	bne end_P2_button_a_check

	; Reverse Player direction
	lda P2_direction
	cmp #UP_DIRECTION
	beq set_P2_direction_to_down

	; direction == DOWN_DIRECTION, so direction = UP_DIRECTION
	lda #UP_DIRECTION
	sta P2_direction
	jmp end_P2_button_a_check

set_P2_direction_to_down:
	; direction == UP_DIRECTION, so direction = DOWN_DIRECTION
	lda #DOWN_DIRECTION
	sta P2_direction
	
end_P2_button_a_check:

	; Check B button (shot) was pressed
	lda P2_buttons
	cmp #BUTTON_B
	bne end_P2_controller_handler

	; check if player´s bullet is not already on screen
	lda bullet2 + SPRITE_VERT_BYTE
	cmp #OFFSCREEN
	bne end_P2_controller_handler

	; spawn a bullet from player´s gun
	lda sprite_player2 + SPRITE_HORZ_BYTE
	sec
	sbc #16
	sta bullet2_x
	lda sprite_player2 + 8 + SPRITE_VERT_BYTE
	clc
	adc #4
	sta bullet2_y
	lda #16
	sta bullet2_direction
	lda #0
	sta bullet2_slowed

end_P2_controller_handler:
	lda #0
	sta P2_buttons
	rts
	

;--------------------------------------------------------------------------
; This function generates a pseudo-random number within a range (inclusive)
; USES:
;   * random_min
;   * random_max
; RETURNS
;   * random_var 
gen_random_byte_within_range:
	jsr gen_random_byte
	
	lda random_max
	sec
	sbc random_min
	clc
	adc #1
	sta random_mod

	lda random_var
module_loop:
	cmp random_mod
	bcc module_loop_end

	sec
	sbc random_mod
	jmp module_loop

module_loop_end:
	clc
	adc random_min
	sta bounded_random_var
	
	rts

;--------------------------------------------------------------------------
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

;--------------------------------------------------------------------------
; Function check_side_collisions
; No arguments and no return.
; Checks collisions with the sides of the screen for both bullets and deals with the effects.
check_side_collisions:
	ldx #$0
check_side_collisions_loop:		; loop over the two bullets which are at positions bullets and bullets + 5 in memory.
	cpx #10
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
	inx
	jmp check_side_collisions_loop

check_side_collisions_done:
	rts

;--------------------------------------------------------------------------
; Function check_top_collisions
; No arguments and no return.
; Checks collisions with the top of the screen for both bullets and deals with the effects.
check_top_collisions:
	ldx #$0
check_top_collisions_loop:		; loop over the two bullets which are at positions bullets and bullets + 5 in memory.
	cpx #10
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
	inx
	jmp check_top_collisions_loop

check_top_collisions_done:
	rts

;--------------------------------------------------------------------------
; Function check_bot_collisions
; No arguments and no return.
; Checks collisions with the bottom of the screen for both bullets and deals with the effects.
check_bot_collisions:
	ldx #$0
check_bot_collisions_loop:		; loop over the two bullets which are at positions bullets and bullets + 5 in memory.
	cpx #10
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
	inx
	jmp check_bot_collisions_loop

check_bot_collisions_done:
	rts

;--------------------------------------------------------------------------
; Function check_barrel_collisions
; No arguments and no return.
; Checks collisions with barrels for both bullets and deals with the effects.
check_barrel_collisions:
	ldx #$0
check_barrel_collisions_outer_loop:		; loop over the two bullets which are at positions bullets and bullets + 5 in memory.
	cpx #10
	beq check_barrel_collisions_done

	ldy #$0
check_barrel_collisions_inner_loop:		; Loop over the eight barrels in positions barrels, barrels + 8, ... barrels + 56 in memory.
	cpy #64
	beq check_barrel_collisions_outer_loop_ok

	lda barrels + 0, Y		; Barrel y_min
	sec
	sbc #1					; TODO: check if is not #1
	cmp bullets + 1, X		; Compare with bullet y.
	bcs	check_barrel_collisions_inner_loop_ok	; y_min - 1 >= bullet_y, so no collision

	lda barrels + 0, Y		; Barrel y_min
	clc
	adc #15					; Barrel y_max now. TODO: check if is not #7
	cmp bullets + 1, X		; Compare with bullet y.
	bcc	check_barrel_collisions_inner_loop_ok	; y_max < bullet_y, so no collision
	
	lda barrels + 3, Y		; Barrel x_min
	sec
	sbc #1					; TODO: check if is not #1
	cmp bullets + 0, X		; Compare with bullet x.
	bcs	check_barrel_collisions_inner_loop_ok	; x_min - 1 >= bullet_x, so no collision

	lda barrels + 3, Y		; Barrel x_min
	clc
	adc #7					; Barrel x_max now. TODO: check if is not #7
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
	inx
	jmp check_barrel_collisions_outer_loop

check_barrel_collisions_done:
	rts

;--------------------------------------------------------------------------
; Function check_bullet_player_collisions
; No arguments and no return.
; Checks collisions with players for both bullets and deals with the effects.
check_bullet_player_collisions:
	ldx #$0
check_bullet_player_collisions_outer_loop:		; loop over the two bullets which are at positions bullets and bullets + 5 in memory.
	cpx #10
	beq check_bullet_player_collisions_done

	ldy #$0
check_bullet_player_collisions_inner_loop:		; Loop over the two players.
	cpy #14
	beq check_bullet_player_collisions_outer_loop_ok

	lda players + 0, Y		; player y_min
	sec
	sbc #1
	cmp bullets + 1, X		; Compare with bullet y.
	bcs	check_bullet_player_collisions_inner_loop_ok	; y_min - 1 >= bullet_y, so no collision

	lda players + 0, Y		; player y_min
	clc
	adc #23					; Player y_max now.
	cmp bullets + 1, X		; Compare with bullet y.
	bcc	check_bullet_player_collisions_inner_loop_ok	; y_max < bullet_y, so no collision
	
	lda players + 6, Y		; player x_min
	sec
	sbc #1					; TODO: check if is not #1
	cmp bullets + 0, X		; Compare with bullet x.
	bcs	check_bullet_player_collisions_inner_loop_ok	; x_min - 1 >= bullet_x, so no collision

	lda players + 6, Y		; Player x_min
	clc
	adc #15
	cmp bullets + 0, X		; Compare with bullet x.
	bcc	check_bullet_player_collisions_inner_loop_ok	; x_max < bullet_x, so no collision

check_bullet_player_collisions_inner_loop_found:
	lda #OFFSCREEN
	sta bullets + 0, X		; Send bullet off-screen.
	sta bullets + 1, X

	lda players + 2, Y		; Player damage taken.
	clc
	adc #1
	sta players + 2, Y		; Increment player damage.

check_bullet_player_collisions_inner_loop_ok:
	tya
	clc
	adc #7
	tay
	jmp check_bullet_player_collisions_inner_loop

check_bullet_player_collisions_outer_loop_ok:
	inx
	inx
	inx
	inx
	inx
	jmp check_bullet_player_collisions_outer_loop

check_bullet_player_collisions_done:
	rts

;--------------------------------------------------------------------------
; Function check_cactus_collisions
; No arguments and no return.
; Checks collisions with cactuses for both bullets and deals with the effects.
check_cactus_collisions:
	ldx #$0
check_cactus_collisions_outer_loop:		; loop over the two bullets which are at positions bullets and bullets + 5 in memory.
	cpx #10
	beq check_cactus_collisions_done

	lda bullets + 4, X 		; Bullet cooldown.
	cmp #0
	bne check_cactus_collisions_on_cooldown	; If is on cooldown, don't collide with another cactus

	ldy #$0
check_cactus_collisions_inner_loop:		; Loop over the eight cactuses in positions cactuses, cactuses + 8, ... cactuses + 56 in memory.
	cpy #64
	beq check_cactus_collisions_outer_loop_ok

	lda cactuses + 0, Y		; Cactus y_min
	sec
	sbc #1					; TODO: check if is not #1
	cmp bullets + 1, X		; Compare with bullet y.
	bcs	check_cactus_collisions_inner_loop_ok	; y_min - 1 >= bullet_y, so no collision

	lda cactuses + 0, Y		; Cactus y_min
	clc
	adc #15					; Cactus y_max now. TODO: check if is not #7
	cmp bullets + 1, X		; Compare with bullet y.
	bcc	check_cactus_collisions_inner_loop_ok	; y_max < bullet_y, so no collision
	
	lda cactuses + 3, Y		; Cactus x_min
	sec
	sbc #1					;TODO: check if is not #1
	cmp bullets + 0, X		; Compare with bullet x.
	bcs	check_cactus_collisions_inner_loop_ok	; x_min - 1 >= bullet_x, so no collision

	lda cactuses + 3, Y		; Cactus x_min
	clc
	adc #7					; Cactus x_max now. TODO: check if is not #7
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

	lda #CACTUS_COOLDOWN_AMOUNT
	sta bullets + 4, X	; Bullet is now on cooldown for cactus collisions.

check_cactus_collisions_inner_loop_ok:
	tya
	clc
	adc #8
	tay
	jmp check_cactus_collisions_inner_loop

	jmp check_cactus_collisions_outer_loop_ok
check_cactus_collisions_on_cooldown:
	dec bullets + 4, X 		; Decrement bullet cooldown.

check_cactus_collisions_outer_loop_ok:
	inx
	inx
	inx
	inx
	inx
	jmp check_cactus_collisions_outer_loop

check_cactus_collisions_done:
	rts

;--------------------------------------------------------------------------
; Function update_frame_counter.
; Increments the frame counter by one.
update_frame_counter:
	lda frame_counter
	clc
	adc #1
	sta frame_counter

	rts
;--------------------------------------------------------------------------
; Function move_bullet.
; Register X must contain the bullet index (0 or 1).
; This method moves the bullet (if currently on-screen) according to its direction and slowed fields.
; This only updates the bullet variables (not the sprite data).
move_bullet:
	txa					; X = 5*X to get correct pointer increment. 
	sta tmp_var
	asl A
	asl A
	clc
	adc tmp_var
	tax					; The two bullets are at positions bullets and bullets + 5 in memory.

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

;--------------------------------------------------------------------------
; Function update_sprites.
; Gets data from variables and updates the sprites needed.
update_sprites:
	lda bullet1_y
	sec
	sbc #4
	sta sprite_bullet1 + 0
	lda bullet1_x
	sec
	sbc #4
	sta sprite_bullet1 + 3

	lda bullet2_y
	sec
	sbc #4
	sta sprite_bullet2 + 0
	lda bullet2_x
	sec
	sbc #4
	sta sprite_bullet2 + 3

	ldx #$0

	rts
	
;----------------------------------------------------------------------------
; Draw Score Functions

; It draws the tiles before the score
; Only other "Draw Score" Functions are supposed to call it
draw_before_score:
	lda $2002
	lda #$20
	sta $2006
	lda #$20
	sta $2006          

	clc
	lda #$29
	ldx #0

draw_before_score_loop
	sta $2007          
	inx
	cpx #$0B
	bne draw_before_score_loop
    rts

; It draws the score according to the values of p1_score and p2_score
; p1 and p2 is supposed to be between 0 and 8
draw_score:
	jsr draw_before_score

	lda #$24
	sta $2007
	sta $2007
	sta $2007
	lda p1_score      ; last digit
	sta $2007
	lda #$24
	sta $2007
	sta $2007
	lda p2_score
	sta $2007
	lda #$24
	sta $2007
	sta $2007
	sta $2007


draw_score_end:
	rts 
 
; Display a winner's message
; It is necessary to set the variable winner to either 1 or 2
draw_winner:
	
	jsr draw_before_score

	lda #$24
	sta $2007
	sta $2007
	lda winner
	sta $2007
	lda #$24
	sta $2007
	lda #$20
	sta $2007
	lda #$12
	sta $2007
	lda #$17
	sta $2007
	lda #$1C
	sta $2007
	lda #$24
	sta $2007
	sta $2007

	lda #$00
	sta p1_score
	sta p2_score
	
	rts

;################################################################
; static data
;################################################################

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

;################################################################
; interrupt vectors
;################################################################

	.org $fffa

	.dw NMI
	.dw reset
	.dw 0 ; IRQ not used.

;################################################################
; CHR-ROM bank
;################################################################

	.incbin "sprite_sheet.chr"   ;includes 8KB graphics file from SMB1
