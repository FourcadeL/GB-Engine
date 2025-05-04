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
    call    ES_update
	call	Sprites_multiplex
	call 	Audio_update
    jr      .loop ; new frame


game_init:
    ; player init
    call    Player_init

    ; ennemy shots init
;    call    ES_init
    
    ret