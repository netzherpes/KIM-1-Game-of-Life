; Target assembler: cc65 --target none -C gol.bin_cc65.cfg
;***************************************
;* Conway's Game of Life               *
;* adapted by Theodore E. Bridge       *
;* November 1980                       *
;*                                     *
;* Setup:                              *
;* $2001 Chars per Line (std $20)      *
;* $2005 Lines per screen (std $10)    *
;* $2009 skip frames (std. $0)         *
;*                                     *
;* Enter your variables at the start:  *
;* ENTER V,H ?                         *
;*                                     *
;* These coordinates are displacements *
;*                                     *
;* from an origin at the center of the *
;*                                     *
;* screen. A coordinate may be any     *
;* decimal                             *
;* digit less than 8 followed by a '-' *
;*                                     *
;* or a <space>. After all is set,     *
;* '/' starts the simulation.          *
;***************************************
         
CPL      =       $20
LIS      =       $21
CENT     =       $22
ADR      =       $24
POINT    =       $26
BEFORE   =       $28
POND     =       $2a
LAST     =       $2c
BUFF     =       $2e
GC       =       $30
GBP      =       $32
CNTG     =       $33
ACT      =       $34
OFFS     =       $35
NN       =       $3d
SAVY     =       $3e

         .org    $2000
Start:   lda     #$20
         sta     CPL
         ldx     #$10
         stx     LIS
         lda     #$00
         sta     GBP
         lda     #$97
         sta     BEFORE
         lda     #$22
         sta     $29
         clc
         lda     BEFORE
         adc     CPL
         sta     POND
         sta     ADR
         lda     $29
         adc     #$00
         sta     $2b
         sta     $25
         jsr     MULTA
         lda     CPL
         lsr     A
         clc
         adc     ADR
         sta     CENT
         lda     $25
         adc     #$00
         sta     $23
         ldx     LIS
         jsr     MULTA
         clc
         lda     ADR
         sta     LAST
         adc     CPL
         sta     BUFF
         lda     $25
         sta     $2d
         adc     #$00
         sta     $2f
         lda     #$00
         sta     OFFS
         clc
         adc     CPL
         sta     $36
         adc     CPL
         sta     $37
         lda     #$01
         sta     $38
         adc     CPL
         adc     CPL
         sta     $39
         lda     #$02
         sta     $3a
         adc     CPL
         sta     $3b
         adc     CPL
         sta     $3c
         ldy     #$00
         sty     CNTG
         sty     GC
         sty     $31
         jsr     CLEAR
         jsr     PLANT
STAR:    jsr     INCG
         jsr     SHOALL
         ldy     #$00
         sty     ACT
         jsr     POST
         jsr     UPDATE
         lda     ACT
         bne     STAR
         brk

         .byte   $00
         .byte   $20
         .byte   $80
         .byte   $20

PRTBYT:  jmp     $1e3b

GETCH:   sty     SAVY
         jsr     $1e5a
         ldy     SAVY
         rts

CRLF:    lda     #$0d
         jsr     OUTCH
         lda     #$0a
OUTCH:   sty     SAVY
         jsr     $1ea0
         ldy     SAVY
L20AF:   rts

MULTA:   dex
         bmi     L20AF
         clc
         lda     ADR
         adc     CPL
         sta     ADR
         lda     #$00
         adc     $25
         sta     $25
         jmp     MULTA

L20C3:   rts

SUBA:    dex
         bmi     L20C3
         sec
         lda     ADR
         sbc     CPL
         sta     ADR
         lda     $25
         sbc     #$00
         sta     $25
         jmp     SUBA

INCG:    jsr     CRLF
         clc
         sed
         lda     #$01
         adc     GC
         sta     GC
         lda     $31
         adc     #$00
         sta     $31
         cld
         jsr     PRTBYT
         lda     GC
         jsr     PRTBYT
         rts

CLEAR:   jsr     MOVE
         lda     LIS
         asl     A
         sta     NN
L20FA:   ldy     CPL
CLR:     dey
         bmi     @L2105
         lda     #$00
         sta     (ADR),y
         beq     CLR

@L2105:  ldx     #$01
         jsr     MULTA
         dec     NN
         bpl     L20FA
         rts

ENTRVH:  jsr     CRLF
         ldx     #$0b
L2114:   lda     ENT,x
         jsr     OUTCH
         dex
         bpl     L2114
         rts

ENT:     .byte   " ? H,V RETNE"

