; #############################################################
; Levels functions
;
;   Handles :
;       - loading of background map
;       - scrolling
;       - new actors requests
;
;
; #############################################################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "utils.inc"
INCLUDE "levels.inc"

;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+


    SECTION "Levels_data", WRAM0

_levels_variables_start:
levels_flags::                       DS 1   ; %lrqxadrc
                                            ;  ||| |||+-- load the next block row request
                                            ;  ||| ||+--- row loader process is active
                                            ;  ||| |+---- row loader process is loading the second row
                                            ;  ||| |
                                            ;  ||| +----- actors loader process
                                            ;  |||
                                            ;  |||
                                            ;  |||
                                            ;  ||+---- querry : querry to load a level
                                            ;  |+----- running : the current level is running
                                            ;  +------ loaded : the current level is loaded
levels_querry::                     DS 1    ; ID of the querried level to load

levels_current_level::              DS 1    ; the current level index
levels_current_scrollY_speed::      DS 1    ; scrolling speed (%ppppssss)
                                            ;           pixel---++++||||
                                            ;             sub-------++++

levels_current_scrollY_position:    DS 3    ; 3 bytes current scroll HH hh %ppppssss

levels_current_tileset:             DS 1    ; id of tileset to use

;       Block and row encoding
levels_current_block_table:         DS 2    ; addr of the block table to use
levels_current_row_table:           DS 2    ; addr of the row table to use

;       Pointers to tilemap
levels_vram_tmap_location:          DS 1    ; $9XX0 : XX = part of vram addr to fill tilemap -> XX range from $00 to $BE

;       Level data
levels_data_pointer:                DS 2    ; addr in the current data structure

;       Row loading related stuff
levels_row_to_load_addr:            DS 2    ; the addr of the row currently beeing loaded

;       Actors loading related stuff
levels_actors_tmp_addr:             DS 2    ; the currently examined actor structure
levels_actors_tmp_stack_push_size:  DS 1    ; the current size of the stack push for request

;       Level flow control data
levels_control_counter:             DS 1    ; level flow control counter
levels_control_saved_return_addr:   DS 2    ; level flow control return addr

levels_target_scrollY_speed:        DS 1    ; the target scrolling speed

_levels_variables_end:





;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Levels_code", ROM0

Levels_init::
    ld hl, levels_flags                     ; reset all levels flags
    ld [hl], $00
    ld hl, levels_current_tileset
    ld [hl], $FF                            ; set current tileset to"none"
    ld hl, video_vram_push_status
    ld [hl], BG_ROW_WIDTH*2                 ; size of row push to display
    ld hl, levels_current_scrollY_position  ; initial scrolling values
    ld a, $00
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ret


; ------------------
; Levels_update()
;   If the current level is not loaded
;       - init load of a new level if requested
;
;   Do needed actions :
;       - scrolls the background
;       - init load of new row
;       - request new actors if needed
; ------------------
Levels_update::
    ld hl, levels_flags
    bit LF_BN_LOADED, [hl]                  ; check loaded flag
    jr z, Levels_load
    bit LF_BN_RUNNING, [hl]                 ; check running flag
    ret z
    call Levels_load_row_routine            ; row load routine
    call Levels_load_actors_row_routine     ; actors load routine
    call Levels_load_data_routine           ; load next data_chunk (end with a row request)
        ; level scroll
    ld a, [levels_current_scrollY_speed]
    ld hl, levels_current_scrollY_position
    add a, [hl]
    ld [hl], a
    ld b, a
    inc hl
    ld a, $00
    jr nc, .no16pix_trigger
    push hl
    ld hl, levels_flags
    set LF_BN_BROW_REQUEST, [hl]                             ; set new row load trigger
    pop hl
    inc a
.no16pix_trigger
    add a, [hl]
    ld [hl], a
    ld c, a
    inc hl
    ld a, $00
    adc a, [hl]
    ld [hl], a
    ld a, b
    and a, %11110000
    ld b, a
    ld a, c
    and a, %00001111
    or a, b
    swap a
    cpl a
    inc a                                   ; 2's complement for actual screen scroll value
    ld [video_Yscroll_s], a

    ret

; --------------------------
; Levels request(b = request level index)
;   Set a level request
;   (flag and level index)
;   WARNING :
;       For the level to actually be loaded, the current level must be unloaded
; --------------------------
Levels_request::
    ld hl, levels_flags
    set 5, [hl]                             ; set querry flag
    ld hl, levels_querry
    ld [hl], b
    ret



