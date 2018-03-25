title_screen_init:
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

; Start the music
jsr audio_music_start

rts
.)

palettes_data:
; Background
.byt $20,$20,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d, $20,$0d,$0d,$0d
; Sprites
.byt $20,$0d,$00,$10, $20,$0d,$00,$10, $20,$0d,$00,$10, $20,$0d,$00,$10

nametable_data:
.byt ZIPNT_ZEROS(32*7)
.byt ZIPNT_ZEROS(32*7+12)
.byt                                                                $04, $05, $06, $07,  $08
.byt ZIPNT_ZEROS(15+12)
.byt                                                                $09, $0a, $0b, $0c,  $0d
.byt ZIPNT_ZEROS(15+12)
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                                                $0e, $0f, $10, $11,  $12
.byt ZIPNT_ZEROS(15+32*7)
.byt ZIPNT_ZEROS(32*6)
nametable_attributes:
.byt ZIPNT_ZEROS(8*8)
.byt ZIPNT_END

.)

title_screen_tick:
.(
lda controller_a_last_frame_btns
bne end

lda controller_a_btns
beq end

lda #GAME_STATE_INGAME
jsr change_global_game_state

end:
rts
.)
