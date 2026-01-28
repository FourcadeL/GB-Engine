; ##############################
; Pincher enemy actor
;
;   Multiple angle animated enemy following the player
;   (as target)
;   Start fom a position
;   Follow the player for a fixed Duration
;   Then exits toward a fixed target
;
;   Handle functions
; ##############################

INCLUDE "hardware.inc"
INCLUDE "utils.inc"
INCLUDE "engine.inc"
INCLUDE "sprites.inc"
INCLUDE "actors.inc"
INCLUDE "player.inc"
INCLUDE "pincher_enemy.inc"

DEF Pinch_enemy_displayList_first_entry EQUS "DisplayList_table + 2 * 2"
DEF Pinch_enemy_displayList_first_entry_index EQU 2


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Pinch_enemy_variables", WRAM0
_pinch_enemy_variables:
pinch_enemy_next_assign_framerule:      DS 1            ; next framerule to use
_pinch_enemy_variables_end:

;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Pinch_enemy_code", ROMX

Pinch_enemy_init::
    ; copy tiles into VRAM
    ld hl, Pinch_enemy_tiles
    ld de, Pinch_enemy_vram_tiles
    ld c, Pinch_enemy_tiles.end - Pinch_enemy_tiles
    call vram_copy_fast

    ; reset variable (not important)

    ; copy displayList_tables
    ld hl, static_dl_addrs
    ld de, Pinch_enemy_displayList_first_entry
    ld b, static_dl_addrs.end - static_dl_addrs
    call memcopy_fast

    ret

; --------------------------------------
; Pinch_enemy_request(b = X start position,
;           c = Y start position
;           StackPush :
;               $SS?? (displacement speed)
;               $DDDD (Duration in frame before timeout)
;               $XEYE (end target position)
; --------------------------------------
Pinch_enemy_request::
    push bc
    ACTOR_FIND_FREE                             ; find actor (hl, de are set)
    pop bc
    ret nz                                      ; no free actor

        ; add pinch enemy at hl and de
    ; sprite data
    ld a, %10000001                             ; active sprite
    ld [hl+], a
    ld a, Pinch_enemy_displayList_first_entry_index  ; default display list (changed at update)
    ld [hl+], a
    swap c
    ld a, c
    and a, %11110000
    ld [hl+], a                                 ; set Y low
    ld a, c
    and a, %00001111
    ld [hl+], a                                 ; set Y high
    swap b
    ld a, b
    and a, %11110000                            ; set X low
    ld [hl+], a
    ld a, b
    and a, %00001111                            ; set X high
    ld [hl+], a

    ld a, LOW(Pinch_enemy_handle)               ; set handle function
    ld [hl+], a
    ld [hl], HIGH(Pinch_enemy_handle)
    

    ; actor data
    ld hl, sp + 7                               ; stackargs botom
        ; state
    ld a, PURSUIT_STATE
    ld [de], a
    inc e
        ; displacement_speed
    ld a, [hl-]
    ld [de], a
    inc e

    dec hl                                      ; unused parameter

        ; timeout_counter
    ld a, [hl-]
    ld b, a
    ld a, [hl-]
    ld [de], a
    inc e
    ld a, b
    ld [de], a
    inc e

        ; x out
    ld a, [hl-]
    ld [de], a
    inc e

        ; y out
    ld a, [hl-]
    ld [de], a
    inc e

        ; framerule
    ld hl, pinch_enemy_next_assign_framerule
    ld a, [hl]
    inc a
    and a, %00000011
    ld [de], a
    ld [hl], a

        ; preset update counter
    inc e
    ld [de], a

        ; reset of variables
    inc e
    ld b, SIZEOF_pinch_enemy_data - d_vector_y
    xor a
.loop
    ld [de], a
    inc e
    dec b
    jr nz, .loop


    ret


; ----------------------------------------------------
; Pinch_enemy_handle(bc = sprite addr, de = actor data addr)
; ----------------------------------------------------
Pinch_enemy_handle:
        ; handle state
    ld a, [de]
    cp a, PURSUIT_STATE
    jr z, handle_pursuit
    cp a, RETURN_STATE
    jr z, handle_return
    cp a, DEAD_STATE
    jr z, handle_dead
        ; no valid state : destroy actor
    xor a
    ld [bc], a
    ret

; -----------------------------------------------------
; handle_pursuit(bc = sprite addr, de = actor data addr)
; -----------------------------------------------------
handle_pursuit:
    ld a, timeout_counter
    ld h, d
    add a, e
    ld l, a

    ld a, [hl]
    sub a, 1
    ld [hl+], a
    ld a, [hl]
    sbc a, 0
    ld [hl], a
    jr nc, .continue_pursuit
        ; timeout, end pursuit
        ld a, RETURN_STATE
        ld [de], a
        jr do_move
.continue_pursuit
    ld a, update_counter
    add a, e
    ld l, a
    ld a, [hl]
    inc a
    ld [hl], a
    cp a, DIRECTION_UPDATE_TRESH
    jr c, do_move                       ; no update
    
    xor a
    ld [hl], a                          ; reset counter

    ; compute new direction vector
    push bc
    push de

    ld a, displacement_speed
    add a, e
    ld l, a
    ld a, [hl]
    push af

    ld h, b
    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld l, a
    ld a, [hl+]
    and a, %11110000
    ld c, a
    ld a, [hl+]
    and a, %00001111
    or a, c
    swap a
    ld c, a                             ; c <- en pixel Y pos

    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl]
    and a, %00001111
    or a, b
    swap a
    ld b, a                             ; b <- en pixel X pos

    MEMBSET d, [player_pixel_Xpos]
    MEMBSET e, [player_pixel_Ypos]
    pop af                              ; retrieve speed value

    call Target_get_displacement_vector
    jr z, .ignore_vector_set

    pop hl
    push hl
    ld a, d_vector_y
    add a, l
    ld l, a

        ; save displacement values
    ld [hl], e
    inc l
    ld [hl], d
    inc l
    ld [hl], c
    inc l
    ld [hl], b

