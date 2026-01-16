; #####################################################
; Player constants
; #####################################################


    IF !DEF(PLAYER_INC)
DEF PLAYER_INC EQU 1

DEF Player_sprite_entry EQUS "Sprite_table"
DEF Player_displaylist_entry EQUS "DisplayList_table"

DEF Player_x_init_pos EQU 80
DEF Player_y_init_pos EQU 120
; DEF Player_x_speed EQU %00010101
DEF Player_x_speed EQU %00011101
; DEF Player_y_speed EQU %00001110
DEF Player_y_speed EQU %00011011
DEF Player_boundary_left EQU $0070
DEF Player_boundary_right EQU $0990
DEF Player_boundary_up EQU $00C0
DEF Player_boundary_down EQU $0880

DEF Player_hitbox_width EQU 12
DEF Player_hitbox_height EQU 12

DEF Player_anim_counter_reset EQU 14

DEF Player_death_anim_counter EQU 160

DEF Player_invincibility_time  EQU 34


    ; PLAYER STATE BITS
DEF PLAYER_STATUS_DESTROYED         EQU 7
DEF PLAYER_STATUS_SHOT_COLLISION    EQU 6
DEF PLAYER_STATUS_ENEMY_COLLISION   EQU 5
DEF PLAYER_STATUS_DYING             EQU 4
DEF PLAYER_STATUS_PU_COLLISION      EQU 3
DEF PLAYER_STATUS_LEFT_MOVE         EQU 2
DEF PLAYER_STATUS_RIGHT_MOVE        EQU 1
DEF PLAYER_STATUS_VERTICAL_MOVE     EQU 0

DEF PLAYER_STATUS_PRIV_INVICIBILITY EQU 0

    ENDC ; PLAYER_INC
