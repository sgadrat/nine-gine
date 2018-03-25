#include "game/music/theme_main/theme_main.asm"

audio_music_start:
.(
jsr audio_unmute_music

lda #%00001111 ; ---DNT21
sta APU_STATUS ;

lda #%01111100 ; DDLCVVVV
sta audio_duty

lda #<track_main_square1
sta audio_square1_track
lda #>track_main_square1
sta audio_square1_track+1

lda #<track_main_square2
sta audio_square2_track
lda #>track_main_square2
sta audio_square2_track+1

lda #<track_main_triangle
sta audio_triangle_track
lda #>track_main_triangle
sta audio_triangle_track+1

jsr audio_reset_music

rts
.)
