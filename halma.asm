    processor 6502
	include vcs.h
	include macro.h
    include halma_macro.h

    seg.u vars
    org $B2

cursorX         .byte
cursorY         .byte
selectedX       .byte
selectedY       .byte
hasSelection    .byte
blink           .byte
lastSwcha       .byte
lastInpt4       .byte
lastSwchb       .byte
currentField    .byte
scratch0        .byte
scratch1        .byte

    seg code_main
    org $F800

COLOR_FIELD_TAKEN = $D6
COLOR_FIELD_FREE = $16
COLOR_FIELD_SELECTED = $66

NUMBER_OF_FIELDS = 6

Start
    CLD
    LDX #$FF
    TXS
    LDX #0
    TXA
    TAY
InitMemory
    STA 0,X
    DEX
    BNE InitMemory

    LDA #%11100000
    STA PF0
    LDA #%00111001
    STA PF1
    LDA #%01110011
    STA PF2
    LDA #0
    STA CTRLPF

    LDA #$FF
    STA lastSwcha
    STA lastSwchb

    LDA #$80
    STA lastInpt4

    JSR Reset

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

    CMP #(COLOR_FIELD_TAKEN & $F0)
    BEQ resetFieldTaken

    CMP #(COLOR_FIELD_FREE & $F0)
    BEQ resetFieldFree

    CMP #(COLOR_FIELD_SELECTED & $F0)
    BEQ resetFieldSelected

    JMP afterResetField

resetFieldTaken:
    LDA #COLOR_FIELD_TAKEN
    JMP afterResetField

resetFieldFree:
    LDA #COLOR_FIELD_FREE
    JMP afterResetField

resetFieldSelected:
    LDA #COLOR_FIELD_SELECTED
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

handleFire:
    LDA INPT4
    TAX
    EOR lastInpt4
    STA scratch0
    TXA
    EOR #$FF
    STX lastInpt4
    AND scratch0
    BPL afterHandleFire

    CalculateCurrentIndex cursorX, cursorY
    LDA $80,Y
    AND #$F0
    CMP #(COLOR_FIELD_FREE & $F0)
    BNE moveSelection
    JSR AttemptMove
    JMP afterHandleFire

moveSelection:
deselectCurrent:
    LDA hasSelection
    BEQ afterDeselectCurrent
    CalculateCurrentIndex selectedX, selectedY
    LDA #(COLOR_FIELD_TAKEN)
    STA $80,Y
afterDeselectCurrent:

    LDA hasSelection
    BEQ selectNew

    LDA #0
    STA hasSelection

    LDA cursorX
    CMP selectedX
    BNE selectNew
    LDA cursorY
    CMP selectedY
    BNE selectNew
    JMP afterHandleFire

selectNew:
    LDA #1
    STA hasSelection
    LDA cursorX
    STA selectedX
    LDA cursorY
    STA selectedY
    CalculateCurrentIndex cursorX, cursorY
    LDA #(COLOR_FIELD_SELECTED)
    STA $80,Y

afterHandleFire:

handleConsole:
    LDA SWCHB
    TAX
    EOR lastSwchb
    STA scratch0
    TXA
    EOR #$FF
    AND scratch0
    STX lastSwchb
    STA scratch0

    LDA #1
    BIT scratch0
    BNE handleReset

    LDA #2
    BIT scratch0
    BNE handleSelect

    JMP afterHandleComsole

handleSelect:
    INC currentField
    LDA currentField
    CMP #(NUMBER_OF_FIELDS)
    BCC handleReset
    LDA #0
    STA currentField

handleReset:
    JSR Reset

afterHandleComsole:


animateBlink:
    INC blink
    LDA blink
    LSR
    LSR
    AND #$07
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
; SUBROUTINE AttemptMove
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AttemptMove SUBROUTINE
    LDA hasSelection
    BNE AttemptMoveSameLine
    RTS

AttemptMoveSameLine:
    LDA cursorY
    CMP selectedY
    BEQ AttemptMoveRight
    JMP AttemptMoveSameCol

AttemptMoveRight:
    LDA cursorX
    CLC
    ADC #2
    CMP selectedX
    BNE AttemptMoveLeft

    STA scratch0
    SEC
    SBC #1
    STA scratch1

    CalculateCurrentIndex scratch1, cursorY
    LDA $80,Y
    AND #$F0
    CMP #(COLOR_FIELD_TAKEN & $F0)
    BNE AttemptMoveLeft
    JMP ApplyMove

