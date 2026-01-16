; #######################################
; Player functions
;
;   move
;       Player position is 2 bytes : %xxxxpppp %ppppssss
;           bits x are unused
;           bits p are position
;           bits s are sub-pixels
;   shoot
; #######################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "charmap.inc"
INCLUDE "player.inc"


    SECTION "Player_variables", WRAM0
_player_variables_start:
player_state::                  DS 1
;   %xxxxxlrv
;    |||||||+-> player has moved vertically
;    |||||||
;    ||||||+-> player has moved right
;    ||||||
;    |||||+-> player has moved left
;    |||||
;    ||||+-> player collision with a powerup
;    ||||
;    |||+-> player is in a dying state (should not give control to player)
;    |||
;    ||+-> player collision with ennemy
;    |+-> player collision with shot
;    +-> player destroyed
player_state_private:           DS 1
;   %xxxxxxxx
;           +--> player is in invincibility state
player_anim_counter::           DS 1
DEF player_Xpos EQUS "Player_sprite_entry + 4"
; player_Xpos::           DS 2
DEF player_Ypos EQUS "Player_sprite_entry + 2"
; player_Ypos::           DS 2
player_pixel_Xpos::             DS 1            ; the integral X position of the player
player_pixel_Ypos::             DS 1            ; the integral Y position of the player
player_dying_counter:           DS 1            ; dying animation counter
player_power_state:             DS 1            ; power up state of the player
                                                 ; 3 states : 0, 1 and 2
player_invincibility_counter:    DS 1
_player_variables_end:



    SECTION "Player_code", ROMX

Player_init::
    ; copy player tiles into VRAM
    ld hl, Player_tiles
    ld de, Player_vram_tiles
    ld c, Player_tiles.end - Player_tiles
    call vram_copy_fast

    ; reset variables
    ld      d, $00
    ld      hl, _player_variables_start
    ld      b, _player_variables_end - _player_variables_start
    call    memset_fast

    ; init sprite
        ; init sprite entry
    ld hl, Player_sprite_entry
    ld a, %10000001     ; player sprite active and displayed
    ld [hl+], a
    ld a, 0             ; use display list entry 0
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a

    ld hl, player_Xpos
    ld a, LOW(Player_x_init_pos << 4)
    ld [hl+], a
    ld a, Player_x_init_pos >> 4
    ld [hl], a
    ld hl, player_Ypos
    ld a, LOW(Player_y_init_pos << 4)
    ld [hl+], a
    ld a, Player_y_init_pos >> 4
    ld [hl], a

        ; set dying counter
    ld hl, player_dying_counter
    ld [hl], Player_death_anim_counter

        ; set invincibility counter
    ld a, Player_invincibility_time
    ld [player_invincibility_counter], a

    call Player_set_idle_frame
    ret


Player_set_idle_frame:
    ld hl, Player_displaylist_entry
    ld a, LOW(player_dl_static)
    ld [hl+], a
    ld [hl], HIGH(player_dl_static)
    ret

Player_set_right_frame:
    ld hl, Player_displaylist_entry
    ld a, LOW(player_dl_right)
    ld [hl+], a
    ld [hl], HIGH(player_dl_right)
    ret

Player_set_left_frame:
    ld hl, Player_displaylist_entry
    ld a, LOW(player_dl_left)
    ld [hl+], a
    ld [hl], HIGH(player_dl_left)
    ret

Player_move_up:
    ld hl, player_state
    set PLAYER_STATUS_VERTICAL_MOVE, [hl]
    ld a, [player_Ypos]
    sub a, Player_y_speed
    ld [player_Ypos], a
    ld a, [player_Ypos+1]
    sbc a, 0
    ld [player_Ypos+1], a
    ret

Player_move_down:
    ld hl, player_state
    set PLAYER_STATUS_VERTICAL_MOVE, [hl]
    ld a, [player_Ypos]
    add a, Player_y_speed
    ld [player_Ypos], a
    ld a, [player_Ypos+1]
    adc a, 0
    ld [player_Ypos+1], a
    ret

Player_move_left:
    ld hl, player_state
    set PLAYER_STATUS_LEFT_MOVE, [hl]
    ld a, [player_Xpos]
    sub a, Player_x_speed
    ld [player_Xpos], a
    ld a, [player_Xpos+1]
    sbc a, 0
    ld [player_Xpos+1], a
    ret

Player_move_right:
    ld hl, player_state
    set PLAYER_STATUS_RIGHT_MOVE, [hl]
    ld a, [player_Xpos]
    add a, Player_x_speed
    ld [player_Xpos], a
    ld a, [player_Xpos+1]
    adc a, 0
    ld [player_Xpos+1], a
    ret

Player_reset_left_pos:
    ld hl, player_Xpos
    ld a, LOW(Player_boundary_left)
    ld [hl+], a
    ld [hl], HIGH(Player_boundary_left)
    ret

