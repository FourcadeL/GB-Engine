; ###################################
; Enemy shots
;
;   Enemy shots are displayed as one metasprite (sprite slot 1)
;   individual shots are updated by leveraging a dynamic display list in ram
;   (each shot is an object entry in the displaylist)
;
;   Each shot has :
;       - 16 bits X pos : %hhhhdddd ddddssss
;       - 16 bits Y pos : %hhhhdddd ddddssss
;       - 16 bits X speed : needed for negative values
;       - 16 bits Y speed : needed for negative values
;
;   Position bytes are :
;       % hhhhdddd ddddssss
;       h : 4 high bits
;       d : the 8 bit real display position
;       s : 4 sub pixel bits
;
; On each updates
;   - Active enemy shots are updated
;   - Active enemy shots are pushed to metasprite
;
;   Data alignment :
; for ease of computation, tables are aligned
; this means we handle AT MOST 16 shots
;   1 bytes tables are 4 ALIGNED
;   2 bytes tables are 5 ALIGNED
;
;   Shots spawn :
;       - only one enemy shot may be spawned per frame (call of ES_update)
;       for that, a spawn request is written by the ES_request_shot routine
;       if multiple requests are fired in the same frame, subsequent requests will
;       overwrite the firt ones
;
;       /!\ WARNINGS
;   - Tables should be placed in memory as : Xposs :: Yposs and  Xspeeds :: Yspeeds
;       variable access from relative addr
;   - es_request variables should be kept in that order
; ###################################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "charmap.inc"
INCLUDE "player.inc"


DEF ES_MAX_SHOTS EQU 16

DEF ES_sprite_entry EQUS "Sprite_table + 1*8"
DEF ES_displayList_entry EQUS "DisplayList_table + 1*2"
DEF ES_displayList_entry_index EQU 1

DEF ES_X_threshold EQU 168
DEF ES_Y_threshold EQU 160


;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                     RAM                                              | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+


    SECTION "Enemy_shots_variables", WRAM0

_es_variables_start:
es_current_es_nb:       DS 1 ; current number of active ennemy shots

es_current_shot_index:  DS 1 ; index of currently handled shot

es_animate_current_index: DS 1 ; index of current shot to animate
es_animate_current_frame: DS 1 ; current frame of tile flip flags to use

es_request_status:: DS 1 ; es request status byte : bit 7 = 1 -> request
es_request_Ypos:: DS 2
es_request_Xpos:: DS 2
es_request_Yspeed:: DS 2
es_request_Xspeed:: DS 2

es_purge_current_index: DS 1 ; index of currently checked shot to purge

es_check_player_collision_start_index_counter: DS 1 ; a counter incremented at each frame, the least significant bit serves for even or add checks
_es_variables_end:


    SECTION "ES_Xposs_table", WRAM0, ALIGN[5]
es_Xposs:      DS 2*ES_MAX_SHOTS ; table of es x positions

    ; SECTION "ES_Yposs_table", WRAM0, ALIGN[5]
es_Yposs:      DS 2*ES_MAX_SHOTS ; table of es y positions

    SECTION "ES_Xspeeds_table", WRAM0, ALIGN[5]
es_Xspeeds:    DS 2*ES_MAX_SHOTS ; table of es x speeds

    ; SECTION "ES_Yspeeds_table", WRAM0, ALIGN[5]
es_Yspeeds:    DS 2*ES_MAX_SHOTS ; table of es y speeds


    SECTION "ES_displaylist_table", WRAM0
es_dynamic_displayList:
es_dynamic_displayList_header:
    DS 1
es_dynamic_displayList_content:
    DS 4*ES_MAX_SHOTS

;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                     ROM                                              | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

    SECTION "Enemy_shots_code", ROMX

