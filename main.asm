.include "nes2header.inc"
nes2mapper 0
nes2prg 1 * 16 * 1024
nes2chr 1 * 8 * 1024
nes2mirror 'V'
nes2tv 'N'
nes2end

.feature leading_dot_in_identifiers
.feature underline_in_numbers
.feature addrsize

;.struct SpriteObject
;Address .word
;CoordX .byte
;CoordY .byte
;.endstruct

.segment "ZEROPAGE"
Sleeping: .res 1
AddressPointer1: .res 2
AddressPointer2: .res 2
AddressPointer3: .res 2

TmpA: .res 1
TmpB: .res 1
TmpC: .res 1
TmpX: .res 1
TmpY: .res 1
TmpZ: .res 1

FrameCount: .res 1

;.segment "OAM"

.segment "BSS"
SpritesA: .res 256
SpritesB: .res 256

.segment "VECTORS0"
    .word NMI
    .word RESET
    .word IRQ

.segment "CHR0"
.incbin "tiles1.chr"

.segment "CHR1"
.incbin "tiles2.chr"

.segment "PAGE0"

.include "sprites.inc"

.include "utils.asm"
.include "sprites.asm"

Palette_Grey:
    .byte $20, $0F, $00, $10

IRQ:
    rti

NMI:
    pha
    txa
    pha

    lda #$3F
    sta $2006
    lda #$00
    sta $2006
    .repeat 4*8, i
        lda Palettes+i
        sta $2007
    .endrepeat

    inc FrameCount
    lda FrameCount
    and #$01
    tax
    ;ldx #0
    jsr WriteObjects

    bit $2002
    lda #0
    sta $2005
    sta $2005

    lda #$FF
    sta Sleeping

    lda #$80
    sta $2000

    lda #%0001_1110
    sta $2001

    pla
    tax
    pla
    rti

BgText:
    .asciiz "Henlo"

RESET:
    sei         ; Disable IRQs
    cld         ; Disable decimal mode

    ldx #$40
    stx $4017   ; Disable APU frame IRQ

    ldx #$FF
    txs         ; Setup new stack

    inx         ; Now X = 0

    stx $2000   ; disable NMI
    stx $2001   ; disable rendering
    stx $4010   ; disable DMC IRQs

:   ; First wait for VBlank to make sure PPU is ready.
    bit $2002   ; test this bit with ACC
    bpl :- ; Branch on result plus

:   ; Clear RAM
    lda #$00
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x

    inx
    bne :-  ; loop if != 0

:   ; Second wait for vblank.  PPU is ready after this
    bit $2002
    bpl :-

    lda #.lobyte(Palette_Grey)
    sta AddressPointer1+0
    lda #.hibyte(Palette_Grey)
    sta AddressPointer1+1
    ldx #0
    jsr LoadPalette

    ldx #4
    jsr LoadPalette

    ldx #' '
    jsr FillScreen

    ldx #0
    jsr FillAttributeTable

    lda #$20
    sta $2006
    lda #$00
    sta $2006

    ldx #0
:   lda BgText, x
    beq :+
    sta $2007
    inx
    jmp :-
:
    lda #$80
    sta $2000

    lda #%0001_1110
    sta $2001

    lda SpriteList+0
    sta AddressPointer1+0
    lda SpriteList+1
    sta AddressPointer1+1
    jsr LoadObject

    lda #10
    sta LoadedSprites_CoordX, x
    lda #30
    sta LoadedSprites_CoordY, x

    lda SpriteList+2
    sta AddressPointer1+0
    lda SpriteList+3
    sta AddressPointer1+1
    jsr LoadObject

    lda #30
    sta LoadedSprites_CoordX, x
    lda #30
    sta LoadedSprites_CoordY, x

    lda SpriteList+2
    sta AddressPointer1+0
    lda SpriteList+3
    sta AddressPointer1+1
    jsr LoadObject

    lda #90
    sta LoadedSprites_CoordX, x
    lda #30
    sta LoadedSprites_CoordY, x

    lda SpriteList+2
    sta AddressPointer1+0
    lda SpriteList+3
    sta AddressPointer1+1
    jsr LoadObject

    lda #150
    sta LoadedSprites_CoordX, x
    lda #30
    sta LoadedSprites_CoordY, x

Frame:
    jsr ReadControllers

    jsr UpdateObjects
    jsr WaitForNMI
    jmp Frame

