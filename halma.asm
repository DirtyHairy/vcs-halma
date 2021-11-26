    processor 6502
	include vcs.h
	include macro.h

    seg code_main
    org $F000

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

DrawColumns:
    LDY #7
DrawColumnsLoop:

DrawSeparatorTop:
    LDA #0
    STA COLUPF
    LDX #7
DrawSeparatorTopLoop:
    STA WSYNC
    DEX
    BNE DrawSeparatorTopLoop

DrawLine:
    LDA #$B4
    STA COLUPF
    LDX #18
DrawLineLoop:
    STA WSYNC
    DEX
    BNE DrawLineLoop

DrawSeparatorBottom:
    LDA #0
    STA COLUPF
    LDX #7
DrawSeparatorBottomLoop:
    STA WSYNC
    DEX
    BNE DrawSeparatorBottomLoop

    DEY
    BNE DrawColumnsLoop

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

    org $FFFC
	.word Start
	.word Start