; ------------------
; Levels_load()
;   Check load flag
;   If load flag is set
;       - Load level in [levels_querry]
;       - Load tileset
;       - Init tilemap
;       - Load music
; ------------------
Levels_load:
;     ld hl, levels_flags       (already in hl)
    bit LF_BN_QUERRY, [hl]                  ; check querry flag
    ret z
    ld a, [levels_querry]
    ld [levels_current_level], a            ; set current level index
    sla a
    sla a
    sla a                                   ; 8 bytes struct index shift
    add a, LOW(LV_infos)
    ld l, a
    ld a, $00
    adc a, HIGH(LV_infos)
    ld h, a                                 ; hl <- requested level infos addr
        ; ------- tileset -------
    ld a, [hl+]
    ld b, a
    ld a, [levels_current_tileset]
    cp a, b
    jr z, .tileset_already_loaded
        ; new tileset load
        ld a, b
        ld [levels_current_tileset], a
        push hl
        call Levels_load_tileset
        pop hl
.tileset_already_loaded
        ; ------- scroll speed -------
    ld a, [hl+]
    ld bc, levels_current_scrollY_speed
    ld [bc], a
        ; ------- level data -------
    ld de, levels_data_pointer
    ld a, [hl+]
    ld [de], a                              ; low of level data pointer
    inc de
    ld a, [hl+]
    ld [de], a                              ; high of level data pointer
        ; ------- blocks and rows -------
    ld a, [hl+]
    sla a
    sla a                                   ; 4 bytes indexed structure shift
    push hl
    add a, LOW(LV_block_row_infos)
    ld l, a
    ld a, $00
    adc a, HIGH(LV_block_row_infos)
    ld h, a
    ld de, levels_current_block_table
    ld a, [hl+]
    ld [de], a                              ; current block table low
    inc de
    ld a, [hl+]
    ld [de], a                              ; current block rable high
    ld de, levels_current_row_table
    ld a, [hl+]
    ld [de], a                              ; current row table low
    inc de
    ld a, [hl]
    ld [de], a                              ; current row table high
    pop hl
        ; ------- Pre loading -------
    ld a, [hl+]
    sla a
    ld e, a
    push hl
        ; goes back "e" rows in the write addr from the current scroll y value
    ld hl, levels_current_scrollY_position
    ld a, [hl+]
    and a, %11110000
    ld b, a
    ld a, [hl]
    and a, %00001111
    or a, b
    swap a
    cpl a                                   ; 2's complement to get register value
    inc a                                   ; a <- current scroll register value
    srl a
    srl a
    res 0, a
    add a, $80
    add a, e
    cp a, $BE
    jr c, .no_correction
    jr z, .no_correction
    sub a, $40
.no_correction
    ld [levels_vram_tmap_location], a
    pop hl
    ld a, [hl+]
    ld d, a
    push hl
.loop
        ; iterate the fill routine
    push de
    ld hl, levels_flags
    set 0, [hl]
    call Levels_load_data_routine
    call Levels_load_row_routine
    call wait_vbl
    call Levels_load_row_routine
    call wait_vbl
    pop de
    dec d
    jr nz, .loop
    pop hl
        ; ------- Level song -------
    ld a, [hl+]
    call Audio_stop_song
    call Audio_load_song_at_index
    call Audio_start_song
        ; ------- Flags setting -------
    ld hl, levels_flags
    ; TODO
    set 7, [hl]                             ; level loaded flag
    set 6, [hl]                             ; level running flag (WILL BE REMOVED)
    ret



; ----------------------------
; Levels_load_data_routine()
;   Load a new chunk of data
;   That is : read level controls until a new row request is read
;
;   Check loader process flag
;       if zero -> return
;       else -> read current control
;-----------------------------
;TODO pit for testing
_ld_blktable_control:
_ld_rowtable_control:
_ld_actortable_control:
_sound_control:
            jr Levels_load_data_routine.next_read
;TODO
Levels_load_data_routine:
    ld a, [levels_flags]
    bit LF_BN_BROW_REQUEST, a               ; loader process request flag
    ret z
        ; READER engaged
    res LF_BN_BROW_REQUEST, a               ; reset request flag
    set LF_BN_ROW_LOAD, a                   ; set row loader active process flag
    res LF_BN_ROW_LOAD_HALF, a              ; reset upper row flag
    set LF_BN_ACT_LOAD, a                   ; set actors load process
    ld [levels_flags], a                    ; write flags
    ld hl, levels_data_pointer
    ld a, [hl+]
    ld h, [hl]
    ld l, a                                 ; hl <- pointer to level data
.next_read
    ld a, [hl+]
    bit 7, a
    jr z, .row_instruction_handle
        ; here :
        ;   a = level control instruction
        ;   hl = current data pointer
        cp a, %10000001
        jr z, _ld_blktable_control
        cp a, %10000010
        jr z, _ld_rowtable_control
        cp a, %10000011
        jr z, _ld_actortable_control
;         and a, %00001000
        bit 3, a
        jr nz, _sound_control
;         and a, %00010000
        bit 4, a
        jr nz, _level_control
        ; TODO : handle control values
.row_instruction_handle
        ; here :
        ;   a = instruction
        ;   hl = current data pointer
    ; the instruction in a is a row instruction (last instruction to process before return handle)
        ; stores data pointer back
    ld b, a
    ld a, l
    ld [levels_data_pointer], a
    ld a, h
    ld [levels_data_pointer+1], a

        ; find addr of row to load
    ld a, b
    swap a
    ld b, a
    and a, %11110000
    ld hl, levels_current_row_table
    add a, [hl]
    inc hl
    ld e, a
    ld a, $00
    adc a, b
    and a, %00001111
    add a, [hl]
    ld d, a                                 ; de <- addr of row to load
    ld hl, levels_row_to_load_addr
    ld [hl], e
    inc hl
    ld [hl], d                              ; set addr of row to load into levels_row_to_load_addr
    ret

    ;----------------------------
    ; control routines
    ;   Each of them has parameters :
    ;       a : current instruction
    ;       hl : current data pointer
    ;   And must end with a jump to Levels_load_data_routine.next_read
    ;       with hl set as a pointer to the next data
    ;----------------------------
    _level_control:
        cp a, %10010000
        jr z, .data_end
        cp a, %10010001
        jr z, .pointer_save
        cp a, %10010010
        jr z, .counter_set
        cp a, %10010101
        jr z, .dec_nz_jump
        cp a, %10011000
        jr z, .scroll_speed_set
        jr Levels_load_data_routine.next_read      ; Unknown instruction -> ignore
    .scroll_speed_set
            ld a, [hl+]
            ld [levels_target_scrollY_speed], a
            jr Levels_load_data_routine.next_read
    .data_end
            ld a, [levels_flags]
            res LF_BN_RUNNING, a
            ld [levels_flags], a
            jr Levels_load_data_routine.next_read
    .pointer_save
            ld a, l
            ld [levels_control_saved_return_addr], a
            ld a, h
            ld [levels_control_saved_return_addr+1], a
            jr Levels_load_data_routine.next_read
    .counter_set
            ld a, [hl+]
            ld [levels_control_counter], a
            jr Levels_load_data_routine.next_read
    .dec_nz_jump
            push hl
            ld hl, levels_control_counter
            dec [hl]
            jr z, .ignore_jump
                ld a, [levels_control_saved_return_addr]
                ld c, a
                ld a, [levels_control_saved_return_addr+1]
                ld b, a
                pop hl
                push bc
        .ignore_jump
            pop hl
            jp Levels_load_data_routine.next_read


; ---------------------------
; Levels_load_row_routine()
;   Load a new row in tilemap
;       Only if bit 1 of flags (row loader process active) is set
;   A call either loads the lower 8 pixel row
;   (if bit 2 of levels_flags is not set)
;   Or the upper 8 pixels row
;   (if bit 2 of levels_flags is set)
;       2 actions :
;           - _lower : load lower row if bit 1 is set but not bit 2 then return
;           - _upper : load upper row if bit 1 is set and bit 2 is set then return
; ---------------------------
Levels_load_row_routine:
    ld a, [levels_flags]
._lower
    bit LF_BN_ROW_LOAD, a                   ; loader process active flag
    ret z
    bit LF_BN_ROW_LOAD_HALF, a              ; loader process upper flag
    jr nz, ._upper
        ; LOWER LOAD
    set LF_BN_ROW_LOAD_HALF, a              ; set process upper flag
    ld [levels_flags], a
    ld e, $02                               ; set tile offset in block
    jr ._blocks_copy
._upper
        ; UPPER LOAD
    res LF_BN_ROW_LOAD, a                   ; loader process reset flag
    ld [levels_flags], a
    ld e, $00
;     jr ._blocks_copy
; -------------
; copy a half row of blocks
; e = offset in block structure
._blocks_copy
    ld hl, levels_row_to_load_addr
    ld a, [hl+]
    ld h, [hl]
    ld l, a                                 ; hl <- addr of row to load
    ld a, [levels_current_block_table]
    ld c, a
    ld a, [levels_current_block_table+1]
    ld b, a                                 ; bc <- base addr of block table
    ld d, BG_ROW_WIDTH
.loop
    ld a, [hl+]
    push hl
    ld h, $00                               ; add current block index << 2+ offset to current block table addr
    sla a
    rl h
    sla a
    rl h
    add a, e
    add a, c
    ld l, a
    ld a, b
    adc a, h
    ld h, a                                 ; hl <- addr of tile index inside block
        ; copy into buffer
    push bc
    ld b, HIGH(video_vram_push_buffer)
    ld a, LOW(video_vram_push_buffer) + BG_ROW_WIDTH*2    ; If value is not 8 bit -> change alignement of buffer
    sub a, d
    sub a, d
    ld c, a
    ld a, [hl+]
    add a, $80                          ; TODO WARNING patch for now but watch for tile alignement
    ld [bc], a
    ld a, [hl]
    add a, $80                          ; TODO WARNING patch for now but watch for tile alignement
    inc bc
    ld [bc], a
    pop bc
    pop hl
    dec d
    jr nz, .loop
    ; set destination addr for vram push
    ld a, [levels_vram_tmap_location]
    ld d, a
    sub a, $02
    cp a, $80
    jr nc, .skip_correction
    ld a, $BE
.skip_correction
    ld [levels_vram_tmap_location], a
    swap d
    ld a, d
    and a, %11110000
    ld e, a
    ld a, %00001111
    and a, d
    or a, $90
    ld d, a                                     ;de <- vram tilemat dest addr
    ld hl, video_vram_push_status
    set LF_BN_LOADED, [hl]
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ret


; --------------------------
; Levels_load_actors_row_routine(hl = addr of the $FF terminated actors row structure)
;   IF the actors loader process flag is set :
;       Compute current row addr structure
;       Call all the actor request routines described in the actor row structure
;       until it finds the $FF terminal
;       Reset the actor loading process flag
; --------------------------
Levels_load_actors_row_routine:
    ld a, [levels_flags]
    bit LF_BN_ACT_LOAD, a
    ret z                                   ; no active process, return
        ; process flag activated
    res LF_BN_ACT_LOAD, a                   ; reset process flag
    ld [levels_flags], a
    ld a, [levels_row_to_load_addr]
    add a, BG_ROW_ACTOR_POINTER_OFFSET
    ld l, a
    ld a, [levels_row_to_load_addr+1]
    adc a, $00
    ld h, a                                 ; hl is the addr of the actors row pointer
    ld a, [hl+]
    ld h, [hl]
    ld l, a                                 ; hl is the addr of the actors row
.loop
    ld a, [hl+]                             ; stack push size for next actor
    cp a, $FF
    ret z                                   ; $FF terminal byte -> exit
    ld [levels_actors_tmp_stack_push_size],a; save stack push size
    ld e, a
    or a, a
    jr z, .register_set_frame               ; stack of size 0 (don't push anything)
.stack_set_frame                            ; loop on stack push size to push parameters
        ld a, [hl+]
        ld b, a
        ld a, [hl+]
        ld c, a
        push bc
        dec e
        jr nz, .stack_set_frame
.register_set_frame
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a                                 ; load all 4 registers
    ld a, l
    ld [levels_actors_tmp_addr], a          ; save low hl
    ld a, h
    ld [levels_actors_tmp_addr+1], a        ; save high hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a                                 ; hl <- actor request function
        CALL_HL                             ; actor request
    ld a, [levels_actors_tmp_stack_push_size]
    rl a
    ld hl, sp+0
    add a, l
    ld l, a
    ld a, $00
    adc a, h
    ld h, a                                 ; poped all stack parameters
    ld sp, hl
        ; retrieve hl + (function addr size)
    ld a, [levels_actors_tmp_addr]
    add a, $02
    ld l, a
    ld a, [levels_actors_tmp_addr+1]
    adc a, $00
    ld h, a
    jr .loop


; ----------------------
; Levels_load_tileset()
;   Load tileset specified in [levels_current_tileset]
;   into vram
; ----------------------
Levels_load_tileset:
    ld a, [levels_current_tileset]
    sla a
    sla a
    sla a                                   ; 8 bytes struct index shift
    add a, LOW(LV_tileset_infos)
    ld l, a
    ld a, $00
    adc a, HIGH(LV_tileset_infos)
    ld h, a                                 ; hl <- requested tileset infos addr
    ld a, [hl+]
    ld e, a                                 ; src addr low
    ld a, [hl+]
    ld d, a                                 ; src addr high
    push de
    ld a, [hl+]
    ld e, a                                 ; dst addr low
    ld a, [hl+]
    ld d, a                                 ; dst addr high
    ld a, [hl+]
    ld c, a                                 ; size low
    ld b, [hl]                              ; size high
    pop hl                                  ; hl <- src addr
    call vram_copy
    ret
