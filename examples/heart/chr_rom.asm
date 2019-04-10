* = 0 ; We just use * to count position in the CHR-rom, begin with zero is easy

; TILE $00 - Heart, frame 1
;
; 00100100
; 01211210
; 12222221
; 01222210
; 01222210
; 00122100
; 00122100
; 00011000
.byt %00100100, %01011010, %10000001, %01000010, %01000010, %00100100, %00100100, %00011000
.byt %00000000, %00100100, %01111110, %00111100, %00111100, %00011000, %00011000, %00000000

; TILE $01 - Heart, frame 2
;
; 00100100
; 01311310
; 13333331
; 01333310
; 01333310
; 00133100
; 00133100
; 00011000
.byt %00100100, %01111110, %11111111, %01111110, %01111110, %00111100, %00111100, %00011000
.byt %00000000, %00100100, %01111110, %00111100, %00111100, %00011000, %00011000, %00000000

#if $1000-* < 0
#echo *** Error: VRAM bank1 data occupies too much space
#else
.dsb $1000-*, 0
#endif

; TILE $00 - Full backdrop color
;
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
.byt $00, $00, $00, $00, $00, $00, $00, $00
.byt $00, $00, $00, $00, $00, $00, $00, $00

; TILE $01 - Solid 1
;
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
.byt $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
.byt $00, $00, $00, $00, $00, $00, $00, $00

#if $2000-* < 0
#echo *** Error: VRAM bank2 data occupies too much space
#else
.dsb $2000-*, 0
#endif