Player_reset_right_pos:
    ld hl, player_Xpos
    ld a, LOW(Player_boundary_right)
    ld [hl+], a
    ld [hl], HIGH(Player_boundary_right)
    ret

Player_reset_up_pos:
    ld hl, player_Ypos
    ld a, LOW(Player_boundary_up)
    ld [hl+], a
    ld [hl], HIGH(Player_boundary_up)
    ret

Player_reset_down_pos:
    ld hl, player_Ypos
    ld a, LOW(Player_boundary_down)
    ld [hl+], a
    ld [hl], HIGH(Player_boundary_down)
    ret

; -----------------------------
; invincibility_update()
;   masks the collision bits
;   make player flicker
;   decrement counter and reset when over
; -----------------------------
invincibility_update:
    ; mask collisions
    ld a, [player_state]
    and a, %10011111
    ld [player_state], a
    ; make player flicker
    ld a, [Player_sprite_entry]
    xor a, %00000001
    ld [Player_sprite_entry], a
    ; decrement counter
    ld a, [player_invincibility_counter]
    dec a
    ld [player_invincibility_counter], a
    ret nz
        ; zero, timer over -> reset invincibility and timer and reset flicker
    ld a, Player_invincibility_time
    ld [player_invincibility_counter], a
    ld a, [player_state_private]
    res PLAYER_STATUS_PRIV_INVICIBILITY, a
    ld [player_state_private], a
    ld a, [Player_sprite_entry]
    or a, %00000001
    ld [Player_sprite_entry], a
    ret

; ---------------------------
; dying_update()
;   display some explosions before setting the "dead bit" state
; ---------------------------
dying_update:
    ld hl, player_dying_counter
    dec [hl]
    jr z, .over
        ; sprite flicker
        push hl
        ld hl, Player_sprite_entry
        ld a, [hl]
        ld b, a
        and a, %11111110
        ld c, a
        ld a, b
        inc a
        res 1, a
        or a, c
        ld [hl], a

        pop hl

        ; display animation
        ld a, %00000111
        and a, [hl]
        ret nz

        call generateRandom
        and a, %00010111
        sub a, %00001111
        ld d, a
        ld a, [player_pixel_Xpos]
        add a, d
        ld b, a

        push bc
        call generateRandom
        pop bc

        and a, %00010111
        sub a, %00001111
        ld d, a
        ld a, [player_pixel_Ypos]
        add a, d
        ld c, a

        jp Explosion_request

.over
    ld hl, player_state
    set PLAYER_STATUS_DESTROYED, [hl]
    ret

Player_update::
    ld hl, player_state
    bit PLAYER_STATUS_DESTROYED, [hl]
    ret nz                              ; dead -> no routine
    bit PLAYER_STATUS_DYING, [hl]
    jr nz, dying_update                 ; dying state, no control

    ; INVINCIBILITY MASK ?
    ld a, [player_state_private]
    bit PLAYER_STATUS_PRIV_INVICIBILITY, a
    call nz, invincibility_update

    ; COLLISIONS UPDATE
    bit PLAYER_STATUS_SHOT_COLLISION, [hl]
    jr z, .no_shot_collision
        ; set invincibility
        ld a, (1<<PLAYER_STATUS_PRIV_INVICIBILITY)
        ld [player_state_private], a
        ; reset flag
        res PLAYER_STATUS_SHOT_COLLISION, [hl]
        ld a, [player_power_state]
        sub a, 1
        jr nc, .not_dead
            ; carry -> powerup underflow -> dead
            set PLAYER_STATUS_DYING, [hl]
    .not_dead
        ld [player_power_state], a
.no_shot_collision

    bit PLAYER_STATUS_ENEMY_COLLISION, [hl]
    jr z, .no_enemy_collision
        set PLAYER_STATUS_DYING, [hl]
.no_enemy_collision

    ; POWERUP UPDATE
    bit PLAYER_STATUS_PU_COLLISION, [hl]
    jr z, .no_power_up_update
        ; set invincibility
        ld a, (1<<PLAYER_STATUS_PRIV_INVICIBILITY)
        ld [player_state_private], a
        ; reset power up flag
        res PLAYER_STATUS_PU_COLLISION, [hl]
        ; increment power state
        ld a, [player_power_state]
        inc a
        cp a, 3
        jr c, .ok
            ld a, 2
    .ok
        ld [player_power_state], a

        ; TODO : SFX
