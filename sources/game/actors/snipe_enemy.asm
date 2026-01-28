; ################################
; Sniper enemy actor
;
;       Sniper enemy will come from a start position,
;       go to a specified target position, fire X shots,
;       then go back to its start position and destroy itself
;
;   handle functions
; ################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "actors.inc"
INCLUDE "snipe_enemy.inc"
INCLUDE "player_shots.inc"
INCLUDE "player.inc"

DEF Snip_enemy_displayList_first_entry EQUS "DisplayList_table + 32 * 2"
DEF Snip_enemy_displayList_first_entry_index EQU 32


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Snip_enemy_variables", WRAM0
_snip_enemy_variables:
snip_enemy_next_assign_framerule:   DS 1            ; next framerule to use
_snip_enemy_variables_end:

;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Snip_enemy_code", ROMX

Snip_enemy_init::
    ; copy tiles into VRAM
    ld hl, Snip_enemy_tiles
    ld de, Snip_enemy_vram_tiles
    ld c, Snip_enemy_tiles.end - Snip_enemy_tiles
    call vram_copy_fast

    ; reset variables
    ld d, $00
    ld hl, _snip_enemy_variables
    ld b, _snip_enemy_variables_end - _snip_enemy_variables
    call memset_fast

    ; copy displayList_tables
    ld hl, static_dl_addrs
    ld de, Snip_enemy_displayList_first_entry
    ld b, static_dl_addrs.end - static_dl_addrs
    call memcopy_fast

    ret


; ---------------------------------------
; Snip_enemy_request(b = X start position,
;       c = Y start position
;       Stackpush : starting and target positions
;           $XTYT (target position 8 bits)
;           $SSNN (S = enemy displacement speed | N = number of shots to fire)
;           $RRSS (R = shoot rate | S = shot speed)
;
;   Request a new sniper enemy at position $XXYY
;   With target $XTYT
; ---------------------------------------
Snip_enemy_request::
    push bc
    ACTOR_FIND_FREE                         ; find actor (hl, de are set)
    pop bc
    ret nz                  ; no actor found

        ; add sniper enemy at hl and de
    ; sprite data
    ld a, %10000001                         ; active sprite
    ld [hl+], a
    ld a, Snip_enemy_displayList_first_entry_index  ; default display list (changed at update)
    ld [hl+], a
    swap c
    ld a, c
    and a, %11110000
    ld [hl+], a                             ; set Y low
    ld a, c
    and a, %00001111
    ld [hl+], a                             ; set Y high
    swap b
    ld a, b
    and a, %11110000                        ; set X low
    ld [hl+], a
    ld a, b
    and a, %00001111                        ; set X high
    ld [hl+], a

    ld a, LOW(Snip_enemy_handle)            ; set handle function
    ld [hl+], a
    ld [hl], HIGH(Snip_enemy_handle)

    ; actor data                                    ; COULD BE OPTIMIZED WITH A LOOP
    ld hl, sp + 7                           ; stackargs botom
        ; state set up
    ld a, MOOVE_STATE
    ld [de], a
    inc e
        ; flags set up
    xor a
    ld [de], a
    inc e
        ; init pos set up
    swap b                                  ; x initial
    ld a, b
    ld [de], a
    inc e
    swap c                                  ; y initial
    ld a, c
    ld [de], a
    inc e
        ; target set up
    ld a, [hl-]                             ; x target
    ld [de], a
    inc e
    ld a, [hl-]                             ; y target
    ld [de], a
    inc e
        ; speed set up
    ld a, [hl-]                             ; enemy speed
    ld [de], a
    inc e
        ; shot set up
    ld a, 1                                 ; shoot counter
    ld [de], a
    inc e
    ld a, [hl-]                             ; shot nb
    inc a
    ld [de], a
    inc e
    ld a, [hl-]                             ; shoot rate
    ld [de], a
    inc e
    ld a, [hl-]                             ; shot speed
    ld [de], a
    inc e

    ld a, ANIM_COUNTER_VALUE
    ld [de], a                                 ; set animation counter
    inc e

        ; framerule set
    ld hl, snip_enemy_next_assign_framerule
    ld a, [hl]
    inc a
    and a, %00000011
    ld [de], a
    ld [hl], a                                  ; framerule for this enemy

    ret



;------------------------------------------------------
; Snip_enemy_handle(bc = sprite addr, de = actor data addr)
;
;------------------------------------------------------
Snip_enemy_handle:
        ; handle state
;     ld a, state
;     add a, e
;     ld h, d
;     ld l, a
    ld a, [de]                                  ; get current state (first byte)
    cp a, MOOVE_STATE
    jr z, move_state_handle
    cp a, SHOOT_STATE
    jr z, shoot_state_handle
    cp a, DEAD_STATE
    jp z, dead_state_handle

    ret

move_state_handle:
    push de
    push bc
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
    ld c, a                                     ; c <- enemy pixel Y pos

    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl+]
    and a, %00001111
    or a, b
    swap a
    ld b, a                                     ; b <- enemy pixel X pos

    ld h, d
    ld a, x_target
    add a, e
    ld l, a
    ld a, [hl+]
    ld d, a                                     ; d <- target pixel X pos

    ld a, [hl+]
    ld e, a                                     ; e <- target pixel Y pos

    ld a, [hl]                                  ; a <- displacement speed

    call Target_get_displacement_vector
    jr z, .null_vector
            ; bc and de are X Y displacement vectors
    pop hl
    push hl
    ld a, SPRITE_STRUCT_Ypos
    add a, l
    ld l, a
        ; add vector to sprite position
    ld a, [hl]
    add a, e
    ld [hl+], a
    ld a, [hl]
    adc a, d
    ld [hl+], a
    ld a, [hl]
    add a, c
    ld [hl+], a
    ld a, [hl]
    adc a, b
    ld [hl], a
    
    pop bc
    pop de

    jp collision_handle
