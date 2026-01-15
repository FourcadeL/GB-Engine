; #######################################
; PS Diag
;
;   This file serves for behaviour and data
;   of the diagonal shots fired by the player
;   (all daigonal shots are shooted by pair)
;
;   All gestion for display and update calls
;   are found in "player_shots.asm"
;       (maybe define here the update macro ?)
;
;   Diagonal shots are shots index 3 to 8
;       and are separated into diagonal right (PS 3 to 5)
;       and diagonal left (PS 6 to 8)
; #######################################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "player_shots.inc"
INCLUDE "player_shot_diag.inc"



;+-------------------------------------------------------------------+
;| +---------------------------------------------------------------+ |
;| |                    ROM                                        | |
;| +---------------------------------------------------------------+ |
;+-------------------------------------------------------------------+


    SECTION "PS_diag_code", ROMX

;-------------------------------
; PS_diag_request(b = Xposs, c = Yposs, d = righ or left flag)
;
;       d = %??????vd
;                  |+-> 0 : right | 1 : left
;                  +--> 0 : up | 1 : down
;
;   Spawn a new diagonal shot
;   at position specified by bc
;-------------------------------
PS_diag_request::
    ;loop to find available slot
    ld h, HIGH(ps_status)
    ld a, d
    and a, %00000011
    or a, %10000000                                 ; shot flags
    ld d, a
    ld a, LOW(ps_status) + PS_DIAG_RIGHT_FIRST_INDEX
    bit 0, d                                        ; horizontal flip ?
    jr z, .no_hflip
        add a, PS_DIAG_NB
.no_hflip
    bit 1, d                                        ; vertical flip ?
    jr z, .no_vflip
        add a, 2 * PS_DIAG_NB
.no_vflip
    ld l, a
    ld e, PS_DIAG_NB
.loop
    bit 7, [hl]
    jr z, _create_shot_at_hl_index_a                ; free slot -> create new
    inc hl
    dec e
    jr nz, .loop
    ret
_create_shot_at_hl_index_a:
    ld a, l
    ld [hl], d                                      ; set new shot flags
    add a, PS_MAX_SHOTS
    ld l, a
    ld [hl], b                                      ; set new shot X postition
    add a, PS_MAX_SHOTS
    ld l, a
    ld [hl], c                                      ; set new shot Y postition

    ret



;+--------------------------------------------------------------+
;| +----------------------------------------------------------+ |
;| |                    VRAM                                  | |
;| +----------------------------------------------------------+ |
;+--------------------------------------------------------------+


    SECTION "PS_diag_tiles", ROMX
Player_shot_diag_tiles:
    LOAD "PS_diag_VRAM", VRAM[$8340]
Player_shot_diag_vram_tiles:
tile1:
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $06, $0c, $0a, $0c, $1c
tile2:
    DB $30, $78, $f0, $f0, $60, $70, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
    ENDL
.end
