A1  = $00		
As1 = $01		
Bb1 = $01		
B1  = $02

C2  = $03
Cs2 = $04
Db2 = $04
D2  = $05
Ds2 = $06
Eb2 = $06
E2  = $07
F2  = $08
Fs2 = $09
Gb2 = $09
G2  = $0A
Gs2 = $0B
Ab2 = $0B
A2  = $0C
As2 = $0D
Bb2 = $0D
B2  = $0E

C3  = $0F
Cs3 = $10
Db3 = $10
D3  = $11
Ds3 = $12
Eb3 = $12
E3  = $13
F3  = $14
Fs3 = $15
Gb3 = $15
G3  = $16
Gs3 = $17
Ab3 = $17
A3  = $18
As3 = $19
Bb3 = $19
B3  = $1a

C4  = $1b
Cs4 = $1c
Db4 = $1c
D4  = $1d
Ds4 = $1e
Eb4 = $1e
E4  = $1f
F4  = $20
Fs4 = $21
Gb4 = $21
G4  = $22
Gs4 = $23
Ab4 = $23
A4  = $24
As4 = $25
Bb4 = $25
B4  = $26

C5  = $27
Cs5 = $28
Db5 = $28
D5  = $29
Ds5 = $2a
Eb5 = $2a
E5  = $2b
F5  = $2c
Fs5 = $2d
Gb5 = $2d
G5  = $2e
Gs5 = $2f
Ab5 = $2f
A5  = $30
As5 = $31
Bb5 = $31
B5  = $32

C6  = $33
Cs6 = $34
Db6 = $34
D6  = $35
Ds6 = $36
Eb6 = $36
E6  = $37
F6  = $38
Fs6 = $39
Gb6 = $39
G6  = $3a
Gs6 = $3b
Ab6 = $3b
A6  = $3c
As6 = $3d
Bb6 = $3d
B6  = $3e

C7  = $3f
Cs7 = $40
Db7 = $40
D7  = $41
Ds7 = $42
Eb7 = $42
E7  = $43
F7  = $44
Fs7 = $45
Gb7 = $45
G7  = $46
Gs7 = $47
Ab7 = $47
A7  = $48
As7 = $49
Bb7 = $49
B7  = $4a

C8  = $4b
Cs8 = $4c
Db8 = $4c
D8  = $4d
Ds8 = $4e
Eb8 = $4e
E8  = $4f
F8  = $50
Fs8 = $51
Gb8 = $51
G8  = $52
Gs8 = $53
Ab8 = $53
A8  = $54
As8 = $55
Bb8 = $55
B8  = $56

C9  = $57
Cs9 = $58
Db9 = $58
D9  = $59
Ds9 = $5a
Eb9 = $5a
E9  = $5b
F9  = $5c
Fs9 = $5d
Gb9 = $5d	

rest = $5e
thirtysecond = $80
sixteenth = $81
eighth = $82
quarter = $83
half = $84
whole = $85
d_sixteenth = $86
d_eighth = $87
d_quarter = $88
d_half = $89
d_whole = $8A  
t_quarter = $8B

;Tempo = (256/(3600/bpm)) * 8 

seventhreebpm = $28
onethirtybpm = $4A

SQUARE_1	= $00
SQUARE_2	= $01
TRIANGLE	= $02
NOISE		= $03

MUSIC_SQ1	= $00
MUSIC_SQ2	= $01
MUSIC_TRI	= $02
MUSIC_NOI	= $03
SFX_1		= $04
SFX_2		= $05

endsound 		   = $A0
coda			   = $A1
set_repeat_counter  = $A4
repeat			   = $A5
transpose 		   = $A8
adjust_note_offset = $A7

tone = $00			; C
dim_secon = $01		; Db
second = $02		; D
minor_third = $03	; Eb
third = $04			; E
fourth = $05		; F
dim_fifth = $06		; Gb
perf_fifth = $07	; G
minor_sixth = $08	; Ab
sixth = $09			; A
minor_seventh = $0A ; Bb
seventh = $0B		; B
octave = $0C9		; C


;------------------------------------------------------------------
; Song list
;------------------------------------------------------------------

