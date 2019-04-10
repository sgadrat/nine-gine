; Subroutine called when the state change to this state
game_states_init:
VECTOR(ingame_init)

; Subroutine called each frame
game_states_tick:
VECTOR(ingame_tick)

palettes_data:
; Background
.byt $20,$0d,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d
; Sprites
.byt $20,$06,$25,$22, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d

nametable_data:
.byt ZIPNT_ZEROS(32*7)
.byt ZIPNT_ZEROS(32*7+12)
.byt                                                                $01, $01, $01, $01,  $01
.byt ZIPNT_ZEROS(15+12)
.byt                                                                $01, $01, $01, $01,  $01
.byt ZIPNT_ZEROS(15+12)
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                                                $01, $01, $01, $01,  $01
.byt ZIPNT_ZEROS(15+32*7)
.byt ZIPNT_ZEROS(32*6)
nametable_attributes:
.byt ZIPNT_ZEROS(8*8)
.byt ZIPNT_END

heart_animation_state = $0550
heart_x = heart_animation_state+ANIMATION_STATE_OFFSET_X_LSB
heart_y = heart_animation_state+ANIMATION_STATE_OFFSET_Y_LSB

; Initialization routine for ingame state
ingame_init:
.(
	; Point PPU to Background palette 0 (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
	lda PPUSTATUS
	lda #$3f
	sta PPUADDR
	lda #$00
	sta PPUADDR

	; Write palette_data in actual ppu palettes
	ldx #$00
	copy_palette:
	lda palettes_data, x
	sta PPUDATA
	inx
	cpx #$20
	bne copy_palette

	; Copy background from PRG-rom to PPU nametable
	lda #<nametable_data
	sta tmpfield1
	lda #>nametable_data
	sta tmpfield2
	jsr draw_zipped_nametable

	; Initialize heart animation state
	lda #<heart_animation_state
	sta tmpfield11
	lda #>heart_animation_state
	sta tmpfield12
	lda #<anim_heart
	sta tmpfield13
	lda #>anim_heart
	sta tmpfield14
	jsr animation_init_state

	; Init heart's position
	lda #$80
	sta heart_x
	sta heart_y

	rts
.)

; Tick routine for ingame state
ingame_tick:
.(
	;
	; Move the heart
	;

	; Check up button
	.(
		lda controller_a_btns
		and #CONTROLLER_BTN_UP
		beq ok

			dec heart_y

		ok:
	.)

	; Check left button
	.(
		lda controller_a_btns
		and #CONTROLLER_BTN_LEFT
		beq ok

			dec heart_x

		ok:
	.)

	; Check right button
	.(
		lda controller_a_btns
		and #CONTROLLER_BTN_RIGHT
		beq ok

			inc heart_x

		ok:
	.)

	; Check down button
	.(
		lda controller_a_btns
		and #CONTROLLER_BTN_DOWN
		beq ok

			inc heart_y

		ok:
	.)

	;
	; Draw the heart
	;

	; Call animation_draw with its parameter
	lda #<heart_animation_state ;
	sta tmpfield11              ; The animation state to draw
	lda #>heart_animation_state ;
	sta tmpfield12              ;
	lda #0         ;
	sta tmpfield13 ;
	sta tmpfield14 ; Camera position (let it as 0/0)
	sta tmpfield15 ;
	sta tmpfield16 ;
	jsr animation_draw

	; Advance animation one tick
	jsr animation_tick

	rts
.)
