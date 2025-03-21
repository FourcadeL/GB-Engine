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

    ; test - display x first sprites
    ld d, %10000000
    ld hl, es_states
    ld b, MAX_SHOTS
    call memset_fast

    ld hl, es_Xspeeds
    ld [hl], 3
    ld hl, es_Yspeeds
    ld [hl], 5
    ; end test


    ; init MAX_SHOTS sprites for ennemy shots
    ld c, MAX_SHOTS*2
    ld hl, es_sprite_ids
.loop
    push bc
    push hl
    ; ld b, %00000000 ; sprite not displayed
    ld b, %00001000 ; test display
    ld c, $11 ; sprite height = 1 width =1
    call Sprite_new

    pop hl
    ld [hl+], a ; save sprite id

    push hl
    ld hl, shots_frame_tile
    ld b, a
    call Sprite_set_tiles
    
    pop hl
    pop bc
    dec c
    jr nz, .loop

    ret

ES_update::
    call update_positions
    call update_display_positions
    call update_sprites_positions
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
.loop
    ld a, [de]
    add a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [de]
    adc a, [hl]
    ld [de], a
    inc de
    inc hl
    dec c
    jr nz, .loop
    ret

;-----------------------------
; update_display_positions()
;
;   For every positions : X display pos = position(sub pixel shifted) + camera-pan
;   Y display pos = position(sub pixel shifted)
;-----------------------------
update_display_positions:
    ld c, MAX_SHOTS+1
    ld hl, es_states-1
    ld de, es_Xposs-2
.loop
    inc hl
    inc de
    inc de
    dec c
    ret z ; return at end of loop
    bit 7, [hl] ; is es active
    jr z, .loop ; inactive ? do not update
    ;-------- update display position
    push bc
    push de
    push hl
        ; X
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    swap a
    and a, %11110000
    ld b, a
    ld a, c
    swap a
    and a, %00001111
    or a, b ; a is 8 bit x pos after shift
    ; TODO should add camera offset here
    ld de, es_sprite_X - es_states
    add hl, de
    ld [hl], a
        ; Y
    pop bc ; retrieve current es_state addr
    pop hl ; retrieve current es_Xposs addr
    push hl
    push bc
    ld de, es_Yposs - es_Xposs
    add hl, de
    ld a, [hl+]
    swap a
    and a, %00001111
    ld d, a
    ld a, [hl]
    swap a
    and a, %11110000
    or a, d ; a is 8 bit Y pos after shift
    ld h, b
    ld l, c
    ld de, es_sprite_Y - es_states
    add hl, de
    ld [hl], a
    pop hl
    pop de
    pop bc
    jr .loop
    ;----------

;-----------------------
; update sprites positions
;   update associated sprite position for every
;   active ennemy shots
; ----------------------
update_sprites_positions:
    ld c, MAX_SHOTS+1
    ld hl, es_states-1
.loop
    inc hl
    dec c
    ret z   ; return at end of loop
    bit 7, [hl]
    jr z, .loop ; inactive -> do not update sprite position
    ; ------------ update corresponding sprite position
    push bc
    push hl
    ld de, es_sprite_ids - es_states
    add hl, de
    ld b, [hl] ; a <- id of sprite
    ld de, es_sprite_X - es_sprite_ids
    add hl, de
    ld c, [hl]
    push bc
    push hl
    call Sprite_set_Xpos
    pop hl
    pop bc
    ld de, es_sprite_Y - es_sprite_X
    add hl, de
    ld c, [hl]
    push bc
    push hl
    call Sprite_set_Ypos
    pop hl
    pop bc
    call Sprite_update_OAM
    pop hl
    pop bc
    jr .loop
    ;-------------

; STATIC DATA FOR ENNEMY SHOTS
shots_frame_tile:
    DB $00

    SECTION "Ennemy_shots_variables", WRAM0

; state byte  %a0000000
;              |
;              -> Active : 1 -> is active 0 -> is not active
_es_variables_start:
es_states:     DS 1*MAX_SHOTS ; table of es state bytes
es_sprite_ids: DS 1*MAX_SHOTS ; table of es sprite_ids
es_sprite_X:   DS 1*MAX_SHOTS ; table of es 8bit x positions (for display)
es_sprite_Y:   DS 1*MAX_SHOTS ; table of es 8bit y positions (for display)
es_Xposs:      DS 2*MAX_SHOTS ; table of es x positions
es_Yposs:      DS 2*MAX_SHOTS ; table of es y positions
es_Xspeeds:    DS 2*MAX_SHOTS ; table of es x speeds
es_Yspeeds:    DS 2*MAX_SHOTS ; table of es y speeds
_es_variables_end:


; Position usage
; Position Bytes : %hhhhhhhh llll llll
;                       ---- ---- ||||
;                                    |-> sub pixels
;                       8 bit used as position for sprite