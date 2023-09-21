; #####################
; Fixed Width Font engine
; each character is a tile
; tile managment is optimised
; by writing at execution level
; tile data on each tile slot

; uses extended ascii table

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"

NB_UNIQUE_TILES EQU 64 ; number of unique tiles available to the fwf text engine

; TODO : pour l'instant seul la partie "récupération de la tile du caractère" est codée
; Je dois encore m'occuper de l'écriture dans la tilemap des lettres ajoutées

    SECTION "fwf_functions", ROM0

;------------------------------------------
;- fwf_init(c = first tile index)
;- initialisation of fwf
;------------------------------------------
fwf_init::
    ; setup tile ids table
    ld a, c
    ld b, NB_UNIQUE_TILES
    ld hl, __FWF_tiles_ids_start
.tile_table_set_loop
    ld [hli], a
    inc a
    dec b
    jr nz, .tile_table_set_loop

    ; setup variables
    ld a, 0
    ld [_next_used_tile_block], a
    
    ; setup characters blocks table
    ld d, $00
    ld b, $FF
    ld hl, __FWF_characters_blocks_start
    call memset_fast
    ret


    SECTION "fwf_characters_blocks", WRAM0, ALIGN[8]
__FWF_characters_blocks_start:
    DS $FF ; 
__FWF_characters_blocks_end:

    SECTION "fwf_tiles_ids", WRAM0, ALIGN[8]
__FWF_tiles_ids_start:
    DS NB_UNIQUE_TILES
__FWF_tiles_ids_end:

    SECTION "fwf_variables", WRAM0
_next_used_tile_block: DS 1

    SECTION "fwf_characters_data", ROM0