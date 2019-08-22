Code:
;################################################################
; Constants
;################################################################

PRG_COUNT = 1 ;1 = 16KB, 2 = 32KB
MIRRORING = %0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

; Wall's limits
RIGHTWALL      = $F4    
TOPWALL        = $20    
BOTTOMWALL     = $E0    
LEFTWALL       = $04    
  
; Players constant X position
P1_X           = $08    
P2_X           = $F0    

; Used to define sprite current direction 
UP_DIRECTION = 0
DOWN_DIRECTION = 1

; Sprite memory area in CPU to DMA usage
SPRITE_AREA  = $0200    

; Begin of Player's sprites in memory
P1_SPRITE  = $0200              
P2_SPRITE  = P1_SPRITE + 16

; Cooldown for gamepad reading
READ_BUTTON_COOLDOWN = $18    ; empirical choice

SPRITES_COUNT = $20 ; just have 8 sprites for now
PALETTE_COUNT = $20 ; 2 palettes of 16 bytes

; Gamepad buttons bits
BUTTON_A = %10000000
BUTTON_B = %01000000
BUTTON_SELECT = %00100000
BUTTON_START = %00010000
BUTTON_UP = %00001000
BUTTON_DOWN = %00000100
BUTTON_LEFT = %00000010
BUTTON_RIGHT = %00000001

;################################################################
; Variables
;################################################################

  .enum $0000

  ; Shots' (x,y) positions
  shot1_x      .dsb 1  
  shot1_y      .dsb 1  
  shot2_x      .dsb 1  
  shot2_y      .dsb 1  
  
  ; Shot speed in both axes
  shot_speed .dsb 1

  ; Gamepad buttons, one bit per button in the following order: A, B, Select, Start, Up, Down, Left, Right
  P1_buttons   .dsb 1  
  P2_buttons   .dsb 1
  aux_buttons  .dsb 1

  ; Current reading cooldown of gamepad buttons
  P1_buttons_cooldown .dsb 1
  P2_buttons_cooldown .dsb 1

  ; Players current y position for the TOP and BOTTOM tiles (diff of 1)
  P1_top_y            .dsb 1
  P1_bottom_y         .dsb 1
  P2_top_y            .dsb 1
  P2_bottom_y         .dsb 1

  ; Players current direction
  P1_direction .dsb 1
  P2_direction .dsb 1
  
  ; Pointers used in Indirect Indexed mode
  pointer_lo  .dsb 1  
  pointer_hi  .dsb 1
   
  .ende
;################################################################
; iNES header
;################################################################

   .db "NES", $1a ;identification of the iNES header
   .db PRG_COUNT ;number of 16KB PRG-ROM pages
   .db $01 ;number of 8KB CHR-ROM pages
   .db $00|MIRRORING ;mapper 0 and mirroring
   .dsb 9, $00 ;clear the remaining bytes

;################################################################
; program bank(s)
;################################################################

   .base $10000-(PRG_COUNT*$4000)

;--------------------------------------------------------------------------
; Include Graphic constants
.include "graphics_constants.asm"

;--------------------------------------------------------------------------
; Function to call all other update functions related to the game state
update_game_state:  
  JSR P1_controller_handler
  JSR P2_controller_handler
  JSR update_P1_direction_by_wall_collision
  JSR update_P2_direction_by_wall_collision
  JSR update_P1_direction_by_wall_collision
  JSR update_P2_direction_by_wall_collision
  JSR update_P1_positions
  JSR update_P2_positions
  JSR update_players_sprites
  RTS

;--------------------------------------------------------------------------
update_P1_direction_by_wall_collision:
  ; Check for direction and y position
  LDA P1_bottom_y
  CMP #BOTTOMWALL
  BNE check_top_wall_collision_P1
  LDA P1_direction
  CMP #DOWN_DIRECTION
  BNE check_top_wall_collision_P1
  
  ; direction == DOWN && Y == BOTTOM -> Had a bottom collision 
  ; have to reverse direction
  LDA #UP_DIRECTION               
  STA P1_direction
  JMP end_update_P1_direction_by_wall_collision

check_top_wall_collision_P1: 
  ; Check for direction and y position
  LDA P1_top_y
  CMP #TOPWALL
  BNE end_update_P1_direction_by_wall_collision
  LDA P1_direction
  CMP #UP_DIRECTION
  BNE end_update_P1_direction_by_wall_collision
  
  ; direction == UP && Y == TOP -> Had a top collision 
  ; have to reverse direction
  LDA #DOWN_DIRECTION           
  STA P1_direction

end_update_P1_direction_by_wall_collision:
  RTS

;--------------------------------------------------------------------------
update_P2_direction_by_wall_collision:

  ; Check for direction and y position
  LDA P2_bottom_y
  CMP #BOTTOMWALL
  BNE check_top_wall_collision_P2
  LDA P2_direction
  CMP #DOWN_DIRECTION
  BNE check_top_wall_collision_P2

  ; direction == DOWN && Y == BOTTOM -> Had a bottom collision 
  ; have to reverse direction
  LDA #UP_DIRECTION          
  STA P2_direction
  JMP end_update_P2_direction_by_wall_collision

