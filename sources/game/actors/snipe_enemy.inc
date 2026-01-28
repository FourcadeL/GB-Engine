; #########################################
; Sniper enemy struct and definitions
; #########################################

    IF!DEF(SNIP_ENEMY_INC)
DEF SNIP_ENEMY_INC EQU 1

DEF SNIP_E_HITBOX_WIDTH         EQU 6
DEF SNIP_E_HITBOX_HEIGHT        EQU 8

DEF DEAD_STATE                  EQU %01000000
DEF SHOOT_STATE                 EQU %00010000
DEF MOOVE_STATE                 EQU %00000100
DEF ENTRY_STATE                 EQU %00000010
DEF LEAVE_STATE                 EQU %00000011


DEF BOTOM_ENTRY_Y_VALUE         EQU 154
DEF TOP_ENTRY_Y_VALUE           EQU $F8

DEF DISPLACEMENT_SPEED          EQU 2

    ; SHOTS
DEF SHOOT_COUNTER_VALUE         EQU 6   ; NB of frames to wait before each shoot attempt


    ; ANIMATION
DEF ANIM_COUNTER_VALUE          EQU 7


;+-------------------------------------------------------------+
;| +---------------------------------------------------------+ |
;| |                    STRUCTURES                           | |
;| +---------------------------------------------------------+ |
;+-------------------------------------------------------------+

RSRESET
DEF state                   RB 1 ; state byte
DEF flags                   RB 1 ; flags byte   %e???????;
;                                                |
;                                                +-> ending sequence (1 -> going out of screen)
DEF x_initial               RB 1 ; x pixel starting pos
DEF y_initial               RB 1 ; y pixel starting pos
DEF x_target                RB 1 ; pixel x position of target displacement
DEF y_target                RB 1 ; pixel y position of target displacement
DEF displacement_speed      RB 1 ; enemy speed (2 bits)
DEF shoot_counter           RB 1 ; numbre of frames between each shots
DEF shoot_nb                RB 1 ; number of shots before end
DEF shoot_rate              RB 1 ; shoot threshold for random
DEF shot_speed              RB 1 ; speed of fired shots
DEF anim_counter            RB 1 ; animation counter byte
DEF framerule               RB 1 ; framerule of enemy

DEF SIZEOF_snip_enemy_data  RB 0

STATIC_ASSERT SIZEOF_snip_enemy_data <= ACTORS_DATA_SIZE, "Data struct for snipe enemy is too large"


    ENDC ; SNIP_ENEMY_INC