GET:     jsr     GETCH
         cmp     #$38
         bmi     L2133
         lda     #$00
L2133:   rts

PLANT:   jsr     ENTRVH
         jsr     GET
         beq     PLANT
         cmp     #$30
         bmi     L2133
         and     #$07
         tax
         lda     CENT
         sta     ADR
         lda     $23
         sta     $25
         jsr     GET
         beq     PLANT
         cmp     #$2d
         beq     MINUS
         jsr     MULTA
         bmi     HOR
MINUS:   jsr     SUBA
HOR:     ldx     #$02
         jsr     L2114
         jsr     GET
         cmp     #$30
         bmi     PLANT
         and     #$07
         sta     NN
         jsr     GET
         beq     PLANT
         cmp     #$2d
         beq     MIN
         clc
         lda     ADR
         adc     NN
         sta     ADR
         lda     $25
         adc     #$00
         sta     $25
L2182:   lda     #$01
         ldy     #$00
         sta     (ADR),y
         jmp     PLANT

MIN:     sec
         lda     ADR
         sbc     NN
         sta     ADR
         lda     $25
         sbc     #$00
         jmp     L2182

L2199:   lda     GBP
         sta     CNTG
L219D:   rts

SHOALL:  dec     CNTG
         bpl     L219D
         jsr     MOVE
         lda     LIS
         sta     NN
SHO:     ldx     #$01
         jsr     MULTA
         dec     NN
         beq     L2199
         ldy     CPL
L21B4:   lda     (ADR),y
         bne     SHOA
         lda     #$20
         bpl     L21BE

SHOA:    lda     #$27
L21BE:   sta     (BUFF),y
         dey
         bne     L21B4
         ldx     #$01
         jsr     MULTA
         ldy     CPL
SHOW:    lda     (ADR),y
         beq     L21DC
         lda     (BUFF),y
         cmp     #$20
         beq     @L21D8
         lda     #$3b
         bpl     SHOWB

@L21D8:  lda     #$2c
SHOWB:   sta     (BUFF),y
L21DC:   dey
         bne     SHOW
         ldy     CPL
@L21E1:  lda     (BUFF),y
         cmp     #$20
         bne     SHOWA
         dey
         bne     @L21E1
SHOWA:   iny
         lda     #$0d
         sta     (BUFF),y
         ldy     #$00
         jsr     CRLF
SHOP:    iny
         lda     (BUFF),y
         cmp     #$0d
         beq     SHO
         jsr     OUTCH
         jmp     SHOP

POST:    jsr     MOVE
         jsr     INCP
L2207:   lda     #$00
         sta     NN
         ldx     #$07
NBR:     lda     OFFS,x
         tay
         lda     (ADR),y
         beq     NB
         bmi     NB
         inc     NN
NB:      dex
         bpl     NBR
         ldy     #$00
         lda     NN
         cmp     #$02
         bmi     DEATH
         cmp     #$03
         beq     BIRTH
         bpl     DEATH
POSTA:   jsr     INCA
         bne     L2207
EDGE:    jsr     MOVE
         lda     LIS
         asl     A
         sta     NN
@L2236:  tya
         sta     (ADR),y
         ldx     #$01
         jsr     MULTA
         dec     NN
         bpl     @L2236
         rts

DEATH:   lda     (POINT),y
         beq     POSTA
         lda     #$02
         bpl     L2251

BIRTH:   lda     (POINT),y
         bne     POSTA
         lda     #$ff
L2251:   sta     (POINT),y
@L2253:  inc     ACT
         beq     @L2253
         jmp     POSTA

UPDATE:  jsr     MOVE
L225D:   lda     (POINT),y
         bmi     ADULT
         cmp     #$02
         bmi     L226D
BURY:    lda     #$00
         beq     L226B

ADULT:   lda     #$01
L226B:   sta     (POINT),y
L226D:   jsr     INCP
         bne     L225D
         rts

INCA:    inc     ADR
         bne     INCP
         inc     $25
INCP:    inc     POINT
         bne     @L227F
         inc     $27
@L227F:  lda     $27
         cmp     $2d
         bmi     @L228A
         sec
         lda     POINT
         sbc     LAST
@L228A:  rts

MOVE:    ldx     #$03
@L228D:  lda     BEFORE,x
         sta     ADR,x
         dex
         bpl     @L228D
         ldy     #$00
         rts
		 
END:     .byte   $00
         .byte   $00