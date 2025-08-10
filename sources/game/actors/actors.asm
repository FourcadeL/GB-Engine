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
; list of ennemy types:
;   - rot : a standard rotating ennemy
; ################################################

INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "charmap.inc"
INCLUDE "actors.inc"


DEF ROT_ANIM_SPEED EQU 6

;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Actors_data_table", WRAM0, ALIGN[6]
    
Actors_data_table:              DS ACTORS_NB * ACTORS_DATA_SIZE


    SECTION "Actors_variables", WRAM0
_ennemy_variables_start:
_rot_ennemy_anim_counter:       DS 1
_rot_ennemy_anim_offset:        DS 1
_ennemy_variables_end:


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Actors_code", ROMX

Actors_init::
    ; copy tiles into VRAM
    ld hl, Actors_tiles
    ld de, Actors_vram_tiles
    ld c, Actors_tiles.end - Actors_tiles
    call vram_copy_fast

    ; reset variables
    ld d, $00
    ld hl, _ennemy_variables_start
    ld b, _ennemy_variables_end - _ennemy_variables_start
    call memset_fast

    ; TESTING : spawn ennemy screen center
    ld hl, Actors_sprite_first_entry
    ;ld a, %10000001
    ld [hl+], a
    ld a, 2
    ld [hl+], a
    ld a, 67
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a

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
;TODO
    ; update ennemy rot display list DEPRECATED
    ld a, [_rot_ennemy_anim_offset]
    add a, LOW(ennemy_rot_dl_frame1)
    ld hl, Actors_rot_displaylist_entry
    ld [hl+], a
    ld [hl], HIGH(ennemy_rot_dl_frame1)
        ; update rot_counter
    ld hl, _rot_ennemy_anim_counter
    inc [hl]
    ld a, [hl]
    cp a, ROT_ANIM_SPEED
    jr nz, .skipROTAnimUpdate
    ld a, 0
    ld [hl], a
    ld a, [_rot_ennemy_anim_offset]
    add a, 9                        ; displayList block size
    cp a, 9*3                       ; Nb of animation frames
    jr nz, .writeNewCounter
    ld a, 0
.writeNewCounter
    ld [_rot_ennemy_anim_offset], a
.skipROTAnimUpdate
    ret


    SECTION "Actors_display_lists", ROMX, ALIGN[4]
ennemy_rot_dl_frame1:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, 0
    DB -8, 0, (tile3 - _VRAM)/16, 0
ennemy_rot_dl_frame2:
    DB 2
    DB -8, -8, (tile5 - _VRAM)/16, 0
    DB -8, 0, (tile7 - _VRAM)/16, 0
ennemy_rot_dl_frame3:
    DB 2
    DB -8, -8, (tile9 - _VRAM)/16, 0
    DB -8, 0, (tile11 - _VRAM)/16, 0

;+------------------------------------------------------------------+
;| +--------------------------------------------------------------+ |
;| |                    VRAM                                      | |
;| +--------------------------------------------------------------+ |
;+------------------------------------------------------------------+

    SECTION "Actors_tiles", ROMX
Actors_tiles:
    LOAD "Actors_VRAM", VRAM[$8060]
Actors_vram_tiles:
tile1:
    DB $00, $00, $01, $01, $00, $00, $03, $1c, $24, $3f, $48, $77, $5d, $7f, $32, $6f
tile2:
    DB $52, $4f, $11, $0f, $0a, $1f, $06, $1b, $03, $1e, $09, $0f, $06, $07, $00, $00
tile3:
    DB $00, $00, $60, $e0, $90, $f0, $c0, $78, $60, $d8, $50, $f8, $88, $f0, $4a, $f2
tile4:
    DB $cc, $76, $ba, $fe, $12, $ee, $24, $fc, $c0, $38, $00, $00, $80, $80, $00, $00

tile5:
    DB $00, $00, $00, $00, $30, $3f, $43, $7d, $34, $7f, $4a, $57, $11, $0f, $13, $2e
tile6:
    DB $13, $3e, $15, $2f, $08, $3f, $04, $3b, $2b, $3c, $28, $39, $14, $1c, $00, $00
tile7:
    DB $00, $00, $28, $38, $14, $9c, $d4, $3c, $20, $dc, $10, $fc, $a8, $f4, $48, $fc
tile8:
    DB $48, $f4, $88, $f0, $52, $ea, $2c, $fe, $c2, $be, $0c, $fc, $00, $00, $00, $00

tile9:
    DB $00, $00, $0b, $0f, $06, $07, $03, $05, $05, $1b, $08, $3f, $11, $6f, $52, $6f
tile10:
    DB $5a, $7f, $71, $6f, $28, $77, $44, $4f, $03, $0c, $00, $07, $01, $03, $00, $00
tile11:
    DB $00, $00, $80, $c0, $00, $e0, $c0, $30, $22, $f2, $14, $ee, $8e, $f6, $da, $7e
tile12:
    DB $4a, $f6, $88, $f6, $10, $fc, $a0, $d8, $c0, $a0, $60, $e0, $d0, $f0, $00, $00

    ENDL
.end
