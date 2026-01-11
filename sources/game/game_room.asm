; ########################################
;  main game room
;
;   player handle
;   shoot handle
;   ennemy spawn
;   pause display
; ########################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"


    SECTION "game_room_variables", WRAM0


    SECTION "game_room", ROM0

    ; 60 fps 1 threads execution (+vbl thread)
game_main::
    call    game_init
.loop
    call    wait_vbl ; thread 1
    call    getInput

    call    Player_update
    call    Actors_update
    call    Rot_enemy_update
    call    ES_update
    call    PS_update
    call    Levels_update
    call    Sprites_multiplex

    ; Test collision flag, if collision, display game over
    ld hl, player_state
    bit 7, [hl]
    jr z, .not_dead
    jp game_over_main
.not_dead

    ; TESTING : RANDOM NEW wav enemy
    ld a, [PAD_pressed]
    and a, PAD_B
    jr z, .skipenn
    ld b, 28
    ld c, 4
    ld d, 1
    ld e, 0
    call Wav_enemy_request
    ld b, 58
    ld c, 4
    ld d, 1
    ld e, 0
    call Wav_enemy_request
    ld b, 88
    ld c, 4
    ld d, 1
    ld e, 0
    call Wav_enemy_request
.skipenn

    ; TESTING : LOAD snip (on select)
    ld a, [PAD_pressed]
    and a, PAD_SELECT
    jr z, .skiplevelLoad
    ld b, 33
    ld c, %10011111
    ld d, 24
    ld e, 0
    call Snip_enemy_request
.skiplevelLoad

    ; TESTING : actor row load (on start)
    ld a, [PAD_pressed]
    and a, PAD_START
    jr z, .skipActGen
    call generateRandom
    and a, %01111111
    ld b, a
    ld c, 2
    ld d, 3
    ld e, 4
    push bc
    push de
    ld b, 6
    ld c, 20
    ld de, Rot_enemy_request
    call Act_generator_request
    pop de
    pop bc
.skipActGen


    jp      .loop ; new frame


game_init:
    ; player init
    call Player_init

    ; ennemy init
    call Actors_init
    call Rot_enemy_init
    call Wav_enemy_init
    call Snip_enemy_init

    ; explosion init
    call Explosion_init

    ; ennemy shots init
    call ES_init

    ; player shots init
    call PS_init

    ; levels logic init
    call Levels_init

    call wait_vbl
    ; start audio track
;     ld hl, song_1_starfield
;     call Audio_load_song
;     call Audio_start_song

    ; set auto repeat mask
    ld hl, PAD_repeat_speed
    ld [hl], %00001000
;     ld [hl], %00001011
    ld hl, PAD_repeat_counter
    ld [hl], $02

    ; load level index 00
    ld b, $00
    ld hl, levels_flags
    res 7, [hl]                 ; flag reset TO force reload
    call Levels_request

    ret
