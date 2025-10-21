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
level_querry::                      DS 1    ; ID of the querried level to load

levels_current_level::              DS 1    ; the current level
levels_current_scrollY_speed::      DS 1    ; scrolling speed (%ppppssss)
                                            ;           pixel---++++||||
                                            ;             sub-------++++
levels_current_scrollY_position:    DS 3    ; 3 bytes current scroll HH hh %ppppssss

levels_current_tileset:             DS 1    ; id of tileset to use

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
    ; TODO
    ld a, 17
    ld [video_Yscroll_s], a                 ; dummy scroll push
    ret



; ------------------
; Levels_load()
;   Check load flag
;   If load flag is set
;       - Load level in [level_querry]
;       - Load tileset
;       - Init tilemap
;       - Load music
; ------------------
Levels_load:
;     ld hl, levels_flags       (already in hl)
    bit 5, [hl]                             ; check querry flag
    ret z
    ; TODO
    ret