.ignore_vector_set
    pop de
    pop bc

    jr do_move


; -----------------------------------------------------
; handle_return(bc = sprite addr, de = actor data addr)
; -----------------------------------------------------
handle_return:
;TODO
; -----------------------------------------------------
; handle_dead(bc = sprite addr, de = actor data addr)
; -----------------------------------------------------
handle_dead:
    ; delete sprite
    xor a
    ld [bc], a

    ; add explosion at former position
    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld l, a
    ld h, b
    ld a, [hl+]
    and a, %11110000
    ld c, a
    ld a, [hl+]
    and a, %00001111
    or a, c
    swap a
    ld c, a
    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl]
    and a, %00001111
    or a, b
    swap a
    ld b, a

    jp Explosion_request


; ---------------------------------------------------
; do_move(bc = sprite addr, de = actor data addr)
; ---------------------------------------------------
do_move:
    push bc
    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld c, a
    ld a, d_vector_y
    add a, e
    ld h, d
    ld l, a
    ld a, [bc]
    add a, [hl]
    ld [bc], a                      ; y low
    inc c
    inc l
    ld a, [bc]
    adc a, [hl]
    ld [bc], a                      ; y high
    inc c
    inc l

    ld a, [bc]
    add a, [hl]
    ld [bc], a                      ; x low
    inc c
    inc l
    ld a, [bc]
    adc a, [hl]
    ld [bc], a                      ; x high

    pop bc
    ; end

; --------------------------------------------
; check_collisions(bc = sprite addr, de = actor data addr)
;
;   Test collisions against player shots
;   Test collision against player
;   Test is done only on framerule
; --------------------------------------------
check_collisions:
        ; check only on framerule
    ld a, e
    add a, framerule
    ld l, a
    ld h, d
    ld a, [Global_counter]
    and a, %00000011
    sub a, [hl]
    ret nz                          ; don't update on wrong framerule
        ; handle collision with player shot
    ; (assume that bc and de are still set)
    push de
    ACTOR_PLAYER_SHOT_COLLISION_SQUARE 9, 10, .shot_collision, .check_player_collision
.shot_collision
    pop hl
;     ld a, state
;     add a, l
;     ld l, a                       ; state is the first byte of structure
    ld [hl], DEAD_STATE
    ret

    ; check player collision (b = enemy Y pixel pos; c = enemy X pixel pos)
.check_player_collision
    ACTOR_PLAYER_COLLISION_SQUARE c, b, PINCH_E_HITBOX_WIDTH, PINCH_E_HITBOX_HEIGHT, .no_player_collision
        ; set collision flag for player
    ld hl, player_state
    set PLAYER_STATUS_ENEMY_COLLISION, [hl]
        ; set enemy in dead state
    pop hl