ES_init::
    ; copy tiles into VRAM
    ld hl, Enemy_shots_tiles
    ld de, Enemy_shots_vram_tiles
    ld c, Enemy_shots_tiles.end - Enemy_shots_tiles
    call vram_copy_fast

    ; reset variables in ram
    ld d, $00
    ld hl, _es_variables_start
    ld b, _es_variables_end - _es_variables_start
    call memset_fast

    ; reset tables
    ld hl, es_Xposs
    ld b, ES_MAX_SHOTS*2
    call memset_fast

    ld hl, es_Yposs
    ld b, ES_MAX_SHOTS*2
    call memset_fast

    ld hl, es_Xspeeds
    ld b, ES_MAX_SHOTS
    call memset_fast

    ld hl, es_Yspeeds
    ld b, ES_MAX_SHOTS
    call memset_fast

    ; set shots metasprite to active and visible + set display list
    ld hl, ES_sprite_entry
    ld [hl], %10000001
    inc hl
    ld [hl], ES_displayList_entry_index
    inc hl
    ld a, $00
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld hl, ES_displayList_entry
    ld a, LOW(es_dynamic_displayList)
    ld [hl+], a
    ld [hl], HIGH(es_dynamic_displayList)

    ; set all tiles in displaylist
    ld hl, es_dynamic_displayList_content + 2
    ld a, (tile1 - _VRAM)/16
    ld d, ES_MAX_SHOTS
.tile_index_set_loop
    ld [hl+], a
    inc hl
    inc hl
    inc hl
    dec d
    jr nz, .tile_index_set_loop


    ret

ES_update::
    call ES_update_positions
    call ES_animate
    call ES_purge_shots
    call ES_check_player_collision
    call ES_handle_request
    call ES_push_to_display
    ret


; ------------------
; ES_request_shot(StackPush :   $XSSS - 16 bit X speed
;               $YSSS - 16 bit Y speed
;               $XXXX - 16 bit X position
;               $YYYY - 16 bit Y position)
;
;   sets up a shot request with specified position and speed
; ------------------
ES_request_shot::
    ld de, es_request_Ypos
    ld hl, sp+2
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    inc de
    ld hl, sp+4
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    inc de
    ld hl, sp+6
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    inc de
    ld hl, sp+8
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    ld hl, es_request_status
    set 7, [hl]
    ret


; ----------------------------------------
; ES_handle_request()
;
;   Spawn new es if requested
; ----------------------------------------
ES_handle_request:
    ld hl, es_request_status
    bit 7, [hl]
    ret z               ; ret if no request
    res 7, [hl]         ; reset request bit
    ld hl, es_current_es_nb
    ld a, [hl]
    ld b, a
    cp a, ES_MAX_SHOTS
    ret z               ; No free slot
    inc [hl]
_create_shot_at_index_b:
    ld a, b
    add a, a
    ld b, a
    ld hl, es_request_Ypos      ; Y pos
    ld d, HIGH(es_Yposs)
    ld a, b
    add a, LOW(es_Yposs)
    ld e, a
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    ld d, HIGH(es_Xposs)        ; X pos
    ld a, b
    add a, LOW(es_Xposs)
    ld e, a
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    ld d, HIGH(es_Yspeeds)      ; Y speed
    ld a, b
    add a, LOW(es_Yspeeds)
    ld e, a
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    ld d, HIGH(es_Xspeeds)      ; X speed
    ld a, b
    add a, LOW(es_Xspeeds)
    ld e, a
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    ret

; ----------------------------------------
; ES_check_player_collision
;   Check if there was a collision with the player
;       if so, sets bit 6 of [player_state]
;
;   Each call checks only HALF of the shots
;       even and odd
; ----------------------------------------
ES_check_player_collision:
    ld a, [es_check_player_collision_start_index_counter]
    inc a
    ld [es_check_player_collision_start_index_counter], a
    and a, %00000001
    ld b, a
    ld hl, es_current_es_nb
    ld a, [hl]
    srl a                       ; iterate on HALF the number of active shots
    jr nc, .even
        inc a                   ; correct if a was odd
        sub a, b                ; correct from start offset
.even
    ret z                       ; return if no shots
    ld c, a
.loop
    ; check the shot collision since we iterate only on the active shots
