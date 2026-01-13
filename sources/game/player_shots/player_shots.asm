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
;       - 8 bits status : %a0c000vf | a : 1 -> active | c : 1 -> collided | vf = flip
;                          | |   ||
;                          | |   |+> flip shot display 1 : flipped | 0 : not flipped
;                          | |   |
;                          | |   +-> vertical flip 1 : flipped | 0 : not flipped
;                          | |
;                          | +--> collided flag (with ennemy)
;                          |
;                          |
;                          +----> active flag
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
;   Shots :
;       0   : straight 1
;       1   : straight 2
;       2   : straight 3
;       3   : diag 1 /
;       4   : diag 2 /
;       5   : diag 3 /
;       6   : diag 4 \
;       7   : diag 5 \
;       8   : diag 6 \
;       9   : diagd 7 \
;       10  : diagd 8 \
;       11  : diagd 9 \
;       12  : diagd 10 /
;       13  : diagd 11 /
;       14  : diagd 12 /
;       15  : free
;
; ##########################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "utils.inc"
INCLUDE "player.inc"
INCLUDE "player_shots.inc"
INCLUDE "player_shot_straight.inc"
INCLUDE "player_shot_diag.inc"


DEF PS_sprite_entry EQUS "Sprite_table + 19*8"
DEF PS_displayList_entry EQUS "DisplayList_table + 19*2"
DEF PS_displayList_entry_index EQU 19

DEF PS_X_threshold EQU 168
DEF PS_Y_threshold EQU 160



;+---------------------------------------------------------------------+
;| +-----------------------------------------------------------------+ |
;| |                        RAM                                      | |
;| +-----------------------------------------------------------------+ |
;+---------------------------------------------------------------------+


    SECTION "PS_tables", WRAM0, ALIGN[7]
    ; %x000.... aligned
ps_status:      DS 1*PS_MAX_SHOTS      ; table of ps status bytes

    ; %x001.... aligned
ps_Xposs:       DS 1*PS_MAX_SHOTS      ; table of ps x positions

    ; %x010.... aligned
ps_Yposs:       DS 1*PS_MAX_SHOTS      ; table of ps y positions

    ; %x011.... aligned
ps_Tiles:       DS 1*PS_MAX_SHOTS

    ; %x100.... aligned
_ps_variables_start:
ps_push_to_display_counter: DS 1
_ps_variables_end:


    SECTION "PS_displaylist_table", WRAM0
ps_dynamic_displayList:
ps_dynamic_displayList_header:
    DS 1
ps_dynamic_displayList_content:
    DS 4*PS_MAX_SHOTS


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+


    SECTION "Player_shots_code", ROMX

PS_init::
    PS_STRAIGHT_INIT
    PS_DIAG_INIT
    ; reset variables in ram
    ld d, $00
    ld hl, _ps_variables_start
    ld b, _ps_variables_end - _ps_variables_start
    call memset_fast

    ; reset tables
    ld hl, ps_status
    ld b, PS_MAX_SHOTS
    call memset_fast

    ld hl, ps_Xposs
    ld b, PS_MAX_SHOTS
    call memset_fast

    ld hl, ps_Yposs
    ld b, PS_MAX_SHOTS
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
    ; WARNING PLAYER SHOTS PURGE is handled by the individual updates
    
        ; low priority update
    ld hl, Global_counter
    bit 0, [hl]
    ret z                       ; don't update on even frames

    ; "per shots" macros will go here
    PS_STRAIGHT_UPDATE
    PS_DIAG_UPDATE

;     jr PS_push_to_display


;---------------------
; PS_push_to_display()
;   pushes all active player shots
;   to meta sprite
;---------------------
PS_push_to_display:
    ld e, PS_MAX_SHOTS
    xor a
    ld d, a
    ld [ps_push_to_display_counter], a  ; set 0 shots to display
    ld hl, ps_status
    ld bc, ps_dynamic_displayList_content
.loop
    bit 7, [hl]
    jr nz, .display_shot                ; a is current shot index
    inc hl
    inc d
    dec e
    jr nz, .loop
    MEMBSET [ps_dynamic_displayList_header], [ps_push_to_display_counter]
    ret
.display_shot
        ;set display position of the shot to current content
        ld a, d
        add a, LOW(ps_Yposs)
        ld l, a
        ld a, [hl]
        sub a, 8                ; compensate for tile Y offset
        ld [bc], a
        inc bc
        ld a, d
        add a, LOW(ps_Xposs)
        ld l, a
        ld a, [hl]
        sub a, 4                ; compensate for tile X offset
        ld [bc], a
        inc bc
        ld a, d
        add a, LOW(ps_Tiles)
        ld l, a
        ld a, [hl]
        ld [bc], a              ; set current shot tile
        inc bc
        
        ld l, LOW(ps_push_to_display_counter)
        inc [hl]                ; increment number of shots to display

        ld a, d
        add a, LOW(ps_status)
        ld l, a
        ld a, [hl]
        and a, %00000011        ; get shot flip flags
        swap a
        rl a
        ld [bc], a              ; set shot flip
        inc bc
    inc hl
    inc d
    dec e
    jr nz, .loop
    MEMBSET [ps_dynamic_displayList_header], [ps_push_to_display_counter]
    ret

