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
    jr      .loop ; new frame


game_init:
    ; player init
    call    Player_init
	
	; ennemy init
	call Ennemy_init
	
	; explosion init
	call Explosion_init

    ; ennemy shots init
;    call    ES_init
    

	call wait_vbl
	; start audio track
	ld hl, songs_start
	ld bc, 7*8
	add hl, bc
	call Audio_load_song
	; call Audio_start_song
    ret