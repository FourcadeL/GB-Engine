; ######################
; PS Straight macros
;
;	These macros actually defines
;	Routines specific to
;	"player_shot_straight.asm"
;	but meant to be called in
;	"player_shots.asm"
;	for code efficiency
; ######################



EXPORT Player_shot_straight_tiles
EXPORT Player_shot_straight_tiles.end
EXPORT Player_shot_straight_vram_tiles

MACRO PS_STRAIGHT_INIT
	; copy tiles into VRAM
	ld hl, Player_shot_straight_tiles
	ld de, Player_shot_straight_vram_tiles
	ld c, Player_shot_straight_tiles.end - Player_shot_straight_tiles
	call vram_copy_fast
ENDM
