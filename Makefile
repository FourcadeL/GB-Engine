#####################################################################
##                           ROM NAME                              ##

NAME = game
EXT	 = gb

##                                                                 ##
#####################################################################

#####################################################################
##                    PATH TO RGBDS BINARIES                       ##

RGBASM  = rgbasm
RGBLINK = rgblink
RGBFIX  = rgbfix

##                                                                 ##
#####################################################################

#####################################################################
##																   ##
ARIACOMP = ./aria
##																   ##
#####################################################################

#####################################################################
##						ASSEMBLY FLAGS							   ##

ASMFLAGS = 

##																   ##
#####################################################################

#####################################################################
##        Source and include folders - including subfolders        ##

SOURCE = ./sources

##                                                                 ##
#####################################################################



#####################################################################
##             Récupération des éléments à build                   ##

BRANCH := $(shell git symbolic-ref -q --short HEAD)
DATE := $(shell date +"%d-%m-%Y_%Hh%M")
BUILDNAME := $(NAME)_build_$(BRANCH)_$(DATE)
TMPNAME := tmp_build

FINALBIN := $(NAME).$(EXT)
TMPBIN := $(TMPNAME).$(EXT)
BIN := $(BUILDNAME).$(EXT)

MYSOURCES := $(shell find $(SOURCE) -type d -print)
SOURCES := $(foreach dir,$(MYSOURCES),$(CURDIR)/$(dir))

SONGFILES := $(foreach dir,$(MYSOURCES), $(wildcard $(dir)/*.sng))

# Tells Make to keep intermediate .asm songfiles
.SECONDARY: $(SONGFILES:.sng=.asm)

# Construct the global asm files pool while avoiding duplicates
ASMPURE := $(foreach dir,$(MYSOURCES),$(wildcard $(dir)/*.asm)) #every asm file (found in directories)
ASMFILES := $(filter-out $(SONGFILES:.sng=.asm), $(ASMPURE)) $(SONGFILES:.sng=.asm) #filter out every song-generated asm duplicate files from the complete list of asm

# Make it include all source folders - Add a '/' at the end of the path
INCLUDES := $(foreach dir,$(MYSOURCES),-i $(dir)/)

# Prepare object paths
OBJ = $(ASMFILES:.asm=.obj)


##                                                                 ##
#####################################################################






#####################################################################
##                   Build and dependancies                        ##

all:	tmp_build

tmp_build:	$(TMPBIN)

build:	$(BIN)
	@rm -f $(OBJ)

final:	$(FINALBIN)
	@rm -f $(OBJ)

rebuild:
	make clean
	make
	@rm -f $(OBJ)

clean:
	@echo rm $(OBJ) $(BIN) $(NAME).sym $(NAME).map
	@rm -f $(OBJ) $(BIN) $(NAME).sym $(NAME).map

%.asm : %.sng
	$(ARIACOMP) -o $@ -f $<

%.obj : %.asm
#	@echo rgbasm $@ $<
	$(RGBASM) $(ASMFLAGS) $(INCLUDES) -o $@ $<

$(BIN): $(OBJ)
#	@echo rgblink $(BIN)
	$(RGBLINK) -o $(BIN) -p 0xFF -m $(BUILDNAME).map -n $(BUILDNAME).sym $(OBJ)
#	@echo rgbfix $(BIN)
	$(RGBFIX) -p 0xFF -v $(BIN)

$(TMPBIN):   $(OBJ)
#	@echo rgblink $(TMPBIN)
	$(RGBLINK) -o $(TMPBIN) -p 0xFF -m $(TMPNAME).map -n $(TMPNAME).sym $(OBJ)
#	@echo rgbfix $(TMPBIN)
	$(RGBFIX) -p 0xFF -v $(TMPBIN)

$(FINALBIN): $(OBJ)
#	@echo rgblink $(FINALBIN)
	$(RGBLINK) -o $(FINALBIN) -p 0xFF -m $(NAME).map -n $(NAME).sym $(OBJ)
#	@echo rgbfix $(FINALBIN)
	$(RGBFIX) -p 0xFF -v $(FINALBIN)

#####################################################################

