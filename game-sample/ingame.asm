player_a_y = $03
player_b_y = $04

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

; Place players
lda #$78
sta player_a_y
sta player_b_y

rts
.)

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
lda players_x, x
sta tmpfield1
lda player_a_y, x
sta tmpfield2
lda #<anim_player
sta tmpfield3
lda #>anim_player
sta tmpfield4
txa
asl
asl
sta tmpfield5
clc
adc #3
sta tmpfield6
txa
sta tmpfield7
lda #0
sta tmpfield12

jsr animation_draw

rts

players_x:
.byt $20, $e0
.)
.)
