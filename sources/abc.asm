;###############
; POC : Another Breakout Clone
;
; main game function that takes advantage of the written engine
;###############

	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"
	INCLUDE "debug.inc"

;#########Constants definition#############
PLAYER_START_X EQU 20
PLAYER_START_Y EQU 147

PLAYER_X_SPEED EQU $01

TILE_LEFT_CORNER_ID EQU $80
TILE_TOP_ID EQU $81
TILE_RIGHT_CORNER_ID EQU $82
TILE_LEFT_ID EQU $83
TILE_RIGHT_ID EQU $85
TILE_LEFT_END_ID EQU $98
TILE_RIGHT_END_ID EQU $99

SPRITE_PLAYER_OFFSET EQU $0B
;##########################################


    SECTION "ABC_functions", ROM0

;------------
;- abc_init()
;- initialize data for main gameblay
;------------
abc_init::
    ; écriture du tileset dans la VRAM
    ld bc, _abc_tileset_end - _abc_tileset_start
    ld hl, _abc_tileset_start
    ld de, _VRAM
    call vram_copy


    ; instanciation du sprite player
    ld b, %00001000 ; see sprite.asm for infos
    ld c, %00010011 ; sprite dimensions (1*3)
    call Sprite_new
    ld [_player_sprite], a

    ; mise en place des graphix
    ld b, a
    ld hl, _player_tiles_ids_start
    call Sprite_set_tiles

    ; mise en place de la position du sprite
    ld a, [_player_sprite]
    ld b, a
    ld c, PLAYER_START_X
    call Sprite_set_Xpos

    ld a, [_player_sprite]
    ld b, a
    ld c, PLAYER_START_Y
    call Sprite_set_Ypos

    ; update ce nouveau sprite
    call Sprite_update_OAM

    PRINT_DEBUG "abc init done"
    ret


;---------------------
;- abc_main()
;- main gameblay loop for abc interraction
;---------------------
abc_main::
    call getInput



; ##################################
    SECTION "ABC_Data", ROMX


_abc_tileset_start:
INCBIN "./bin/tileset_v0.1.bin"
_abc_tileset_end:

_player_tiles_ids_start:
DB $15, $16, $17





; ###################################
    SECTION "ABC_Variables", WRAM0

_player_sprite: DS 1 ; indicateur du sprite du joueur

_player_X_pos: DS 1 ; position du joueur X
_player_Y_pos: DS 1 ; position du joueur Y



; the brick layer is stored in a table of size 18*17
; this table is stored here for reference of collisions
_brick_layer_start:
    DS $0132
_brick_layer_end:
