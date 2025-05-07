; #######################################
; Player functions
; 
;   move
;		Player position is 2 bytes : %xxxxpppp %ppppssss
;			bits x are unused
;			bits p are position
;			bits s are sub-pixels
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

DEF Player_x_speed EQU %00010101
DEF Player_y_speed EQU %00001110
DEF Player_boundary_left EQU $0070
DEF Player_boundary_right EQU $0990
DEF Player_boundary_up EQU $00C0
DEF Player_boundary_down EQU $0880

DEF Player_anim_counter_reset EQU 14

	SECTION "Player_variables", WRAM0
_player_variables_start:
player_state::      	DS 1
;	%xxxxxlrv
;		  ||+-> player has moved vertically
;		  ||
;		  |+-> player has moved right
;		  |
;		  +-> player has moved left
player_anim_counter::	DS 1
player_Xpos::       	DS 2
player_Ypos::       	DS 2
_player_variables_end:



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

	call Player_set_idle_frame
    ret


Player_set_idle_frame:
	ld hl, Player_displaylist_entry
	ld a, LOW(player_dl_static)
	ld [hl+], a
	ld [hl], HIGH(player_dl_static)
	ret

Player_set_right_frame:
	ld hl, Player_displaylist_entry
	ld a, LOW(player_dl_right)
	ld [hl+], a
	ld [hl], HIGH(player_dl_right)
	ret

Player_set_left_frame:
	ld hl, Player_displaylist_entry
	ld a, LOW(player_dl_left)
	ld [hl+], a
	ld [hl], HIGH(player_dl_left)
	ret
	
Player_move_up:
	ld hl, player_state
	set 0, [hl]
	ld a, [player_Ypos]
	sub a, Player_y_speed
	ld [player_Ypos], a
	ld a, [player_Ypos+1]
	sbc a, 0
	ld [player_Ypos+1], a
	ret

Player_move_down:
	ld hl, player_state
	set 0, [hl]
	ld a, [player_Ypos]
	add a, Player_y_speed
	ld [player_Ypos], a
	ld a, [player_Ypos+1]
	adc a, 0
	ld [player_Ypos+1], a
	ret

Player_move_left:
	ld hl, player_state
	set 2, [hl]
	ld a, [player_Xpos]
	sub a, Player_x_speed
	ld [player_Xpos], a
	ld a, [player_Xpos+1]
	sbc a, 0
	ld [player_Xpos+1], a
	ret

Player_move_right:
	ld hl, player_state
	set 1, [hl]
	ld a, [player_Xpos]
	add a, Player_x_speed
	ld [player_Xpos], a
	ld a, [player_Xpos+1]
	adc a, 0
	ld [player_Xpos+1], a
	ret

Player_reset_left_pos:
	ld hl, player_Xpos
	ld a, LOW(Player_boundary_left)
	ld [hl+], a
	ld [hl], HIGH(Player_boundary_left)
	ret

Player_reset_right_pos:
	ld hl, player_Xpos
	ld a, LOW(Player_boundary_right)
	ld [hl+], a
	ld [hl], HIGH(Player_boundary_right)
	ret

Player_reset_up_pos:
	ld hl, player_Ypos
	ld a, LOW(Player_boundary_up)
	ld [hl+], a
	ld [hl], HIGH(Player_boundary_up)
	ret

Player_reset_down_pos:
	ld hl, player_Ypos
	ld a, LOW(Player_boundary_down)
	ld [hl+], a
	ld [hl], HIGH(Player_boundary_down)
	ret

Player_update::
    ; POSITION UPDATE
    ld a, [PAD_hold]
    and PAD_RIGHT
	call nz, Player_move_right

    ld a, [PAD_hold]
    and PAD_LEFT
	call nz, Player_move_left

    ld a, [PAD_hold]
    and PAD_DOWN
	call nz, Player_move_down

    ld a, [PAD_hold]
    and PAD_UP
	call nz, Player_move_up

	; ANIMATION
	ld a, [PAD_pressed]
	and a, PAD_LEFT + PAD_RIGHT
	ld b, a
	ld a, [PAD_hold]
	and a, PAD_LEFT + PAD_RIGHT
	xor a, b				; new counter ?
	jr nz, .noCounterReset
	ld hl, player_anim_counter
	ld [hl], Player_anim_counter_reset
	call Player_set_idle_frame
.noCounterReset
	ld hl, player_anim_counter
	dec [hl]
	jr nz, .noFrameUpdate
	ld a, [player_state]
	and a, %00000100				; animation left ?
	call nz, Player_set_left_frame
	ld a, [player_state]
	and a, %00000010				; animation right ?
	call nz, Player_set_right_frame
.noFrameUpdate
	ld a, [player_state]
	and a, %11111000			; reset animation flags
	ld [player_state], a

	; BOUDARIES APPLY
		; boundary X
	ld hl, player_Xpos
	ld a, [hl+]
	swap a 
	and a, %00001111
	ld b, a
	ld a, [hl+]
	swap a
	and a, %11110000
	or a, b
	ld b, a
	cp a, (HIGH(Player_boundary_left)<<4) + (LOW(Player_boundary_left)>>4)
	call c, Player_reset_left_pos
	ld a, b
	cp a, (HIGH(Player_boundary_right)<<4) + (LOW(Player_boundary_right)>>4)
	call nc, Player_reset_right_pos
		; boundary Y
	ld hl, player_Ypos
	ld a, [hl+]
	swap a
	and a, %00001111
	ld b, a
	ld a, [hl+]
	swap a
	and a, %11110000
	or a, b
	ld b, a
	cp a, (HIGH(Player_boundary_up)<<4) + (LOW(Player_boundary_up)>>4)
	call c, Player_reset_up_pos
	ld a, b
	cp a, (HIGH(Player_boundary_down)<<4) + (LOW(Player_boundary_down)>>4)
	call nc, Player_reset_down_pos


    ; SPRITE position update
	ld hl, player_Xpos
	ld a, [hl+]
	swap a
	and a, %00001111			; apply mask
	ld b, a
	ld a, [hl+]
	swap a
	and a, %11110000			; apply mask
	or a, b
	ld b, a						; b <- X pos 8 bit
	ld a, [hl+]
	swap a
	and a, %00001111			; mask
	ld c, a
	ld a, [hl+]
	swap a
	and a, %11110000
	or a, c

	ld hl, Player_sprite_entry + 2
	ld [hl], a

	ld hl, Player_sprite_entry + 4
	ld [hl], b
    ret


    
	SECTION "Player_display_lists", ROMX
player_dl_static:
	DB 2
	DB -8, -8, (tile1 - _VRAM)/16, 0
	DB -8, 0, (tile1 - _VRAM)/16, OAMF_XFLIP
player_dl_left:
	DB 2
	DB -8, -8, (tile3 - _VRAM)/16, 0
	DB -8, 0, (tile5 - _VRAM)/16, 0
player_dl_right:
	DB 2
	DB -8, -8, (tile5 - _VRAM)/16, OAMF_XFLIP
	DB -8, 0, (tile3 - _VRAM)/16, OAMF_XFLIP


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