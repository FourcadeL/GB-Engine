; #####################################################
; Player constants
; #####################################################


	IF !DEF(PLAYER_INC)
DEF PLAYER_INC EQU 1

DEF Player_sprite_entry EQUS "Sprite_table"
DEF Player_displaylist_entry EQUS "DisplayList_table"

DEF Player_x_speed EQU %00010101
DEF Player_y_speed EQU %00001110
DEF Player_boundary_left EQU $0070
DEF Player_boundary_right EQU $0990
DEF Player_boundary_up EQU $00C0
DEF Player_boundary_down EQU $0880

DEF Player_hitbox_width EQU 14
DEF Player_hitbox_height EQU 12

DEF Player_anim_counter_reset EQU 14

	ENDC ; PLAYER_INC