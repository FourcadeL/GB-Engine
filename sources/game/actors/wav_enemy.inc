; ######################################
; Waving enemy struct and definitions
; ######################################


    IF!DEF(WAV_ENEMY_INC)
DEF WAV_ENEMY_INC EQU 1

DEF Y_SPEED                 EQU $0F



; Auto delete passed this Y threshold
DEF BOUNDARY_Y              EQU 160

; hitbox values
DEF WAV_E_HITBOX_WIDTH      EQU 6
DEF WAV_E_HITBOX_HEIGHT     EQU 8

; animation speed
DEF ANIM_COUNTER_VALUE      EQU 24


; ENNEMY STATES :
;   DEAD
;   DELETE
;   SHOOT
;   COUNTER


DEF DEAD_STATE              EQU %01000000
DEF DELETE_STATE            EQU %01000001
DEF SHOOT_STATE             EQU %00010000
DEF COUNTER_STATE           EQU %00000010


;+----------------------------------------------------------------------+
;| +------------------------------------------------------------------+ |
;| |                          STRUCTURES                              | |
;| +------------------------------------------------------------------+ |
;+----------------------------------------------------------------------+

RSRESET
DEF state                   RB 1 ; state byte
DEF x_movement_count        RB 1 ; counter for sine value to use in X movement
DEF x_movement_step         RB 1 ; movement step in sine table (sine amplitude)
DEF shoot_timeout           RB 1 ; timeout between shots (counter reset value)
DEF shoot_counter           RB 1 ; countdown counter for next shot (updated counter)
DEF shoot_rate              RB 1 ; shoot threshold for random
DEF shot_speed              RB 1 ; speed of fired shots
DEF anim_counter            RB 1 ; animation counter byte
DEF framerule               RB 1 ; framerule of enemy

DEF SIZEOF_wav_enemy_data   RB 0

STATIC_ASSERT SIZEOF_wav_enemy_data <= ACTORS_DATA_SIZE, "Data struct for rot_enemy is too large"

    ENDC ; WAV_ENEMY_INC
