.pushseg
.segment "ZEROPAGE"

CoordX: .res 1
CoordY: .res 1

.segment "BSS"

OBJ_COUNT = 8

LoadedSprites_Lo: .res OBJ_COUNT
LoadedSprites_Hi: .res OBJ_COUNT

LoadedSprites_CoordX: .res OBJ_COUNT
LoadedSprites_CoordY: .res OBJ_COUNT

SpriteOffset: .res 1
LoadedSpriteCount: .res 1

.popseg

UpdateObjects:
    ;clc
    lda #.lobyte(SpritesA)
    ;adc SpriteOffset
    sta AddressPointer2+0

    lda #.hibyte(SpritesA)
    sta AddressPointer2+1
    lda #0
    sta TmpA

    lda #64
    sta TmpY ; total sprites

    ;lda #OBJ_COUNT
    ;sta TmpZ

    ; find how many are loaded
    ldy #0
:   lda LoadedSprites_Hi, y
    beq :+
    iny
    cpy #OBJ_COUNT
    bne :-
:
    sty LoadedSpriteCount
    sty TmpZ

    ldx SpriteOffset
    lda FrameCount
    and #$01
    bne @loopObj

    inc SpriteOffset
    lda SpriteOffset
    cmp LoadedSpriteCount
    bcc @loopObj
    lda #0
    sta SpriteOffset

@loopObj:
    lda LoadedSprites_Lo, x
    sta AddressPointer1+0
    lda LoadedSprites_Hi, x
    sta AddressPointer1+1
    beq @justNext

    ldy #0
    lda (AddressPointer1), y
    sta TmpX

    lda LoadedSprites_CoordX, x
    sta CoordX
    lda LoadedSprites_CoordY, x
    sta CoordY

    ;ldx TmpA

    inc AddressPointer1+0
    bne @loopData
    inc AddressPointer1+1
@loopData:
    ldy #0
    clc
    lda (AddressPointer1), y
    adc CoordY
    sta (AddressPointer2), y

    iny
    lda (AddressPointer1), y
    sta (AddressPointer2), y

    iny
    lda (AddressPointer1), y
    sta (AddressPointer2), y

    iny
    clc
    lda (AddressPointer1), y
    adc CoordX
    sta (AddressPointer2), y

    dec TmpY

    dec TmpX
    beq @nextObj

    clc
    lda AddressPointer1+0
    adc #.sizeof(ObjectData)
    sta AddressPointer1+0

    lda AddressPointer1+1
    adc #0
    sta AddressPointer1+1

    clc
    lda AddressPointer2+0
    adc #.sizeof(SpriteData)
    sta AddressPointer2+0
    jmp @loopData

@nextObj:
    clc
    lda AddressPointer2+0
    adc #.sizeof(SpriteData)
    sta AddressPointer2+0

@justNext:
    inx
    ;cpx #OBJ_COUNT
    cpx LoadedSpriteCount
    bne :+
    ldx #0
:
    dec TmpZ
    beq @done
    jmp @loopObj
@done:

    ldy #0
    lda TmpY
    beq :+
    bmi :+
@clearLoop:
    lda #$FF
    sta (AddressPointer2), y
    clc
    lda AddressPointer2+0
    adc #.sizeof(SpriteData)
    sta AddressPointer2+0
    dec TmpY
    beq :+
    jmp @clearLoop
:

    lda #%0101_1110
    sta $2001
    ;jmp CopyRevSprites
    jmp CopyRevSprites_Unrolled
    rts

CopyRevSprites:
    ldx #0
    ldy #.sizeof(SpriteData)*63
@loop:
    .repeat 4, i
    lda SpritesA, x
    sta SpritesB, y
    inx
    iny
    .endrepeat

    .repeat 8
    dey
    .endrepeat

    cpx #0
    bne @loop

    rts

CopyRevSprites_Unrolled:
    .repeat 64, i
        .repeat 4, j
            lda SpritesA+j+(i*4)
            sta SpritesB+j+((63-i)*4)
        .endrepeat
    .endrepeat
    rts

; A or B selected with value in X
WriteObjects:
    lda #$00
    sta $2003

    cpx #0
    bne :+
    lda #.hibyte(SpritesA)
    jmp :++
:
    lda #.hibyte(SpritesB)
:

    ;lda #$02
    sta $4014
    rts

; Beginning of data in AddressPointer1
; Object ID in X on return
LoadObject:
    ; find empty spot
    ldx #0
:
    lda LoadedSprites_Hi, x
    beq :++
    inx
    cpx #.sizeof(LoadedSprites_Hi)
    bne :+
    ; cant fit? give up.
    rts
:
    jmp :--
:

    lda AddressPointer1+0
    sta LoadedSprites_Lo, x
    lda AddressPointer1+1
    sta LoadedSprites_Hi, x
    rts

; Object ID in X
UnloadObject:
    cpx #.sizeof(LoadedSprites_Hi)-1
    jmp @last

    txa
    tay
    iny
@loop:
    lda LoadedSprites_Hi, y
    sta LoadedSprites_Hi, x
    inx
    iny
    cpy #.sizeof(LoadedSprites_Hi)
    bne @loop

@last:
    lda #0
    sta LoadedSprites_Hi, x
    sta LoadedSprites_Lo, x
    rts
