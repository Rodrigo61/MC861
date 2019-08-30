
palette:
	.db $37,$2C,$26,$05,  $37,$37,$10,$00,  $37,$37,$37,$37,  $37,$37,$37,$18   ; Background palette
	.db $37,$16,$27,$1B,  $37,$16,$27,$11,  $37,$19,$10,$00,  $37,$16,$26,$06   ; Sprite palette

sprites:
	; vert tile attr horiz
	; Bullets' sprites. Both x and y positions should change during the game
	; Bullet 1
	.db OFFSCREEN, $03, $42, OFFSCREEN   
	; Bullet 2
	.db OFFSCREEN, $03, $42, OFFSCREEN   


	; Players' sprites. Only vertical byte should change during the game
	; Player 1
	.db OFFSCREEN, $04, $00, PLAYER1_X   
	.db OFFSCREEN, $05, $00, PLAYER1_X + 8   
	.db OFFSCREEN, $14, $00, PLAYER1_X
	.db OFFSCREEN, $15, $00, PLAYER1_X + 8
	.db OFFSCREEN, $24, $00, PLAYER1_X
	.db OFFSCREEN, $25, $00, PLAYER1_X + 8
	; Player 2
	.db OFFSCREEN, $04, $41, PLAYER2_X + 8   
	.db OFFSCREEN, $05, $41, PLAYER2_X
	.db OFFSCREEN, $14, $41, PLAYER2_X + 8
	.db OFFSCREEN, $15, $41, PLAYER2_X
	.db OFFSCREEN, $24, $41, PLAYER2_X + 8
	.db OFFSCREEN, $25, $41, PLAYER2_X

	; Cactus' sprites. Both x and y positions should change during the game
	; Cactus 1
	.db OFFSCREEN, $00, $42, OFFSCREEN
	.db OFFSCREEN, $10, $42, OFFSCREEN
	; Cactus 2
	.db OFFSCREEN, $02, $40, OFFSCREEN   
	.db OFFSCREEN, $12, $40, OFFSCREEN   
	; Cactus 3
	.db OFFSCREEN, $00, $42, OFFSCREEN   
	.db OFFSCREEN, $10, $42, OFFSCREEN
	; Cactus 4
	.db OFFSCREEN, $02, $40, OFFSCREEN   
	.db OFFSCREEN, $12, $40, OFFSCREEN
	; Cactus 5
	.db OFFSCREEN, $00, $42, OFFSCREEN   
	.db OFFSCREEN, $10, $42, OFFSCREEN
	; Cactus 6
	.db OFFSCREEN, $02, $40, OFFSCREEN   
	.db OFFSCREEN, $12, $40, OFFSCREEN
	; Cactus 7
	.db OFFSCREEN, $00, $42, OFFSCREEN   
	.db OFFSCREEN, $10, $42, OFFSCREEN
	; Cactus 8
	.db OFFSCREEN, $02, $40, OFFSCREEN   
	.db OFFSCREEN, $12, $40, OFFSCREEN


	; Barrels' sprites. Both x and y positions should change during the game
	; Barrel 1
	.db OFFSCREEN, $01, $43, OFFSCREEN   
	.db OFFSCREEN, $11, $43, OFFSCREEN
	; Barrel 2
	.db OFFSCREEN, $01, $43, OFFSCREEN   
	.db OFFSCREEN, $11, $43, OFFSCREEN
	; Barrel 3
	.db OFFSCREEN, $01, $43, OFFSCREEN   
	.db OFFSCREEN, $11, $43, OFFSCREEN   
	; Barrel 4
	.db OFFSCREEN, $01, $43, OFFSCREEN   
	.db OFFSCREEN, $11, $43, OFFSCREEN   
	; Barrel 5
	.db OFFSCREEN, $01, $43, OFFSCREEN   
	.db OFFSCREEN, $11, $43, OFFSCREEN   
	; Barrel 6
	.db OFFSCREEN, $01, $43, OFFSCREEN   
	.db OFFSCREEN, $11, $43, OFFSCREEN   
	; Barrel 7
	.db OFFSCREEN, $01, $43, OFFSCREEN   
	.db OFFSCREEN, $11, $43, OFFSCREEN
	; Barrel 8
	.db OFFSCREEN, $01, $43, OFFSCREEN   
	.db OFFSCREEN, $11, $43, OFFSCREEN

	.align $100
background:

	; row 1: not shown.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25 
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

	; row 2: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

	; row 3: houses top.
	i=$30
	.rept 16
		.db i
		i=i+1
	.endr
	i=$30
	.rept 16
		.db i
		i=i+1
	.endr

	; row 4: houses middle.
	i=$40
	.rept 16
		.db i
		i=i+1
	.endr
	i=$40
	.rept 16
		.db i
		i=i+1
	.endr

	; row 5: houses bottom.
	i=$50
	.rept 16
		.db i
		i=i+1
	.endr
	i=$50
	.rept 16
		.db i
		i=i+1
	.endr

	; row 6: sidewalk.
	.db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  
	.db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  

	; row 7: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 8: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 9: backdrop only.
	.db $25,$F1,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 10: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 11: backdrop only (with grass).
	.db $25,$25,$F1,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 12: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 13: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$F1,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 14: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 15: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 16: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$F1,$25,$25,$25,$25  

	; row 17: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 18: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 19: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 20: backdrop only.
	.db $25,$F1,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 21: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 22: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$F1,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 23: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 24: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$F1,$25,$25  

	; row 25: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$F1,$25,$25,$25,$25,$25,$25  

	; row 26: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 27: backdrop only.
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  
	.db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  

	; row 28: rocks.
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  

	; row 29: rocks.
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  

	; row 30 rocks.
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  


attributes:  ;8 x 8 = 64 bytes
	.db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.db %11110000, %11110000, %11110000, %11110000, %11110000, %11110000, %11110000, %11110000
	.db %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
	.db %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
	.db %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
	.db %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
	.db %01011111, %01011111, %01011111, %01011111, %01011111, %01011111, %01011111, %01011111
	.db %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
