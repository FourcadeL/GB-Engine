; #######################################
; Player functions
; 
;   move
;   shoot
; #######################################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "charmap.inc"


DEF Player_sprite_entry EQUS "Sprite_table"
DEF Player_displaylist_entry EQUS "DisplayList_table"


    SECTION "Player_code", ROMX

Player_init::
	; copy player tiles into VRAM
	ld hl, Player_tiles
	ld de, Player_vram_tiles
	ld c, Player_tiles.end - Player_tiles
	call vram_copy_fast

    ; reset variables
    ld      d, $00
    ld      hl, _player_variables_start
    ld      b, _player_variables_end - _player_variables_start
    call    memset_fast

	; init sprite
		; init sprite entry
	ld hl, Player_sprite_entry
	ld a, %10000001 	; player sprite active and displayed
	ld [hl+], a
	ld a, 0				; use display list entry 0
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a

		; init display list entry
	ld hl, Player_displaylist_entry
	ld a, LOW(player_dl_static)
	ld [hl+], a
	ld a, HIGH(player_dl_static)
	ld [hl], a
    ret


Player_update::
    ; BASIC POSITION UPDATE
    ld hl, player_Xpos
    ld a, [PAD_hold]
    and PAD_RIGHT
    cp a, PAD_RIGHT
    jr nz, .skip_right
    inc [hl]
.skip_right
    ld hl, player_Xpos
    ld a, [PAD_hold]
    and PAD_LEFT
    cp a, PAD_LEFT
    jr nz, .skip_left
    dec [hl]
.skip_left
    ld hl, player_Ypos
    ld a, [PAD_hold]
    and PAD_DOWN
    cp a, PAD_DOWN
    jr nz, .skip_down
    inc [hl]
.skip_down
    ld hl, player_Ypos
    ld a, [PAD_hold]
    and PAD_UP
    cp a, PAD_UP
    jr nz, .skip_up
    dec [hl]
.skip_up

    ; SPRITE POSITION BASIC UPDATE
	ld hl, Player_sprite_entry + 2
	ld a, [player_Ypos]
	ld [hl], a

	ld hl, Player_sprite_entry + 4
	ld a, [player_Xpos]
	ld [hl], a  
	;TODO
    
    ret


    

	SECTION "Player_variables", WRAM0
_player_variables_start:
player_state::      DS 1
player_sprite_idx:: DS 1
player_Xpos::       DS 2
player_Ypos::       DS 2
_player_variables_end:

	SECTION "Player_display_lists", ROMX
player_dl_static:
	DB 2
	DB 0, 0, (tile1 - _VRAM)/16, 0
	DB 0, 8, (tile1 - _VRAM)/16, OAMF_XFLIP



;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |					VRAM 											  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

	SECTION "Player_tiles", ROMX
Player_tiles:
	LOAD "Player_VRAM", VRAM[$8000]
Player_vram_tiles:
tile1:
	DB $00, $00, $01, $01, $03, $02, $03, $06, $02, $07, $0e, $27, $2f, $2e, $1f, $37
tile2:
	DB $3d, $6e, $6f, $5b, $57, $6e, $77, $4d, $54, $7d, $52, $57, $12, $13, $01, $11
tile3:
	DB $00, $00, $01, $01, $03, $02, $03, $00, $00, $03, $00, $0b, $07, $0c, $0f, $0f
tile4:
	DB $0e, $09, $0b, $0f, $0b, $06, $0b, $07, $02, $0f, $0e, $0f, $04, $0d, $01, $09
tile5:
	DB $00, $00, $80, $80, $80, $80, $80, $80, $80, $80, $c0, $90, $f0, $f0, $e0, $b0
tile6:
	DB $b0, $f8, $b8, $e8, $68, $d8, $e8, $58, $28, $f8, $68, $e8, $a0, $a0, $00, $20
	ENDL
.end