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
_framerule: DS 1


    SECTION "game_room", ROMX

    ; 60 fps 1 threads execution (+vbl thread)
game_main::
    call    game_init
.loop
    call    wait_vbl ; thread 1
    call    getInput

    call    Player_update
    call    Actors_update
    call    Rot_ennemy_update
    call    ES_update
    call    PS_update
    call    Sprites_multiplex

    ; Test collision flag, if collision, display game over
    ld hl, player_state
    bit 6, [hl]
    jr z, .no_collision
    jp game_over_main
.no_collision

    ; TESTING : RANDOM NEW EXPLOSION
    call generateRandom
    and a, %11111100
    jr nz, .skipExplosion
    call generateRandom
    and a, %01111111
    push af
    call generateRandom
    and a, %01111111
    pop bc
    ld c, a
    call Explosion_request
.skipExplosion

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

    ; TESTING : TARGETED SHOT
    ld hl, _framerule
    inc [hl]
    bit 5, [hl]
    jr z, .loop
    res 5, [hl]
    ld d, $01       ; shot speed
    ld b, $42
    ld c, $42
    call TP_request_shot_toward_player
    jp      .loop ; new frame


game_init:
    ; player init
    call Player_init

    ; ennemy init
    call Actors_init
    call Rot_ennemy_init

    ; explosion init
    call Explosion_init

    ; ennemy shots init
    call ES_init

    ; player shots init
    call PS_init

    call wait_vbl
    ; start audio track
    ld hl, song_1_starfield
    call Audio_load_song
    call Audio_start_song
    ret
