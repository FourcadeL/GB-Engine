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
                                            ;  |||    +-- load the next tile row in tilemap
                                            ;  |||
                                            ;  ||+---- querry : querry to load a level
                                            ;  |+----- running : the current level is running
                                            ;  +------ loaded : the current level is loaded
levels_querry::                      DS 1    ; ID of the querried level to load

levels_current_level::              DS 1    ; the current level
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
    bit 6,  [hl]                            ; check running flag
    ret z
    ; TODO
    ld hl, video_Yscroll_s
    inc [hl]                                ; dummy scroll push
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
    sla a
    sla a
    sla a                                   ; 8 bytes struct index shift
    add a, LOW(LV_infos)
    ld l, a
    ld a, $00
    adc a, HIGH(LV_infos)
    ld h, a                                 ; hl <- requested level infos addr
        ; check tileset
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
    ; TODO
    ld hl, levels_flags
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