SADCOWBOY = $00
DUELMUSIC = $01
BLURSONG2 = $02
SOUNDTRAC = $03
JUMPSOUND = $04
OOFSOUND1 = $05
OOFSOUND2 = $06
EXPLOSION = $07

sound_opcodes:
	.word	se_op_endsound	    	 ; $A0
	.word	se_op_infinite_loop 	 ; $A1
	.word	se_op_change_ve	    	 ; $A2
	.word	se_op_duty	    	 	 ; $A3
	.word	se_op_set_loop1_counter	 ; $A4
	.word	se_op_loop1		 		 ; $A5
	.word	se_op_set_note_offset	 ; $A6
	.word 	se_op_adjust_note_offset ; $A7
	.word	se_op_transpose		 	 ; $A8
	;; etc, 1 entry per subroutine

volume_envelope_constants:
	ve_staccato		= $00
	ve_fade_out		= $02
	ve_drum_decay 	= $09


note_table:
.word                                                                $07F1, $0780, $0713 ; A1-B1 ($00-$02)
.word $06AD, $064D, $05F3, $059D, $054D, $0500, $04B8, $0475, $0435, $03F8, $03BF, $0389 ; C2-B2 ($03-$0E)
.word $0356, $0326, $02F9, $02CE, $02A6, $027F, $025C, $023A, $021A, $01FB, $01DF, $01C4 ; C3-B3 ($0F-$1A)
.word $01AB, $0193, $017C, $0167, $0151, $013F, $012D, $011C, $010C, $00FD, $00EF, $00E2 ; C4-B4 ($1B-$26)
.word $00D2, $00C9, $00BD, $00B3, $00A9, $009F, $0096, $008E, $0086, $007E, $0077, $0070 ; C5-B5 ($27-$32)
.word $006A, $0064, $005E, $0059, $0054, $004F, $004B, $0046, $0042, $003F, $003B, $0038 ; C6-B6 ($33-$3E)
.word $0034, $0031, $002F, $002C, $0029, $0027, $0025, $0023, $0021, $001F, $001D, $001B ; C7-B7 ($3F-$4A)
.word $001A, $0018, $0017, $0015, $0014, $0013, $0012, $0011, $0010, $000F, $000E, $000D ; C8-B8 ($4B-$56)
.word $000C, $000C, $000B, $000A, $000A, $0009, $0008              

.word $0000			; Rest

note_length_table:
	.byte	$01		; 32nd note
	.byte	$02		; 16th note
	.byte	$04		; 8th note
	.byte	$08		; Quarter note
	.byte	$10		; Half note
	.byte	$20		; Whole note

	;; Dotted notes
	.byte	$03		; Dotted 16th note
	.byte	$06		; Dotted 8th note
	.byte	$0c		; Dotted quarter note
	.byte	$18		; Dotted half note
	.byte	$30		; Dotted whole note?

	;; Other
	;; Modified quarter to fit after d_sixteenth triplets
	.byte	$07
	.byte	$14		; 2 quarters plus an 8th
	.byte	$0a


; Function sound_init
; No arguments. 
; No return - just starts the sound engine variables and silences all channels
sound_init:
	;; Enable Square 1, Square 2, Triangle and Noise channels
	lda	#$0f
	sta	$4015

	lda	#$00
	sta	sound_disable_flag ; Clear disable flag
	;; Later, if we have other variables we want to initialize, we will do
	;; that here.

	;; Initializing these to $FF ensures that the first notes of these
	;; songs isnt skipped.
	lda	#$ff
	sta	sound_sq1_old
	sta	sound_sq2_old

; Function se_silence
; No arguments. 
; No return - silences all channels
se_silence:	
	lda	#$30
	sta	soft_apu_ports		; Set Square 1 volume to 0
	sta	soft_apu_ports+4 	; Set Square 2 volumne to 0
	sta	soft_apu_ports+12	; Set Noise volume to 0
	lda	#$80
	sta	soft_apu_ports+8 	; Silence Triangle
	
	rts

; Function sound_disable
; No arguments.
; No return - Disables all channels 
sound_disable:
	lda	#$00
	sta	$4015				; Disable all channels
	lda	#$01
	sta	sound_disable_flag 
	rts
