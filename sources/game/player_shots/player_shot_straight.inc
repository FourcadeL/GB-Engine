; ######################
; PS Straight macros
;
;   These macros actually defines
;   Routines specific to
;   "player_shot_straight.asm"
;   but meant to be called in
;   "player_shots.asm"
;   for code efficiency
; ######################

    IF!DEF(PLAYER_SHOT_STRAIGHT_INC)
DEF PLAYER_SHOT_STRAIGHT_INC EQU 1

DEF PS_STRAIGHT_FIRST_INDEX EQU 0
DEF PS_STRAIGHT_NB EQU 3

DEF PS_Y_SPEED EQU 12

EXPORT Player_shot_straight_tiles
EXPORT Player_shot_straight_tiles.end
EXPORT Player_shot_straight_vram_tiles

MACRO PS_STRAIGHT_INIT
    ; copy tiles into VRAM
    ld hl, Player_shot_straight_tiles
    ld de, Player_shot_straight_vram_tiles
    ld c, Player_shot_straight_tiles.end - Player_shot_straight_tiles
    call vram_copy_fast

    ; set tiles for straight shots in displayList
    ld hl, ps_dynamic_displayList_content + PS_STRAIGHT_FIRST_INDEX * 4 + 2
    ld a, (Player_shot_straight_vram_tiles - _VRAM)/16
    ld d, PS_STRAIGHT_NB
.straight_set_loop
    ld [hl+], a
    inc hl
    inc hl
    inc hl
    dec d
    jr nz, .straight_set_loop
ENDM

MACRO PS_STRAIGHT_UPDATE
    ; iterate over straight positions
    ld c, PS_STRAIGHT_NB
    ld de, ps_status + PS_STRAIGHT_FIRST_INDEX
    ld hl, ps_Yposs + PS_STRAIGHT_FIRST_INDEX
.loop
    ld a, [de]
    bit 5, a
    jr nz, .delete_shot
    ld a, [hl]
    sub a, PS_Y_SPEED
    ld [hl], a
    jr c, .delete_shot          ; carry means shot overflow from top of the screen -> reset status
    inc de
    inc hl
    dec c
    jr nz, .loop
    jr .end
.delete_shot
    ld a, 0
    ld [de], a
    inc de
    dec c
    jr nz, .loop
.end
ENDM

    ENDC ; PLAYER_SHOT_STRAIGHT_INC
