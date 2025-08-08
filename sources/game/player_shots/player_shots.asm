; #########################################
; Player shots
;
;   Player shots are handled simillarly to ennemy shots :
;   all shots are displayed as one metasprite
;
;   Player shots can be of various types but each one stores
;   only its position
;
;   All shots tables are aligned but contrôle routines are
;   called spearately since each one contrôles a specific shot type
;
;   Contrarily to ennemy shots, player shots only stores their
;   pixel perfect position
;   (they moove fast enough that sub pixels are not an issue)
;
;   Each shot has :
;       - 8 bits status : %a0000000 | a : 1 -> active
;       - 8 bits X pos : %dddddddd
;       - 8 bits Y pos : %dddddddd
;   d : the 8 bit display position of the shot
;
;   Updates happens on every ODD frames :
;       - All shots are updated
;       - All shots are pushed to metasprite
;
;   Data alignment :
;       tables are aligned to handle at most 16 shots
;       (1 bytes table are 4 aligned)
;
; ##########################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "utils.inc"
INCLUDE "player.inc"
INCLUDE "player_shots.inc"
INCLUDE "player_shot_straight.inc"

DEF MAX_SHOTS EQU 16

DEF PS_sprite_entry EQUS "Sprite_table + 15*8"
DEF PS_displayList_entry EQUS "DisplayList_table + 13*2"
DEF PS_displayList_entry_index EQU 13

DEF PS_X_threshold EQU 168
DEF PS_Y_threshold EQU 160



;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                     RAM                  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

    SECTION "Player_shots_variables", WRAM0

_ps_variables_start:
ps_purge_current_index: DS 1
_ps_variables_end:

    SECTION "PS_status_table", WRAM0, ALIGN[4]
ps_status:      DS 1*MAX_SHOTS      ; table of ps status bytes

    SECTION "PS_Xposs_table", WRAM0, ALIGN[4]
ps_Xposs:       DS 1*MAX_SHOTS      ; table of ps x positions

    SECTION "PS_Yposs_table", WRAM0, ALIGN[4]
ps_Yposs:       DS 1*MAX_SHOTS      ; table of ps y positions


    SECTION "PS_displaylist_table", WRAM0
ps_dynamic_displayList:
ps_dynamic_displayList_header:
    DS 1
ps_dynamic_displayList_content:
    DS 4*MAX_SHOTS


;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                     ROM                  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+


    SECTION "Player_shots_code", ROMX

PS_init::
    PS_STRAIGHT_INIT
    ; reset variables in ram
    ld d, $00
    ld hl, _ps_variables_start
    ld b, _ps_variables_end - _ps_variables_start
    call memset_fast

    ; reset tables
    ld hl, ps_status
    ld b, MAX_SHOTS
    call memset_fast

    ld hl, ps_Xposs
    ld b, MAX_SHOTS
    call memset_fast

    ld hl, ps_Yposs
    ld b, MAX_SHOTS
    call memset_fast

    ; set player shots metasprite to active and visible + set display list in RAM
    ld hl, PS_sprite_entry
    ld [hl], %10000001
    inc hl
    ld [hl], PS_displayList_entry_index
    ld hl, PS_displayList_entry
    ld a, LOW(ps_dynamic_displayList)
    ld [hl+], a
    ld [hl], HIGH(ps_dynamic_displayList)
    
    ret




PS_update::
        ; high priority update
    call PS_purge_shots

        ; low priority update
    ld hl, Global_counter
    bit 0, [hl]
    ret z                       ; don't update on even frames

    ; "per shots" macros will go here
    PS_STRAIGHT_UPDATE_POS
    ; TODO
    call PS_push_to_display
    ret

;---------------------
; PS_purge_shots()
;   Delete ps outside of screen bounding box
;   Test one shot per call
;---------------------
PS_purge_shots:
    ld a, [ps_purge_current_index]
    inc a
    and a, %00001111    ; mask for 16 shots (4 bits)
    ld [ps_purge_current_index], a

        ; Test for index correction
    ld b, a
    ld h, HIGH(ps_status)
    add a, LOW(ps_status)
    ld l, a
    bit 7, [hl]             ;return if shot uninitialized

    push hl
    ld a, b
    ld h, HIGH(ps_Xposs)
    add a, LOW(ps_Xposs)
    ld l, a
    ld a, [hl]
    cp a, PS_X_threshold
    jr nc, .resetShot

    ld a, b
    ld h, HIGH(ps_Yposs)
    add a, LOW(ps_Yposs)
    ld l, a
    ld a, [hl]
    cp a, PS_Y_threshold
    jr nc, .resetShot
    pop hl
    ret
.resetShot
    pop hl
    res 7, [hl]
    ret

;---------------------
; PS_push_to_display()
;   pushes all active player shots
;   to meta sprite
;---------------------
PS_push_to_display:
    ld e, MAX_SHOTS
    ld a, 0
    ld [ps_dynamic_displayList_header], a       ; set 0 shots to display
    ld hl, ps_status
    ld bc, ps_dynamic_displayList_content
.loop
    bit 7, [hl]
    jr nz, .display_shot                ; a is current shot index
    inc hl
    inc a
    dec e
    jr nz, .loop
    ret
.display_shot
        ;set display position of the shot to current content
        push hl                 ; save current status addr
        ld d, a                 ; save current shot index
        ld h, HIGH(ps_Yposs)
        add a, LOW(ps_Yposs)
        ld l, a
        ld a, [hl]
        sub a, 8                ; compensate for tile Y offset
        ld [bc], a
        inc bc
        ld a, d
        ld h, HIGH(ps_Xposs)
        add a, LOW(ps_Xposs)
        ld l, a
        ld a, [hl]
        sub a, 4                ; compensate for tile X offset
        ld [bc], a
        inc bc
        inc bc
        inc bc
        ld hl, ps_dynamic_displayList_header
        inc [hl]                ; increment number of shots to display
        ld a, d
        pop hl
    inc hl
    inc a
    dec e
    jr nz, .loop
    ret

