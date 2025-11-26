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

    ; TESTING : RANDOM NEW rot enemy
    call generateRandom
    and a, %11111100
    ld a, [PAD_pressed]
    and a, PAD_B
    jr z, .skipenn
    call generateRandom
    and a, %01111111
    ld b, a
    ld b, 18
    call Rot_enemy_request
.skipenn

    ; TESTING : LOAD LEVEL (on select)
    ld a, [PAD_pressed]
    and a, PAD_SELECT
    jr z, .skiplevelLoad
    ld b, $00
    ld hl, levels_flags
    res 7, [hl]
    call Levels_request
.skiplevelLoad

    ; TESTING : ACT_GENERATOR test (on start)
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
    ld hl, song_1_starfield
    call Audio_load_song
    call Audio_start_song

    ; set auto repeat mask
    ld hl, PAD_repeat_speed
    ld [hl], %00001111
    ret
