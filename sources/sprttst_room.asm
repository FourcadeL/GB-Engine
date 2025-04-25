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
	call wait_vbl

	; main test code goes here
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

	ret



	SECTION "sprt_test_room_data", ROMX
_text:
	DB " SPRITE TEST :\n This window will have interactive elements\\0"
