    processor 6502
	include vcs.h
	include macro.h

    seg code_main
    org $F000

    MAC LineKernel
.p0 SET ({1} + 0)
.p1 SET ({1} + 1)
.p2 SET ({1} + 2)
.p3 SET ({1} + 3)
.p4 SET ({1} + 4)
.p5 SET ({1} + 5)
.p6 SET ({1} + 6)

.loop
    DEX             ; 0 ->  2
    LDA #0          ; 2 ->  4
    STA COLUPF      ; 4 ->  7
    LDA .p0         ; 7 ->  10
    SLEEP 17        ; 10 -> 27

    STA COLUPF      ; 27 -> 30
    LDA .p1         ; 30 -> 33

    STA COLUPF      ; 33 -> 36
    LDA .p2         ; 36 -> 39

    STA COLUPF      ; 39 -> 42
    LDA .p3         ; 42 -> 45
    NOP             ; 45 -> 47

    STA COLUPF      ; 47 -> 50
    LDA .p4         ; 50 -> 53

    STA COLUPF      ; 53 -> 56
    LDA .p5         ; 56 -> 59

    STA COLUPF      ; 59 -> 62
    LDA .p6         ; 62 -> 65

    STA COLUPF      ; 65 -> 68
    LDA $85         ; 68 -> 71
    TXA             ; 71 -> 73
    BNE .loop       ; 73 -> 0
    NOP             ; 75 -> 1
    ENDM

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
    LDX #49
    LDA #42
InitMatrixLoop:
    STA $7F,X
    ADC #13
    DEX
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

DrawColumns:
    LDY #7
DrawColumnsLoop:

DrawSeparatorTop:
    LDA #0
    STA COLUPF
    LDX #6
DrawSeparatorTopLoop:
    STA WSYNC
    DEX
    BNE DrawSeparatorTopLoop

    LDX #18
    STA WSYNC

DrawRow:
    LineKernel $80

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
