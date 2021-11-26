DASM = DASM

source = halma.asm
binary = $(source:.asm=.bin)

all: bin

bin: $(binary)

clean:
	rm -f $(binary)

%.bin : %.asm halma_macro.h
	$(DASM) $< -f3 -o$@

.PHONY: all bin clean
