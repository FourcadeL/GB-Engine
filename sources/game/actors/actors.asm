; ################################################
; Actors functions
;
;   Actors are all interactive elements of the game
;   this file handles pooling of actors in the sprite table
;   but each actor should provide its own hanlding and update function
;   which will be linked in its sprite entry
;
;   16 Actors can be present at the same time
;   Actors have a "data pool" of accessible variables for each of them
;   64 bytes of data accessible
;       %ffffffii ii000000 : addr of an actor data block
;
;   f : the fixed addr part
;   i : the actor index (16 actors)
;   0 : addr is 6 aligned
;   
;
;   ------
; list of ennemy actors:
;   - explosion sfx
;   - rot : a standard rotating ennemy
; ################################################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "charmap.inc"
INCLUDE "actors.inc"



;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Actors_data_table", WRAM0, ALIGN[6]
    
Actors_data_table:              DS ACTORS_NB * ACTORS_DATA_SIZE



;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Actors_code", ROMX

Actors_init::
    ; TESTING : spawn ennemy screen center
    ld b, 67
    ld c, 67
    call Rot_ennemy_request

    ret

; --------------------------
; Actors_update()
;
;   Iterates over all actors
;   Calls their handling function if they are active
;       (with the actor data addr in register de
;       and actors sprite addr in bc)
; --------------------------
Actors_update::
    ld hl, Actors_sprite_first_entry
    ld d, 0
    ld e, ACTORS_NB
.loop
    bit 7, [hl]
    jr nz, .handle_current
    ld a, 8
    add a, l
    ld l, a
    inc d
    dec e
    jr nz, .loop
    ret
.handle_current
    ld b, h
    ld c, l
    push hl
    push de                 ; save iteration registers
    ld e, d                 ; find addr of actor data with offset d into de
    swap e
    sla e
    sla e
    ld a, d
    srl a
    srl a
    ld d, a
    ld a, e
    add a, LOW(Actors_data_table)
    ld e, a
    ld a, d
    adc a, HIGH(Actors_data_table)
    ld d, a

    ld a, 6                 ; retrieve hndling sprite function into hl
    add a, l
    ld l, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    CALL_HL
    pop de                  ; restore iteration registers
    pop hl
    ld a, 8
    add a, l
    ld l, a
    inc d
    dec e
    jr nz, .loop
    ret

