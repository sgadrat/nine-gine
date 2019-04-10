animation_states = $059c ; $059c to $05ff
player_a_y = animation_states+ANIMATION_STATE_OFFSET_Y_LSB
player_b_y = animation_states+ANIMATION_STATE_LENGTH+ANIMATION_STATE_OFFSET_Y_LSB

ingame_init:
.(
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

; Initialize players' animations
ldx #ANIMATION_STATE_LENGTH*2
copy_one_byte:
	dex

	lda player_animation_states, x
	sta animation_states, x

	cpx #0
	bne copy_one_byte

rts
.)

player_animation_states:
; player_a
.byt $20, $00, $78, $00, <anim_player, >anim_player, $00, $00, $00, $1f, <anim_player, >anim_player
; player_b
.byt $e0, $00, $78, $00, <anim_player, >anim_player, $00, $00, $20, $3f, <anim_player, >anim_player

palettes_data:
; Background
.byt $20,$20,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d
; Sprites
.byt $20,$0d,$00,$10, $20,$0d,$00,$10, $20,$0d,$00,$10, $20,$0d,$00,$10

nametable_data:
.byt ZIPNT_ZEROS(32*7)
.byt ZIPNT_ZEROS(32*7)
.byt ZIPNT_ZEROS(32*3)
.byt ZIPNT_ZEROS(32*7)
.byt ZIPNT_ZEROS(32*6)
nametable_attributes:
.byt ZIPNT_ZEROS(8*8)
.byt ZIPNT_END

.)

ingame_tick:
.(
; Move players according to the state of their controller
ldx #0
move_one_player:
lda controller_a_btns, x
cmp #CONTROLLER_BTN_UP
bne check_down
lda player_a_y, x
sec
sbc #2
sta player_a_y, x
check_down:
lda controller_a_btns, x
cmp #CONTROLLER_BTN_DOWN
bne end_move_player
lda player_a_y, x
clc
adc #2
sta player_a_y, x
end_move_player:

inx
cpx #2
bne move_one_player

; Refresh players animations
ldx #0
jsr draw_one_player
ldx #1
jsr draw_one_player

end:
rts

draw_one_player:
.(
lda players_animation_state_addr, x
sta tmpfield11
lda #>animation_states
sta tmpfield12
lda #0
sta tmpfield13
sta tmpfield14
sta tmpfield15
sta tmpfield16

jsr animation_draw

rts

players_animation_state_addr:
.byt <animation_states, <animation_states+ANIMATION_STATE_LENGTH
.)
.)
