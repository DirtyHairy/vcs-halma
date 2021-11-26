DASM = DASM

source = halma.asm
binary = $(source:.asm=.bin)

all: bin

bin: $(binary)

clean:
	rm -f $(binary)

%.bin : %.asm
	$(DASM) $< -f3 -o$@

.PHONY: all bin clean
