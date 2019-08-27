;----------------------------------------------------------------
; constants
;----------------------------------------------------------------

PRG_COUNT = 1 ;1 = 16KB, 2 = 32KB
MIRRORING = %0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

staTETITLE     = $00  ; displaying title screen
staTEPLAYING   = $01  ; move paddles/ball, check for collisions
staTEGAMEOVER  = $02  ; displaying game over screen
  
RIGHTWALL      = $F4  ; when ball reaches one of these, do something
TOPWALL        = $20
BOTTOMWALL     = $E0
LEFTWALL       = $04
  
PADDLE1X       = $08  ; horizontal position for paddles, doesnt move
PADDLE2X       = $F0




;----------------------------------------------------------------
; variables
;----------------------------------------------------------------

   .enum $0000

   ;NOTE: declare variables using the DSB and DSW directives, like this:

  
gamestate     .dsb 1  ; .dsb 1 means reserve one byte of space
ballx         .dsb 1  ; ball horizontal position
bally         .dsb 1  ; ball vertical position
ballup        .dsb 1  ; 1 = ball moving up
balldown      .dsb 1  ; 1 = ball moving down
ballleft      .dsb 1  ; 1 = ball moving left
ballright     .dsb 1  ; 1 = ball moving right
ballspeedx    .dsb 1  ; ball horizontal speed per frame
ballspeedy    .dsb 1  ; ball vertical speed per frame
paddle1ytop   .dsb 1  ; player 1 paddle top vertical position
paddle2ybot   .dsb 1  ; player 2 paddle bottom vertical position
buttons1      .dsb 1  ; player 1 gamepad buttons, one bit per button
buttons2      .dsb 1  ; player 2 gamepad buttons, one bit per button
scoreOnes     .dsb 1  ; byte for each digit in the decimal score
scoreTens     .dsb 1
scoreHundreds .dsb 1

winner .dsb 1
p1_score .dsb 1
p2_score .dsb 1
end_score .dsb 1

   .ende

   ;NOTE: you can also split the variable declarations into individual pages, like this:

   ;.enum $0100
   ;.ende

   ;.enum $0200
   ;.ende

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

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  bit $2002
  bpl vblankwait1

clrmem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0200, x
  inx
  bne clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  bit $2002
  bpl vblankwait2


LoadPalettes:
  lda $2002             ; read PPU status to reset the high/low latch
  lda #$3F
  sta $2006             ; write the high byte of $3F00 address
  lda #$00
  sta $2006             ; write the low byte of $3F00 address
  ldx #$00              ; start out at 0
LoadPalettesLoop:
  lda palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  sta $2007             ; write to PPU
  inx                   ; X = X + 1
  cpx #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  bne LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down


  


;;;Set some initial ball stats
  lda #$01
  sta balldown
  sta ballright
  lda #$00
  sta ballup
  sta ballleft
  
  lda #$50
  sta bally
  
  lda #$80
  sta ballx
  
  lda #$02
  sta ballspeedx
  sta ballspeedy


;;;Set initial score value
  lda #$00
  sta scoreOnes
  sta scoreTens
  sta scoreHundreds
  sta winner
  sta p1_score
  sta p2_score
  sta end_score


;;:Set starting game state
  lda #staTEPLAYING
  sta gamestate


              
  lda #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  sta $2000

  lda #%00011110   ; enable sprites, enable background, no clipping on left side
  sta $2001

Forever:
  jmp Forever     ;jump back to Forever, infinite loop, waiting for NMI
  
 

NMI:
  lda #$00
  sta $2003       ; set the low byte (00) of the RAM address
  lda #$02
  sta $4014       ; set the high byte (02) of the RAM address, start the transfer

  lda end_score
  cmp #$00
  bne keep_winner
  jsr draw_score
