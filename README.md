# Steckhalma for Atari 2600

This is [peg solitaire](https://en.wikipedia.org/wiki/Peg_solitaire)
(also called Steckhalma in German) for the Atari 2600

# How to play

You can select different boards via "Select Game" (`F1` on stella) 
Reset (`F2` on stella) is supported.
Use the Joystick to move the Cursor, select a peg by pressing fire,
move the cursor to the new position an move the peg by pressing fire again.
Only valid move will be supported!



# Prerequisites

* [dasm](https://dasm-assembler.github.io/)
* [stella](https://stella-emu.github.io/)

# How to build

```
make
```

# How to run in simulator

```
make run
```

# Code Build Run Loop

With [watchexec](https://github.com/watchexec/watchexec), you can easily
implement a watcher, that will rebuild and restart the ROM every time the
source file changes an on the file system, e.g. saving the ASM file in the
editor.


```
watchexec -e asm,h,bin -- make run-bg
```

