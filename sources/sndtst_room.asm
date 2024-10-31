; #####################################
; room sound test
; 
;   Song play
;   SFX triggering
; ####################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "charmap.inc"


    SECTION "snd_test_room", ROM0

snd_test_main::
    call snd_test_init
.loop
    call getInput
    call wait_vbl

    call update_selector
    call update_display
    call update_selector_display

    ; exit room when start is pressed
    ld a, [PAD_pressed]
    cp a, PAD_START
    ret z
    jr .loop



snd_test_init:
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


    ; display
    call update_selector_display
    ret

; ----------------
; update selector()
; UP/DOWN : change selector value (song, sfxv, sfxc)
; L/R : change selected value (-/+)
; A : play selected (song / sfx)
; B : stop song
; ----------------
update_selector:
    ld a, [PAD_pressed]
    cp a, PAD_B
    call z, Audio_stop_song

    ld a, [PAD_pressed]
    cp a, PAD_A
    call z, validate_selection

    ld a, [PAD_pressed]
    cp a, PAD_RIGHT
    call z, increm_selection

    ld a, [PAD_pressed]
    cp a, PAD_LEFT
    call z, decrem_selection

    ld a, [PAD_pressed]
    cp a, PAD_DOWN
    jr nz, .skip_increm
        ld hl, _selector_value
        inc [hl]
        ld a, [hl]
        cp a, 3
        jr c, .skip_increm
        ld [hl], $00
.skip_increm

    ld a, [PAD_pressed]
    cp a, PAD_UP
    jr nz, .skip_decrem
        ld hl, _selector_value
        dec [hl]
        ld a, [hl]
        cp a, 3
        jr c, .skip_decrem
        ld [hl], 2
.skip_decrem
    ret

update_display:
    ; selector
    ld a, [_selector_value]
    add a, $80
    ld d, a
    ld c, $01
    ld hl, $984D
    call vram_set_fast

    ; song selection
    ld a, [_song_select_value]
    add a, $80
    ld d, a
    ld c, $01
    ld hl, $98A9
    call vram_set_fast

    ; sfx selection
    ld a, [_sfx_select_value]
    add a, $80
    ld d, a
    ld c, $01
    ld hl, $98EB
    call vram_set_fast

    ; sfx ch
    ld a, [_sfx_channel_value]
    add a, $80
    ld d, a
    ld c, $01
    ld hl, $992F
    call vram_set_fast
    ret

update_selector_display:
    ; reset current indicators
    ld d, $00
    ld c, $01
    ld hl, $98A1
    call vram_set_fast
    ld d, $00
    ld c, $01
    ld hl, $98E1
    call vram_set_fast
    ld d, $00
    ld c, $01
    ld hl, $9921
    call vram_set_fast
    
    ; set indicator to new location
    ld hl, _select_locations
    ld a, [_selector_value]
    ld b, $00
    sla a
    ld c, a
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, $91
    ld c, $01
    call vram_set_fast
    ret

   
decrem_selection:
    ld a, [_selector_value]
    ld hl, _song_select_value
    add a, l
    ld l, a
    dec [hl]
    ret
increm_selection:
    ld a, [_selector_value]
    ld hl, _song_select_value
    add a, l
    ld l, a
    inc [hl]
    ret
validate_selection:
    ld a, [_selector_value]
    cp a, $00 ; is selector on song select ?
    jr nz, .playsfx
        ; load and play song
        ld a, [_song_select_value]
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
.playsfx
    ld a, [_sfx_select_value]
    and a, %00011111
    ld b, a
    ld a, [_sfx_channel_value]
    rrc a
    rrc a
    and a, %11000000
    or a, b
    call sfx_request
    ret









    SECTION "snd_test_room_data", ROMX
_text:
    DB " \n   SOUND TEST\n \n \n \n   Song :\n \n   SFX id :\n \n   SFX channel:\n \n A : play\n B : stop\n \n  START to exit\\0"

_select_locations:
    DW $98A1, $98E1, $9921

    SECTION "snd_test_room_variables", WRAM0, ALIGN[2]

_song_select_value: DS 1
_sfx_select_value: DS 1
_sfx_channel_value: DS 1

_selector_value: DS 1 ; (0 -> sng, 1 -> sfxs, 2 -> sfxc)