; Function sound_load
; Takes a song number from register A
; No return - Plays the chosen song/sfx
sound_load:
	sta tmp_var
	tya
	pha
	txa
	pha

	lda tmp_var

	sta	sound_temp1			; Save song number
	asl	a					; Multiply by 2. Index into a table of pointers.
	tay
	lda	song_headers, y		; Setup the pointer to our song header
	sta	sound_ptr
	lda	song_headers+1, y
	sta	sound_ptr+1

	ldy	#$00
	lda	(sound_ptr), y		; Read the first byte: # streams
	;; Store in a temp variable. We will use this as a loop counter: how
	;; many streams to read stream headers for
	sta	sound_temp2
	iny
loop:
	lda	(sound_ptr), y		; Stream number
	tax						; Stream number acts as our variable index
	iny

	lda	(sound_ptr), y		; Status byte. 1=enable, 0=disable
	sta	stream_status, x
	;; If status byte is 0, stream disable, so we are done
	beq	next_stream
	iny

	lda	(sound_ptr), y		; Channel number
	sta	stream_channel, x
	iny

	lda	(sound_ptr), y		; Initial duty and volume settings
	sta	stream_vol_duty, x
	iny

	lda	(sound_ptr), y		; Initial envelope
	sta	stream_ve, x
	iny

	;; Pointer to stream data. Little endian, so low byte first
	lda	(sound_ptr), y
	sta	stream_ptr_lo, x
	iny

	lda	(sound_ptr), y
	sta	stream_ptr_hi, x
	iny

	lda	(sound_ptr), y
	sta	stream_tempo, x

	lda	#$ff
	sta	stream_ticker_total, x

	lda	#$01
	sta	stream_note_length_counter, x
	sta	stream_note_length, x

	lda	#$00
	sta	stream_ve_index, x
	sta	stream_loop1, x
	sta	stream_note_offset, x
next_stream:
	iny

	lda	sound_temp1				; Song number
	sta	stream_curr_sound, x

	dec	sound_temp2				; Our loop counter
	bne	loop
	
	pla
	tax
	pla
	tay

	rts

sound_play_frame:
	lda	sound_disable_flag
	bne	sound_play_frame_done	; If disable flag is set, dont' advance a frame

	;; Silence all channels. se_set_apu will set volume later for all
	;; channels that are enabled. The purpose of this subroutine call is
	;; to silence all channels that aren't used by any streams
	jsr	se_silence

	ldx	#$00
sound_play_frame_loop:
	lda	stream_status, x
	and	#$01						; Check whether the stream is active
	beq	sound_play_frame_endloop	; If the channel isn't active, skip it

	;; Add the tempo to the ticker total.  If there is an $FF -> 0
	;; transition, there is a tick
	lda	stream_ticker_total, x
	clc
	adc	stream_tempo, x
	sta	stream_ticker_total, x
	;; Carry clear = no tick. If no tick, we are done with this stream.
	bcc	set_buffer

	;; Else there is a tick. Decrement the note length counter
	dec	stream_note_length_counter, x
	;; If counter is non-zero, our note isn't finished playing yet
	bne	set_buffer
	;; Else our note is finished. Reload the note length counter
	lda	stream_note_length, x
	sta	stream_note_length_counter, x
	
	jsr	se_fetch_byte
set_buffer:
	;; Copy the current stream's sound data for the current from into our
	;; temporary APU vars (soft_apu_ports)
	jsr	se_set_temp_ports
sound_play_frame_endloop:
	inx
	cpx	#$06
	bne	sound_play_frame_loop
	;; Copy the temporary APU variables (soft_apu_ports) to the real
	;; APU ports ($4000, $4001, etc.)
	jsr	se_set_apu
sound_play_frame_done:
	rts

;;;
;;; se_fetch_byte reads one byte from the sound data stream and handles it
;;; Inputs:
;;; 	X: stream number
;;; 
se_fetch_byte:
	lda	stream_ptr_lo, x
	sta	sound_ptr
	lda	stream_ptr_hi, x
	sta	sound_ptr+1

	ldy	#$00
