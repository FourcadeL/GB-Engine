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
_framerule:	DS 1


    SECTION "game_room", ROMX

    ; 60 fps 1 threads execution (+vbl thread)
game_main::
	call    game_init
.loop
	call    wait_vbl ; thread 1
	call    getInput

	call    Player_update
	call	Ennemy_update
	call	Explosion_update
	call    ES_update
	call	PS_update
	call	Sprites_multiplex

	; Test collision flag, if collision, display game over
	ld hl, player_state
	bit 6, [hl]
	jr z, .no_collision
	jp game_over_main
.no_collision

	; TESTING : RANDOM NEW EXPLOSION
	ld a, [PAD_pressed]
	and a, PAD_A
	jr z, .skipExplosion
	call generateRandom
	and a, %01111111
	push af
	call generateRandom
	and a, %01111111
	pop bc
	ld c, a
	call Explosion_request
.skipExplosion

	; TESTING : TARGETED SHOT
	ld hl, _framerule
	inc [hl]
	ld hl, PAD_pressed
	; bit 5, [hl]
	ld a, [hl]
	and a, PAD_B
	jr z, .loop
	res 5, [hl]
	ld d, $01		; shot speed
	ld b, $42
	ld c, $42
	call TP_request_shot_toward_player
    jp      .loop ; new frame


game_init:
	; player init
	call Player_init
	
	; ennemy init
	call Ennemy_init
	
	; explosion init
	call Explosion_init

	; ennemy shots init
	call ES_init

	; player shots init
	call PS_init

	call wait_vbl
	; start audio track
	ld hl, songs_start
	ld bc, 7*8
	add hl, bc
	call Audio_load_song
	call Audio_start_song
    ret
