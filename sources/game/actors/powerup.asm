; ################################
; Powerup actor
;
;   Unique powerup type of the game
; ################################



INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "sprites.inc"
INCLUDE "actors.inc"
INCLUDE "player.inc"
INCLUDE "utils.inc"
INCLUDE "powerup.inc"

DEF PowerUp_displaylist_entry EQUS "DisplayList_table + 31*2"
DEF PowerUp_displaylist_entry_index EQU 31


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "PowerUp_variables", WRAM0
_pu_variables_start:
pu_anim_counter:        DS 1
pu_anim_offset:         DS 1
pu_amount:              DS 1                ; the number of currently active powerups on screen
_pu_variables_end:


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "PowerUp_code", ROMX

PU_init::
    ; copy tiles into VRAM
    ld hl, PU_tiles
    ld de, PU_vram_tiles
    ld c, PU_tiles.end - PU_tiles
    call vram_copy_fast

    ; reset variables
    ld d, $00
    ld hl, _pu_variables_start
    ld b, _pu_variables_end - _pu_variables_start
    call memset_fast

    ; set displaylist first frame addr
    ld hl, PowerUp_displaylist_entry
    ld a, LOW(pu_dl_frame1)
    ld [hl+], a
    ld [hl], HIGH(pu_dl_frame1)

    ; set initial animation counter
    MEMBSET [pu_anim_counter], ANIMATION_COUNTER_VAL

    ret


;------------------------------
; PU_request(b = X pixel pos, c = Y pixel pos)
;
;   Request a power up at position bc
;------------------------------
PU_request::
    push bc
    ACTOR_FIND_FREE                         ; hl, de are set
    pop bc
    ret nz                                  ; no free actor ?

        ; sprite data
    ld a, %10000001                         ; active and display
    ld [hl+], a
    ld a, PowerUp_displaylist_entry_index   ; shared displaylist
    ld [hl+], a
    swap c                                  ; Y position
    ld a, c
    and a, %11110000
    ld [hl+], a
    ld a, c
    and a, %00001111
    ld [hl+], a
    swap b                                  ; X position
    ld a, b
    and a, %11110000
    ld [hl+], a
    ld a, b
    and a, %00001111
    ld [hl+], a
    ld a, LOW(PU_handle)
    ld [hl+], a
    ld [hl], HIGH(PU_handle)

        ; actor data
    ld hl, pu_amount
    inc [hl]
    ld a, [hl]
    ld [de], a                              ; own index
    inc e
    ld a, 62                                ; initial sine offset
    ld [de], a

    ret

; ------------------------------------------------
; PU_handle(bc = sprite addr, de = actor data addr)
;
;   1 - do movement
;   2 - IF ownindex >= pu_amount THEN handle animation for all
;   3 - do collision
; ------------------------------------------------
PU_handle:
        ; movement
    ; Y movement
    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld h, b
    ld l, a
    ld a, [hl]
    add a, Y_SPEED
    ld [hl+], a
    ld a, [hl]
    adc a, 0
    ld [hl], a
        ; Test low nibble of a + 1:
        ; greater than High nibble of BOUNDARY_Y
        ; -> delete sprite
        inc a
        and a, %00001111
        cp a, BOUNDARY_Y >> 4
        jp nc, _delete_pu

    ; X movement
    push de
    ld a, x_movement_count
    add a, e
    ld h, d
    ld l, a
    ld a, [hl]                              ; get and increment counter
    add a, SINE_STEP
    ld [hl], a
    GET_SINE_A
    sra a                                   ; shift sine amplitude
    sra a
    ld d, $00
    bit 7, a
    jr z, .positive_sine
        dec d                               ; correct HIGH part of sine displacement
