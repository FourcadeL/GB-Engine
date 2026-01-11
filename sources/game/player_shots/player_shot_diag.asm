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
;       d = %???????d
;                   +-> 0 : right : 1 : left
;
;   Spawn a new diagonal shot
;   at position specified by bc
;-------------------------------
PS_diag_request::
    ;loop to find available slot
    ld hl, ps_status + PS_DIAG_RIGHT_FIRST_INDEX
    bit 0, d                                        ; left shot ?
    ld a, 0
    ld d, %10000000                                 ; active, right shot status
    ld e, PS_DIAG_NB
    jr z, .loop                                     ; right shot, start search
        ; left shot
        inc d                                       ; change r/l flag
        ld hl, ps_status + PS_DIAG_LEFT_FIRST_INDEX ; change table slice
.loop
    bit 7, [hl]
    jr z, _create_shot_at_hl_index_a                ; free slot -> create new
    inc hl
    inc a
    dec e
    jr nz, .loop
    ret
_create_shot_at_hl_index_a:
    ld [hl], d                                      ; set new shot flags
    bit 0, d
    ld d, PS_DIAG_RIGHT_FIRST_INDEX
    jr z, .create_shot
        ld d, PS_DIAG_LEFT_FIRST_INDEX
.create_shot
    add a, d
    ld d, a
    add a, LOW(ps_Xposs)
    ld l, a
    ld [hl], b                                      ; set new shot X postition
    ld a, d
    add a, LOW(ps_Yposs)
    ld l, a
    ld [hl], c                                      ; set new shot Y postition

    ret



;+--------------------------------------------------------------------+
;| +----------------------------------------------------------------+ |
;| |                    VRAM                                        | |
;| +----------------------------------------------------------------+ |
;+--------------------------------------------------------------------+


    SECTION "PS_diag_tiles", ROMX
Player_shot_diag_tiles:
    LOAD "PS_diag_VRAM", VRAM[$8340]
Player_shot_diag_vram_tiles:
; TODO tiles data
tile1:
    DB $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $18
tile2:
    DB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $18
    ENDL
.end
