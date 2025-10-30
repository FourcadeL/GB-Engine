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


    SECTION "game_room", ROMX

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
    bit 6, [hl]
    jr z, .no_collision
    jp game_over_main
.no_collision

    ; TESTING : RANDOM NEW rot enemy
    call generateRandom
    and a, %11111100
    ld a, [PAD_pressed]
    and a, PAD_START
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
    call Levels_request
.skiplevelLoad


    ; TESTING : PLAYER SHOOT
    ld a, [PAD_pressed]
    and a, PAD_A
    jr z, .skipShooting
    ld a, [player_pixel_Xpos]
    ld b, a
    ld a, [player_pixel_Ypos]
    ld c, a
    call PS_straight_request
.skipShooting

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
    ret