AttemptMoveLeft:
    LDA cursorX
    SEC
    SBC #2
    CMP selectedX
    BNE AttemptMoveSameCol

    STA scratch0
    CLC
    ADC #1
    STA scratch1

    CalculateCurrentIndex scratch1, cursorY
    LDA $80,Y
    AND #$F0
    CMP #(COLOR_FIELD_TAKEN & $F0)
    BNE AttemptMoveSameCol
    JMP ApplyMove

AttemptMoveSameCol:
    LDA cursorX
    CMP selectedX
    BEQ AttemptMoveDown
    RTS

AttemptMoveDown:
    LDA cursorY
    CLC
    ADC #2
    CMP selectedY
    BNE AttemptMoveUp

    STA scratch0
    SEC
    SBC #1
    STA scratch1

    CalculateCurrentIndex cursorX, scratch1
    LDA $80,Y
    AND #$F0
    CMP #(COLOR_FIELD_TAKEN & $F0)
    BNE AttemptMoveUp
    JMP ApplyMove

AttemptMoveUp:
    LDA cursorY
    SEC
    SBC #2
    CMP selectedY
    BNE AttemptMoveEnd

    STA scratch0
    CLC
    ADC #1
    STA scratch1

    CalculateCurrentIndex cursorX, scratch1
    LDA $80,Y
    AND #$F0
    CMP #(COLOR_FIELD_TAKEN & $F0)
    BNE AttemptMoveEnd

ApplyMove
    LDA #COLOR_FIELD_FREE
    STA $80,Y
    CalculateCurrentIndex selectedX, selectedY
    LDA #COLOR_FIELD_FREE
    STA $80,Y
    CalculateCurrentIndex cursorX, cursorY
    LDA #COLOR_FIELD_TAKEN
    STA $80,Y
    LDA #0
    STA hasSelection

AttemptMoveEnd:
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUBROUTINE Reset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Reset SUBROUTINE
    LDA #03
    STA cursorX
    STA cursorY

    LDA #0
    STA selectedX
    STA selectedY
    STA hasSelection
    STA blink

    LDY #49
    LDA #0
    STA scratch0
    LDA #(>startField)
    STA scratch1
    LDX currentField
    INX
SelectField:
    DEX
    BEQ InitMatrixLoop
    LDA scratch0
    CLC
    ADC #49
    STA scratch0
    LDA scratch1
    ADC #0
    STA scratch1
    JMP SelectField

InitMatrixLoop:
    DEY
    LDA (scratch0),Y
    STA $80,Y
    TYA
    BNE InitMatrixLoop

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

C___ = #0
C_FF = COLOR_FIELD_FREE
C__X = COLOR_FIELD_TAKEN

    org $FE00
startField
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C__X, C__X, C__X, C__X, C__X, C___
    .byte C__X, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C__X, C__X, C__X, C_FF, C__X, C__X, C__X
    .byte C__X, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C___, C__X, C__X, C__X, C__X, C__X, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___

    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C__X, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C__X, C__X, C__X, C_FF, C__X, C__X, C__X
    .byte C__X, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___

    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C___, C__X, C__X, C_FF, C__X, C__X, C__X
    .byte C___, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___

    .byte C___, C___, C___, C___, C___, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C__X, C__X, C__X, C__X, C__X, C___
    .byte C___, C__X, C__X, C_FF, C__X, C__X, C___
    .byte C___, C__X, C__X, C__X, C__X, C__X, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C___, C___, C___, C___, C___, C___

    .byte C___, C___, C___, C__X, C___, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C__X, C__X, C__X, C__X, C__X, C___
    .byte C__X, C__X, C__X, C_FF, C__X, C__X, C__X
    .byte C___, C__X, C__X, C__X, C__X, C__X, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C___, C___, C__X, C___, C___, C___

    .byte C___, C___, C___, C___, C___, C___, C___
    .byte C___, C___, C___, C_FF, C___, C___, C___
    .byte C___, C___, C__X, C__X, C__X, C___, C___
    .byte C___, C__X, C__X, C__X, C__X, C__X, C___
    .byte C__X, C__X, C__X, C__X, C__X, C__X, C__X
    .byte C___, C___, C___, C___, C___, C___, C___
    .byte C___, C___, C___, C___, C___, C___, C___

    org $FFFC
	.word Start
	.word Start
