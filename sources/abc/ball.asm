; Fonctions et routines pour la gestion de balles

; position value  : %BBBBBBBBbbbbbbbb
; screen position :        ^^^^^^^^

; -----constantes physiques-------------
BALL_X_INIT_POS EQU %0000000000010000
BALL_Y_INIT_POS EQU %0000000000010000
BALL_X_SPEED EQU %00000010
BALL_Y_SPEED EQU %00000010
; --------------------------------------

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
    ret


ball_move::

ball_calculate_screen_pos::
    ld



SECTION "ball_variables", WRAM0

; ball position (big endian)
ball_pos_x: DS 2
ball_pos_y: DS 2

; les positions sur l'écran sont ramenées à 8bits
; par des opérations de shift sur la position détaillée
ball_screen_pos_x: DS 1
ball_screen_bos_y: DS 1