COMPILER = ../bin/pmas
INCLUDE_FILES = $(wildcard src/**/.{asm,bin})
TILES = src/includes/tiles
ROM = refurb

# try to assemble the "runtime" file as standalone file (as if included elsewhere)
# then create the binary of the dot command
$(ROM).min: src/$(ROM).asm $(INCLUDE_FILES) Makefile $(TILES).bin
	cd src; $(COMPILER) $(ROM).asm ../$(ROM).min ../$(ROM).sym > /dev/null

$(TILES).bin: $(TILES).bmp
	bin/bmp2bin -m $(TILES).bmp $@

.PHONY: all clean

all:  $(ROM).min

clean:
	$(RM) -f $(ROM).min $(ROM).sym $(TILES).bin
