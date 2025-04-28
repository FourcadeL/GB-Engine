; #######################################
; room sprite test
;
; 	Spawn player sprite
;	Test player sprite moves
;	Spawn test sprites
; #######################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "charmap.inc"


	SECTION "sprt_test_room", ROM0

sprt_test_main::
	call sprt_test_init
.loop
	call getInput

	; basic movement
	ld a, [PAD_hold]
	cp PAD_UP
	jr nz, .skipUP
	ld hl, Sprite_table+2
	dec [hl]
.skipUP
	cp PAD_DOWN
	jr nz, .skipDOWN
	ld hl, Sprite_table+2
	inc [hl]
.skipDOWN
	cp PAD_RIGHT
	jr nz, .skipRIGHT
	ld hl, Sprite_table+4
	inc [hl]
.skipRIGHT
	cp PAD_LEFT
	jr nz, .skipLEFT
	ld hl, Sprite_table+4
	dec [hl]
.skipLEFT

	call wait_vbl
	call Sprites_multiplex
	jr .loop




sprt_test_init:
	; fwf init
	ld a, 20
	call fwf_automaton_set_display_width
	ld a, 18
	call fwf_automaton_set_display_height
	ld a, $02
	call fwf_automaton_set_timer
	ld a, $00
	call fwf_automaton_set_blank_tile_id
	ld de, $9800
	call fwf_automaton_set_display_start_addr
	ld de, _text
	call fwf_automaton_set_read_addr
	call fwf_automaton_init

	;sprite init code goes here
	call Sprites_init

	; initialize basic sprite
	ld hl, Sprite_table
	ld a, %10000001
	ld [hl+], a
	ld a, 1
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld hl, DisplayList_table
	ld a, LOW(displayList1)
	ld [hl+], a
	ld a, HIGH(displayList1)
	ld [hl+], a


	ld hl, Sprite_table+8
	ld a, %10000001
	ld [hl+], a
	ld a, 1
	ld [hl+], a
	ld a, 33
	ld [hl+], a
	ld a, 0
	ld [hl+], a
	ld a, 23
	ld [hl+], a
	ld hl, DisplayList_table+2
	ld a, LOW(displayList2)
	ld [hl+], a
	ld a, HIGH(displayList2)
	ld [hl+], a

	ld hl, Sprite_table+16
	ld a, %10000001
	ld [hl+], a
	ld a, 1
	ld [hl+], a
	ld a, 53
	ld [hl+], a
	ld a, 0
	ld [hl+], a
	ld a, 33
	ld [hl+], a

	ld hl, Sprite_table+24
	ld a, %10000001
	ld [hl+], a
	ld a, 2
	ld [hl+], a
	ld a, 43
	ld [hl+], a
	ld a, 0
	ld [hl+], a
	ld a, 99
	ld [hl+], a
	ld hl, DisplayList_table+4
	ld a, LOW(displayList3)
	ld [hl+], a
	ld a, HIGH(displayList3)
	ld [hl+], a


; AUDIO INIT TEST (plus sprites)
; Audio init
    ld hl, __Wave_Pattern_Sawtooth_start
    ; ld hl, __Wave_Pattern_Triangle_start
    call Audio_set_wave_pattern
    ld b, 6 ; tracker speed
    call Audio_init
	
	; request song 6
; load and play song
        ld a, 6
        ld b, $00
        sla a
        rl b
        sla a
        rl b
        sla a
        rl b
        ld c, a
        ld hl, songs_start
        add hl, bc
        call Audio_load_song
        call Audio_start_song
        ret
	ret



	SECTION "sprt_test_room_data", ROMX
_text:
	DB " SPRITE TEST :\n This window will have interactive elements\\0"

; blank sprites test
displayList1:
	DB 4, 0, 0, 2, 0
	DB 16, 0, 3, 0
	DB 0, 8, 4, 0
	DB 16, 8, 5, 0

displayList2:
	DB 12, 0, 0, 6, 0
	DB 16, 0, 7, 0
	DB 0, 8, 9, 0
	DB 16, 8, 10, 0
	DB 0, 16, 11, 0
	DB 0, 24, 12, 0
	DB 0, 32, 13, 0
	DB 0, 40, 14, 0
	DB 0, 48, 15, 0
	DB 0, 56, 16, 0
	DB 0, 64, 17, 0
	DB 0, 72, 18, 0
	
displayList3:
	DB 9, 0, 0, 30, 0
	DB 16, 0, 31, 0
	DB 32, 0, 45, 0
	DB 48, 0, 87, 0
	DB 64, 0, 65, 0
	DB 80, 0, 66, 0
	DB 96, 0, 98, 0
	DB 112, 0, 45, 0
	DB 128, 0, 78, 0