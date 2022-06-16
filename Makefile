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
##        Source and include folders - including subfolders        ##

SOURCE = ./sources

##                                                                 ##
#####################################################################



#####################################################################
##             Récupération des éléments à build                   ##

BRANCH := $(shell git symbolic-ref -q --short HEAD)
DATE := $(shell date +"%d-%m-%Y_%Hh%M")
BUILDNAME := build_$(BRANCH)_$(DATE)

FINALBIN := $(NAME).$(EXT)
BIN := $(BUILDNAME).$(EXT)

MYSOURCES := $(shell find $(SOURCE) -type d -print)
SOURCES := $(foreach dir,$(MYSOURCES),$(CURDIR)/$(dir))

ASMFILES := $(foreach dir,$(MYSOURCES),$(wildcard $(dir)/*.asm))

# Make it include all source folders - Add a '/' at the end of the path
INCLUDES := $(foreach dir,$(MYSOURCES),-i $(dir)/)

# Prepare object paths
OBJ = $(ASMFILES:.asm=.obj)

##                                                                 ##
#####################################################################






#####################################################################
##                   Build and dependancies                        ##

all: $(BIN)
	@rm -f $(OBJ)

final: $(FINALBIN)
	@rm -f $(OBJ)

rebuild:
	@make clean
	@make
	@rm -f $(OBJ)

clean:
	@echo rm $(OBJ) $(BIN) $(NAME).sym $(NAME).map
	@rm -f $(OBJ) $(BIN) $(NAME).sym $(NAME).map

%.obj : %.asm
	@echo rgbasm $@ $<
	@$(RGBASM) $(INCLUDES) -o$@ $<

$(BIN): $(OBJ)
	@echo rgblink $(BIN)
	@$(RGBLINK) -o $(BIN) -p 0xFF -m $(BUILDNAME).map -n $(BUILDNAME).sym $(OBJ)
	@echo rgbfix $(BIN)
	@$(RGBFIX) -p 0xFF -v $(BIN)

$(FINALBIN): $(OBJ)
	@echo rgblink $(FINALBIN)
	@$(RGBLINK) -o $(FINALBIN) -p 0xFF -m $(NAME).map -n $(NAME).sym $(OBJ)
	@echo rgbfix $(FINALBIN)
	@$(RGBFIX) -p 0xFF -v $(FINALBIN)

#####################################################################

