; ################################
; Rot ennemy struct and definitions
; ################################


    IF!DEF(ROT_ENNEMY_INC)
DEF ROT_ENNEMY_INC EQU 1

DEF Y_SPEED                 EQU %00001101
DEF X_SPEED                 EQU %00000111

DEF ASCENT_TIME_COUNTER     EQU 50
DEF DESCENT_TIME_COUNTER    EQU 70

; DEF BOUNDARY_LEFT           EQU

; ENNEMY STATES :
;   DEAD
;   DELETE
;   SHOOT
;   COUNTER
;   CHANGE_MOVE
;   CHANGE_FIRE_RATE
;   CHANGET_FIRE_SPEED

; MOVE STATES :
;   DESCENT
;   ASCENT_RIGHT
;   ASCENT_LEFT

DEF DEAD_STATE                  EQU %01000000
DEF DELETE_STATE                EQU %01000001
DEF SHOOT_STATE                 EQU %00010000
DEF COUNTER_STATE               EQU %00000010
DEF CHANGE_MOVE_STATE           EQU %10000001
DEF CHANGE_FIRE_RATE_STATE      EQU %10000010
DEF CHANGE_FIRE_SPEED_STATE     EQU %10000011

DEF MOVE_DESCENT_STATE          EQU %00000001
DEF MOVE_ASCENT_RIGHT_STATE     EQU %00000010
DEF MOVE_ASCENT_LEFT_STATE      EQU %00000011

;+----------------------------------------------------------------------+
;| +------------------------------------------------------------------+ |
;| |                          STRUCTURES                              | |
;| +------------------------------------------------------------------+ |
;+----------------------------------------------------------------------+

; rotating ennemy data structure
RSRESET
DEF state                   RB 1 ; state byte
DEF move_state              RB 1 ; type of move for the ennemy
DEF Y_pos                   RB 2 ; 2 bytes Y pos (little endian)
DEF X_pos                   RB 2 ; 2 bytes X pos (little endian)
DEF move_counter            RB 1 ; move counter byte
DEF shoot_timeout           RB 1 ; timeout before next shoot
DEF shoot_rate              RB 1 ; shoot rate mask for random
DEF shot_speed              RB 1 ; speed of fired shots

DEF SIZEOF_rot_ennemy_data  RB 0

STATIC_ASSERT SIZEOF_rot_ennemy_data <= ACTORS_DATA_SIZE, "Data struct is too large"

    ENDC ; ROT_ENNEMY_INC
