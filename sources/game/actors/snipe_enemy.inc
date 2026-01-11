; #########################################
; Sniper enemy struct and definitions
; #########################################

    IF!DEF(SNIP_ENEMY_INC)
DEF SNIP_ENEMY_INC EQU 1

DEF SNIP_E_HITBOX_WIDTH         EQU 6
DEF SNIP_E_HITBOX_HEIGHT        EQU 8

DEF DEAD_STATE                  EQU %01000000
DEF SHOOT_STATE                 EQU %00010000
DEF ENTRY_STATE                 EQU %00000010
DEF LEAVE_STATE                 EQU %00000011


DEF BOTOM_ENTRY_Y_VALUE         EQU 144

    ; ANIMATION
DEF ANIM_COUNTER_VALUE          EQU 7


;+----------------------------------------------------------------------+
;| +------------------------------------------------------------------+ |
;| |                          STRUCTURES                              | |
;| +------------------------------------------------------------------+ |
;+----------------------------------------------------------------------+

RSRESET
DEF state                   RB 1 ; state byte
DEF flags                   RB 1 ; flags byte   %e??????d
;                                                ||     +> direction (1 -> going up | 0 -> going down)
;                                                ||
;                                                ||
;                                                +-> ending sequence (1 -> going out of screen)
DEF y_target                RB 1 ; counter for Y target
DEF shoot_nb                RB 1 ; number of shots before end
DEF shoot_rate              RB 1 ; shoot threshold for random
DEF shot_speed              RB 1 ; speed of fired shots
DEF anim_counter            RB 1 ; animation counter byte
DEF framerule               RB 1 ; framerule of enemy

DEF SIZEOF_snip_enemy_data  RB 0

STATIC_ASSERT SIZEOF_snip_enemy_data <= ACTORS_DATA_SIZE, "Data struct for rot_enemy is too large"


    ENDC ; SNIP_ENEMY_INC
