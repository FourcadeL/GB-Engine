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
    ld d, $80
.loop2
    push bc
    push de
    call getInput
    call fwf_automaton_update
    call wait_vbl
    call display_song_nb
    call Audio_update
    ; ld a, [PAD_pressed]
    ; cp a, PAD_B
    ; call z, playNoise15
    ld a, [PAD_pressed]
    cp a, PAD_A
    call z, Audio_start_song
    ld a, [PAD_pressed]
    cp a, PAD_UP
    jr nz, .skip_increm
        call load_inc_song
.skip_increm
    ld a, [PAD_pressed]
    cp a, PAD_DOWN
    jr nz, .skip_decrem
        call load_dec_song
.skip_decrem
    pop bc
    pop de
    jr .loop2


display_song_nb:
    ld a, [_song_select_pointer_offset]
    add a, $80
    ld d, a
    ld c, $01
    ld hl, $984E
    call vram_set_fast
    ret

load_inc_song:
    call Audio_pause_song
    ld hl, _song_select_pointer_offset
    inc [hl]
    ld a, [hl]
    jr _common_load_new_song
load_dec_song:
    call Audio_pause_song
    ld hl, _song_select_pointer_offset
    dec [hl]
    ld a, [hl]
_common_load_new_song:
    sla a
    sla a
    sla a
    ld c, a
    ld b, $00
    ld hl, song_0
    add hl, bc
    call Audio_load_song
    ret

room_init:
    ld c, $01
    call fwf_init
    ld a, 20
    call fwf_automaton_set_display_width
    ld a, 18
    call fwf_automaton_set_display_height
    ld a, $03
    call fwf_automaton_set_timer
    ld a, $00
    call fwf_automaton_set_blank_tile_id
    ld de, $9800
    call fwf_automaton_set_display_start_addr
    ld de, _text
    call fwf_automaton_set_read_addr
    call fwf_automaton_init
    call fwf_automaton_update

    ; Audio initialisation
    ld hl, __Wave_Pattern_Sawtooth_start
    ; ld hl, __Wave_Pattern_Triangle_start
    call Audio_set_wave_pattern
    ld b, 6 ; tracker speed
    call Audio_init
    ld hl, song_0
    ; ld hl, song_1
    ; ld hl, song_2
    call Audio_load_song
    
    ld hl, _song_select_pointer_offset
    ld [hl], $00
    ret



    SECTION "Test_data", ROM0

    _text:
        DB " \n \n   TEST AUDIO\n \nTest du moteur audio \n \nUp / Down :\nselect song\n \nA : test play\n \n"
        DB "     Enjoy ;)\\0"

    _aud:
        DB $00, $01, $02, $03, $04, $05, $06, $07
        DB $14, $15, $16, $17
        DB $24, $25, $26, $27
        DB $34, $35, $36, $37
        DB $44, $45, $46, $47
        DB $54, $55, $56, $57
        DB $64, $65, $66, $67
        DB $74, $75, $76, $77
        DB $84, $85, $86, $87
        DB $94, $85, $86, $87
        DB $A4, $A5, $A6, $A7
        DB $B4, $B5, $B6, $B7
        DB $C4, $C5, $C6, $C7
        DB $D4, $D5, $D6, $D7
        DB $E4, $E5, $E6, $E7
        DB $F4, $F5, $F6, $F7

    __Wave_Pattern_Sawtooth_start:
    INCBIN "sawtooth.bin"
    __Wave_Pattern_Sawtooth_end:

    __Wave_Pattern_Triangle_start:
    INCBIN "triangle.bin"
    __Wave_Pattern_Triangle_end:
    

    SECTION "quick selection", WRAM0
_song_select_pointer_offset: DS 1