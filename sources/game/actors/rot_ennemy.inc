; ################################
; Rot ennemy struct and definitions
; ################################


    IF!DEF(ROT_ENNEMY_INC)
DEF ROT_ENNEMY_INC EQU 1

DEF Y_SPEED                 EQU %00001111
DEF X_SPEED                 EQU %00001001

; ENNEMY STATES :
;   DEAD
;   SHOOT
;   MOVE_COUNT

; MOVE STATES :
;   DESCENT
;   ASCENT_RIGHT
;   ASCENT_LEFT

DEF DEAD_STATE              EQU %01000000
DEF SHOOT_STATE             EQU %00010000
DEF COUNTER_STATE           EQU %00000010

DEF MOVE_DESCENT_STATE      EQU %00000001
DEF MOVE_ASCENT_RIGHT_STATE EQU %00000010
DEF MOVE_ASCENT_LEFT_STATE  EQU %00000011

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

DEF SIZEOF_rot_ennemy_data  RB 0

STATIC_ASSERT SIZEOF_rot_ennemy_data <= ACTORS_DATA_SIZE, "Data struct is too large"

    ENDC ; ROT_ENNEMY_INC
