; ###########################
; Rotating enemy actor
;
;   spawn rotation enemy
;   animate rotating enemy
;   delete enemy
; ###########################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "charmap.inc"
INCLUDE "actors.inc"
INCLUDE "rot_enemy.inc"
INCLUDE "player_shots.inc"

DEF ROT_ANIM_SPEED EQU 6
DEF Rot_enemy_displaylist_entry EQUS "DisplayList_table + 26*2"
DEF Rot_enemy_displaylist_entry_index EQU 26

;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Rot_enemy_variables", WRAM0
_rot_enemy_variables_start:
rot_enemy_anim_counter:       DS 1
rot_enemy_anim_offset:        DS 1
_rot_enemy_variables_end:

;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Rot_enemy_code", ROMX

Rot_enemy_init::
    ; copy tiles into VRAM
    ld hl, Rot_enemy_tiles
    ld de, Rot_enemy_vram_tiles
    ld c, Rot_enemy_tiles.end - Rot_enemy_tiles
    call vram_copy_fast

    ; reset variables
    ld d, $00
    ld hl, _rot_enemy_variables_start
    ld b, _rot_enemy_variables_end - _rot_enemy_variables_start
    call memset_fast

    ret



;--------------------------------
; Rot_enemy_request(b = xpos; c = ypos)
;   Request a new rotating enemy at position specified by bc
;--------------------------------
Rot_enemy_request::
    push bc
    ACTOR_FIND_FREE                             ; find actor (hl, de are set)
    pop bc
    ret nz                                      ; no actors found ?
        ; add rotating enemy at hl and de
    ld a, %10000001
    ld [hl+], a
    ld a, Rot_enemy_displaylist_entry_index    ; set display list
    ld [hl+], a
    ld [hl], c                                  ; set Y pos
    inc hl
    inc hl
    ld [hl], b                                  ; set X pos
    inc hl
    inc hl
    ld a, LOW(Rot_enemy_handle)
    ld [hl+], a
    ld [hl], HIGH(Rot_enemy_handle)

    ;  actor data
    ; WARNING init depend on actor data order for rot enemy in rot_enemy.inc
    ld h, d
    ld l, e
    ld a, COUNTER_STATE
    ld [hl+], a
    ld a, MOVE_ASCENT_RIGHT_STATE
    ld [hl+], a
    swap c
    ld a, c
    and a, %11110000        ; low nibble of Y pos
    ld [hl+], a
    ld a, c
    and a, %00001111        ; high nibble of Y pos
    ld [hl+], a
    swap b
    ld a, b
    and a, %11110000        ; low nibble of X pos
    ld [hl+], a
    ld a, b
    and a, %00001111        ; high nibble of X pos
    ld [hl], a
    ret

Rot_enemy_update::
    ; update enemy rot display list
    ld a, [rot_enemy_anim_offset]
    add a, LOW(enemy_rot_dl_frame1)
    ld hl, Rot_enemy_displaylist_entry
    ld [hl+], a
    ld [hl], HIGH(enemy_rot_dl_frame1)
        ; update rot_counter
    ld hl, rot_enemy_anim_counter
    inc [hl]
    ld a, [hl]
    cp a, ROT_ANIM_SPEED
    jr nz, .skipROTAnimUpdate
    ld a, 0
    ld [hl], a
    ld a, [rot_enemy_anim_offset]
    add a, 9                        ; displayList block size
    cp a, 9*3                       ; Nb of animation frames
    jr nz, .writeNewCounter
    ld a, 0
.writeNewCounter
    ld [rot_enemy_anim_offset], a
.skipROTAnimUpdate
    ret


;------------------------------------------
; Rot_enemy_handle(bc = sprite addr, de = actor data addr)
;
;   1 - do main state handle
;   2 - do movement handle
;   3 - do collision detection with player shots
;------------------------------------------
Rot_enemy_handle:
        ; handle state
    ld a, state
    add a, e
    ld h, d
    ld l, e
    ld a, [hl]                  ; get current state
    cp a, COUNTER_STATE
    jp z, move_count_handle
    cp a, DEAD_STATE
    jp z, dead_state_handle
    cp a, DELETE_STATE
    jp z, delete_state_handle
    cp a, SHOOT_STATE
    jp z, shoot_state_handle
