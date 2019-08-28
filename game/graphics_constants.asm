palette:
  .db $22,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;background palette
  .db $22,$16,$27,$1B,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C   ;;sprite palette

sprites:
  ;vert tile attr horiz
  ; Bullets' sprites. Both x and y positions should change during the game
  ; Bullet 1
  .db OFFSCREEN, $03, $40, OFFSCREEN   
  ; Bullet 2
  .db OFFSCREEN, $03, $40, OFFSCREEN   


  ; Players' sprites. Only vertical byte should change during the game
  ; Player 1
  .db OFFSCREEN, $04, $00, $00   
  .db OFFSCREEN, $05, $00, $08   
  .db OFFSCREEN, $14, $00, $00   
  .db OFFSCREEN, $15, $00, $08   
  .db OFFSCREEN, $24, $00, $00   
  .db OFFSCREEN, $25, $00, $08   
  ; Player 2
  .db OFFSCREEN, $04, $40, $F8   
  .db OFFSCREEN, $05, $40, $F0   
  .db OFFSCREEN, $14, $40, $F8   
  .db OFFSCREEN, $15, $40, $F0
  .db OFFSCREEN, $24, $40, $F8   
  .db OFFSCREEN, $25, $40, $F0     

  ; Cactus' sprites. Both x and y positions should change during the game
  ; Cactus 1
  .db OFFSCREEN, $00, $40, OFFSCREEN
  .db OFFSCREEN, $10, $40, OFFSCREEN
  ; Cactus 2
  .db OFFSCREEN, $02, $40, OFFSCREEN   
  .db OFFSCREEN, $12, $40, OFFSCREEN   
  ; Cactus 3
  .db OFFSCREEN, $00, $40, OFFSCREEN   
  .db OFFSCREEN, $10, $40, OFFSCREEN
  ; Cactus 4
  .db OFFSCREEN, $02, $40, OFFSCREEN   
  .db OFFSCREEN, $12, $40, OFFSCREEN
  ; Cactus 5
  .db OFFSCREEN, $00, $40, OFFSCREEN   
  .db OFFSCREEN, $10, $40, OFFSCREEN
  ; Cactus 6
  .db OFFSCREEN, $02, $40, OFFSCREEN   
  .db OFFSCREEN, $12, $40, OFFSCREEN
  ; Cactus 7
  .db OFFSCREEN, $00, $40, OFFSCREEN   
  .db OFFSCREEN, $10, $40, OFFSCREEN
  ; Cactus 8
  .db OFFSCREEN, $02, $40, OFFSCREEN   
  .db OFFSCREEN, $12, $40, OFFSCREEN


  ; Barrels' sprites. Both x and y positions should change during the game
  ; Barrel 1
  .db OFFSCREEN, $01, $40, OFFSCREEN   
  .db OFFSCREEN, $11, $40, OFFSCREEN
  ; Barrel 2
  .db OFFSCREEN, $01, $40, OFFSCREEN   
  .db OFFSCREEN, $11, $40, OFFSCREEN
  ; Barrel 3
  .db OFFSCREEN, $01, $40, OFFSCREEN   
  .db OFFSCREEN, $11, $40, OFFSCREEN   
  ; Barrel 4
  .db OFFSCREEN, $01, $40, OFFSCREEN   
  .db OFFSCREEN, $11, $40, OFFSCREEN   
  ; Barrel 5
  .db OFFSCREEN, $01, $40, OFFSCREEN   
  .db OFFSCREEN, $11, $40, OFFSCREEN   
  ; Barrel 6
  .db OFFSCREEN, $01, $40, OFFSCREEN   
  .db OFFSCREEN, $11, $40, OFFSCREEN   
  ; Barrel 7
  .db OFFSCREEN, $01, $40, OFFSCREEN   
  .db OFFSCREEN, $11, $40, OFFSCREEN
  ; Barrel 8
  .db OFFSCREEN, $01, $40, OFFSCREEN   
  .db OFFSCREEN, $11, $40, OFFSCREEN

  .org $E100
background:
  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;row 1
  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;wall

  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$24,$24,$24,$00,$24  ;;row 1
  .db $24,$00,$24,$24,$24,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;wall

  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;row 1
  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;wall

  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;row 1
  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;wall

  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;row 1
  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;wall

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $26,$26,$26,$26,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$24,$26,$26,$26,$26  ;;all sky

  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;row 1
  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;wall

  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;row 1
  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;wall

  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;row 1
  .db $29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29  ;;wall


attributes:  ;8 x 8 = 64 bytes
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
