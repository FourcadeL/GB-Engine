; ###################################
; Ennemy shots
;
;	Ennemy shots are displayed as one metasprite (sprite slot 1)
;	individual shots are updated by leveraging a dynamic display list in ram
;	(each shot is an object entry in the displaylist)
;
;	Each shot has :
;		- 8 bits status : %a0000000 | a : 1 -> active
;		- 16 bits X pos : %hhhhdddd ddddssss
;		- 16 bits Y pos : %hhhhdddd ddddssss
;		- 16 bits X speed : needed for negative values
;		- 16 bits Y speed : needed for negative values
;
;	Position bytes are :
;		% hhhhdddd ddddssss
;		h : 4 high bits
;		d : the 8 bit real display position
;		s : 4 sub pixel bits
;
; On each updates
;	- All ennemy shots are updated
;	- All ennemy shots are pushed to metasprite
;
;	Data alignment :
; for ease of computation, tables are aligned
; this means we handle AT MOST 16 shots
; 	1 bytes tables are 4 ALIGNED
;	2 bytes tables are 5 ALIGNED
;
;		/!\ WARNINGS
;	- Tables should be placed in memory as : Xposs :: Yposs and  Xspeeds :: Yspeeds
;		Position update computation relies on contiguity
; 	- es_number_of_displayed_shots should be addr after es_current_shot_index
;		variable access from relative addr
; ###################################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "charmap.inc"


DEF MAX_SHOTS EQU 16

DEF ES_sprite_entry EQUS "Sprite_table + 1*8"
DEF ES_displayList_entry EQUS "DisplayList_table + 1*2"
DEF ES_displayList_entry_index EQU 1


;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |					 RAM 											  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+


    SECTION "Ennemy_shots_variables", WRAM0

_es_variables_start:
es_current_shot_index:	DS 1 ; index of currently handled shot
es_number_of_displayed_shots:	DS 1 ; number of shots active and displayed this frame

es_animate_current_index: DS 1 ; index of current shot to animate
es_animate_current_frame: DS 1 ; current frame of tile flip lags to use
_es_variables_end:

	SECTION "ES_status_table", WRAM0, ALIGN[4]
es_status:     DS 1*MAX_SHOTS ; table of es status bytes

	SECTION "ES_Xposs_table", WRAM0, ALIGN[5]
es_Xposs:      DS 2*MAX_SHOTS ; table of es x positions

	; SECTION "ES_Yposs_table", WRAM0, ALIGN[5]
es_Yposs:      DS 2*MAX_SHOTS ; table of es y positions

	SECTION "ES_Xspeeds_table", WRAM0, ALIGN[5]
es_Xspeeds:    DS 2*MAX_SHOTS ; table of es x speeds

	; SECTION "ES_Yspeeds_table", WRAM0, ALIGN[5]
es_Yspeeds:    DS 2*MAX_SHOTS ; table of es y speeds


	SECTION "ES_displaylist_table", WRAM0
es_dynamic_displayList:
es_dynamic_displayList_header:
	DS 1
es_dynamic_displayList_content:
	DS 4*MAX_SHOTS

;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |					 ROM 											  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

    SECTION "Ennemy_shots_code", ROMX

ES_init::
	; copy tiles into VRAM
	ld hl, Ennemy_shots_tiles
	ld de, Ennemy_shots_vram_tiles
	ld c, Ennemy_shots_tiles.end - Ennemy_shots_tiles
	call vram_copy_fast

    ; reset variables in ram
    ld d, $00
    ld hl, _es_variables_start
    ld b, _es_variables_end - _es_variables_start
    call memset_fast

	; reset tables
	ld hl, es_status
	ld b, MAX_SHOTS
	call memset_fast

	ld hl, es_Xposs
	ld b, MAX_SHOTS*2
	call memset_fast

	ld hl, es_Yposs
	ld b, MAX_SHOTS*2
	call memset_fast

	ld hl, es_Xspeeds
	ld b, MAX_SHOTS
	call memset_fast

	ld hl, es_Yspeeds
	ld b, MAX_SHOTS
	call memset_fast
	
	; set shots metasprite to active and visible + set display list
	ld hl, ES_sprite_entry
	ld [hl], %10000001
	inc hl
	ld [hl], ES_displayList_entry_index
	ld hl, ES_displayList_entry
	ld a, LOW(es_dynamic_displayList)
	ld [hl+], a
	ld [hl], HIGH(es_dynamic_displayList)
	
	; set all tiles in displaylist
	ld hl, es_dynamic_displayList_content + 2
	ld a, (tile1 - _VRAM)/16
	ld d, MAX_SHOTS
