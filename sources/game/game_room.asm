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
INCLUDE "charmap.inc"


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
	call	Sprites_multiplex
	call 	Audio_update

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

	; TESTING : RANDOM SHOT
	ld a, [PAD_pressed]
	and a, PAD_B
	jr z, .loop
	call generateRandom
	ld c, a
	ld b, 0
	and a, %00001111
	bit 5, c
	jr z, .positiveX
	dec b
	xor a, $FF
.positiveX
	ld c, a
	push bc
	call generateRandom
	ld c, a
	ld b, 0
	and a, %00001111
	bit 4, c
	jr z, .positiveY
	dec b
	xor a, $FF
.positiveY
	ld c, a
	push bc
	ld b, %00000010
	ld c, %10110000
	push bc
	push bc
	call ES_request_shot
	pop bc
	pop bc
	pop bc
	pop bc
    jr      .loop ; new frame


game_init:
    ; player init
    call    Player_init
	
	; ennemy init
	call Ennemy_init
	
	; explosion init
	call Explosion_init

    ; ennemy shots init
	call    ES_init
    

	call wait_vbl
	; start audio track
	ld hl, songs_start
	ld bc, 7*8
	add hl, bc
	call Audio_load_song
	; call Audio_start_song
    ret