check_top_wall_collision_P2:
  ; Check for direction and y position
  LDA P2_top_y
  CMP #TOPWALL
  BNE end_update_P2_direction_by_wall_collision
  LDA P2_direction
  CMP #UP_DIRECTION
  BNE end_update_P2_direction_by_wall_collision

  ; direction == UP && Y == TOP -> Had a top collision 
  ; have to reverse direction
  LDA #DOWN_DIRECTION         
  STA P2_direction

end_update_P2_direction_by_wall_collision:
  RTS

;--------------------------------------------------------------------------
update_P1_positions:
  LDA P1_direction
  CMP #UP_DIRECTION
  BEQ P1_move_up_direction

  ; direction == DOWN_DIRECTION -> have move down
  INC P1_top_y
  INC P1_bottom_y
  JMP end_update_P1_positions

  ; direction == UP_DIRECTION -> so have move up
P1_move_up_direction:
  DEC P1_top_y
  DEC P1_bottom_y

end_update_P1_positions:
  RTS

;--------------------------------------------------------------------------
update_P2_positions:
  LDA P2_direction
  CMP #UP_DIRECTION
  BEQ P2_move_up_direction

  ; direction == DOWN_DIRECTION -> have move down
  INC P2_top_y
  INC P2_bottom_y
  JMP end_update_P2_positions

  ; direction == UP_DIRECTION -> so have move up
P2_move_up_direction:
  DEC P2_top_y
  DEC P2_bottom_y

end_update_P2_positions:
  RTS

;--------------------------------------------------------------------------
; This function copies the current players' positions into the position's bytes
; in their sprites
update_players_sprites:
  
  ; Update P1 sprite
  LDA P1_top_y
  STA P1_SPRITE
  STA P1_SPRITE + 4
  LDA P1_bottom_y
  STA P1_SPRITE + 8
  STA P1_SPRITE + 12

  ; Update P2 sprite
  LDA P2_top_y
  STA P2_SPRITE
  STA P2_SPRITE + 4
  LDA P2_bottom_y
  STA P2_SPRITE + 8
  STA P2_SPRITE + 12
 
  RTS
  
;--------------------------------------------------------------------------
; This function reads the P1 controller, but it uses an aux variable to read.
; The value of this aux variable is only copied to P1_buttons variable when
; the player actually pressed a button and the cooldown time has finished.
; This aux variable strategy avoids entering in the cooldown time even without 
; pressing a button.
; The cooldown time is required because the frame rate is too quickly
read_P1_controller:
  ; Serial buttons reading 
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
read_P1_controller_loop:
  LDA $4016           ; 4016 is correct port for P2
  LSR A               ; bit0 -> Carry
  ROL aux_buttons     ; bit0 <- Carry
  DEX
  BNE read_P1_controller_loop

  ; Check if some button was clicked, i.e. some bit have to be 1
  LDA aux_buttons
  CMP #0
  BEQ P1_button_cooldown_update

  ; Check if cooldown time has finished
  LDA P1_buttons_cooldown
  CMP #0
  BEQ apply_reading_P1

  ; None button was clicked or cooldown time hasn't finished
  ; we just ignore the reading
  JMP P1_button_cooldown_update

apply_reading_P1:
  ; Reset cooldown
  LDA #READ_BUTTON_COOLDOWN
  STA P1_buttons_cooldown
  ; Transfer aux variable
  LDA aux_buttons
  STA P1_buttons

P1_button_cooldown_update:
  ; if cooldown > 0, decrement it
  ; else finish the function
  LDA P1_buttons_cooldown
  CMP #0
  BEQ read_P1_controller_end
  DEC P1_buttons_cooldown

read_P1_controller_end:
  RTS

;--------------------------------------------------------------------------
; Same function as 'read_P1_controller', but for Player 2
read_P2_controller:
  ; Serial buttons reading 
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
read_P2_controller_loop:
  LDA $4017           ; 4017 is correct port for P2
  LSR A               ; bit0 -> Carry
  ROL aux_buttons     ; bit0 <- Carry
  DEX
  BNE read_P2_controller_loop

  ; Check if some button was clicked, i.e. some bit have to be 1
  LDA aux_buttons
  CMP #0
  BEQ P2_button_cooldown_update

  ; Check if cooldown time has finished
  LDA P2_buttons_cooldown
  CMP #0
  BEQ apply_reading_P2

  ; None button was clicked or cooldown time hasn't finished
  ; we just ignore the reading
  JMP P2_button_cooldown_update

apply_reading_P2:
  ; Reset cooldown
  LDA #READ_BUTTON_COOLDOWN
  STA P2_buttons_cooldown
  ; Transfer aux variable
  LDA aux_buttons
  STA P2_buttons

P2_button_cooldown_update:
  ; if cooldown > 0, decrement it
  ; else finish the function
  LDA P2_buttons_cooldown
  CMP #0
  BEQ read_P2_controller_end
  DEC P2_buttons_cooldown

read_P2_controller_end:
  RTS

