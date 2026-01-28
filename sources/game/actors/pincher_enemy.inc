; ########################################
; Pincher enemy struct and definitions
; ########################################

    IF!DEF(PINCH_ENEMY_INC)
DEF PINCH_ENEMY_INC EQU 1

DEF PURSUIT_STATE           EQU %10000000
DEF DEAD_STATE              EQU %01000000
DEF RETURN_STATE            EQU %10000001

DEF PINCH_E_HITBOX_WIDTH    EQU 6
DEF PINCH_E_HITBOX_HEIGHT   EQU 6

DEF DIRECTION_UPDATE_TRESH  EQU 7

;+-------------------------------------------------------------+
;| +---------------------------------------------------------+ |
;| |                    STRUCTURES                           | |
;| +---------------------------------------------------------+ |
;+-------------------------------------------------------------+

RSRESET
DEF state                   RB 1
DEF displacement_speed      RB 1 ; enemy speed (2 bits)
DEF timeout_counter         RB 2 ; counter until enemy gives up
DEF x_out_target            RB 1 ; x pixel position target for out sequence
DEF y_out_target            RB 1 ; y pixel position target for out sequence
DEF framerule               RB 1
DEF update_counter          RB 1 ; counter for displacement vector update
DEF d_vector_y              RB 2 ; current displacement vector y
DEF d_vector_x              RB 2 ; current displacement vector x

DEF SIZEOF_pinch_enemy_data RB 0

STATIC_ASSERT SIZEOF_pinch_enemy_data <= ACTORS_DATA_SIZE, "Data structure for pinch enemy is too large"

    ENDC    ; PINCH_ENEMY_INC

