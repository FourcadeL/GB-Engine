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

NB_UNIQUE_TILES EQU 42 ; number of unique tiles available to the fwf text engine
                        ; can't be more than 127

;-------------------------------------------------------
;- GET_NEXT_FREE_TILE_OFFSET() -> b = tile id offset to use ; c = tile id to use
;- [hl, a, b, c]
;-------------------------------------------------------
MACRO GET_NEXT_FREE_TILE_OFFSET
    ld hl, _next_used_tile_id_offset
    ld a, [hl]
    ld b, a
    inc a
    cp a, NB_UNIQUE_TILES
    jr nz, .end_procedure
    
    ld a, $00
.end_procedure
    ld [hl], a
    ld a, b
    ld hl, _first_tile_id
    add a, [hl]
    ld c, a
ENDM

;---------------------------------------
;- GET_TILE_VRAM_ADDR(a = tile id) -> hl = VRAM addr of the tile
;- [a, hl, b]
;---------------------------------------
MACRO GET_TILE_VRAM_ADDR
    ld h, HIGH($8000)
    cp a, $80
    jr nc, .get_address
    ld h, HIGH($9000)
.get_address
    swap a
    ld b, a
    and a, %11110000
    ld l, a
    ld a, b
    and a, %00001111
    add a, h
    ld h, a
ENDM


    SECTION "fwf_functions", ROM0

;------------------------------------------
;- fwf_init(c = first tile index)
;- initialisation of fwf
;------------------------------------------
fwf_init::
    ; setup tile ids table
    ld a, c
    ld [_first_tile_id], a

    ; setup variables
    ld a, $00
    ld [_next_used_tile_id_offset], a
    
    ; setup characters blocks table
    ld d, $00
    ld b, $FF
    ld hl, __FWF_characters_blocks_start
    call memset_fast
    ret

;--------------------------------------------
;- fwf_flush()
;- flushes all initialised characters for a new write
;--------------------------------------------
fwf_flush::
    ld hl, __FWF_characters_blocks_start
    ld d, $FF
.erase_loop
    res 7, [hl]
    inc hl
    dec d
    jr nz, .erase_loop
    ld hl, _next_used_tile_id_offset
    ld [hl], $00
    ret

;-----------------------------------
;- fwf_display_char(l = char to display, de = tilemap destination addr)
;- displays character l on tilemap addr de
;-----------------------------------
fwf_display_char::
    push de
    ld h, HIGH(__FWF_characters_blocks_start)
    push hl
    bit 7, [hl]
    call z, fwf_init_char

    pop hl
    ld a, [hl]
    and a, %01111111
    ld hl, _first_tile_id
    add a, [hl]
    ld d, a
    pop hl
    ld c, $01
    call vram_set_fast
    ret

;-----------------------------------------------
;- fwf_init_char(l = char to initialize) -> ()
;- initialize character l
;- -> copy character tile data in VRAM
;- -> sets access attributes in character blocks
;-----------------------------------------------
fwf_init_char:
    push hl
    GET_NEXT_FREE_TILE_OFFSET
    pop hl
    ld h, HIGH(__FWF_characters_blocks_start)
    ld a, b
    or a, %10000000
    ld [hl], a
    push hl
    ld a, c
    GET_TILE_VRAM_ADDR
    pop de
    push hl
    ld l, e
    call fwf_get_tile_data_addr
    pop de
    ld c, $10
    call vram_copy_fast
    ret

    SECTION "fwf_characters_blocks", WRAM0, ALIGN[8]
__FWF_characters_blocks_start:
    DS $FF ; 
__FWF_characters_blocks_end:


    SECTION "fwf_variables", WRAM0
_next_used_tile_id_offset: DS 1
_first_tile_id: DS 1