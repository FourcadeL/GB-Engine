; ################################
; Sniper enemy actor
;
;   handle functions
; ################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "actors.inc"
INCLUDE "snipe_enemy.inc"
INCLUDE "player_shots.inc"
INCLUDE "player.inc"

DEF Snip_enemy_displayList_first_entry EQUS "DisplayList_table + 32 * 2"
DEF Snip_enemy_displayList_first_entry_index EQU 32


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Snip_enemy_variables", WRAM0
_snip_enemy_variables:
snip_enemy_next_assign_framerule:   DS 1            ; next framerule to use
_snip_enemy_variables_end:

;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Snip_enemy_code", ROMX

Snip_enemy_init::
    ; copy tiles into VRAM
    ld hl, Snip_enemy_tiles
    ld de, Snip_enemy_vram_tiles
    ld c, Snip_enemy_tiles.end - Snip_enemy_tiles
    call vram_copy_fast

    ; reset variables
    ld d, $00
    ld hl, _snip_enemy_variables
    ld b, _snip_enemy_variables_end - _snip_enemy_variables
    call memset_fast

    ; copy displayList_tables
    ld hl, static_dl_addrs
    ld de, Snip_enemy_displayList_first_entry
    ld b, static_dl_addrs.end - static_dl_addrs
    call memcopy_fast

    ret


; ---------------------------------------
; Snip_enemy_request(b = x pixel pos,
;       c = entry flag and height target (%ehhhhhhh)
;       d = shoot number,
;       e = shot speed)
;   Request a new sniper enemy at position b
;   With height target before shooting c (h)
;   Enemy will come from top if c (e) is reset and from botom if c (e) is set
; ---------------------------------------
Snip_enemy_request::
    push de
    push bc
    ACTOR_FIND_FREE                         ; find actor (hl, de are set)
    pop bc
    jr z, .proceed          ; no actor found
        ; no free slot
        pop de
        ret
.proceed
        ; add sniper enemy at hl and de
    ; sprite data
    push bc
    ld a, %10000001
    ld [hl+], a
    ld a, Snip_enemy_displayList_first_entry_index
    ld b, $F8                               ; top entry Y
    bit 7, c                                ; botom entry ?
    jr z, .no_correction
        ld b, BOTOM_ENTRY_Y_VALUE
        add a, 2
.no_correction
    ld [hl+], a
    swap b
    ld a, b
    and a, %11110000
    ld [hl+], a                             ; set Y low
    ld a, b
    and a, %00001111
    ld [hl+], a                             ; set Y high
    pop bc
    swap b
    ld a, b
    and a, %11110000                        ; set X low
    ld [hl+], a
    ld a, b
    and a, %00001111                        ; set X high
    ld [hl+], a

    ld a, LOW(Snip_enemy_handle)
    ld [hl+], a
    ld [hl], HIGH(Snip_enemy_handle)

    ; actor data
    ld h, d
    ld l, e
    pop de
    ld a, ENTRY_STATE
    ld [hl+], a
        ; flags set up
        ld a, c
        and a, %10000000
        rlc a
        ld [hl+], a
    ld a, c
    and a, %01111111
    ld [hl+], a                                 ; set y_target
    ld a, d
    ld [hl+], a                                 ; set shoot_nb
    ld a, 98                                    ; TODO : shoot rate default
    ld [hl+], a
    ld a, e
    ld [hl+], a                                 ; set shot_speed
    ld a, ANIM_COUNTER_VALUE
    ld [hl+], a                                 ; set animation counter

        ; framerule set
    ld de, snip_enemy_next_assign_framerule
    ld a, [de]
    inc a
    and a, %00000011
    ld [de], a
    ld [hl], a                                  ; framerule for this enemy

    ret



;------------------------------------------------------
; Snip_enemy_handle(bc = sprite addr, de = actor data addr)
;
;------------------------------------------------------
Snip_enemy_handle:
        ; handle state
;     ld a, state
;     add a, e
;     ld h, d
;     ld l, a
    ld a, [de]                                  ; get current state (first byte)
    cp a, ENTRY_STATE
    jr z, entry_state_handle
    cp a, LEAVE_STATE
    jr z, leave_state_handle
    cp a, SHOOT_STATE
    jr z, shoot_state_handle
    cp a, DEAD_STATE
    jr z, dead_state_handle

    ret

entry_state_handle:
leave_state_handle:
shoot_state_handle:
dead_state_handle:
    ret



    SECTION "Snip_enemy_display_lists", ROMX, ALIGN[4]
snip_enemy_dl_frame1:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, %00010000
    DB -8, 0, (tile1 - _VRAM)/16, %00110000
snip_enemy_dl_frame2:
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, %00010000
    DB -8, 0, (tile3 - _VRAM)/16, %00110000
snip_enemy_dl_frame3:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, %01010000
    DB -8, 0, (tile1 - _VRAM)/16, %01110000
snip_enemy_dl_frame4:
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, %01010000
    DB -8, 0, (tile3 - _VRAM)/16, %01110000


static_dl_addrs:                                    ; static outline of dl for setup in displayList table
    DW snip_enemy_dl_frame1
    DW snip_enemy_dl_frame2
    DW snip_enemy_dl_frame3
    DW snip_enemy_dl_frame4
.end

;+---------------------------------------------------------------+
;| +-----------------------------------------------------------+ |
;| |                    VRAM                                   | |
;| +-----------------------------------------------------------+ |
;+---------------------------------------------------------------+

    SECTION "Snip_enemy_tiles", ROMX
Snip_enemy_tiles:
    LOAD "Snip_enemy_VRAM", VRAM[$8300]
Snip_enemy_vram_tiles:
tile1:
    DB $18, $00, $18, $18, $08, $10, $67, $ff, $db, $fe, $96, $fd, $7b, $fe, $6e, $5d
tile2:
    DB $37, $2e, $1f, $3f, $2c, $3f, $07, $30, $05, $56, $23, $04, $03, $02, $00, $00
tile3:
    DB $00, $00, $00, $00, $10, $08, $ff, $67, $db, $fe, $96, $fd, $7b, $fe, $6e, $5d
tile4:
    DB $37, $2e, $1f, $3f, $2c, $3f, $07, $30, $05, $56, $23, $04, $03, $02, $00, $00
    ENDL
.end
