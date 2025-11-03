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



;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                        RAM                                 | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+


    SECTION "Levels_data", WRAM0

_levels_variables_start:
levels_flags:                       DS 1    ; %lrqxxxxc
                                            ;  |||    +-- load the next block row in tilemap
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

_levels_variables_end:





;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Levels_code", ROMX

Levels_init::
    ld hl, levels_flags                     ; reset all levels flags
    ld [hl], $00
    ld hl, levels_current_tileset
    ld [hl], $FF                            ; set current tileset to"none"
    ld hl, video_vram_push_status
    ld [hl], 10                             ; size of row push to display
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
    bit 7, [hl]                             ; check loaded flag
    jr z, Levels_load
    bit 6, [hl]                             ; check running flag
    ret z
    bit 1, [hl]                             ; check new 
    ; TODO
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
    set 0, [hl]                             ; set new row load trigger
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
    bit 5, [hl]                             ; check querry flag
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
        inc hl
    ; TODO
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
