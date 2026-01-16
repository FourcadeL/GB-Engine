; ##########################################
; PowerUp struct and definitions
; ##########################################

    IF !DEF(PU_INC)
DEF PU_INC EQU 1

DEF PU_HITBOX_WIDTH         EQU 7
DEF PU_HITBOX_HEIGHT        EQU 7

DEF Y_SPEED                 EQU $05
DEF BOUNDARY_Y              EQU 160

DEF SINE_STEP               EQU 2


    ; ANIMATION
DEF ANIMATION_COUNTER_VAL   EQU 14
DEF NB_ANIMATION_FRAME      EQU 4


;+---------------------------------------------------------------+
;| +-----------------------------------------------------------+ |
;| |                      STRUCTURES                           | |
;| +-----------------------------------------------------------+ |
;+---------------------------------------------------------------+

RSRESET
DEF own_index               RB 1 ; the index of this pu on the screen
DEF x_movement_count        RB 1 ; counter for sine value to use in X movement

DEF SIZEOF_powerup_data     RB 0

STATIC_ASSERT SIZEOF_powerup_data <= ACTORS_DATA_SIZE, "Data structure for powerup is too large"


    ENDC ; PU_INC
