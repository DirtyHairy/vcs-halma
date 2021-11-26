    processor 6502
	include vcs.h
	include macro.h
    include halma_macro.h

    seg code_main
    org $F000

COLOR_BAD_FIELD = 0
COLOR_FIELD_TAKEN = $D6
COLOR_FIELD_FREE = $0C

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
    LDX #50
InitMatrixLoop:
    DEX
    LDA startField,X
    STA $80,X
    TXA
    BNE InitMatrixLoop

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

    LDA #%11100000
    STA PF0
    LDA #%00111001
    STA PF1
    LDA #%01110011
    STA PF2
    LDA #0
    STA CTRLPF

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