;--------------------------------------------------------------------------
; This is the PPU clean up section, so rendering the next frame starts properly.
clean_PPU:
  LDA #%10010000   ; enable nmi, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
  RTS

;--------------------------------------------------------------------------
; This function starts the DMA transfer, which copies from $0200 to $0300 (256 bytes)
; from CPU to PPU's sprite memory
dma_transfer:
  LDA #$00
  STA $2003       ; (TARGET) dma will copy 256 bytes starting from address $00 of PPU's sprite memory
  LDA #$02
  STA $4014       ; (SOURCE) dma will copy the next 256 byte starting from addres $0200 of CPU's memory
  RTS

;--------------------------------------------------------------------------
; This function updates player 1 direction by reversing it if button A was pressed
P1_controller_handler:
  LDA P1_buttons
  CMP #BUTTON_A
  BNE end_P1_controller_handler

  ; Reverse Player direction
  LDA P1_direction
  CMP #UP_DIRECTION
  BEQ set_P1_direction_to_down

  ; direction == DOWN_DIRECTION, so direction = UP_DIRECTION
  LDA #UP_DIRECTION
  STA P1_direction
  JMP end_P1_controller_handler

set_P1_direction_to_down:
  ; direction == UP_DIRECTION, so direction = DOWN_DIRECTION
  LDA #DOWN_DIRECTION
  STA P1_direction
  
end_P1_controller_handler:
  LDA #0
  STA P1_buttons
  RTS

;--------------------------------------------------------------------------
; This function updates player 2 direction by reversing it if button A was pressed
P2_controller_handler:
  LDA P2_buttons
  CMP #BUTTON_A
  BNE end_P2_controller_handler

  ; Reverse Player direction
  LDA P2_direction
  CMP #UP_DIRECTION
  BEQ set_P2_direction_to_down

  ; direction == DOWN_DIRECTION, so direction = UP_DIRECTION
  LDA #UP_DIRECTION
  STA P2_direction
  JMP end_P2_controller_handler

set_P2_direction_to_down:
  ; direction == UP_DIRECTION, so direction = DOWN_DIRECTION
  LDA #DOWN_DIRECTION
  STA P2_direction
  
end_P2_controller_handler:
  LDA #0
  STA P2_buttons
  RTS
  
;################################################################
; RESET
;################################################################
reset:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable nmi
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2

  
  ; Copy hardcoded background graphics from graphics_constants.asm to the PPU memory
load_palettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
load_palettes_loop:
  LDA palette, x        
  STA $2007             
  INX                   
  CPX #PALETTE_COUNT     
  BNE load_palettes_loop 
                         

  ; Copy hardcoded background graphics from graphics_constants.asm to the PPU memory
load_background:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$20
  STA $2006             ; write the high byte of $2000 address
  LDA #$00
  STA $2006             ; write the low byte of $2000 address

  LDA #$00
  STA pointer_lo       ; put the low byte of the address of background into pointer
  LDA #>background
  STA pointer_hi       ; put the high byte of the address into pointer
  
  LDX #$00             ; start at pointer + 0
  LDY #$00
load_background_outside_loop:
load_background_inside_loop:
  LDA (pointer_lo), y  ; copy one background byte from address in pointer plus Y
  STA $2007            ; this runs 256 * 4 times
  
  INY                  ; inside loop counter
  CPY #$00
  BNE load_background_inside_loop      ; run the inside loop 256 times before continuing down
  
  INC pointer_hi       ; low byte went 0 to 256, so high byte needs to be changed now
 
  INX
  CPX #$04
  BNE load_background_outside_loop     ; run the outside loop 256 times before continuing down


  ; Copy hardcoded sprites graphics from graphics_constants.asm to the DMA area
load_sprites:
  LDX #$00              
load_sprites_loop:
  LDA sprites, x        
  STA SPRITE_AREA, x    
  INX                   
  CPX #SPRITES_COUNT 
  BNE load_sprites_loop   

;--------------------------------------------------------------------------
; Setting players' initial states 

  ; Initial direction
  LDA #DOWN_DIRECTION
  STA P1_direction
  LDA #UP_DIRECTION
  STA P2_direction
  
  ; Initial position
  LDA #80
  STA P1_top_y
  STA P2_top_y
  LDA #88
  STA P1_bottom_y
  STA P2_bottom_y

;--------------------------------------------------------------------------
; Set some configuration flags to CPU
  LDA #%10010000   ; enable nmi, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001

;--------------------------------------------------------------------------
Forever:
  JMP Forever     ; jump back to Forever, infinite loop, waiting for nmi

;################################################################
; nmi
;################################################################
nmi:
  JSR dma_transfer
  JSR clean_PPU

  ; Game loop
  JSR read_P1_controller  
  JSR read_P2_controller
  JSR update_game_state

  RTI     

;################################################################
; IRQ
;################################################################
IRQ:
;################################################################
; interrupt vectors
;################################################################

   .org $fffa
   .dw nmi
   .dw reset
   .dw IRQ

;################################################################
; CHR-ROM bank
;################################################################

   .incbin "mario.chr"   ;includes 8KB graphics file from SMB1