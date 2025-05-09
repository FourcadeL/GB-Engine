; ###################################
; Ennemy shots structure
; ###################################


; compilation constants
DEF MAX_SHOTS EQU 20


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "charmap.inc"


    SECTION "Ennemy_shots_code", ROMX

ES_init::
    ; reset variables in ram
    ld d, $00
    ld hl, _es_variables_start
    ld b, _es_variables_end - _es_variables_start
    call memset_fast

	; TESTING
    ld hl, es_Xspeeds
    ld [hl], 3
    ld hl, es_Yspeeds
    ld [hl], 5
    ; end test


    ret

ES_update::
    call update_positions
    ret


; ------------------
; ES_spawn_shot()
;  TODO : push position and speed
; create active es shot
; ------------------
ES_spawn_shot::



; ----------------------
; update_positions()
; 
;   For every X and Y positions :
;   X = X+SpeedX
;   Y = Y+SpeedY
; ----------------------
update_positions:
    ld c, MAX_SHOTS*2
    ld de, es_Xposs
    ld hl, es_Xspeeds
	ld b, 0
.loop
    ld a, [de]
    add a, [hl]
    ld [de], a
    inc de
    ld a, [de]
	adc a, b
    ld [de], a
    inc de
    inc hl
    dec c
    jr nz, .loop
    ret

    SECTION "Ennemy_shots_variables", WRAM0

; state byte  %a0000000
;              |
;              -> Active : 1 -> is active 0 -> is not active
_es_variables_start:
es_status:     DS 1*MAX_SHOTS ; table of es status bytes
es_Xposs:      DS 2*MAX_SHOTS ; table of es x positions
es_Yposs:      DS 2*MAX_SHOTS ; table of es y positions
es_Xspeeds:    DS 1*MAX_SHOTS ; table of es x speeds
es_Yspeeds:    DS 1*MAX_SHOTS ; table of es y speeds
_es_variables_end:


; Position usage
; Position Bytes : %hhhhhhhh llll llll
;                       ---- ---- ||||
;                                    |-> sub pixels
;                       8 bit used as position for sprite