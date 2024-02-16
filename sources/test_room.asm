; ###########################################
; test room
; ###########################################



INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "charmap.inc"
INCLUDE "utils.inc"
INCLUDE "tracker.inc"





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
    call Audio_update
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
    ; ld hl, __Wave_Pattern_Sawtooth_start
    ld hl, __Wave_Pattern_Triangle_start
    call Audio_set_wave_pattern


    ld b, HIGH(_tracker_dummy_track)
    ld c, HIGH(_tracker_blank_track)
    push bc
    ld b, c
    push bc
    ld b, 12 ; tracker speed
    call Audio_init
    pop bc
    pop bc
    ret



    SECTION "tracker dummy", ROM0, ALIGN[8]
_tracker_dummy_track:
    DB %10001011 ; call to block
    DB HIGH(_tracker_GAM_track)
    DB %10001011 ; call to block
    DB HIGH(_tracker_ACDLL_track)
    DB %10001011 ; call to block
    DB HIGH(_tracker_ALCF_track)
    DB %10000100 ; global return

    SECTION "track 0", ROM0, ALIGN[8]
_tracker_blank_track:
    DB %11111111 ; set waiting time to 127
    DB %01010100 ; play blanck note
    DB %00010110 ; play note
    DB %01010100 ; play blanck note
    DB %01010100 ; play blanck note
    DB %01010100 ; play blanck note
    DB %10000100 ; total return

    SECTION "track 1", ROM0, ALIGN[8]
_tracker_ACDLL_track:
    DB %10100001 ; set repeat counter to 1
    DB %10000001 ; set return tracker here
    DB %11000001 ; set wainting time to 1
    DB 12, 12, 12, 14, 
    DB %11000011 ; set waiting time to 3
    DB 16, 14
    DB %11000001 ; set waiting time to 1
    DB 12, 16, 14, 14
    DB %11000111 ; set waiting time to 7
    DB 12
    DB %10001011 ; call to block
    DB HIGH(_tracker_GAM_track)
    DB %10000111 ; conditionnal return to return tracker
    DB %11000001 ; set wainting time to 1
    DB 14, 14, 14, 14
    DB %11000011 ; set waiting time to 3
    DB 9, 9
    DB %11000001 ; set wainting time to 1
    DB 14, 12, 11, 9
    DB %11000111 ; set waiting time to 7
    DB 7
    DB %10001011 ; call to block
    DB HIGH(_tracker_GAM_track)
    DB %10001000 ; block end

    SECTION "track 2", ROM0, ALIGN[8]
_tracker_ALCF_track:
    DB %11000001 ; wait 1
    DB 24
    DB %11000000 ; wait 0
    DB 24, 28, 28, 26, 28, 26
    DB %11000001 ; wait 1
    DB 24
    DB %11000000 ; wait 0
    DB 24, 28, 28, 26
    DB %11000001 ; wait 1
    DB 28, 28
    DB %11000000 ; wait 0
    DB 28, 26, 24, 28, 31, 28
    DB %11000001 ; wait 1
    DB 31
    DB %11000000 ; wait 0
    DB 31, 28, 24, 28
    DB %11000011 ; wait 3
    DB 26
    DB %10001011 ; call to block
    DB HIGH(_tracker_GAM_track)
    DB %10001011 ; call to block
    DB HIGH(_tracker_ACDLL_track)
    DB %10001000 ; block end

    SECTION "track 3", ROM0, ALIGN[8]
_tracker_GAM_track:
    DB %11000000 ; wait 0
    DB 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36
    DB %10001000 ; block end


    SECTION "Test_data", ROM0

    _text:
        DB " \n \n   TEST AUDIO\n \n Test du moteur audio :\n \n \n Push B pour tester de jouer une note\n \n Push A pour une note WAVE\n \n"
        DB "Le tracker audio devrait se lancer tout seul et boucler ;)\\0"

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
    