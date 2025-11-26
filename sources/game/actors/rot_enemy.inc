; ################################
; Rot ennemy struct and definitions
; ################################


    IF!DEF(ROT_ENNEMY_INC)
DEF ROT_ENNEMY_INC EQU 1

DEF Y_SPEED                 EQU %00001101
DEF X_SPEED                 EQU %00001010

DEF ASCENT_TIME_COUNTER     EQU 36
DEF DESCENT_TIME_COUNTER    EQU 98

; Auto delete after passed threshold
DEF BOUNDARY_Y              EQU 160

; hitbox values
DEF ROT_E_HITBOX_WIDTH      EQU 8
DEF ROT_E_HITBOX_HEIGHT     EQU 8


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
DEF move_counter            RB 1 ; move counter byte
DEF shoot_timeout           RB 1 ; timeout between shots
DEF shoot_counter           RB 1 ; countdown counter for next shot
DEF shoot_rate              RB 1 ; shoot threshold for random
DEF shot_speed              RB 1 ; speed of fired shots
DEF framerule               RB 1 ; framerule for collision test

DEF SIZEOF_rot_ennemy_data  RB 0

STATIC_ASSERT SIZEOF_rot_ennemy_data <= ACTORS_DATA_SIZE, "Data struct for rot_enemy is too large"

    ENDC ; ROT_ENNEMY_INC