fetch:
	lda	(sound_ptr), y
	bpl	note				; If < #$80, it's a Note
	cmp	#$A0
	bcc	note_length			; Else if < #$A0, it's a Note Length
opcode:						; Else it's an opcode
	;; Do Opcode stuff
	jsr	se_opcode_launcher
	iny						; Next position in data stream
	;; After our opcode is done, grab another byte unless the stream
	;; is disabled.
	lda	stream_status, x
	and	#%00000001
	bne	fetch
	rts
note_length:
	;; Do Note Length stuff
	and	#%01111111				; Chop off bit 7
	sty	sound_temp1				; Save Y because we are about to destroy it
	tay
	lda	note_length_table, y	; Get the note length count value
	sta	stream_note_length, x
	sta	stream_note_length_counter, x
	ldy	sound_temp1				; Restore Y
	iny
	jmp	fetch					; Fetch another byte
note:
	;; Do Note stuff
	sta sound_temp2             ; Save the note value
    lda stream_channel, x       ; What channel are we using?
    cmp #NOISE                  ; Is it the Noise channel?
    bne not_noise              
    jsr se_do_noise         ; If so, JSR to a subroutine to handle noise data
    jmp reset_ve           	; and skip the note table when we return
not_noise:                  ; else grab a period from the note_table
    lda sound_temp2     	; Restore note value
	sty	sound_temp1			; Save our index into the data stream
	clc
	adc	stream_note_offset, x
	asl	a
	tay
	lda	note_table, y
	sta	stream_note_lo, x
	lda	note_table+1, y
	sta	stream_note_hi, x
	ldy	sound_temp1			; Restore data stream index
reset_ve:    
	lda	#$00				; Start at beginning of envelope for new notes
	sta	stream_ve_index, x
	;; Check if it's a rest and modify the status flag appropriately
	jsr	se_check_rest
update_pointer:
	iny
	tya
	clc
	adc	stream_ptr_lo, x
	sta	stream_ptr_lo, x
	bcc	end
	inc	stream_ptr_hi, x
end:
	rts


;;;
;;; se_check_rest will read a byte from the data stream and determine if
;;; it is a rest or not.  It will set our clear the current stream's
;;; rest flag accordingly.
;;; Inputs:
;;; 	X: stream number
;;; 	Y: data stream index
;;; 
se_check_rest:
	lda	(sound_ptr), y		; Read the note byte again
	cmp	#rest
	bne	not_rest
rest:
	lda	stream_status, x
	ora	#%00000010			; Set the rest bit in the status byte
	bne	store				; This will always branch (cheaper than a jmp)
not_rest:
	lda	stream_status, x
	and	#%11111101			; Clear the rest bit in the status byte
store:
	sta	stream_status, x
	rts

   

;;;
;;; se_set_temp_ports will copy a stream's sound data to the temporary APU
;;; variables.
;;; Inputs:
;;; 	X: stream number
;;; 
se_set_temp_ports:
	lda	stream_channel, x
	;; Multiply by 4 so our index will point to the right set of registers
	asl	a
	asl	a
	tay

	;; Volume, using envelopes
	jsr	se_set_stream_volume
	
	;; Sweep
	lda	#$08
	sta	soft_apu_ports+1, y
	
	;; Period lo
	lda	stream_note_lo, x
	sta	soft_apu_ports+2, y
	
	;; Period high
	lda	stream_note_hi, x
	sta	soft_apu_ports+3, y
	
	rts

;;;
;;; se_set_stream_volume
;;; Inputs:
;;; 	X: Stream number
;;; 	Y: Index to channel in soft_apu_ports
;;;
se_set_stream_volume:
	sty	sound_temp1				; Save our index into soft_apu_ports
	
	lda	stream_ve, x			; Which volume envelope?
	asl	a						; Multiply by 2 for table of words
	tay
	lda	volume_envelopes, y 	; Get the low byte of the address from table
	sta	sound_ptr
	lda	volume_envelopes+1, y 	; Get the high byte of the address
	sta	sound_ptr+1

