    processor 6502
	include vcs.h
	include macro.h
    include halma_macro.h

    seg.u vars
    org $B2

cursorX     .byte
cursorY     .byte
blink       .byte
lastSwcha   .byte
scratch0    .byte

    seg code_main
    org $F000

COLOR_BAD_FIELD = 0
COLOR_FIELD_TAKEN = $D6
COLOR_FIELD_FREE = $1C

MASKED_FIELD_TAKEN = $D0
MASKED_FIELD_FREE = $10

Start
    CLD
    LDX #0
    TXA
    TAY
InitMemory
    STA 0,X
    DEX
    BNE InitMemory
    TXS

Init:
    LDA #03
    STA cursorX
    STA cursorY

    LDA SWCHA
    STA lastSwcha

; TODO: Off by one --- why?
    LDX #50
InitMatrixLoop:
    DEX
    LDA startField,X
    STA $80,X
    TXA
    BNE InitMatrixLoop

    LDA #%11100000
    STA PF0
    LDA #%00111001
    STA PF1
    LDA #%01110011
    STA PF2
    LDA #0
    STA CTRLPF

MainLoop:
    LDA #$02
    STA VSYNC
    STA VBLANK
    STA WSYNC
    STA WSYNC
    STA WSYNC

    LDA #0
    STA VSYNC

Vblank
    LDA #53
    STA TIM64T

resetField:
    CalculateCurrentIndex cursorX,cursorY

    LDA $80,Y
    AND #$f0

    CMP #MASKED_FIELD_TAKEN
    BEQ resetFieldTaken

    CMP #MASKED_FIELD_FREE
    BEQ resetFieldFree

    JMP afterResetField

resetBadField:
    LDA #COLOR_BAD_FIELD
    JMP afterResetField

resetFieldTaken:
    LDA #COLOR_FIELD_TAKEN
    JMP afterResetField

resetFieldFree:
    LDA #COLOR_FIELD_FREE
    JMP afterResetField

afterResetField:
    STA $80,Y

handleJoystick:
    LDA SWCHA
    TAX
    EOR lastSwcha
    STA scratch0
    TXA
    EOR #$FF
    AND scratch0
    STX lastSwcha
    STA scratch0

    BMI right

    LDA #$40
    BIT scratch0
    BNE left

    LDA #$20
    BIT scratch0
    BNE down

    LDA #$10
    BIT scratch0
    BNE up

    JMP afterHandleJoystick

left:
    LDX cursorX
    DEX
    STX scratch0

    BMI afterLeft

    CalculateCurrentIndex scratch0, cursorY
    LDA $80,Y
    BEQ afterLeft

    LDA scratch0
    STA cursorX
afterLeft:
    JMP afterHandleJoystick

right:
    LDX cursorX
    INX
    STX scratch0
    TXA

    CMP #7
    BCS afterRight

    CalculateCurrentIndex scratch0, cursorY
    LDA $80,Y
    BEQ afterRight

    LDA scratch0
    STA cursorX
afterRight:
    JMP afterHandleJoystick

up:
    LDX cursorY
    DEX
    STX scratch0

    BMI afterUp

    CalculateCurrentIndex cursorX, scratch0
    LDA $80,Y
    BEQ afterUp

    LDA scratch0
    STA cursorY
afterUp:
    JMP afterHandleJoystick

down:
    LDX cursorY
    INX
    STX scratch0
    TXA

    CMP #7
    BCS afterHandleJoystick

    CalculateCurrentIndex cursorX, scratch0
    LDA $80,Y
    BEQ afterHandleJoystick

    LDA scratch0
    STA cursorY

afterHandleJoystick:

animateBlink:
    INC blink
    LDA blink
    LSR
    AND #$0f
    STA scratch0

    CalculateCurrentIndex cursorX,cursorY

    LDA $80,Y
    AND #$f0
    EOR scratch0
    STA $80,Y


WaitVblank:
    LDA INTIM
    BNE WaitVblank

    STA WSYNC
    STA VBLANK
Kernel:

    JMP .rowAlign0
    ALIGN 256
.rowAlign0
    DrawRow 128
    DrawRow 135
    DrawRow 142

    JMP .rowAlign1
    ALIGN 256
.rowAlign1
    DrawRow 149
    DrawRow 156
    DrawRow 163

    JMP .rowAlign2
    ALIGN 256
.rowAlign2
    DrawRow 170

KernelBlank:
    LDX #4
KernelBlankLoop:
    STA WSYNC
    DEX
    BNE KernelBlankLoop

Overscan:
    LDA #$02
    STA VBLANK
    LDX #36
OverscanLoop:
    STA WSYNC
    DEX
    BNE OverscanLoop

    JMP MainLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

C___ = COLOR_BAD_FIELD
C_FF = COLOR_FIELD_FREE
C__X = COLOR_FIELD_TAKEN

    org $FF00
startField
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C__X, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C__X, C__X, C__X, C_FF, C__X, C__X, C__X
    .byte C__X, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___

    org $FFFC
	.word Start
	.word Start
