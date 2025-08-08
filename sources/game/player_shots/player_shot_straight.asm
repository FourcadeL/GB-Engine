; #############################
; PS Straight
;
;   This file serves for behaviour and data
;   for the straight shots fired by the player
;
;   All gestion for display and update calls
;   are found in "player_shots.asm"
;       (maybe define here the update macro ?)
;
;   Straight shots are shots index 0 and 1 in the
;   player_shots tables
; #############################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "player_shots.inc"
INCLUDE "player_shot_straight.inc"




;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                    ROM                   | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+


    SECTION "PS_straight_code", ROMX

;-------------------------------
; PS_straight_request(b=Xposs, c=Yposs)
;
;   Spawn a new straight shot
;   at position specified by bc
;-------------------------------
PS_straight_request::
        ; loop to find available slot
    ld hl, ps_status
    ld d, 0
    ld e, PS_STRAIGHT_NB
.loop
    bit 7, [hl]
    jr z, _create_shot_at_hl_index_d
    inc hl
    inc d
    dec e
    jr nz, .loop
    ret
_create_shot_at_hl_index_d:
    set 7, [hl]
    ld a, d
    ld h, HIGH(ps_Xposs)
    add a, LOW(ps_Xposs)
    ld l, a
    ld [hl], b
    ld a, d
    ld h, HIGH(ps_Yposs)
    add a, LOW(ps_Yposs)
    ld l, a
    ld [hl], c
    ret




;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                    VRAM                  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+


    SECTION "PS_straight_tiles", ROMX
Player_shot_straight_tiles:
    LOAD "PS_straight_VRAM", VRAM [$8280]
Player_shot_straight_vram_tiles:
tile1:
    DB $00, $00, $00, $00, $00, $00, $00, $00, $18, $18, $18, $00, $18, $18, $18, $18
tile2:
    DB $18, $18, $18, $18, $18, $3c, $24, $3c, $00, $00, $00, $00, $00, $00, $00, $00
    ENDL
.end