read_ve:
	ldy	stream_ve_index, x	; Our current position within the envelope
	lda	(sound_ptr), y	   	; Grab the value
	cmp	#$ff
	bne	set_vol	   			; Not $FF, set the volume
	dec	stream_ve_index, x 	; It's $FF, go back and read last value again
	jmp	read_ve

set_vol:
	sta	sound_temp2			; Save our new volume value

	cpx	#TRIANGLE			; If not triangle channel, go ahead
	bne	squares
	lda	sound_temp2			; Else if volume not zero, go ahead
	bne	squares
	lda	#$80
	bmi	store_vol			; Else silence the channel with #$80
squares:
	lda	stream_vol_duty, x ; Get current vol/duty settings
	and	#$F0		   		; Zero out old volume
	ora	sound_temp2	   		; OR our new volume in

store_vol:
	ldy	sound_temp1			; Get the index into soft_apu_ports
	sta	soft_apu_ports, y 	;	Store the volume in our temp port
	inc	stream_ve_index, x 	; Move volume envelope index to next position

rest_check:
	;; Check the rest flag. If set, overwrite volume with silence value.
	lda	stream_status, x
	and	#%00000010
	beq	se_set_stream_volume_done	; If clear, no rest, so quit
	lda	stream_channel, x
	cmp	#TRIANGLE					; If Triangle, silence with #$80
	beq	tri
	lda	#$30						; Square and Noise, silence with #$30
	bne	se_set_stream_volume_store
tri:
	lda	#$80
se_set_stream_volume_store:
	sta	soft_apu_ports, y
se_set_stream_volume_done:
	rts
	
;;; 
;;; se_set_apu copies the temporary APU variables to the real APU ports.
;;; 
se_set_apu:
square1:
	lda	soft_apu_ports+0
	sta	$4000
	lda	soft_apu_ports+1
	sta	$4001
	lda	soft_apu_ports+2
	sta	$4002
	;; Conditionally write $4003
	lda	soft_apu_ports+3
	cmp	sound_sq1_old		; Compare to last write
	beq	square2				; Don't write this frame if they were equal
	sta	$4003
	sta	sound_sq1_old		; Save the value we just wrote to $4003
square2:
	lda	soft_apu_ports+4
	sta	$4004
	lda	soft_apu_ports+5
	sta	$4005
	lda	soft_apu_ports+6
	sta	$4006
	;; Conditionally write $4007, as above
	lda	soft_apu_ports+7
	cmp	sound_sq2_old
	beq	triangle
	sta	$4007
	sta	sound_sq2_old
triangle:
	lda	soft_apu_ports+8
	sta	$4008
	lda	soft_apu_ports+10 ; There is no $4009, so we skip it
	sta	$400a
	lda	soft_apu_ports+11
	sta	$400b
noise:
	lda	soft_apu_ports+12
	sta	$400c
	lda	soft_apu_ports+14 ; There is no $400D, so we skip it
	sta	$400e
	lda	soft_apu_ports+15
	sta	$400f
	rts

se_do_noise:
    lda sound_temp2     	;restore the note value
    and #%00010000      	;isolate bit4
    beq mode0          	;if it's clear, Mode-0, so no conversion
mode1:
    lda sound_temp2     	;else Mode-1, restore the note value
    ora #%10000000      	;set bit 7 to set Mode-1
    sta sound_temp2
mode0:
    lda sound_temp2
    sta stream_note_lo, x   ;temporary port that gets copied to $400E
    rts

se_op_endsound:
	lda	stream_status, x ; End of stream, so disable it and silence
	and	#%11111110
	sta	stream_status, x ; Clear enable flag in status byte

	lda	stream_channel, x
	cmp	#TRIANGLE
	beq	silence_tri		; Triangle is silenced differently
	lda	#$30			; Squares and noise silenced with #$30
	bne	silence	
silence_tri:
	lda	#$80			; Triangle silenced with #$80
silence:
	sta	stream_vol_duty, x
	
	rts

