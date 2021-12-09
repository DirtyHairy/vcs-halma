DASM   = dasm
STELLA = stella

source = halma.asm
binary = $(source:.asm=.bin)

all: bin

bin: $(binary)

run: $(binary)
	$(STELLA) $(binary)

run-bg: $(binary)
	pkill stella; true
	$(STELLA) $(binary) &

clean:
	rm -f $(binary) $(binary:.bin=.lst) $(binary:.bin=.sym)

%.bin : %.asm halma_macro.h
	$(DASM) $< -f3 -o$@ -l$(binary:.bin=.lst) -s$(binary:.bin=.sym)

.PHONY: all bin clean
