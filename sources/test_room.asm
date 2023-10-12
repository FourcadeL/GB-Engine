; ###########################################
; test room
; ###########################################



INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "charmap.inc"
INCLUDE "utils.inc"





;-------------------------------------------
;- Room main
;-------------------------------------------

    SECTION "Room_test", ROM0


room_main::
    call room_init

    ld bc, _aud ; partition start
.loop2
    push bc
    call getInput
    call fwf_automaton_update
    call wait_vbl
    pop bc
    ld a, [PAD_pressed]
    cp a, PAD_B
    jr nz, .not12update
    push bc
    ld a, [bc]
    call Audio_get_note_frequency12
    MEMBSET [rNR10], $00
    MEMBSET [rNR11], $80
    MEMBSET [rNR12], $F1
    MEMBSET [rNR13], c
    ld a, b
    or %11000000
    ld [rNR14], a
    pop bc
    inc bc
.not12update
    ld a, [PAD_pressed]
    cp a, PAD_A
    jr nz, .notwaveupdate
    push bc
    ld a, [bc]
    call Audio_get_note_frequency12
    MEMBSET [rNR31], $80
    MEMBSET [rNR32], %00100000
    MEMBSET [rNR33], c
    ld a, b
    or %11000000
    ld [rNR34], a
    pop bc
    inc bc
.notwaveupdate
    jr .loop2


room_init:
    ld c, $01
    call fwf_init
    ld a, 20
    call fwf_automaton_set_display_width
    ld a, 18
    call fwf_automaton_set_display_height
    ld a, $00
    call fwf_automaton_set_timer
    ld a, $00
    call fwf_automaton_set_blank_tile_id
    ld de, $9800
    call fwf_automaton_set_display_start_addr
    ld de, _text
    call fwf_automaton_set_read_addr
    call fwf_automaton_init
    call fwf_automaton_update
    call Audio_init
    ; ld hl, __Wave_Pattern_Sawtooth_start
    ld hl, __Wave_Pattern_Triangle_start
    call Audio_set_wave_pattern
    ret



    SECTION "Test_data", ROM0
    
    _text:
        DB " \n \n   TEST AUDIO\n \n Test du moteur audio :\n \n \n Push B pour tester de jouer une note\n \n Push A pour une note WAVE\\0"

    _aud:
        DB 04, 04, 04, 06, 8, 6, 4, 8, 6, 6, 4
        DB 04, 04, 04, 06, 8, 6, 4, 8, 6, 6, 4
        DB 04, 04, 04, 06, 8, 6, 4, 8, 6, 6, 4
        DB 04, 04, 04, 06, 8, 6, 4, 8, 6, 6, 4
        DB 04, 04, 04, 06, 8, 6, 4, 8, 6, 6, 4
        DB 04, 04, 04, 06, 8, 6, 4, 8, 6, 6, 4
        DB 04, 04, 04, 06, 8, 6, 4, 8, 6, 6, 4
        DB 24, 24, 24, 26, 28, 26, 24, 28, 26, 26, 24, 24, 24
        DB 36, 40, 38, 36, 40, 38, 36, 40, 43, 41, 40, 38, 40
        DB 36, 40, 38, 36, 40, 38, 36, 40, 43, 41, 40, 38, 36, 36, 36
        DB 24, 24, 24, 26, 28, 26, 24, 28, 26, 26, 24, 24, 24
        DB 36, 40, 38, 36, 40, 38, 36, 40, 43, 41, 40, 38, 40
        DB 36, 40, 38, 36, 40, 38, 36, 40, 43, 41, 40, 38, 36, 36, 36
        DB 24, 24, 24, 26, 28, 26, 24, 28, 26, 26, 24, 24, 24
        DB 36, 40, 38, 36, 40, 38, 36, 40, 43, 41, 40, 38, 40
        DB 36, 40, 38, 36, 40, 38, 36, 40, 43, 41, 40, 38, 36, 36, 36
        DB 24, 24, 24, 26, 28, 26, 24, 28, 26, 26, 24, 24, 24
        DB 36, 40, 38, 36, 40, 38, 36, 40, 43, 41, 40, 38, 40
        DB 36, 40, 38, 36, 40, 38, 36, 40, 43, 41, 40, 38, 36, 36, 36

    __Wave_Pattern_Sawtooth_start:
    INCBIN "sawtooth.bin"
    __Wave_Pattern_Sawtooth_end:

    __Wave_Pattern_Triangle_start:
    INCBIN "triangle.bin"
    __Wave_Pattern_Triangle_end:
    