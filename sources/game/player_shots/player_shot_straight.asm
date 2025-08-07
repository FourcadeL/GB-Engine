; #############################
; PS Straight
;
;	This file serves for behaviour and data
;	for the straight shots fired by the player
;
;	All gestion for display and update calls
;	are found in "player_shots.asm"
;		(maybe define here the update macro ?)
;
;	Straight shots are shots index 0 and 1 in the
;	player_shots tables
; #############################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "player_shot_straight.inc"




;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |					MACROS 				  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+
; TODO





;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |					VRAM 				  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+


	SECTION "PS_straight_tiles", ROMX
Player_shot_straight_tiles:
	LOAD "PS_straight_VRAM", VRAM [$8280]
Player_shot_straight_vram_tiles:
tile1:
	DB $00, $00, $00, $00, $00, $00, $00, $00, $18, $18, $18, $00, $18, $18, $18, $18
tile2:
	DB $18, $18, $18, $18, $18, $3c, $24, $3c, $00, $00, $00, $00, $00, $00, $00, $00
	ENDL
.end

