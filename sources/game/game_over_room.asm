; ###############################
;   game over handling room
;
;   display a game over message
;   Placeholder before real management
; ###############################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "charmap.inc"

    SECTION "game_over_room", ROMX

game_over_main::
    call game_over_init
.loop
    call wait_vbl
    call fwf_automaton_update

    call getInput
    ld a, [PAD_pressed]
    and a, PAD_START
    jr z, .loop
        ; reload game room
        call fwf_automaton_flush
    jp game_main

game_over_init:
    ; fwf init
    ld a, 20
    call fwf_automaton_set_display_width
    ld a, 18
    call fwf_automaton_set_display_height
    ld a, $01
    call fwf_automaton_set_timer
    ld a, $00
    call fwf_automaton_set_blank_tile_id
    ld de, $9800
    call fwf_automaton_set_display_start_addr
    ld de, _text
    call fwf_automaton_set_read_addr
    call fwf_automaton_init

    call Audio_stop_song
    ret

_text:
    DB" \n   GAME OVER (tmp)\n \n \nPress START\n    to reload\\0"
