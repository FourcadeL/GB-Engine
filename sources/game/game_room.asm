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

    ; TESTING : RANDOM NEW powerup
    ld a, [PAD_pressed]
    and a, PAD_B
    jr z, .skipenn
    ld b, 30
    ld c, 7
    call PU_request
.skipenn

    ; TESTING : LOAD snip (on select)
    ld a, [PAD_pressed]
    and a, PAD_SELECT
    jr z, .skiplevelLoad
        ; test snip enemy spawn
        ; target
    ld b, 50
    ld c, 45
    push bc
        ; speed and shot nb
    ld b, 3
    ld c, 18
    push bc
        ; shoot rate and speed
    ld b, 130
    ld c, 2
    push bc
        ; starting position
    ld b, 12
    ld c, 160
    call Snip_enemy_request
    pop af
    pop af
    pop af
.skiplevelLoad

    ; TESTING : LOAD pinch (on start)
    ld a, [PAD_pressed]
    and a, PAD_START
    jr z, .skipActGen
        ; test pinch enemy spawn
        ; speed
    ld b, 2
    push bc
        ; Duration
    ld b, 1
    ld c, $FF
    push bc
        ; end target
    ld b, 255
    ld c, 255
    push bc
        ; start position
    ld b, 22
    ld c, 0
    call Pinch_enemy_request
    pop bc
    pop bc
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
    call PU_init
    call Pinch_enemy_init

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
;     call Levels_request

    ret