.check_shot_collision
    ld a, b
    add a, a
    ld h, HIGH(es_Xposs)
    add a, LOW(es_Xposs)
    ld l, a
    ld a, [hl+]
    swap a
    and a, %00001111
    ld e, a
    ld a, [hl]
    swap a
    and a, %11110000
    or a, e
    ld hl, player_pixel_Xpos
    sub a, [hl]
    add a, Player_hitbox_width/2
    cp a, Player_hitbox_width
    jr nc, .no_collision
    ld a, b
    add a, a
    ld h, HIGH(es_Yposs)
    add a, LOW(es_Yposs)
    ld l, a
    ld a, [hl+]
    swap a
    and a, %00001111
    ld e, a
    ld a, [hl]
    swap a
    and a, %11110000
    or a, e
    ld hl, player_pixel_Ypos
    sub a, [hl]
    add a, Player_hitbox_height/2
    cp a, Player_hitbox_height
    jr nc, .no_collision
        ; all tests passed, there is a collision
    ld hl, player_state
    set 6, [hl]
    ret                         ; stop there for collision tests
.no_collision
    inc b
    inc b
    dec c
    jr nz, .loop
    ret

; ----------------------------------------
; ES_purge_shots()
;   Delete es outside of screen bounding box
;
;   Each call check for only ONE shot
; ----------------------------------------
ES_purge_shots:
    ld a, [es_current_es_nb]
    or a, a
    ret z                               ; no active shots -> return
    ld b, a
    ld a, [es_purge_current_index]
    inc a
    ld [es_purge_current_index], a
    cp a, b
    jr c, .skipIndexCorrection
    ld a, 0
    ld [es_purge_current_index], a
.skipIndexCorrection
    ld d, a
    sla a
    ld b, a

    ld h, HIGH(es_Xposs)
    add a, LOW(es_Xposs)
    ld l, a
        ; test X bounds
        ld a, [hl+]
        swap a
        and a, %00001111
        ld c, a
        ld a, [hl]
        swap a
        and a, %11110000
        or a, c
        cp a, ES_X_threshold
        jr nc, .resetShot
    ld a, b
    ld h, HIGH(es_Yposs)
    add a, LOW(es_Yposs)
    ld l, a
        ; test Y bounds
        ld a, [hl+]
        swap a
        and a, %00001111
        ld c, a
        ld a, [hl]
        swap a
        and a, %11110000
        or a, c
        cp a, ES_Y_threshold
        jr nc, .resetShot
    ret
.resetShot
;     jr ES_delete_shot                 ; no need because of code placement

; ---------------------------------------
; ES_delete_shot(d = shot index)
;   delete shot at index d
; ---------------------------------------
ES_delete_shot:
    ld hl, es_current_es_nb
    ld a, [hl]
    dec a
    ld [hl], a
    ld e, a
    cp a, d
    ret z                               ; last shot removed
        ; need to transfer last shot of table to index d
    sla e                               ; e <- low index of shot to read from
    sla d                               ; d <- index of shot to write to
        ; copy Xpos
    ld h, HIGH(es_Xposs)
    ld a, LOW(es_Xposs)
    add a, e
    ld l, a
    ld b, HIGH(es_Xposs)
    ld a, LOW(es_Xposs)
    add a, d
    ld c, a
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl]
    ld [bc], a
        ; copy Ypos
    ld h, HIGH(es_Yposs)
    ld a, LOW(es_Yposs)
    add a, e
    ld l, a
    ld b, HIGH(es_Yposs)
    ld a, LOW(es_Yposs)
    add a, d
    ld c, a
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl]
    ld [bc], a
        ; copy Xspeed
    ld h, HIGH(es_Xspeeds)
    ld a, LOW(es_Xspeeds)
    add a, e
    ld l, a
    ld b, HIGH(es_Xspeeds)
    ld a, LOW(es_Xspeeds)
    add a, d
    ld c, a
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl]
    ld [bc], a
        ; copy Yspeed
    ld h, HIGH(es_Yspeeds)
    ld a, LOW(es_Yspeeds)
    add a, e
    ld l, a
    ld b, HIGH(es_Yspeeds)
    ld a, LOW(es_Yspeeds)
    add a, d
    ld c, a
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl]
    ld [bc], a
    ret