keep_winner:

  ;;This is the PPU clean up section, so rendering the next frame starts properly.
  lda #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  sta $2000
  lda #%00011110   ; enable sprites, enable background, no clipping on left side
  sta $2001
  lda #$00        ;;tell the ppu there is no background scrolling
  sta $2005
  sta $2005
    
  ;;;all graphics updates done by here, run game engine


  jsr ReadController1  ;;get the current button data for player 1
  jsr ReadController2  ;;get the current button data for player 2
  
GameEngine:  
  lda gamestate
  cmp #staTETITLE
  beq EngineTitle    ;;game is displaying title screen
    
  lda gamestate
  cmp #staTEGAMEOVER
  beq EngineGameOver  ;;game is displaying ending screen
  
  lda gamestate
  cmp #staTEPLAYING
  beq EnginePlaying   ;;game is playing
GameEngineDone:  
  
  jsr UpdateSprites  ;;set ball/paddle sprites from positions

  rti             ; return from interrupt
 
 
 
 
;;;;;;;;
 
EngineTitle:
  ;;if start button pressed
  ;;  turn screen off
  ;;  load game screen
  ;;  set starting paddle/ball position
  ;;  go to Playing State
  ;;  turn screen on
  jmp GameEngineDone

;;;;;;;;; 
 
EngineGameOver:
  ;;if start button pressed
  ;;  turn screen off
  ;;  load title screen
  ;;  go to Title State
  ;;  turn screen on 
  jmp GameEngineDone
 
;;;;;;;;;;;
 
EnginePlaying:

MoveBallRight:
  lda ballright
  beq MoveBallRightDone   ;;if ballright=0, skip this section

  lda ballx
  clc
  adc ballspeedx        ;;ballx position = ballx + ballspeedx
  sta ballx

  lda ballx
  cmp #RIGHTWALL
  bcc MoveBallRightDone      ;;if ball x < right wall, still on screen, skip next section
  lda #$00
  sta ballright
  lda #$01
  sta ballleft         ;;bounce, ball now moving left
  ;;in real game, give point to player 1, reset ball
  jsr IncrementScore
MoveBallRightDone:


MoveBallLeft:
  lda ballleft
  beq MoveBallLeftDone   ;;if ballleft=0, skip this section

  lda ballx
  sec
  sbc ballspeedx        ;;ballx position = ballx - ballspeedx
  sta ballx

  lda ballx
  cmp #LEFTWALL
  bcs MoveBallLeftDone      ;;if ball x > left wall, still on screen, skip next section
  lda #$01
  sta ballright
  lda #$00
  sta ballleft         ;;bounce, ball now moving right
  ;;in real game, give point to player 2, reset ball
  jsr IncrementScore
MoveBallLeftDone:


MoveBallUp:
  lda ballup
  beq MoveBallUpDone   ;;if ballup=0, skip this section

  lda bally
  sec
  sbc ballspeedy        ;;bally position = bally - ballspeedy
  sta bally

  lda bally
  cmp #TOPWALL
  bcs MoveBallUpDone      ;;if ball y > top wall, still on screen, skip next section
  lda #$01
  sta balldown
  lda #$00
  sta ballup         ;;bounce, ball now moving down
MoveBallUpDone:


MoveBallDown:
  lda balldown
  beq MoveBallDownDone   ;;if ballup=0, skip this section

  lda bally
  clc
  adc ballspeedy        ;;bally position = bally + ballspeedy
  sta bally

  lda bally
  cmp #BOTTOMWALL
  bcc MoveBallDownDone      ;;if ball y < bottom wall, still on screen, skip next section
  lda #$00
  sta balldown
  lda #$01
  sta ballup         ;;bounce, ball now moving down
MoveBallDownDone:

MovePaddleUp:
  ;;if up button pressed
  ;;  if paddle top > top wall
  ;;    move paddle top and bottom up
MovePaddleUpDone:

MovePaddleDown:
  ;;if down button pressed
  ;;  if paddle bottom < bottom wall
  ;;    move paddle top and bottom down
MovePaddleDownDone:
  
CheckPaddleCollision:
  ;;if ball x < paddle1x
  ;;  if ball y > paddle y top
  ;;    if ball y < paddle y bottom
  ;;      bounce, ball now moving left
