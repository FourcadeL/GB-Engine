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

BIN	:= $(NAME).$(EXT)

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
	@$(RGBLINK) -o $(BIN) -p 0xFF -m $(NAME).map -n $(NAME).sym $(OBJ)
	@echo rgbfix $(BIN)
	@$(RGBFIX) -p 0xFF -v $(BIN)

#####################################################################

