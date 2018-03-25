;
; Labels reset between states
;

screen_shake_counter = $00
screen_shake_nextval_x = $01
screen_shake_nextval_y = $02

;
; Audio engine labels
;

audio_square1_sample_counter = $d0  ;
audio_square2_sample_counter = $d1  ; Counter in the sample - index of a note
audio_triangle_sample_counter = $d2 ;

audio_square1_note_counter = $d3  ;
audio_square2_note_counter = $d4  ; Counter in the note - time left before next note
audio_triangle_note_counter = $d5 ;

audio_channel_mode = $d6 ; Square or triangle

audio_square1_track = $d7  ;
audio_square2_track = $d9  ; Adress of the current track for each channel
audio_triangle_track = $db ;

audio_duty = $dd
audio_music_enabled = $de

audio_square1_track_counter = $0600  ;
audio_square2_track_counter = $0601  ; Counter in the track - index of a sample
audio_triangle_track_counter = $0602 ;

;
; Global labels
;

controller_a_btns = $e0
controller_b_btns = $e1
controller_a_last_frame_btns = $e2
controller_b_last_frame_btns = $e3
global_game_state = $e4

; State of the NMI processing
;  $00 - NMI processed
;  $01 - Waiting for the next NMI to be processed
nmi_processing = $e5

scroll_x = $e6
scroll_y = $e7
ppuctrl_val = $e8

tmpfield1 = $f0
tmpfield2 = $f1
tmpfield3 = $f2
tmpfield4 = $f3
tmpfield5 = $f4
tmpfield6 = $f5
tmpfield7 = $f6
tmpfield8 = $f7
tmpfield9 = $f8
tmpfield10 = $f9
tmpfield11 = $fa
tmpfield12 = $fb
tmpfield13 = $fc
tmpfield14 = $fd
tmpfield15 = $fe
tmpfield16 = $ff


stack = $0100
oam_mirror = $0200
nametable_buffers = $0300
particle_blocks = $0500
particle_block_0 = $0500
particle_block_1 = $0520
previous_global_game_state = $540
;$06xx may be used by audio engine, see "Audio engine labels"
virtual_frame_cnt = $0700
skip_frames_to_50hz = $0701
