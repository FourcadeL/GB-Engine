; #######################################
; Player functions
; 
;   move
;   shoot
; #######################################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "charmap.inc"


    SECTION "Player_code", ROMX

Player_init::
    ; reset variables
    ld      d, $00
    ld      hl, _player_variables_start
    ld      b, _player_variables_end - _player_variables_start
    call    memset_fast

    ; create player sprite
    ld      b, %00001000 ; sprite displayed
    ld      c, $12      ; sprite height = 1 width = 2
    call    Sprite_new ; new sprite
    ld      [player_sprite_idx], a ;save sprite idx
    
    ld      hl, player_frame_1_tiles
    ld      b, a
    call    Sprite_set_tiles

    ret


Player_update::
    ; BASIC POSITION UPDATE
    ld hl, player_Xpos
    ld a, [PAD_hold]
    and PAD_RIGHT
    cp a, PAD_RIGHT
    jr nz, .skip_right
    inc [hl]
.skip_right
    ld hl, player_Xpos
    ld a, [PAD_hold]
    and PAD_LEFT
    cp a, PAD_LEFT
    jr nz, .skip_left
    dec [hl]
.skip_left
    ld hl, player_Ypos
    ld a, [PAD_hold]
    and PAD_DOWN
    cp a, PAD_DOWN
    jr nz, .skip_down
    inc [hl]
.skip_down
    ld hl, player_Ypos
    ld a, [PAD_hold]
    and PAD_UP
    cp a, PAD_UP
    jr nz, .skip_up
    dec [hl]
.skip_up

    ; SPRITE POSITION BASIC UPDATE
    ld a, [player_sprite_idx]
    ld b, a
    ld a, [player_Xpos]
    ld c, a
    call Sprite_set_Xpos
    ld a, [player_sprite_idx]
    ld b, a
    ld a, [player_Ypos]
    ld c, a
    call Sprite_set_Ypos
    ld a, [player_sprite_idx]
    call Sprite_update_OAM
    ret


    
; STATIC DATA FOR PLAYER
player_frame_1_tiles:
    DB $04, $06
player_frame_2_tiles:
    DB $08, $0A

    SECTION "Player_variables", WRAM0
_player_variables_start:
player_state::      DS 1
player_sprite_idx:: DS 1
player_Xpos::       DS 2
player_Ypos::       DS 2
_player_variables_end: