; ###########################
; Waving enemy actor
;
;   handle waving enemy actor functions
; ###########################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "actors.inc"
INCLUDE "wav_enemy.inc"
INCLUDE "player_shots.inc"
INCLUDE "player.inc"

DEF Wav_enemy_displayList_first_entry EQUS "DisplayList_table + 27*2"
DEF Wav_enemy_displayList_first_entry_index EQU 27



;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Wav_enemy_variables", WRAM0
_wav_enemy_variables:
wav_enemy_next_assign_framerule:    DS 1            ; next framerule to use
_wav_enemy_variables_end:

;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Wav_enemy_code", ROMX

Wav_enemy_init::
    ; copy tiles into VRAM
    ld hl, Wav_enemy_tiles
    ld de, Wav_enemy_vram_tiles
    ld c, Wav_enemy_tiles.end - Wav_enemy_tiles
    call vram_copy_fast

    ; reset variables
    ld d, $00
    ld hl, _wav_enemy_variables
    ld b, _wav_enemy_variables_end - _wav_enemy_variables
    call memset_fast

    ; copy displayList_tables
    ld hl, static_dl_addrs
    ld de, Wav_enemy_displayList_first_entry
    ld b, static_dl_addrs.end - static_dl_addrs
    call memcopy_fast

    ret


;----------------------------------------
; Wav_enemy_request(b = x pixel pos c = sine step speed)
;   Request a new waving enemy at position specified by b
;   with sine amplitude as defined in c
;   Enemy always starts up at the top of the screen
;----------------------------------------
Wav_enemy_request::
    push bc
    ACTOR_FIND_FREE                         ; find actor (hl, de are set)
    pop bc
    ret nz

        ; add waving enemy at hl and de
    ; sprite data
    ld a, %10000001
    ld [hl+], a

    ld a, Wav_enemy_displayList_first_entry_index ; display list
    ld [hl+], a
    ld a, $80                               ; start Y pos is $0F80
    ld [hl+], a
    ld a, $0F
    ld [hl+], a
    swap b
    ld a, b
    and a, $F0
    ld [hl+], a                             ; set X low position
    ld a, b
    and a, $0F
    ld [hl+], a                             ; set X high position
    ld a, LOW(Wav_enemy_handle)
    ld [hl+], a
    ld [hl], HIGH(Wav_enemy_handle)

    ; actor data
    ld h, d
    ld l, e
    ld a, COUNTER_STATE
    ld [hl+], a
    ld [hl], 00                             ; startup movement count
    inc hl
    ld [hl], c                              ; sine step speed
    inc hl

    ld [hl], 20                             ; TODO default shoot timeout
    inc hl
    ld [hl], 40                             ; TODO default shoot countdown
    inc hl
    ld [hl], %00001111                      ; TODO default shoot threshold (higher = more shoots)
    inc hl
    ld [hl], 2                              ; TODO default shot speed (0 to 3)
    inc hl

        ; animation counter
    ld [hl], ANIM_COUNTER_VALUE
    inc hl

        ; framerule set
    ld de, wav_enemy_next_assign_framerule
    ld a, [de]
    inc a
    and a, %00000011
    ld [de], a
    ld [hl], a                              ; framerule for this enemy

    ret


;-------------------------------------------------------------
; Wav_enemy_handle(bc = sprite addr, da = actor data addr)
;
;   1 - do main state handle
;   2 - do movement handle
;   3 - do animation handling
;   4 - do collision handling
;-------------------------------------------------------------
Wav_enemy_handle:
       ; handle state
;     ld a, state
;     add a, e
;     ld h, d
;     ld l, e
    ld a, [de]                              ; get current state (first byte)
    cp a, COUNTER_STATE
    jr z, count_state_handle
    cp a, SHOOT_STATE
    jr z, shoot_state_handle
    cp a, DEAD_STATE
    jr z, dead_state_handle
    cp a, DELETE_STATE
    jr z, delete_state_handle

    ret

;-----------------------------------------------
; count_state_handle(bc = sprite addr, da = actor data addr)
;
;   Update shoot counter
;-----------------------------------------------
count_state_handle:
    ld a, shoot_timeout
    add a, e
    ld l, a
    ld h, d
    ld a, [hl+]                             ; stores counter reset value
    dec [hl]
    jr nz, movement_handle                  ; no trigger, continue to movement routine

        ; trigger a shot
    ld [hl], a                              ; reset counter
    ld a, SHOOT_STATE
    ld [de], a
    jr movement_handle


;------------------------------------------------
; movement_handle(bc = sprite addr, de = actor data addr)
;
;   Update enemy position (sinus)
;------------------------------------------------
movement_handle:
        ; handle Y movement
    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld h, b
    ld l, a
    ld a, [hl]
    add a, Y_SPEED
    ld [hl+], a
    ld a, [hl]
    adc a, 0
    ld [hl], a
        ; Test low nibble of a + 1:
        ; grater than High nibble of BOUNDARY_Y
        ; -> delete sprite
        inc a
        and a, %00001111
        cp a, BOUNDARY_Y >> 4
        jr nc, delete_state_handle

        ; handle X movement
    push de
    ld a, x_movement_count
    add a, e
    ld h, d
    ld l, a
    ld a, [hl+]
    add a, [hl]                         ; advance counter
    dec hl
    ld [hl], a                          ; stores ocunter back
    GET_SINE_A
    sra a                               ; shift sine aplitude
    sra a
    ld d, $00                           ; high part of 16 bit position offset
    bit 7, a
    jr z, .positive_sine
        dec d                           ; sine is negative -> high 16 bit part is %11111111
.positive_sine
    ld e, a
    ld a, SPRITE_STRUCT_Xpos
    add a, c
    ld h, b
    ld l, a
    ld a, [hl]
    add a, e
    ld [hl+], a
    ld a, [hl]
    adc a, d
    ld [hl], a

    pop de

    jr animation_handle



;------------------------------------------------
; dead_state_handle(bc = sprite addr)
;
;   put explosion at old position
;   delete sprite entry
;------------------------------------------------
dead_state_handle:
        ; add explosion at former position
    push bc
    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld l, a
    ld h, b
    ld a, [hl+]
    and a, %11110000
    ld c, a
    ld a, [hl+]
    and a, %00001111
    or a, c
    swap a
    ld c, a                         ; c <- y pixel pos
    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl]
    and a, %00001111
    or a, b
    swap a
    ld b, a
    call Explosion_request
    pop bc
;     jr delete_state_handle
;------------------------------------------------
; delete_state_handle(bc = sprite addr)
;
;   delete sprite entry
;------------------------------------------------
delete_state_handle:
        ; delete sprite
    ld a, 0
    ld [bc], a
    ret
;------------------------------------------------
; shoot_state_handle(bc = sprite addr, de = actor data addr)
;
;   reset state to counter
;   random shoot
;------------------------------------------------
shoot_state_handle:
        ; reset state
    ld a, COUNTER_STATE
    ld [de], a

    push bc
    push de
    push hl
        ; test if random is under threshold
    call generateRandom
    pop hl
    pop de
    pop bc
    cp a, [hl]
    ret nc                          ; if shoot_rate <= a

        ; shoot toward player
    push de
    push bc

    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld h, b
    ld l, a
    ld a, [hl+]
    and a, %11110000
    ld c, a
    ld a, [hl+]
    and a, %00001111
    or a, c
    swap a
    ld c, a                         ; b <- Y pixel pos of enemy
    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl]
    and a, %00001111
    or a, b
    swap a
    ld b, a                         ; c <- X pixel pos of enemy

    ld a, shot_speed
    add a, e
    ld h, d
    ld l, a

    ld d, [hl]                      ; shot speed

    call TP_request_shot_toward_player

    pop bc
    pop de

    jp movement_handle


;---------------------------
; animation_handle(bc = sprite addr, de = actor data addr)
;
;   Update animation of actor
;----------------------------
animation_handle:
    ld a, anim_counter
    add a, e
    ld l, a
    ld h, d
    dec [hl]
    jr nz, collision_handle             ; no trigger, next action
        ; update animation
    ld [hl], ANIM_COUNTER_VALUE
    ld a, SPRITE_STRUCT_displ
    add a, c
    ld l, a
    ld h, b
    ld a, [hl]
    inc a
    ld [hl], a
    cp a, Wav_enemy_displayList_first_entry_index + 4       ; 4 frame
    jr nz, collision_handle             ; no reset of animation frame
    ld a, Wav_enemy_displayList_first_entry_index
    ld [hl], a
;     jp collision_handle



;-------------------------
; collision_handle(bc = sprite addr, de = actor data addr)
;
;   Tests against all enemy shots if there is a collision
;   Test player collision and set player flag if collision occured
;   Test is done only on current enemy framerule
;------------------------
collision_handle:
        ; check only on framerule
    ld a, e
    add a, framerule
    ld l, a
    ld h, d
    ld a, [Global_counter]
    and a, %00000011
    sub a, [hl]
    ret nz                          ; don't update on wrong framerule
        ; handle collision with player shot
    ; (assume that bc and de are still set)
    push de
    ld a, SPRITE_STRUCT_Ypos
    add a, c
    ld h, b
    ld l, a
    ld a, [hl+]
    and a, %11110000
    ld d, a
    ld a, [hl+]
    and a, %00001111
    or a, d
    swap a
    ld d, a                     ; d <- enemy pixel Y pos
    ld a, [hl+]
    and a, %11110000
    ld e, a
    ld a, [hl]
    and a, %00001111
    or a, e
    swap a
    ld e, a                     ; e <- enemy pixel X pos

    ld b, d
    ld c, e

        ; test against all player shots
    ld hl, ps_status            ; status table
    ld d, 0                     ; index count
    ld e, PS_MAX_SHOTS
.loop
    bit 7, [hl]
    jr nz, .test_shot
    inc hl
    inc d
    dec e
    jr nz, .loop
    jr .check_player_collision
.test_shot
    push hl
    ld h, HIGH(ps_Yposs)
    ld a, LOW(ps_Yposs)
    add a, d
    ld l, a
    ld a, [hl]
    sub a, b                    ; Y pos diff
    jr nc, .non_negativeY
    cpl a
    inc a
.non_negativeY
    and a, %11110000
    jr nz, .abort_this_collision
    ld h, HIGH(ps_Xposs)
    ld a, LOW(ps_Xposs)
    add a, d
    ld l, a
    ld a, [hl]
    sub a, c                    ; X pos diff
    jr nc, .non_negativeX
    cpl a
    inc a
.non_negativeX
    and a, %11111000
    jr nz, .abort_this_collision
        ; collision found, set state
    pop hl
    set 5, [hl]                 ; set collide flag to shot
    pop hl
    ld a, state
    add a, l
    ld l, a
    ld [hl], DEAD_STATE
    ret
.abort_this_collision
    pop hl
    inc hl
    inc d
    dec e
    jr nz, .loop

    ; check player collision (b = enemy Y pixel pos; c = enemy X pixel pos)
.check_player_collision
    ACTOR_PLAYER_COLLISION_SQUARE c, b, WAV_E_HITBOX_WIDTH, WAV_E_HITBOX_HEIGHT, .no_player_collision
        ; set collision flag for player
    ld hl, player_state
    set 5, [hl]
        ; set enely in dead state
    pop hl
;     ld a, state
;     add a, l
;     ld l, a                       ; state is the first byte of structure
    ld [hl], DEAD_STATE
    ret
.no_player_collision
    pop de
    ret


    SECTION "Wav_enemy_display_lists", ROMX, ALIGN[4]
enemy_wav_dl_frame1:
    DB 2
    DB -8, -8, (tile1 - _VRAM)/16, 0
    DB -8, 0, (tile1 - _VRAM)/16, %00100000
enemy_wav_dl_frame2:
    DB 2
    DB -8, -8, (tile3 - _VRAM)/16, 0
    DB -8, 0, (tile5 - _VRAM)/16, 0
enemy_wav_dl_frame3:
    DB 2
    DB -8, -8, (tile5 - _VRAM)/16, %00100000
    DB -8, 0, (tile3 - _VRAM)/16, %00100000


static_dl_addrs:                ; static outline of dl for setup in displyList table
    DW enemy_wav_dl_frame1
    DW enemy_wav_dl_frame2
    DW enemy_wav_dl_frame1
    DW enemy_wav_dl_frame3
.end
;+------------------------------------------------------------------+
;| +--------------------------------------------------------------+ |
;| |                    VRAM                                      | |
;| +--------------------------------------------------------------+ |
;+------------------------------------------------------------------+

    SECTION "Wav_enemy_tiles", ROMX
Wav_enemy_tiles:
    LOAD "Wav_enemy_VRAM", VRAM[$82A0]
Wav_enemy_vram_tiles:
tile1:
    DB $02, $00, $00, $02, $00, $62, $64, $91, $a6, $13, $17, $27, $1f, $6c, $1f, $2c
tile2:
    DB $16, $64, $99, $29, $38, $91, $78, $11, $31, $50, $09, $20, $08, $00, $00, $08
tile3:
    DB $02, $00, $00, $02, $00, $02, $04, $02, $04, $03, $1f, $0f, $0e, $1d, $0f, $1c
tile4:
    DB $0e, $1d, $1f, $0f, $0e, $06, $0c, $0c, $05, $0c, $04, $0c, $0c, $04, $00, $00
tile5:
    DB $40, $00, $00, $40, $00, $70, $70, $88, $a8, $44, $40, $a4, $40, $b4, $40, $a4
tile6:
    DB $40, $b4, $48, $a4, $20, $c8, $30, $c0, $a0, $50, $90, $20, $10, $00, $00, $00
    ENDL
.end
