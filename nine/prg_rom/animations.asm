; Draw the current frame of an animation
;  tmpfield1 - X position
;  tmpfield2 - Y position
;  tmpfield3, tmpfield4 - vector to the animation
;  tmpfield5 - index of the first OAM sprite to use
;  tmpfield6 - index of the last OAM sprite to use
;  tmpfield7 - direction of the animation (0 - natural, 1 - horizontally flipped)
;  tmpfield12 - current tick number
;
; Set tmpfield12 to next tick number
; Overwrite all refisters and tmpfields
;
animation_draw:
.(
; Pretty names
animation_vector = tmpfield3   ; Not movable - Used as parameter for draw_anim_frame subroutine
first_sprite_index = tmpfield5 ; Not movable - Used as parameter for draw_anim_frame subroutine
last_sprite_index = tmpfield6  ; Not movable - Used as parameter for draw_anim_frame subroutine
animation_direction = tmpfield7 ; Not movable - Used as parameter for draw_anim_frame subroutine
frame_first_tick = tmpfield11
current_tick_number = tmpfield12

.(

; Initialization
ldx #$00
ldy #$00
lda #$00
sta frame_first_tick

; New frame (search for the frame on time with clock)
new_frame:
lda (animation_vector), y ; Load frame duration
beq loop_animation ; Frame of duration 0 means end of animation
clc                        ; Compute current frame's clock end
adc frame_first_tick       ;
cmp current_tick_number ;
beq search_next_frame   ; If the current frame ends after the clock time, draw it
bcs draw_current_frame  ;
search_next_frame:
sta frame_first_tick ; Store next frame's clock begin (= current frame's clock end)

; Search the next frame
lda #$01
jsr add_to_anim_vector
skip_sprite:
lda (animation_vector), y ; Check current sprite continuation byte
beq end_skip_frame        ;
sta tmpfield8  ;
lda #$05       ;
sta tmpfield9  ; Set data length in tmpfield9
lda #%00001000 ; hitbox data is 15 bytes long
bit tmpfield8  ; other data are 5 bytes long
beq inc_cursor ; (counting the continuation byte)
lda #15        ;
sta tmpfield9  ;
inc_cursor:
lda tmpfield9          ; Add data length to the animation vector, to point
jsr add_to_anim_vector ; on the next continuation byte
jmp skip_sprite
end_skip_frame:
lda #$01               ; Skip the last continuation byte
jsr add_to_anim_vector ;
jmp new_frame

draw_current_frame:
; Increment animation_vector to skip the frame duration field
lda #$01
jsr add_to_anim_vector

txa
pha
jsr draw_anim_frame
pla
tax

tick_clock:
inc current_tick_number
jmp end

loop_animation:
lda #$00
sta current_tick_number

end:
rts
.)

add_to_anim_vector:
.(
clc
adc animation_vector
sta animation_vector
lda #$00
adc animation_vector+1
sta animation_vector+1
rts
.)

.)

; Draw an animation frame on screen
;  tmpfield1 - Position X
;  tmpfield2 - Position Y
;  tmpfield3, tmpfield4 - Vector pointing to the frame to draw
;  tmpfield5 - First sprite index to use
;  tmpfield6 - Last sprite index to use
;  tmpfield7 - Animation's direction (0 normal, 1 flipped)
;  tmpfield8 - X position
;  tmpfield9 - Y position
;
; Overwrites tmpfield5, tmpfield8, tmpfield10, tmpfield14, tmpfield15 and all registers
draw_anim_frame:
.(
; Pretty names
anim_pos_x = tmpfield1
anim_pos_y = tmpfield2
frame_vector = tmpfield3
sprite_index = tmpfield5
last_sprite_index = tmpfield6
animation_direction = tmpfield7
sprite_orig_x = tmpfield8
sprite_orig_y = tmpfield9
continuation_byte = tmpfield10

.(
; Initialization
ldy #$00

; Check continuation byte - zero value means end of data
draw_one_sprite:
lda (frame_vector), y
beq clear_unused_sprites
iny

; Check positioning mode from continuation byte
sta continuation_byte
lda #%00000010
bit continuation_byte
beq set_relative
lda #$00
sta sprite_orig_x
sta sprite_orig_y
jmp move_sprite
set_relative:
lda anim_pos_x
sta sprite_orig_x
lda anim_pos_y
sta sprite_orig_y

move_sprite:
jsr anim_frame_move_sprite
jmp draw_one_sprite

; Place unused sprites off screen
clear_unused_sprites:
lda last_sprite_index
cmp sprite_index
bcc end

lda sprite_index ;
asl              ; Set X to the byte offset of the sprite in OAM memory
asl              ;
tax              ;

lda #$fe
sta oam_mirror, x
inx
sta oam_mirror, x
inx
sta oam_mirror, x
inx
sta oam_mirror, x

inc sprite_index
jmp clear_unused_sprites

end:
rts
.)

anim_frame_move_sprite:
.(
; Copy sprite data

attributes_modifier = tmpfield14
sprite_used = tmpfield15 ; 0 - first sprite, 1 - last sprite

; Compute direction dependent information
;  attributes modifier - to flip the animation if needed
;  A - sprite index to use
lda animation_direction
beq default_direction

lda #$40                ; Flip horizontally attributes
sta attributes_modifier ;

lda #%00010000              ;
bit continuation_byte       ;
beq use_last_sprite         ;
lda #0                      ;
jmp set_sprite_used         ; Use the last sprite unless explicitely foreground
use_last_sprite:            ;
lda #1                      ;
set_sprite_used:            ;
sta sprite_used             ;
jmp end_init_direction_data ;

default_direction:
lda #$00                ;
sta attributes_modifier ; Do not flip attributes
sta sprite_used         ; Always use the first sprite

end_init_direction_data:

; X points on sprite data to modify
lda sprite_used
beq use_first_sprite
lda last_sprite_index
jmp sprite_index_set
use_first_sprite:
lda sprite_index
sprite_index_set:
asl
asl
tax

; Y value, must be relative to animation Y position
lda (frame_vector), y
clc
adc sprite_orig_y
sta oam_mirror, x
eor sprite_orig_y ;
bpl continue      ;
lda sprite_orig_y ; Skip the sprite if it wraps the screen from
cmp #%11000000    ; bottom to top
bcs skip          ;
continue:         ;
inx
iny
; Tile number
lda (frame_vector), y
sta oam_mirror, x
inx
iny
; Attributes
;  Flip horizontally (eor $40) if oriented to the right
lda (frame_vector), y
eor attributes_modifier
sta oam_mirror, x
inx
iny
; X value, must be relative to animation X position
;  Flip symetrically to the vertical axe if needed
lda animation_direction
bne flip_x
lda (frame_vector), y
jmp got_relative_pos
flip_x:
lda (frame_vector), y
eor #%11111111
clc
adc #1
got_relative_pos:
clc
adc sprite_orig_x
sta oam_mirror, x
iny

; Next sprite
lda sprite_used
beq inc_sprite_index
dec last_sprite_index
jmp end_next_sprite
inc_sprite_index:
inc sprite_index
end_next_sprite:
jmp end

; Skip sprite
skip:
lda #$fe          ; Reset OAM sprite's Y position
sta oam_mirror, x ;
iny ;
iny ; Advance to the next frame's sprite
iny ;
iny ;

end:
rts
.)

.)