Movement_handle:
        ; handle movement
    ld a, move_state
    add a, e
    ld h, d
    ld l, a
    ld a, [hl]
    cp a, MOVE_DESCENT_STATE
    jp z, move_descent_handle
    cp a, MOVE_ASCENT_RIGHT_STATE
    jp z, move_ascent_right_handle
    cp a, MOVE_ASCENT_LEFT_STATE
    jp z, move_ascent_left_handle
;-------------------------
; Collision_handle(de = actor data addr)
;
;   Tests agains all enemy shots if there is a collision
;   Test is done only on EVEN frames (synced with player_shots)
;------------------------
Collision_handle:
        ; don't check on ODD frames
    ld hl, Global_counter
    bit 0, [hl]
    ret nz                          ; don't update on odd frames
        ; handle collision with player shot
    ; (assume that bc and de are still set)
    ld a, Y_pos
    add a, e
    ld h, d
    ld l, a
    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl+]
    and a, %00001111
    or a, b
    swap a
    ld b, a                     ; b <- enemy pixel Y pos
    ld a, [hl+]
    and a, %11110000
    ld c, a
    ld a, [hl]
    and a, %00001111
    or a, c
    swap a
    ld c, a                     ; c <- enemy pixel X pos

        ; test agains all player shots
    push de
    ld hl, ps_status            ; status table
    ld d, 0                     ; index count
    ld e, ES_MAX_SHOTS
.loop
    bit 7, [hl]
    jr nz, .test_shot
    inc hl
    inc d
    dec e
    jr nz, .loop
    pop de
    ret
.test_shot
    push hl
    ld h, HIGH(ps_Yposs)
    ld a, LOW(ps_Yposs)
    add a, d
    ld l, a
    ld a, [hl]
    sub a, b                    ; Y pos diff
    jr nc, .non_negativeY
    cpl a
    inc a
.non_negativeY
    and a, %11110000
    jr nz, .abort_this_collision
    ld h, HIGH(ps_Xposs)
    ld a, LOW(ps_Xposs)
    add a, d
    ld l, a
    ld a, [hl]
    sub a, c                    ; X pos fiff
    jr nc, .non_negativeX
    cpl a
    inc a
.non_negativeX
    and a, %11111000
    jr nz, .abort_this_collision
        ; collision found, set state
    pop hl
    set 5, [hl]                 ; set collide flag to shot
    pop hl
    ld a, state
    add a, l
    ld l, a
    ld [hl], DEAD_STATE
    ret
.abort_this_collision
    pop hl
    inc hl
    inc d
    dec e
    jr nz, .loop
    pop de
    ret


move_ascent_left_handle:
    push de
    push bc
    ld a, Y_pos
    add a, e
    ld h, d
    ld l, a
    ld a, [hl]
    sub a, Y_SPEED
    ld [hl+], a
    ld e, a
    ld a, [hl]
    sbc a, 0
    ld [hl+], a
    and a, %00001111
    ld d, a
    ld a, e
    and a, %11110000
    or a, d
    swap a
    ld d, a                     ; d <- Y pixel pos
    
    ld a, [hl]
    sub a, X_SPEED
    ld [hl+], a
    ld e, a
    ld a, [hl]
    sbc a, 0
    ld [hl], a
    and a, %00001111
    ld b, a
    ld a, e
    and a, %11110000
    or a, b
    swap a
    ld e, a                     ; e <- X pixel pos
    jr common_set_sprite_pos
move_ascent_right_handle:
    push de
    push bc
    ld a, Y_pos
    add a, e
    ld h, d
    ld l, a
    ld a, [hl]
    sub a, Y_SPEED
    ld [hl+], a
    ld e, a
    ld a, [hl]
    sbc a, 0
    ld [hl+], a
    and a, %00001111
    ld d, a
    ld a, e
    and a, %11110000
    or a, d
    swap a
    ld d, a                     ; d <- Y pixel pos
    
    ld a, [hl]
    add a, X_SPEED
    ld [hl+], a
    ld e, a
    ld a, [hl]
    adc a, 0
    ld [hl], a
    and a, %00001111
    ld b, a
    ld a, e
    and a, %11110000
    or a, b
    swap a
    ld e, a                     ; e <- X pixel pos
    ;jr common_set_sprite_pos
