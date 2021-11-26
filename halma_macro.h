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

    MAC DrawRow
.separatorTop:
    LDA #0
    STA COLUPF
    LDX #6
.separatorTopLoop:
    STA WSYNC
    DEX
    BNE .separatorTopLoop

    LDX #18
    STA WSYNC

.row:
    LineKernel {1}

.separatorBottom:
    LDA #0
    STA COLUPF
    LDX #7
.separatorBottomLoop:
    STA WSYNC
    DEX
    BNE .separatorBottomLoop
    ENDM