se_op_infinite_loop:
	lda	(sound_ptr), y	 	; Read ptr low from the data stream
	sta	stream_ptr_lo, x 	; Update our data stream position
	iny			 			; Next byte
	lda	(sound_ptr), y		; Read ptr high from the data stream
	sta	stream_ptr_hi, x 	; Update our data stream position

	;; Update the pontier to reflect the new position
	sta	sound_ptr+1
	lda	stream_ptr_lo, x
	sta	sound_ptr

	;; After opcodes return, we do an iny.  Since we reset the stream
	;; buffer position, we will want y to restart at 0 again.
	ldy	#$FF
	
	rts

se_op_change_ve:
	lda	(sound_ptr), y		; Read the argument
	sta	stream_ve, x		; Store it in our volume envelope variable
	lda	#$00
	sta	stream_ve_index, x 	; Reset envelope index to beginning
	rts

se_op_duty:
	lda	(sound_ptr), y		; Read the argument
	sta	stream_vol_duty, x
	rts

se_op_set_loop1_counter:
	lda	(sound_ptr), y		; Read the argument (# times to loop)
	sta	stream_loop1, x		; Store it in the loop counter variable
	rts

se_op_loop1:
	dec	stream_loop1, x		; Decrement the counter
	lda	stream_loop1, x
	beq	last_iteration		; If zero, we are done looping
	jmp	se_op_infinite_loop ; If not zero, jump back
last_iteration:	
	iny
	rts

se_op_set_note_offset:
	lda	(sound_ptr), y			; Read the argument
	sta	stream_note_offset, x 	; Set the note offset
	rts

se_op_adjust_note_offset:
	lda	(sound_ptr), y			; Read the argument (what value to add)
	clc
	adc	stream_note_offset, x 	; Add it to the current offset
	sta	stream_note_offset, x 	;  and save it.
	rts
	
se_op_transpose:
	lda	(sound_ptr), y			; Read low byte of pointer to lookup table
	sta	sound_ptr2
	iny
	lda	(sound_ptr), y			; Read high byte of pointer to lookup table
	sta	sound_ptr2+1

	;; Get loop counter, and put it in Y. This will be our idex into
	;; the lookup table.
	sty	sound_temp1
	lda	stream_loop1, x
	tay
	dey							; Subtract 1 because indexes start from 0

	;; Read a value from the table, and add it to the note offset.
	lda	(sound_ptr2), y
	clc
	adc	stream_note_offset, x
	sta	stream_note_offset, x

	ldy	sound_temp1				; Restore Y
	rts

;;; 
;;; se_opcode_launcher will read an address from the opcode jump table
;;; and indirect jump there.
;;; Inputs:
;;; 	A: opcode byte
;;; 	Y: data stream position
;;; 	X: stream number
;;;
se_opcode_launcher:
	sty	sound_temp1	
	sec
	sbc	#$A0		
	asl	a		
	tay
	lda	sound_opcodes, y 	
	sta	sound_ptr2
	lda	sound_opcodes+1, y 	
	sta	sound_ptr2+1
	ldy	sound_temp1
	iny			
	jmp	(sound_ptr2)

;;;;
;;;; Volume envelopes for sound modulation
;;;;
volume_envelopes:
    .word se_ve_1
    .word se_ve_2
    .word se_ve_3
    .word se_ve_4
    .word se_ve_tgl_1
    .word se_ve_tgl_2
	.word se_drum_decay
    
se_drum_decay:
    .byte $0E, $09, $08, $06, $04, $03, $02, $01, $00  ;7 frames per drum.  Experiment to get the length and attack you want.
    .byte $FF
se_ve_1:
    .byte $0F, $0E, $0D, $0C, $09, $05, $00
    .byte $FF
se_ve_2:
    .byte $01, $01, $02, $02, $03, $03, $04, $04, $07, $07
    .byte $08, $08, $0A, $0A, $0C, $0C, $0D, $0D, $0E, $0E
    .byte $0F, $0F
    .byte $FF
se_ve_3:
    .byte $0F, $0F, $0E, $0E, $0D, $0D, $0C, $0C, $0A, $0A
    .byte $08, $08, $07, $07, $06, $06, $05, $05, $04, $04
    .byte $03, $03
    .byte $FF
se_ve_4:
    .byte $0D, $0D, $0D, $0C, $0B, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $06, $06, $06, $05, $04, $00
    .byte $FF
    
se_ve_tgl_1:
    .byte $0F, $0B, $09, $08, $07, $06, $00
    .byte $FF
    
se_ve_tgl_2:
    .byte $0B, $0B, $0A, $09, $08, $07, $06, $06, $06, $05
    .byte $FF

;------------------------------------------------------------------
; SFX
;------------------------------------------------------------------

;------------------------------------------------------------------
; Boing
;------------------------------------------------------------------

sfx0_header:
    .byte $01          		;1 stream
    
    .byte SFX_1         ; which stream
    .byte $01           	; status byte (stream enabled)
    .byte SQUARE_1     		; which channel
    .byte $F1          		; initial volume and duty 
    .byte ve_fade_out     	; volume envelope
    .word sfx0_tri			; pointer to stream
    .byte onethirtybpm     ; 73 bpm tempo

sfx0_tri:
	.byte thirtysecond, C5,G7,C8,d_sixteenth, C8
	.byte endsound


;------------------------------------------------------------------
; Damage
;------------------------------------------------------------------

sfx1_header:
    .byte $01          		;1 stream
    
    .byte SFX_1         ; which stream
    .byte $01           	; status byte (stream enabled)
    .byte SQUARE_1     		; which channel
    .byte $3F          		; initial volume and duty 
    .byte ve_fade_out     	; volume envelope
    .word sfx2_square1 		; pointer to stream
    .byte seventhreebpm     ; 73 bpm tempo

sfx1_square1:
	.byte set_repeat_counter, $02
repeat_tritone:    
	.byte eighth, C7,Fs7
	.byte repeat
	.word repeat_tritone
	.byte endsound
;------------------------------------------------------------------
; Damage 2
;------------------------------------------------------------------

sfx2_header:	
    .byte $01          		;1 stream
    
    .byte SFX_1         	; which stream
    .byte $01           	; status byte (stream enabled)
    .byte SQUARE_1     		; which channel
    .byte $3F          		; initial volume and duty 
    .byte ve_fade_out     	; volume envelope
    .word sfx2_square1 		; pointer to stream
    .byte seventhreebpm     ; 73 bpm tempo

sfx2_square1:
    .byte eighth, C3,Ds3	
	.byte endsound
;------------------------------------------------------------------
; Explode
;------------------------------------------------------------------

sfx3_header:	
    .byte $01          		;1 stream
    
    .byte SFX_1         	; which stream
    .byte $01           	; status byte (stream enabled)
    .byte SQUARE_1     		; which channel
    .byte $3F          		; initial volume and duty 
    .byte ve_fade_out     	; volume envelope
    .word sfx3_square1 		; pointer to stream
    .byte onethirtybpm     ; 73 bpm tempo

sfx3_square1:
    .byte sixteenth, As2,Ds2,eighth,C2	
	.byte endsound

;------------------------------------------------------------------
; Songs
;------------------------------------------------------------------

;------------------------------------------------------------------
; Bang Bang
;------------------------------------------------------------------

song0_header:
    .byte $03			;3 streams
    
    .byte MUSIC_SQ1     ; which stream
    .byte $01           ; status byte (stream enabled)
    .byte SQUARE_1      ; which channel
    .byte $BC           ; initial volume and duty
    .byte ve_fade_out   ; volume envelope
    .word song0_square1 ; pointer to stream
    .byte seventhreebpm ; 73 bpm tempo

    .byte MUSIC_SQ2     ; which stream
    .byte $01           ; status byte (stream enabled)
    .byte SQUARE_2      ; which channel
    .byte $3A           ; initial volume and duty
    .byte ve_fade_out   ; volume envelope
    .word song0_square2 ; pointer to stream
    .byte seventhreebpm ; 73 bpm tempo    

    .byte MUSIC_TRI     ; which stream
    .byte $01           ; status byte (stream enabled)
    .byte TRIANGLE      ; which channel
    .byte $81           ; initial volume and duty 
    .byte ve_fade_out   ; volume envelope
    .word song0_triangle; pointer to stream
    .byte seventhreebpm ; 73 bpm tempo     

song0_square1:
    .byte eighth, C5, F4, Gs4, C5, quarter, As4, Gs4 
	.byte eighth, Cs5, F4, As4, Cs5, quarter, C5, As4 
	.byte d_eighth, C5, C4, E4, Cs5, C5, As4, Gs4, G4
	.byte half, C4
	.byte endsound
	; .byte coda
    ; .word song0_square1

song0_square2:
    .byte eighth, G5, C4, Ds4, G5, quarter, F4, Ds4 
	.byte eighth, Gs5, C4, F4, Gs5, quarter, G5, F4 
	.byte d_eighth, G5, G4, B4, Gs5, G5, F4, Ds4, D4
	.byte half, Gs4
	.byte endsound
	; .byte coda
    ; .word song0_square2

song0_triangle:
	.byte quarter, C4, Gs3,  half, As3
	.byte quarter, Cs4,As3,  half, C4 
	.byte d_quarter, B3, E3, C4, G3
	.byte half, F4
	.byte endsound
	;.byte coda
	;.word song0_triangle

;------------------------------------------------------------------
; The good, the bad and the ugly
;------------------------------------------------------------------

song1_header:
    .byte $02       	; 3 streams
    
	.byte MUSIC_SQ1     ; which stream
    .byte $01           ; status byte (stream enabled)
    .byte SQUARE_1      ; which channel
    .byte $38         	; initial volume and duty
	.byte ve_fade_out   ; volume envelope
    .word song1_sq1 	; pointer to stream
    .byte onethirtybpm  ; 130 bpm tempo    

	.byte MUSIC_SQ2     ; which stream
    .byte $01           ; status byte (stream enabled)
    .byte SQUARE_2      ; which channel
    .byte $38         	; initial volume and duty
    .byte ve_fade_out   ; volume envelope
	.word song1_sq2 	; pointer to stream
    .byte onethirtybpm  ; 130 bpm tempo     
    

song1_sq1:
	.byte adjust_note_offset, tone
repeat_s1_sq1:
	;bar 1 2
	.byte sixteenth, A5, D6, A5, D6, quarter, A5, F5
	.byte half, G5, D5	
	;bar 5 6
	.byte sixteenth, A5, D6, A5, D6, quarter, A5, F5
	.byte half, G5, C6
	;bar 5 6
	.byte sixteenth, A5, D6, A5, d_quarter, D6, quarter, F5
	.byte eighth, E5, D5, d_half, C5
	.byte eighth, rest
	.byte coda	
	.word repeat_s1_sq1


song1_sq2:
	.byte adjust_note_offset, perf_fifth
repeat_s1_sq2:
	;bar 1 2
	.byte sixteenth, A5, D6, A5, D6, quarter, A5, F5
	.byte half, G5, D5	
	;bar 5 6
	.byte sixteenth, A5, D6, A5, D6, quarter, A5, F5
	.byte half, G5, C6
	;bar 5 6
	.byte sixteenth, A5, D6, A5, d_quarter, D6, quarter, F5
	.byte eighth, E5, D5, d_half, C5
	.byte eighth, rest
	.byte coda
	.word repeat_s1_sq2

; D4 F4 A4 F4 C4
; D4 F4 A4 F4 C4
; A4 E5 C4 G5
; A5 
; D5 F5 E5 D5
; G5
; D5 F5 E5 D5
; G5
; D5 F5 E5 D5
; G5
; D5 F5 E5 D5
; G5 D5 F5 E5 D5 E5 C5 D5 C5 B4 C5 A4 B4 A4 G4 A4 F4 G4 Gs4 E4 D4  
;------------------------------------------------------------------
; Song 2
;------------------------------------------------------------------

song2_header:

;------------------------------------------------------------------
; Game soundtrack
;------------------------------------------------------------------

song3_header:


;------------------------------------------------------------------
; Song Table
;------------------------------------------------------------------


song_headers
	.word	song0_header	; Bang Bang 
	.word 	song1_header	; The good, the bad and the ugly
	.word	song2_header	;
	.word 	song3_header	; 
	.word	sfx0_header		; 
	.word 	sfx1_header		; 
	.word	sfx2_header		;			 
	.word 	sfx3_header		; 
	
