; Fonctions et routines pour la gestion de balles

; position value  : %BBBBBBBBbbbbbbbb
; screen position :        ^^^^^^^^

; -----constantes physiques-------------
BALL_X_INIT_POS EQU %0000000000010000
BALL_Y_INIT_POS EQU %0000000000010000
BALL_X_INIT_SPEED EQU %00000010
BALL_Y_INIT_SPEED EQU %00000010
; --------------------------------------

    INCLUDE "hardware.inc"
    INCLUDE "engine.inc"
    INCLUDE "debug.inc"
    INCLUDE "macros.inc"

SECTION "ball_functions", ROMX

ball_init::
    ; set position
    ld a, low(BALL_X_INIT_POS)
    ld hl, ball_pos_x
    ld [hli], a
    ld a, high(BALL_X_INIT_POS)
    ld [hl], a
    ld a, low(BALL_Y_INIT_POS)
    ld hl, ball_pos_y
    ld [hli], a
    ld a, high(BALL_Y_INIT_POS)
    ld [hl], a
    ld a, BALL_X_INIT_SPEED
    ld hl, ball_speed_x
    ld [hl+], a
    ld [hl], BALL_Y_INIT_SPEED
    ; create ball sprite
    ld b, %00001000 ;sprite attributes display
    ld c, %00010001 ;sprite size 1*1
    call Sprite_new
    ld hl, ball_sprite
    ld [hl], a
    ld b, a
    ld hl, _ball_tile_id
    call Sprite_set_tiles
    PRINT_DEBUG "Ball init done"
    call _ball_debug_print_position
    ret


ball_move::
    ; add speed vector value to x
    ld hl, ball_pos_x
    ld a, [hl+]
    ld b, [hl]
    ld hl, ball_speed_x
    bit 7, [hl]
    jr z, .speed_x_add
    call sub_hl_speed_to_ba
    jr .speed_x_end
.speed_x_add
    call add_hl_speed_to_ba
.speed_x_end
    ld hl, ball_pos_x
    ld [hl+], a
    ld [hl], b
    ; add speed vector value to y
    ld hl, ball_pos_y
    ld a, [hl+]
    ld b, [hl]
    ld hl, ball_speed_y
    bit 7, [hl]
    jr z, .speed_y_add
    call sub_hl_speed_to_ba
    jr .speed_y_end
.speed_y_add
    call add_hl_speed_to_ba
.speed_y_end
    ld hl, ball_pos_y
    ld [hl+], a
    ld [hl], b
    ret
add_hl_speed_to_ba: ; adds 7 bits of speed value on hl to ba
    add a, [hl]
    ld c, a
    ld a, b
    adc a, $00
    ld b, a
    ld a, c
    ret
sub_hl_speed_to_ba: ; subs 7 bits of speed value on hl to ba
    res 7, [hl]
    sub a, [hl]
    ld c, a
    ld a, b
    sbc a, $00
    ld b, a
    ld a, c
    set 7, [hl]
    ret

ball_calculate_screen_pos::
    ld hl, ball_pos_x
    ld a, [hl+]
    ld b, [hl]
    SHIFTR_U16_ba
    SHIFTR_U16_ba
    ld [ball_screen_pos_x], a
    ld hl, ball_pos_y
    ld a, [hl+]
    ld b, [hl]
    SHIFTR_U16_ba
    SHIFTR_U16_ba
    ld [ball_screen_pos_y], a
    ret

update_ball::
    PRINT_DEBUG "updating ball"
    call ball_move
    call _ball_debug_print_position
    call ball_calculate_screen_pos
    call update_ball_sprite
    ret

update_ball_sprite:
    ; update ball position
    ld hl, ball_sprite
    ld b, [hl]
    ld hl, ball_screen_pos_x
    ld c, [hl]
    call Sprite_set_Xpos
    ld hl, ball_sprite
    ld b, [hl]
    ld hl, ball_screen_pos_y
    call Sprite_set_Ypos
    ; update associated sprite
    ld hl, ball_sprite
    ld b, [hl]
    call Sprite_update_OAM
    ret

_ball_debug_print_position:
    PRINT_DEBUG "ball position :"
    ld hl, ball_pos_x
    ld c, [hl]
    inc hl
    ld b, [hl]
    PRINT_DEBUG "ball x pos : %BC%"
    ld hl, ball_pos_y
    ld c, [hl]
    inc hl
    ld b, [hl]
    PRINT_DEBUG "ball y pos : %BC%"
    PRINT_DEBUG "ball screen position :"
    ld hl, ball_screen_pos_x
    ld b, [hl]
    PRINT_DEBUG "ball screen x : %B%"
    ld hl, ball_screen_pos_y
    ld b, [hl]
    PRINT_DEBUG "ball screen y : %B%"
    ret

SECTION "ball_data", ROMX
_ball_tile_id: DB $14


SECTION "ball_variables", WRAM0

ball_sprite: DS 1

; ball position (big endian)
ball_pos_x: DS 2
ball_pos_y: DS 2
; ball speed (8 bit two's complement)
ball_speed_x: DS 1
ball_speed_y: DS 1

; les positions sur l'écran sont ramenées à 8bits
; par des opérations de shift sur la position détaillée
ball_screen_pos_x: DS 1
ball_screen_pos_y: DS 1