CheckPaddleCollisionDone:

  jmp GameEngineDone
 
 
 
 
UpdateSprites:
  lda bally  ;;update all ball sprite info
  sta $0200
  
  lda #$30
  sta $0201
  
  lda #$00
  sta $0202
  
  lda ballx
  sta $0203
  
  ;;update paddle sprites
  rts
 
 
;draw_score:
;  lda $2002
;  lda #$20
;  sta $2006
;  lda #$20
;  sta $2006          ; start drawing the score at PPU $2020
;  
;;  lda scoreHundreds  ; get first digit
;;  clc
;;  adc #$30           ; add ascii offset  (this is UNUSED because the tiles for digits start at 0)
;  lda #0
;  sta $2007          ; draw to background
;;  lda scoreTens      ; next digit
;;  clc
;;  adc #$30           ; add ascii offset
;  ;lda #0
;  sta $2007
;  lda scoreOnes      ; last digit
;;  clc
;;  adc #$30           ; add ascii offset
;  sta $2007
;  lda #0
;  sta $2007
;  sta $2007
;  lda scoreOnes
;  sta $2007
;  rts

draw_score:
	lda $2002
	lda #$20
	sta $2006
	lda #$20
	sta $2006          ; start drawing the score at PPU $2020

	clc
	lda #$0
	ldx #0
draw_score_loop:
	sta $2007          ; draw to background
	inx
	cpx #$0B
	bne draw_score_loop

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

	lda p1_score
	cmp #$8
	bne draw_score_end
	jsr draw_winner

draw_score_end:
	rts 
 
draw_winner:
	lda $2002
	lda #$20
	sta $2006
	lda #$20
	sta $2006          ; start drawing the score at PPU $2020
	
	clc
	lda #$0
	ldx #0
draw_winner_loop:
	sta $2007          ; draw to background
	inx
	cpx #$0B
	bne draw_winner_loop

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

	lda #$01
	sta end_score
	rts
 

IncrementScore:
IncOnes:
  lda p1_score      ; load the lowest digit of the number
  clc 
  adc #$01           ; add one
  sta p1_score
  cmp #$05           ; check if it overflowed, now equals 10
  bne winner_verify        ; if there was no overflow, all done
IncHundreds:
  lda p2_score
  clc
  adc #$01
  sta p2_score      ; wrap digit to 0
winner_verify:
  lda p1_score
  cmp #$08
  bne IncDone
  lda end_score
  cmp #$01
  bne winner_is_off
  lda #$00
  sta end_score
  lda #$00
  sta p1_score
  sta p2_score
  sta winner
  jmp IncDone
winner_is_off:
  lda #$01
  sta winner
  jmp draw_winner
IncDone:

 
ReadController1:
  lda #$01
  sta $4016
  lda #$00
  sta $4016
  ldx #$08
ReadController1Loop:
  lda $4016
  lsr A            ; bit0 -> Carry
  rol buttons1     ; bit0 <- Carry
  dex
  bne ReadController1Loop
  rts
  
ReadController2:
  lda #$01
  sta $4016
  lda #$00
  sta $4016
  ldx #$08
ReadController2Loop:
  lda $4017
  lsr A            ; bit0 -> Carry
  rol buttons2     ; bit0 <- Carry
  dex
  bne ReadController2Loop
  rts  


  .org $E000
palette:
  .db $22,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;background palette
  .db $22,$1C,$15,$14,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C   ;;sprite palette

sprites:
     ;vert tile attr horiz
  .db $80, $32, $00, $80   ;sprite 0
  .db $80, $33, $00, $88   ;sprite 1
  .db $88, $34, $00, $80   ;sprite 2
  .db $88, $35, $00, $88   ;sprite 3
;----------------------------------------------------------------
; interrupt vectors
;----------------------------------------------------------------

   .org $fffa

   .dw NMI
   .dw reset
   .dw 0


;----------------------------------------------------------------
; CHR-ROM bank
;----------------------------------------------------------------

   .incbin "mario.chr"
   
