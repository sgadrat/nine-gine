;
; Credits in the rom
;

credits_begin:
.asc "             credits",$0a
.asc $0a
.asc "             authors",$0a
.asc $0a
.asc "authors names",$0a
.asc $0a
.asc "           art sources",$0a
.asc $0a
.asc "source name", $0a 
.asc "    by source author", $0a
.asc $0a
.asc "             thanks",$0a
.asc $0a
.asc "some awesome beings",$0a
.byt $00
credits_end:

;
; Print some PRG-ROM space usage information
;

#echo PRG-ROM total space:
#print $10000-$8000
#echo
#echo PRG-ROM free space:
#print $fffa-*

;
; Fill code bank and set entry points vectors (also from nesmine)
;

#if $fffa-* < 0
#echo *** Error: Code occupies too much space
#else
.dsb $fffa-*, 0     ;aligning
.word nmi           ;entry point for VBlank interrupt  (NMI)
.word reset         ;entry point for program start     (RESET)
.word cursed        ;entry point for masking interrupt (IRQ)
#endif
