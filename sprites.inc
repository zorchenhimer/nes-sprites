Sp_Palette_0 = %0000_0000
Sp_Palette_1 = %0000_0001
Sp_Palette_2 = %0000_0010
Sp_Palette_3 = %0000_0011

Sp_Priority_Behind  = %0010_0000
Sp_Priority_InFront = %0000_0000

Sp_FlipHoriz = %0100_0000
Sp_FlipVert  = %1000_0000

.struct ObjectData
OffsetY .byte
Tile    .byte
Attr    .byte
OffsetX .byte
.endstruct

.struct SpriteData
CoordY .byte
Tile   .byte
Attr   .byte
CoordX .byte
.endstruct

SpriteList:
    .word :+
    .word :++

;;;;;
:   .byte 7 ; tile count

    .byte 0*8 ; offset vertical
    .byte $80 ; tile
    .byte Sp_Palette_0   ; palette & attr
    .byte 0*8 ; offset horizontal

    .byte 0*8
    .byte $81
    .byte Sp_Palette_0
    .byte 1*8

    .byte 0*8
    .byte $82
    .byte Sp_Palette_0
    .byte 2*8

    .byte 0*8
    .byte $83
    .byte Sp_Palette_0
    .byte 3*8

    .byte 1*8
    .byte $90
    .byte Sp_Palette_0
    .byte 0*8

    .byte 1*8
    .byte $91
    .byte Sp_Palette_0
    .byte 1*8

    .byte 1*8
    .byte $92
    .byte Sp_Palette_0
    .byte 2*8

;;;;;
:   .byte 13

    .byte 0*8
    .byte $84
    .byte Sp_Palette_0
    .byte 1*8

    .byte 0*8
    .byte $85
    .byte Sp_Palette_0
    .byte 2*8

    .byte 0*8
    .byte $86
    .byte Sp_Palette_0
    .byte 3*8

    .byte 0*8
    .byte $87
    .byte Sp_Palette_0
    .byte 4*8

    .byte 0*8
    .byte $88
    .byte Sp_Palette_0
    .byte 5*8

    .byte 0*8
    .byte $89
    .byte Sp_Palette_0
    .byte 6*8

    .byte 1*8
    .byte $93
    .byte Sp_Palette_0
    .byte 0*8

    .byte 1*8
    .byte $94
    .byte Sp_Palette_0
    .byte 1*8

    .byte 1*8
    .byte $95
    .byte Sp_Palette_0
    .byte 2*8

    .byte 1*8
    .byte $96
    .byte Sp_Palette_0
    .byte 3*8

    .byte 1*8
    .byte $97
    .byte Sp_Palette_0
    .byte 4*8

    .byte 1*8
    .byte $98
    .byte Sp_Palette_0
    .byte 5*8

    .byte 1*8
    .byte $99
    .byte Sp_Palette_0
    .byte 6*8
