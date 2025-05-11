; ###########################################
; Explosion display fx functions
;
; 	spawn explosion
;	animate explosion
;	delete explosion
; ###########################################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "charmap.inc"

DEF Explosion_sprite_first_entry EQUS "Sprite_table + 16*8"
DEF Explosion_displayList_first_entry EQUS "DisplayList_table + 14*2"
DEF Explosion_displayList_first_entry_index EQU 14

DEF Explosion_max_number EQU 4



	SECTION "Explosion_code", ROMX

Explosion_init::
	; copy tiles in VRAM
	ld hl, Explosion_tiles
	ld de, Explosion_vram_tiles
	ld bc, Explosion_tiles.end - Explosion_tiles
	call vram_copy

	; copy display lists in display list table
	ld hl, static_dl_addrs
	ld de, Explosion_displayList_first_entry
	ld b, static_dl_addrs.end - static_dl_addrs
	call memcopy_fast

	ret


Explosion_update::
	; iterate over active explosion sprites
	ld hl, Explosion_sprite_first_entry
	ld b, Explosion_max_number
.loop
	bit 7, [hl]
	call nz, Explosion_handle_current

	ld a, 8
	add a, l
	ld l, a
	dec b
	jr nz, .loop
	ret

;----------------------------------------------
; Explosion_request(b = xpos ; c = ypos)
;	Resquest an explosion sprite at position specified by bc
;
;	If possible, adds explosion sprite to the explosion pool
;	Else, do nothing
;----------------------------------------------
Explosion_request::
	ld hl, Explosion_sprite_first_entry
	ld d, Explosion_max_number
.loop
	bit 7, [hl]
	jr z, _add_explosion_at_hl
	ld a, 8
	add a, l
	ld l, a
	dec d
	ret z
	jr .loop
_add_explosion_at_hl:
	ld a, %10000001
	ld [hl+], a
	ld a, Explosion_displayList_first_entry_index
	ld [hl+], a
	ld [hl], c
	inc hl
	inc hl
	ld [hl], b
	inc hl
	inc hl
	ld a, 0
	ld [hl+], a
	ld [hl+], a
	ret

;----------------------------------------------
; Explosion_handle_current(hl = sprite addr of explosion to handle)
;	steps explosion animation
;	delete sprite if animation count is over
;
; saves registers hl
;
;		Animation sub counter is byte 6 of sprite entry
;			b6 : %ssssssss
;				s : sub frame count
; b6 is incremented by %01000000 at each update
; display list pointer is incremented when a carry is detected
;
;		Animation frame counter is byte 7 of sprite entry
;			b7 : frame counter
;
; there is 6 animation frames
;	so b7 > 6 means we kill the sprite
;
;----------------------------------------------
Explosion_handle_current:
	push hl
	ld c, l
	ld d, h
	ld a, 6
	add a, l
	ld e, a					; de is addr of animation counter byte
	ld a, 1
	add a, l
	ld l, a					; hl is addr of dl pointer
	ld a, [de]
	add a, %00110000
	ld [de], a
	jr nc, .finalize
		; increment animation frame and counter
	inc [hl]
	ld a, 6
	add a, l
	ld l, a					; hl is addr of animation frame counter byte
	ld a, [hl]
	inc a
	ld [hl], a
	cp a, 6
	jr nz, .finalize
		; kill sprite
	ld l, c
	res 7, [hl]
.finalize
	pop hl
	ret


	SECTION "Explosion_display_lists", ROMX
explosion_dl_frame1:
	DB 1
	DB -8, -4, (tile1 - _VRAM)/16, 0
explosion_dl_frame2:
	DB 1
	DB -8, -4, (tile3 - _VRAM)/16, 0
explosion_dl_frame3:
	DB 2
	DB -8, -8, (tile5 - _VRAM)/16, 0
	DB -8, 0, (tile7 - _VRAM)/16, 0