.no_power_up_update

    ; POSITION UPDATE
    ld a, [PAD_hold]
    and PAD_RIGHT
    call nz, Player_move_right

    ld a, [PAD_hold]
    and PAD_LEFT
    call nz, Player_move_left

    ld a, [PAD_hold]
    and PAD_DOWN
    call nz, Player_move_down

    ld a, [PAD_hold]
    and PAD_UP
    call nz, Player_move_up

    ; PIXEL POSITION UPDATE
    ld hl, player_Xpos
    ld a, [hl+]
    swap a
    and a, %00001111
    ld b, a
    ld a, [hl]
    swap a
    and a, %11110000
    or a, b
    ld [player_pixel_Xpos], a
    ld hl, player_Ypos
    ld a, [hl+]
    swap a
    and a, %00001111
    ld b, a
    ld a, [hl]
    swap a
    and a, %11110000
    or a, b
    ld [player_pixel_Ypos], a

    ; ANIMATION
    ld a, [PAD_pressed]
    and a, PAD_LEFT + PAD_RIGHT
    ld b, a
    ld a, [PAD_hold]
    and a, PAD_LEFT + PAD_RIGHT
    xor a, b                ; new counter ?
    jr nz, .noCounterReset
    ld hl, player_anim_counter
    ld [hl], Player_anim_counter_reset
    call Player_set_idle_frame
.noCounterReset
    ld hl, player_anim_counter
    dec [hl]
    jr nz, .noFrameUpdate
    ld a, [player_state]
    and a, %00000100                ; animation left ?
    call nz, Player_set_left_frame
    ld a, [player_state]
    and a, %00000010                ; animation right ?
    call nz, Player_set_right_frame
.noFrameUpdate
    ld a, [player_state]
    and a, %11111000            ; reset animation flags
    ld [player_state], a

    ; BOUDARIES APPLY
        ; boundary X
    ld a, [player_pixel_Xpos]
    ld b, a
    cp a, (HIGH(Player_boundary_left)<<4) + (LOW(Player_boundary_left)>>4)
    call c, Player_reset_left_pos
    ld a, b
    cp a, (HIGH(Player_boundary_right)<<4) + (LOW(Player_boundary_right)>>4)
    call nc, Player_reset_right_pos
        ; boundary Y
    ld a, [player_pixel_Ypos]
    ld b, a
    cp a, (HIGH(Player_boundary_up)<<4) + (LOW(Player_boundary_up)>>4)
    call c, Player_reset_up_pos
    ld a, b
    cp a, (HIGH(Player_boundary_down)<<4) + (LOW(Player_boundary_down)>>4)
    call nc, Player_reset_down_pos

    ; SHOOTING
    ld a, [PAD_repeat]
    and a, PAD_A
    jr z, .skipShooting
        ; get player pixel position
    ld a, [player_pixel_Xpos]
    ld b, a
    ld a, [player_pixel_Ypos]
    ld c, a

        ; test powerup state
    ld a, [player_power_state]
    cp a, 1
    jr c, .single_shoot
    cp a, 2
    jr c, .forward_shoot
        ; state >= 2 -> shoot behind
        push bc
        ld d, 2
        call PS_diag_request
        pop bc
        push bc
        ld d, 3
        call PS_diag_request
        pop bc
.forward_shoot
        ; state >= 1 -> shoot diagonal
        push bc
        ld d, 0
        call PS_diag_request
        pop bc
        push bc
        ld d, 1
        call PS_diag_request
        pop bc
.single_shoot
    call PS_straight_request

.skipShooting
    ret





    SECTION "Player_display_lists", ROMX
player_dl_static:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, 0
    DB -8, 0, (tile1 - _VRAM)/16, OAMF_XFLIP
player_dl_left:
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, 0
    DB -8, 0, (tile5 - _VRAM)/16, 0
player_dl_right:
    DB 2
    DB -8, -8, (tile5 - _VRAM)/16, OAMF_XFLIP
    DB -8, 0, (tile3 - _VRAM)/16, OAMF_XFLIP


;+---------------------------------------------------------------------+
;| +-----------------------------------------------------------------+ |
;| |                    VRAM                                         | |
;| +-----------------------------------------------------------------+ |
;+---------------------------------------------------------------------+

    SECTION "Player_tiles", ROMX
Player_tiles:
    LOAD "Player_VRAM", VRAM[$8000]
Player_vram_tiles:
tile1:
    DB $00, $00, $01, $01, $03, $02, $03, $06, $02, $07, $0e, $27, $2f, $2e, $1f, $37
tile2:
    DB $3d, $6e, $6f, $5b, $57, $6e, $77, $4d, $54, $7d, $52, $57, $12, $13, $01, $11
tile3:
    DB $00, $00, $01, $01, $03, $02, $03, $00, $00, $03, $00, $0b, $07, $0c, $0f, $0f
tile4:
    DB $0e, $09, $0b, $0f, $0b, $06, $0b, $07, $02, $0f, $0e, $0f, $04, $0d, $01, $09
tile5:
    DB $00, $00, $80, $80, $80, $80, $80, $80, $80, $80, $c0, $90, $f0, $f0, $e0, $b0
tile6:
    DB $b0, $f8, $b8, $e8, $68, $d8, $e8, $58, $28, $f8, $68, $e8, $a0, $a0, $00, $20
    ENDL
.end
