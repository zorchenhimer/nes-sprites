.pushseg
.segment "zeropage"

.segment "BSS"

LoadedSprites_Lo: .res 8
LoadedSprites_Hi: .res 8

LoadedSprites_CoordX: .res 8
LoadedSprites_CoordY: .res 8

.popseg

UpdateObjects:
    lda #.lobyte(SpritesA)
    sta AddressPointer2+0
    lda #.hibyte(SpritesA)
    sta AddressPointer2+1

    ldx #0
    ;ldy #0
@loopObj:
    lda LoadedSprites_Lo, x
    sta AddressPointer1+0
    lda LoadedSprites_Hi, x
    sta AddressPointer1+1
    beq @justNext

    ldy #0
    lda (AddressPointer1), y
    sta TmpX

    inc AddressPointer1+0
    bne @loopData
    inc AddressPointer1+1
@loopData:
    ldy #ObjectData::Tile
    lda (AddressPointer1), y
    ldy #SpriteData::Tile
    sta (AddressPointer2), y

    ldy #ObjectData::Attr
    lda (AddressPointer1), y
    ldy #SpriteData::Attr
    sta (AddressPointer2), y

    clc
    ldy #ObjectData::OffsetX
    lda (AddressPointer1), y
    adc LoadedSprites_CoordX, x
    ldy #SpriteData::CoordX
    sta (AddressPointer2), y

    clc
    ldy #ObjectData::OffsetY
    lda (AddressPointer1), y
    adc LoadedSprites_CoordY, x
    ldy #SpriteData::CoordY
    sta (AddressPointer2), y

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

    lda AddressPointer2+1
    adc #0
    sta AddressPointer2+1

@justNext:
    inx
    cpx #.sizeof(LoadedSprites_Hi)
    beq @done
    jmp @loopObj
@done:

    ldy #0
@clearLoop:
    lda AddressPointer2+0
    beq :+

    lda #$FF
    sta (AddressPointer2), y
    clc
    lda AddressPointer2+0
    adc #.sizeof(SpriteData)
    sta AddressPointer2+0
    bcs :+
    jmp @clearLoop
:

    jmp CopyRevSprites
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