.tile_index_set_loop
	ld [hl+], a
	inc hl
	inc hl
	inc hl
	dec d
	jr nz, .tile_index_set_loop

	; TESTING : adds 5 shots to display with various speeds
	ld hl, es_status
	ld a, %10000000
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
    ld hl, es_Xspeeds
    ld [hl], 1
	inc hl
	inc hl
	ld [hl], 2
	inc hl
	inc hl
	ld [hl], 3
	inc hl
	inc hl
	ld [hl], 4
	inc hl
	inc hl
	ld [hl], 5
    ld hl, es_Yspeeds
    ld [hl], 1
	inc hl
	inc hl
	ld [hl], 3
	inc hl
	inc hl
	ld [hl], 5
	inc hl
	inc hl
	ld [hl], 7
	inc hl
	inc hl
	ld [hl], 9
    ; end test


    ret

ES_update::
    call ES_update_positions
	call ES_animate
	call ES_push_to_display
    ret


; ------------------
; ES_spawn_shot()
;  TODO : push position and speed
; create active es shot
; ------------------
ES_spawn_shot::


; ----------------------------------------
; ES_animate()
;	Animates shots (rotation)
; 	individual tiles flip should follow : 00 : 10 : 11 : 01
; 	I use byte with mask %01100000 incremented by %00110000 for a reasonable approximation
;
;	Each call animates ONE shot
; 	animated shot ID is last + 7 (so each tile is animated once after 16 calls)
; 	 
; ----------------------------------------
ES_animate:
	ld hl, es_animate_current_frame
	ld a, [hl]
	and a, %01100000
	ld d, a					; d <- current flags to use
	ld hl, es_animate_current_index
	ld a, [hl]
	sla a
	sla a
	ld hl, es_dynamic_displayList_content + 3
	add a, l
	ld l, a
	ld a, h
	adc a, 0
	ld h, a					; hl is addr of current animated shot flags
	ld [hl], d
	ld hl, es_animate_current_index
	ld a, [hl]
	add a, 7
	ld [hl], a
	cp a, MAX_SHOTS
	ret c					; carry -> index < 16 no index correction or frame change
	sub a, MAX_SHOTS
	ld [hl], a
	ret nz					; non zero -> do not update animation frame
	ld hl, es_animate_current_frame
	ld a, [hl]
	add a, %00110000
	ld [hl], a
	ret


;---------------------
; ES_push_to_display()
;	pushes all active ennemy shots
;	to meta sprite
;---------------------
ES_push_to_display:
	ld e, MAX_SHOTS				; remaining shots
	ld a, 0
	ld [es_current_shot_index], a
	ld [es_number_of_displayed_shots], a
	ld hl, es_status
	ld bc, es_dynamic_displayList_content
.loop
	bit 7, [hl]
	jr nz, .display_shot
	inc hl
	ld a, [es_current_shot_index]
	inc a
	ld [es_current_shot_index], a
	dec e
	jr nz, .loop
.finalize
		; finalize display
	ld hl, es_dynamic_displayList_header
	ld a, [es_number_of_displayed_shots]
	ld [hl], a
	ret
.display_shot:
		; set display position to current content
		push hl
		ld hl, es_Yposs
		ld a, [es_current_shot_index]
		add a
		add a, l
		ld l, a				; hl is addr of shot Y position
		ld a, [hl+]
		and a, %11110000
		swap a
		ld d, a
		ld a, [hl]
		and a, %00001111
		swap a
		or a, d
		sub a, 8			; compensate for tile Y offset
		ld [bc], a
		inc bc
		ld hl, es_Xposs
		ld a, [es_current_shot_index]
		add a
		add a, l
		ld l, a				; hl is addr of shot X position
		ld a, [hl+]
		and a, %11110000
		swap a
		ld d, a
		ld a, [hl]
		and a,%00001111
		swap a
		or a, d
		sub a, 4
		ld [bc], a			; compensate for tile X offset
		inc bc
		inc bc
		inc bc
		ld hl, es_current_shot_index
		inc [hl]						; next shot index
		inc hl
		inc [hl]						; increment number of shots to display
		pop hl
	inc hl
	dec e
	jr nz, .loop
	jr .finalize

; ----------------------
; ES_update_positions()
; 
;   For every X and Y positions :
;   X = X+SpeedX
;   Y = Y+SpeedY
; ----------------------
ES_update_positions:
    ld c, MAX_SHOTS*2
    ld de, es_Xposs
    ld hl, es_Xspeeds
.loop
    ld a, [de]
    add a, [hl]
    ld [de], a
    inc de
	inc hl
    ld a, [de]
	adc a, [hl]
    ld [de], a
    inc de
    inc hl
    dec c
    jr nz, .loop
    ret





;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |					VRAM 											  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

	SECTION "Ennemy_shots_tiles", ROMX
Ennemy_shots_tiles:
	LOAD "Ennemy_shots_VRAM", VRAM [$8260]
Ennemy_shots_vram_tiles:
tile1:
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3c, $18, $66, $3c, $42, $7e
tile2:
	DB $46, $7a, $6e, $34, $3c, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	ENDL
.end