common_set_sprite_pos:
    pop bc
    ld a, 2
    add a, c
    ld h, b
    ld l, a
    ld [hl], d
    inc hl
    inc hl
    ld [hl], e
    pop de
    jp Collision_handle
move_descent_handle:
    push de
    ld a, Y_pos
    add a, e
    ld h, d
    ld l, a
    ld a, [hl]
    add a, Y_SPEED
    ld [hl+], a
    ld e, a
    ld a, [hl]
    adc a, 0
    ld [hl], a
    and a, %00001111
    ld d, a
    ld a, e
    and a, %11110000
    or a, d
    swap a
    ld d, a
    ld a, 2
    add a, c
    ld h, b
    ld l, a
    ld [hl], d
    pop de
    jp Collision_handle

delete_state_handle:
        ; delete sprite
    ld a, 0
    ld [bc], a
    ret
dead_state_handle:
        ; delete sprite
    ld a, 0
    ld [bc], a
        ; add explosion at former position
    ld a, Y_pos
    add a, e
    ld l, a
    ld h, d
    ld a, [hl+]
    and a, %11110000
    ld c, a
    ld a, [hl+]
    and a, %00001111
    or a, c
    swap a
    ld c, a                         ; c <- y pixel pos
    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl]
    and a, %00001111
    or a, b
    swap a
    ld b, a
    jp Explosion_request

move_count_handle:
;TODO
    jp Movement_handle
shoot_state_handle:
    jp Movement_handle


    SECTION "Rot_enemy_display_lists", ROMX, ALIGN[4]
enemy_rot_dl_frame1:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, 0
    DB -8, 0, (tile3 - _VRAM)/16, 0
enemy_rot_dl_frame2:
    DB 2
    DB -8, -8, (tile5 - _VRAM)/16, 0
    DB -8, 0, (tile7 - _VRAM)/16, 0
enemy_rot_dl_frame3:
    DB 2
    DB -8, -8, (tile9 - _VRAM)/16, 0
    DB -8, 0, (tile11 - _VRAM)/16, 0


;+------------------------------------------------------------------+
;| +--------------------------------------------------------------+ |
;| |                    VRAM                                      | |
;| +--------------------------------------------------------------+ |
;+------------------------------------------------------------------+

    SECTION "Rot_enemy_tiles", ROMX
Rot_enemy_tiles:
    LOAD "Rot_enemy_VRAM", VRAM[$8060]
Rot_enemy_vram_tiles:
tile1:
    DB $00, $00, $01, $01, $00, $00, $03, $1c, $24, $3f, $48, $77, $5d, $7f, $32, $6f
tile2:
    DB $52, $4f, $11, $0f, $0a, $1f, $06, $1b, $03, $1e, $09, $0f, $06, $07, $00, $00
tile3:
    DB $00, $00, $60, $e0, $90, $f0, $c0, $78, $60, $d8, $50, $f8, $88, $f0, $4a, $f2
tile4:
    DB $cc, $76, $ba, $fe, $12, $ee, $24, $fc, $c0, $38, $00, $00, $80, $80, $00, $00

tile5:
    DB $00, $00, $00, $00, $30, $3f, $43, $7d, $34, $7f, $4a, $57, $11, $0f, $13, $2e
tile6:
    DB $13, $3e, $15, $2f, $08, $3f, $04, $3b, $2b, $3c, $28, $39, $14, $1c, $00, $00
tile7:
    DB $00, $00, $28, $38, $14, $9c, $d4, $3c, $20, $dc, $10, $fc, $a8, $f4, $48, $fc
tile8:
    DB $48, $f4, $88, $f0, $52, $ea, $2c, $fe, $c2, $be, $0c, $fc, $00, $00, $00, $00

tile9:
    DB $00, $00, $0b, $0f, $06, $07, $03, $05, $05, $1b, $08, $3f, $11, $6f, $52, $6f
tile10:
    DB $5a, $7f, $71, $6f, $28, $77, $44, $4f, $03, $0c, $00, $07, $01, $03, $00, $00
tile11:
    DB $00, $00, $80, $c0, $00, $e0, $c0, $30, $22, $f2, $14, $ee, $8e, $f6, $da, $7e
tile12:
    DB $4a, $f6, $88, $f6, $10, $fc, $a0, $d8, $c0, $a0, $60, $e0, $d0, $f0, $00, $00

    ENDL
.end