;     ld a, state
;     add a, l
;     ld l, a                       ; state is the first byte of structure
    ld [hl], DEAD_STATE
    ret
.no_player_collision
    pop de
    ret

    SECTION "Pinch_enemy_display_lists", ROMX
; display lists encode 8 animation frame of trigo rotation
; starting from
; | \ - / | \ - /
; v
pinch_enemy_dl_f1:              ; |
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, 0
    DB -8, 0, (tile1 - _VRAM)/16, OAMF_XFLIP
pinch_enemy_dl_f2:              ; \
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, 0
    DB -8, 0, (tile5 - _VRAM)/16, 0
pinch_enemy_dl_f3:              ; -
    DB 2
    DB -8, 8, (tile7 - _VRAM)/16, 0
    DB -8, 0, (tile9 - _VRAM)/16, 0
pinch_enemy_dl_f4:              ; /
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, OAMF_YFLIP
    DB -8, 0, (tile5 - _VRAM)/16, OAMF_YFLIP
pinch_enemy_dl_f5:              ; |
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, OAMF_YFLIP
    DB -8, 0, (tile1 - _VRAM)/16, OAMF_XFLIP|OAMF_YFLIP
pinch_enemy_dl_f6:              ; \
    DB 2
    DB -8, -8, (tile5 - _VRAM)/16, OAMF_XFLIP|OAMF_YFLIP
    DB -8, 0, (tile3 - _VRAM)/16, OAMF_XFLIP|OAMF_YFLIP
pinch_enemy_dl_f7:              ; -
    DB 2
    DB -8, 8, (tile9 - _VRAM)/16, OAMF_XFLIP
    DB -8, 0, (tile7 - _VRAM)/16, OAMF_XFLIP
pinch_enemy_dl_f8:              ; /
    DB 2
    DB -8, -8, (tile5 - _VRAM)/16, OAMF_XFLIP
    DB -8, 0, (tile3 - _VRAM)/16, OAMF_YFLIP
    
static_dl_addrs:
    ; static outline of dl in displayList table
    DW pinch_enemy_dl_f1
    DW pinch_enemy_dl_f2
    DW pinch_enemy_dl_f3
    DW pinch_enemy_dl_f4
    DW pinch_enemy_dl_f5
    DW pinch_enemy_dl_f6
    DW pinch_enemy_dl_f7
    DW pinch_enemy_dl_f8
.end



;+---------------------------------------------------------------+
;| +-----------------------------------------------------------+ |
;| |                    VRAM                                   | |
;| +-----------------------------------------------------------+ |
;+---------------------------------------------------------------+

    SECTION "Pinch_enemy_tiles", ROMX
Pinch_enemy_tiles:
    LOAD "Pinch_enemy_VRAM", VRAM[$83E0]
Pinch_enemy_vram_tiles:
tile1:
    DB $ff, $00, $cf, $30, $8e, $51, $1c, $8a, $4c, $ca, $bf, $7f, $f4, $76, $c4, $26
tile2:
    DB $c2, $63, $ae, $6e, $82, $8c, $93, $d8, $d9, $54, $cd, $72, $e7, $30, $ff, $18
tile3:
    DB $fe, $01, $ff, $01, $fb, $01, $e1, $17, $e3, $03, $c6, $17, $ec, $1c, $78, $fc
tile4:
    DB $3e, $3f, $b1, $b5, $a3, $e3, $e0, $53, $f8, $19, $f1, $09, $f8, $0c, $fe, $07
tile5:
    DB $7f, $60, $1f, $30, $ff, $e0, $cf, $d8, $8b, $8e, $81, $c3, $a1, $b1, $64, $fd
tile6:
    DB $25, $0b, $24, $09, $f5, $09, $3f, $00, $1f, $e0, $ff, $00, $1f, $80, $bf, $e0
tile7:
    DB $e7, $18, $cb, $2e, $86, $47, $96, $66, $fc, $1c, $ff, $07, $e4, $1f, $c4, $24
tile8:
    DB $c4, $24, $e4, $1f, $ff, $07, $fc, $1c, $96, $66, $86, $47, $cb, $2e, $e7, $18
tile9:
    DB $ff, $30, $8f, $dc, $43, $c6, $19, $1f, $4d, $71, $47, $68, $f3, $c4, $1f, $80
tile10:
    DB $1f, $80, $f3, $c4, $47, $68, $4d, $71, $19, $1f, $43, $c6, $8f, $dc, $ff, $30
    ENDL
.end
