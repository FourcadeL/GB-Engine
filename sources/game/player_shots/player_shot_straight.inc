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


DEF PS_STRAIGHT_FIRST_INDEX EQU 0
DEF PS_STRAIGHT_NB EQU 2

EXPORT Player_shot_straight_tiles
EXPORT Player_shot_straight_tiles.end
EXPORT Player_shot_straight_vram_tiles

MACRO PS_STRAIGHT_INIT
	; copy tiles into VRAM
	ld hl, Player_shot_straight_tiles
	ld de, Player_shot_straight_vram_tiles
	ld c, Player_shot_straight_tiles.end - Player_shot_straight_tiles
	call vram_copy_fast

	; set tiles for straight shots in displayList
	ld hl, ps_dynamic_displayList_content + PS_STRAIGHT_FIRST_INDEX * 4 + 2
	ld a, (Player_shot_straight_vram_tiles - _VRAM)/16
	ld d, PS_STRAIGHT_NB
.straight_set_loop
	ld [hl+], a
	inc hl
	inc hl
	inc hl
	dec d
	jr nz, .straight_set_loop
ENDM
