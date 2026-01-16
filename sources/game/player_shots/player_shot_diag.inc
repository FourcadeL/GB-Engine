; ######################
; PS Diag macros
;
;   These macro defines code for
;   "player_shot_diag.asm"
;   meant to be called in
;   "player_shots.asm"
;
;   Diagonal PS status bit encodes left or right type
;       - 8 bits status : %a0c000bd | a : 1 -> active | c : 1 -> collided | d : direction
;                          | |   ||
;                          | |   |+--> directions 0 : diag right | 1 : diag left
;                          | |   +---> backward 0 : headead up | 1 : headed up
;                          | |
;                          | +--> collided flag (with ennemy)
;                          |
;                          |
;                          +----> active flag
; ######################

    IF!DEF(PLAYER_SHOT_DIAG_INC)
DEF PLAYER_SHOT_DIAG_INC EQU 1

DEF PS_DIAG_RIGHT_FIRST_INDEX EQU 3
DEF PS_DIAG_LEFT_FIRST_INDEX EQU 6
DEF PS_DIAG_RIGHT_DOWN_FIRST_INDEX EQU 9
DEF PS_DIAG_LEFT_DOWN_FIRST_INDEX EQU 12
DEF PS_DIAG_NB EQU 3


DEF PS_DIAG_Y_SPEED EQU 9
DEF PS_DIAG_X_SPEED EQU 5

EXPORT Player_shot_diag_tiles
EXPORT Player_shot_diag_tiles.end
EXPORT Player_shot_diag_vram_tiles

MACRO PS_DIAG_INIT
    ; copy tiles into VRAM
    ld hl, Player_shot_diag_tiles
    ld de, Player_shot_diag_vram_tiles
    ld c, Player_shot_diag_tiles.end - Player_shot_diag_tiles
    call vram_copy_fast

    ; set tiles for diag shots in displaylist
    ld hl, ps_Tiles + PS_DIAG_RIGHT_FIRST_INDEX
    ld d, (Player_shot_diag_vram_tiles - _VRAM) / 16
    ld b, PS_DIAG_NB * 4                    ; (fill both r/l/v tables)
    call memset_fast
ENDM


MACRO PS_DIAG_UPDATE
    ; iterate over diag shots (right and left)
    ld e, PS_DIAG_NB * 4                            ; left, right, up and botom
    ld hl, ps_status + PS_DIAG_RIGHT_FIRST_INDEX
    ld b, LOW(ps_Xposs) + PS_DIAG_RIGHT_FIRST_INDEX
    ld c, LOW(ps_Yposs) + PS_DIAG_RIGHT_FIRST_INDEX
.loop\@
    bit 5, [hl]
    jr nz, .delete_shot\@
        ld d, l
        bit 1, [hl]                                     ; down shot ?
        ld l, c
        ld a, [hl]
        jr nz, .down_shot\@
            sub a, PS_DIAG_Y_SPEED
            ld [hl], a
            ld l, d
            jr c, .delete_shot\@                            ; carry means shot overflow from top
            jr .continue\@
.down_shot\@
        add a, PS_DIAG_Y_SPEED
        ld [hl], a
        ld l, d
        cp a, 144                                       ; overflow the screen Y border ?
        jr nc, .delete_shot\@

.continue\@
        bit 0, [hl]                                     ; left shot ?
        ld l, b
        ld a, [hl]
        jr nz, .left_shot\@
            add a, PS_DIAG_X_SPEED
            cp a, 168                                   ; overflow the screen X border ?

            ld [hl], a
            ld l, d
            jr nc, .delete_shot\@
            inc b
            inc c
            inc hl
            dec e
            jr nz, .loop\@
            jr .end\@
.left_shot\@
        sub a, PS_DIAG_X_SPEED

        ld [hl], a
        ld l, d
        jr c, .delete_shot\@                            ; overflow from the right or the left
        inc b
        inc c
        inc hl
        dec e
        jr nz, .loop\@
        jr .end\@
.delete_shot\@
    xor a
    ld [hl+], a
    inc b
    inc c
    dec e
    jr nz, .loop\@
.end\@
ENDM


    ENDC ; PLAYER_SHOT_DIAG_INC