; ----------------------------------------
; ES_animate()
;   Animates shots (rotation)
;   individual tiles flip should follow : 00 : 10 : 11 : 01
;   I use byte with mask %01100000 incremented by %00110000 for a reasonable approximation
;
;   Each call animates ONE shot
;   animated shot ID is last + 7 (so each tile is animated once after 16 calls)
;
; ----------------------------------------
ES_animate:
    ld hl, es_animate_current_frame
    ld a, [hl]
    and a, %01100000
    ld d, a                 ; d <- current flags to use
    ld hl, es_animate_current_index
    ld a, [hl]
    sla a
    sla a
    ld hl, es_dynamic_displayList_content + 3
    add a, l
    ld l, a
    ld a, h
    adc a, 0
    ld h, a                 ; hl is addr of current animated shot flags
    ld [hl], d
    ld hl, es_animate_current_index
    ld a, [hl]
    add a, 7
    ld [hl], a
    cp a, ES_MAX_SHOTS
    ret c                   ; carry -> index < 16 no index correction or frame change
    sub a, ES_MAX_SHOTS
    ld [hl], a
    ret nz                  ; non zero -> do not update animation frame
    ld hl, es_animate_current_frame
    ld a, [hl]
    add a, %00110000
    ld [hl], a
    ret


;---------------------
; ES_push_to_display()
;   pushes all active enemy shots
;   to meta sprite
;---------------------
ES_push_to_display:
    ld a, [es_current_es_nb]
    or a, a
    jr z, .finalize                 ; finalize if no shots to display
    ld e, a
    ld a, 0
    ld [es_current_shot_index], a
    ld bc, es_dynamic_displayList_content
.loop
        ; display all shots until d is 0 since first d shots are active
.display_shot
        ; set display position to current content
        ld hl, es_Yposs
        ld a, [es_current_shot_index]
        add a
        add a, l
        ld l, a             ; hl is addr of shot Y position
        ld a, [hl+]
        and a, %11110000
        swap a
        ld d, a
        ld a, [hl]
        and a, %00001111
        swap a
        or a, d
        sub a, 8            ; compensate for tile Y offset
        ld [bc], a
        inc bc
        ld hl, es_Xposs
        ld a, [es_current_shot_index]
        add a
        add a, l
        ld l, a             ; hl is addr of shot X position
        ld a, [hl+]
        and a, %11110000
        swap a
        ld d, a
        ld a, [hl]
        and a,%00001111
        swap a
        or a, d
        sub a, 4            ; compensate for tile X offset
        ld [bc], a
        inc bc
        inc bc
        inc bc
        ld hl, es_current_shot_index
        inc [hl]                        ; next shot index
    dec e
    jr nz, .loop
.finalize
        ; finalize display
    ld hl, es_dynamic_displayList_header
    ld a, [es_current_es_nb]
    ld [hl], a
    ret

; ----------------------
; ES_update_positions()
;
;   For every X and Y positions :
;   X = X+SpeedX
;   Y = Y+SpeedY
; ----------------------
ES_update_positions:
    ld hl, es_current_es_nb
    ld a, [hl]
    or a, a
    ret z                               ; No shots to update, return
    push af                             ; save a
    ld c, a
    ld de, es_Xposs
    ld hl, es_Xspeeds
.loop_x                                 ; loop on x positions
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
    jr nz, .loop_x
    pop bc                              ; get counter saved
    ld de, es_Yposs
    ld hl, es_Yspeeds
.loop_y                                 ; loop on y positions
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
    dec b
    jr nz, .loop_y
    ret





;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                    VRAM                                              | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

    SECTION "Enemy_shots_tiles", ROMX
Enemy_shots_tiles:
    LOAD "Enemy_shots_VRAM", VRAM [$8260]
Enemy_shots_vram_tiles:
tile1:
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3c, $18, $66, $3c, $42, $7e
tile2:
    DB $46, $7a, $6e, $34, $3c, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ENDL
.end
