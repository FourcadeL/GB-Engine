; ################################################
; Static definitions of sprite handler values
; ################################################



    IF !DEF(SPRITES_INC)
DEF SPRITES_INC EQU 1

; objects mode
DEF MODE_16                 EQU 1   ; 1 = 8*16 objects mode

; Maximum number of sprites
DEF MAX_SPRITE_NUMBER       EQU 20

; Sprite stricture size
DEF SPRITE_STRUCTURE_SIZE   EQU 8

; Maximum number of display lists
DEF MAX_DISPLAYLIST_NUMBER  EQU 32



; Display list OAM attributes modes
DEF DL_DEFAULT EQU %00000000
;   FOR OAM FLAGS, SEE HARDWARE.INC DEFINITIONS
;   @OAMF section



;------------------------
; INDEXOF(tile addr)
;   returns the tile index associated to
;   the given tile addr
;------------------------
MACRO INDEXOF
    "(\1 - $8000) / 16"
ENDM



    ENDC ; SPRITES_INC
