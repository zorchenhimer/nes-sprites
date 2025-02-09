.PHONY: all env clean chr
.PRECIOUS: images/tiles1.bmp images/tiles2.bmp

CHRUTIL = ../go-nes/bin/chrutil

NAME = sprites
NESCFG = nes_nrom.cfg
CAFLAGS = -g -t nes
LDFLAGS = -C $(NESCFG) --dbgfile bin/$(NAME).dbg -m bin/$(NAME).map

SOURCES = \
	main.asm \
	sprites.asm \
	sprites.inc \
	utils.asm

CHR = \
	  tiles1.chr \
	  tiles2.chr \

all: env chr bin/$(NAME).nes
env: bin/

send: all
	./edlink-n8 bin/$(NAME).nes

clean:
	-rm bin/* *.chr *.i

bin/:
	-mkdir bin

bin/$(NAME).nes: bin/main.o
	ld65 $(LDFLAGS) -o $@ $^

bin/main.o: $(SOURCES) $(CHR)
	ca65 $(CAFLAGS) -o $@ main.asm

%.chr: images/%.bmp
	$(CHRUTIL) $< -o $@

images/%.bmp: images/%.aseprite
	aseprite -b $< --save-as $@
