;###############
; POC : Another Breakout Clone
;
; main game function that takes advantage of the written engine
;###############

	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"
	INCLUDE "debug.inc"

;#########Constants definition#############
PLAYER_START_X EQU 43
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


;--------- field informations ----
FIELD_START_ADDR EQU $9821
FIELD_WIDTH_VAL EQU 18

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

    ld bc, _abc_tileset_end - _abc_tileset_start
    ld hl, _abc_tileset_start
    ld de, _VRAM + $0800
    call vram_copy

    ; dessin de l'outline
    call set_outline

    ; mise en place des valeurs initiales du joueur
    ld a, PLAYER_START_X
    ld hl, _player_X_pos
    ld [hl], a

    ld a, PLAYER_START_Y
    ld hl, _player_Y_pos
    ld [hl], a


    ; instanciation du sprite player
    ld b, %00001000 ; see sprite.asm for infos
    ld c, %00010011 ; sprite dimensions (1*3)
    call Sprite_new
    ld [_player_sprite], a

    ; mise en place des graphix
    ld b, a
    ld hl, _player_tiles_ids_start
    call Sprite_set_tiles


    PRINT_DEBUG "abc init done"
    ret


;---------------------
;- abc_main()
;- main gameblay loop for abc interaction
;---------------------
abc_main::
    call getInput
    call movePlayer
    call update_player_sprite
    call wait_vbl
    jr abc_main


;--------------------------
;- update_player_sprite()
;- met à jour la position du sprite représentant le joueur
;- a parir des position du joueur
;--------------------------
update_player_sprite:
    ; calcul de la position X du sprite
    ld a, [_player_X_pos]
    sub a, SPRITE_PLAYER_OFFSET
    ld c, a
    ld a, [_player_sprite]
    ld b, a
    call Sprite_set_Xpos

    ld a, [_player_Y_pos]
    ld c, a
    ld a, [_player_sprite]
    ld b, a
    call Sprite_set_Ypos

    ; update ce nouveau sprite
    call Sprite_update_OAM
    ret


;------------------
;- movePlayer()
;- modifie la position du joueur
;- en fonction des inputs
;-------------------
movePlayer:
    ld a, [PAD_hold]
    and PAD_LEFT
    jr z, .skip_left
    ld hl, _player_X_pos
    ld a, [hl]
    sub a, PLAYER_X_SPEED
    ld [hl], a
.skip_left
    ld a, [PAD_hold]
    and PAD_RIGHT
    jr z, .skip_right
    ld hl, _player_X_pos
    ld a, [hl]
    add a, PLAYER_X_SPEED
    ld [hl], a
.skip_right
    ld a, [PAD_pressed]
    and PAD_A
    jr z, .skip_flip
    ; doing a sprite flip for fun and because I want to test stuff
    PRINT_DEBUG "flip set"
    ld a, [_player_sprite]
    ld b, a
    ld c, %00101000
    call Sprite_set_attr
.skip_flip
    ld a, [PAD_pressed]
    and PAD_B
    jr z, .skip_flip_reset
    ; reseting sprite flip
    PRINT_DEBUG "flip reset"
    ld a, [_player_sprite]
    ld b, a
    ld c, %00001000
    call Sprite_set_attr
.skip_flip_reset
    ret

;-----------------------------------------------

;-------------------------
;- set_outline()
;- set the the screen outline
;-------------------------
set_outline:
    ld bc, $0001
    ld hl, _SCRN0
    ld d, TILE_LEFT_CORNER_ID
    call vram_set
    ld bc, $0012
    ld hl, _SCRN0 + $01
    ld d, TILE_TOP_ID
    call vram_set
    ld bc, $0001
    ld hl, _SCRN0 + $13
    ld d, TILE_RIGHT_CORNER_ID
    call vram_set

    ld b, $10
    ld hl, _SCRN0 + $20
.loop_for_borders
    push bc
    push hl
    ld  bc, $0001
    ld d, TILE_LEFT_ID
    call vram_set
    pop hl
    ADD_U16_hl_val $0013
    push hl
    ld bc, $0001
    ld d, TILE_RIGHT_ID
    call vram_set
    pop hl
    ADD_U16_hl_val $000D
    pop bc
    dec b
    jr nz, .loop_for_borders

    ld bc, $0001
    ld hl, _SCRN0 + $0220
    ld d, TILE_LEFT_END_ID
    call vram_set
    ld bc, $0001
    ld hl, _SCRN0 + $0233
    ld d, TILE_RIGHT_END_ID
    call vram_set
    ret



;---------------------
;- set_brick_layer() bc = data table start pointer
;- sets up the brick layer 
;- from a data table pointer
;-   detail :
;-     each brick is two tiles wide
;-     they are filled tile by tile (so semi offsetted brick can exist)
;-     each byte entry is as follows :
;-       %iiiiiiiP : i -> the brick id (7 bits)
;-                   P -> the placement bit : 0 is left tile of the brick 1 is right tile of the brick
;-       a zero byte indicates an empty space (1 tile wide)
;-       so the backgroud image should be placed at this til 
;-------------------------------
set_brick_layer:
    ld hl, _brick_layer_start; hl will serve as the write register
    ld de, _brick_layer_end - _brick_layer_start ; counter of filled infos for loop
.loop
    ld a, [bc]
    and $FF
    jr z, empty_space ; empty space in layer, dont add anything
    ;TODO
.empty_space
    ld [hl+], a
    dec [hl] de
    ;TODO





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