.positive_sine
    ld e, a
    ld a, SPRITE_STRUCT_Xpos
    add a, c
    ld h, b
    ld l, a
    ld a, [hl]
    add a, e
    ld [hl+], a
    ld a, [hl]
    adc a, d
    ld [hl], a

    pop de

        ; ANIMATION ?
    ld hl, pu_amount
    ld a, [de]
    cp a, [hl]
    jr c, .skip_animation
        ; ownindex >= pu_amount -> should handle animation
        ld hl, pu_anim_counter
        dec [hl]
        jr nz, .skip_animation
        ld a, ANIMATION_COUNTER_VAL
        ld [hl], a
        inc hl                              ; hl = pu_anim_offset
        ld a, [hl]
        add a, 9                            ; displaylist element size for powerup
        cp a, NB_ANIMATION_FRAME*9
        jr c, .ok
            ; reset animation counter
            xor a
    .ok
        ld [hl], a
        add a, LOW(pu_dl_frame1)
        ld hl, PowerUp_displaylist_entry
        ld [hl+], a
        ld [hl], HIGH(pu_dl_frame1)
.skip_animation

        ; COLLISIONS
    ld a, SPRITE_STRUCT_Ypos
    ld h, b
    add a, c
    ld l, a
    ld a, [hl+]                             ; Y pos
    and a, %11110000
    ld e, a
    ld a, [hl+]
    and a, %00001111
    or a, e
    swap a
    ld e, a

    ld a, [hl+]                             ; X pos
    and a, %11110000
    ld d, a
    ld a, [hl]
    and a, %00001111
    or a, d
    swap a
    ld d, a

    ACTOR_PLAYER_COLLISION_SQUARE d, e, PU_HITBOX_WIDTH, PU_HITBOX_HEIGHT, .no_collision
        ; collision code
    ld hl, player_state
    set PLAYER_STATUS_PU_COLLISION, [hl]
    jr _delete_pu

.no_collision
    ret


_delete_pu:
    xor a
    ld [bc], a
    ld hl, pu_amount
    dec [hl]                                ; decrement powerup amount
    ret

    SECTION "PowerUp_display_lists", ROMX, ALIGN[4]
pu_dl_frame1:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, 0
    DB -8, 0, (tile1 - _VRAM)/16, %00100000
pu_dl_frame2:
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, 0
    DB -8, 0, (tile5 - _VRAM)/16, 0
pu_dl_frame3:
    DB 2
    DB -8, -8, (tile7 - _VRAM)/16, 0
    DB -8, 0, (tile7 - _VRAM)/16, %00100000
pu_dl_frame4:
    DB 2
    DB -8, -8, (tile5 - _VRAM)/16, %00100000
    DB -8, 0, (tile3 - _VRAM)/16, %00100000


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                    VRAM                                    | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "PowerUp_tiles", ROMX
PU_tiles:
    LOAD "PowerUp_VRAM", VRAM[$8360]
PU_vram_tiles:
tile1:
    DB $00, $00, $01, $00, $01, $01, $0f, $0e, $17, $1f, $2f, $38, $4f, $78, $7f, $79
tile2:
    DB $0e, $0b, $0e, $0b, $07, $07, $07, $04, $03, $03, $02, $02, $00, $00, $00, $00
tile3:
    DB $00, $00, $00, $01, $01, $01, $07, $06, $0b, $0f, $0b, $0e, $13, $1e, $17, $1c
tile4:
    DB $0f, $08, $1f, $18, $1f, $1f, $07, $04, $03, $03, $01, $03, $00, $00, $00, $00
tile5:
    DB $00, $00, $00, $80, $80, $80, $e0, $60, $d0, $f0, $e8, $38, $f8, $18, $e0, $70
tile6:
    DB $a0, $f0, $90, $f0, $f0, $f0, $e0, $20, $c0, $c0, $40, $c0, $00, $00, $00, $00
tile7:
    DB $00, $00, $01, $00, $01, $01, $07, $06, $0a, $0f, $0f, $0a, $0f, $0b, $0b, $0c
tile8:
    DB $17, $1c, $17, $1c, $1f, $1f, $07, $04, $03, $03, $01, $01, $00, $00, $00, $00
    ENDL
.end