.null_vector
    pop bc
    pop de

    ld a, flags
    ld h, d
    add a, e
    ld l, a
    bit 7, [hl]
    jr z, .set_next_state
        ; already on its way back, delete
        xor a
        ld [bc], a                              ; reset sprite flags
        ret
.set_next_state
    set 7, [hl]                                 ; set return flags
        ; set shoot state
    ld a, SHOOT_STATE
    ld [de], a
        ; copy new target pixel pos
    ld b, d
    ld a, x_initial
    add a, e
    ld c, a
    ld a, x_target
    add a, e
    ld l, a
    ld a, [bc]
    inc c
    ld [hl+], a
    ld a, [bc]
    ld [hl], a

    ret
        
    


shoot_state_handle:
    ld a, shoot_counter
    ld h, d
    add a, e
    ld l, a
    dec [hl]
    jr nz, collision_handle                     ; wait for shoot
    ld [hl], SHOOT_COUNTER_VALUE
    inc l
    dec [hl]
    jr nz, .do_shoot_attempt
        ; all shots have been fired -> next state
        ld a, MOOVE_STATE
        ld [de], a
        ret
.do_shoot_attempt
    inc l
    push bc
    push de
    push hl

    call generateRandom

    pop hl
    pop de
    pop bc

    cp a, [hl]
    jr nc, collision_handle                     ; a < shoot_rate -> do shoot
        ; shot toward the player
    push bc
    push de

    inc l
    ld a, [hl]                                  ; a <- shot speed
    push af

    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld h, b
    ld l, a
    ld a, [hl+]
    and a, %11110000
    ld c, a
    ld a, [hl+]
    and a, %00001111
    or a, c
    swap a
    ld c, a                                     ; b <- Y pixel pos of enemy
    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl]
    and a, %00001111
    or a, b
    swap a
    ld b, a                                     ; c <- X pixel pos of enemy


    pop de                                      ; d <- shot speed

    call ES_request_shot_toward_player

    pop bc
    pop de

    jr collision_handle


dead_state_handle:
        ; delete sprite
    ld a, 0
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


;-------------------------
; collision_handle(bc = sprite addr, de = actor data addr)
;
;   Tests against all player shots if there is a collision
;   Test player collision and set player flag if collision occured
;   Test is done only on current enemy framerule
;------------------------
collision_handle:
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
;     ld l, a
    ld [hl], DEAD_STATE
    ret

    ; check player collision (b = enemy Y pixel pos; c = enemy X pixel pos)
.check_player_collision
    ACTOR_PLAYER_COLLISION_SQUARE c, b, SNIP_E_HITBOX_WIDTH, SNIP_E_HITBOX_HEIGHT, .no_player_collision
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

    SECTION "Snip_enemy_display_lists", ROMX, ALIGN[4]
snip_enemy_dl_frame1:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, %00010000
    DB -8, 0, (tile1 - _VRAM)/16, %00110000
snip_enemy_dl_frame2:
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, %00010000
    DB -8, 0, (tile3 - _VRAM)/16, %00110000
snip_enemy_dl_frame3:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, %01010000
    DB -8, 0, (tile1 - _VRAM)/16, %01110000
snip_enemy_dl_frame4:
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, %01010000
    DB -8, 0, (tile3 - _VRAM)/16, %01110000


static_dl_addrs:                                    ; static outline of dl for setup in displayList table
    DW snip_enemy_dl_frame1
    DW snip_enemy_dl_frame2
    DW snip_enemy_dl_frame3
    DW snip_enemy_dl_frame4
.end

;+---------------------------------------------------------------+
;| +-----------------------------------------------------------+ |
;| |                    VRAM                                   | |
;| +-----------------------------------------------------------+ |
;+---------------------------------------------------------------+

    SECTION "Snip_enemy_tiles", ROMX
Snip_enemy_tiles:
    LOAD "Snip_enemy_VRAM", VRAM[$8300]
Snip_enemy_vram_tiles:
tile1:
    DB $18, $00, $18, $18, $08, $10, $67, $ff, $db, $fe, $96, $fd, $7b, $fe, $6e, $5d
tile2:
    DB $37, $2e, $1f, $3f, $2c, $3f, $07, $30, $05, $56, $23, $04, $03, $02, $00, $00
tile3:
    DB $00, $00, $00, $00, $10, $08, $ff, $67, $db, $fe, $96, $fd, $7b, $fe, $6e, $5d
tile4:
    DB $37, $2e, $1f, $3f, $2c, $3f, $07, $30, $05, $56, $23, $04, $03, $02, $00, $00
    ENDL
.end