explosion_dl_frame4:
	DB 2
	DB -8, -8, (tile9 - _VRAM)/16, 0
	DB -8, 0, (tile11 - _VRAM)/16, 0
explosion_dl_frame5:
	DB 2
	DB -8, -8, (tile13 - _VRAM)/16, 0
	DB -8, 0, (tile15 - _VRAM)/16, 0
explosion_dl_frame6:
	DB 2
	DB -8, -8, (tile17 - _VRAM)/16, 0
	DB -8, 0, (tile19 - _VRAM)/16, 0

static_dl_addrs:				; static ouline of dl for setup in displyList table
	DW explosion_dl_frame1
	DW explosion_dl_frame2
	DW explosion_dl_frame3
	DW explosion_dl_frame4
	DW explosion_dl_frame5
	DW explosion_dl_frame6
.end

;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |					VRAM 											  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+


	SECTION "Explosion_tiles", ROMX
Explosion_tiles:
	LOAD "Explosion_VRAM", VRAM[$8120]
Explosion_vram_tiles:
	; frame1
tile1:
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $00, $3c, $08
tile2:
	DB $3c, $14, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	; frame2
tile3:
	DB $00, $00, $00, $00, $00, $00, $00, $00, $08, $00, $18, $00, $bd, $18, $7e, $24
tile4:
	DB $7e, $00, $bc, $18, $12, $00, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	; frame3
tile5:
	DB $00, $00, $00, $00, $00, $01, $f0, $3b, $00, $3f, $00, $3c, $01, $38, $21, $3c
tile6:
	DB $c1, $3c, $00, $1e, $10, $1e, $00, $0f, $08, $0f, $0c, $04, $10, $00, $00, $00
tile7:
	DB $00, $00, $00, $80, $00, $80, $2e, $e8, $04, $fc, $00, $f8, $00, $38, $80, $18
tile8:
	DB $84, $3c, $00, $7c, $06, $fc, $08, $f8, $c0, $e0, $00, $00, $00, $00, $00, $00
	; frame 4
tile9:
	DB $0f, $00, $1f, $0f, $19, $0f, $10, $1f, $e4, $3f, $c8, $78, $43, $70, $13, $70
tile10:
	DB $cb, $78, $21, $38, $20, $3c, $12, $1f, $68, $2f, $38, $1b, $18, $00, $00, $00
tile11:
	DB $00, $00, $80, $00, $2c, $20, $0f, $ec, $0b, $fa, $47, $7e, $a0, $3c, $c0, $5c
tile12:
	DB $c0, $1c, $a4, $3c, $64, $7c, $8b, $f8, $12, $f0, $06, $c0, $18, $00, $00, $00
	; frame 5
tile13:
	DB $09, $06, $10, $0f, $27, $18, $58, $27, $00, $7f, $04, $1a, $03, $41, $03, $e2
tile14:
	DB $43, $a3, $0b, $e1, $45, $b9, $c0, $3c, $80, $7c, $50, $2d, $00, $1f, $00, $07
tile15:
	DB $c0, $00, $00, $60, $0c, $70, $02, $7c, $03, $3c, $01, $3e, $a0, $9e, $c0, $47
tile16:
	DB $c2, $c1, $80, $82, $c9, $84, $61, $8e, $00, $e8, $08, $74, $80, $78, $20, $50
	; frame 6
tile17:
	DB $00, $00, $00, $05, $10, $08, $20, $10, $10, $20, $03, $23, $07, $07, $05, $45
tile18:
	DB $07, $47, $22, $43, $42, $22, $01, $01, $08, $20, $00, $0c, $04, $01, $00, $00
tile19:
	DB $00, $00, $20, $c0, $40, $30, $00, $00, $00, $04, $c4, $c2, $e0, $e2, $a0, $a2
tile20:
	DB $e1, $e0, $40, $c0, $46, $40, $88, $84, $04, $08, $40, $20, $00, $c0, $00, $00
	ENDL
.end