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
PLAYER_START_Y EQU 120
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



