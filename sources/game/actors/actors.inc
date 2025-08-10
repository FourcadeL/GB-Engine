; #############################
; Actors shared pointers and defines
;
;   All actors implementations
;   have access to the actors tables
; #############################

;   ---- DEFINES ----

DEF Actors_sprite_first_entry EQUS "Sprite_table + 2*8"
DEF Actors_displayList_first_entry EQUS "DisplayList_table + 2*2"
DEF Actors_rot_displaylist_entry EQUS "DisplayList_table + 2*2"

DEF ACTORS_NB EQU 16
DEF ACTORS_DATA_SIZE EQU 64

;   ---- EXPORTS ----

EXPORT Actors_data_table


;   ---- MACROS ----

;----------------------
; ACTOR_FIND_FREE
;   find the first free actor slot
;   if no free actors -> return
;   if free actor found -> continue with addr of free sprite in hl
;       and addr of free actor table slot in de
;   [a, hl, de]
;----------------------
MACRO ACTOR_FIND_FREE
    push bc
    ld hl, Actors_sprite_first_entry
    ld de, Actors_data_table
    ld b, ACTORS_NB
.loop
    bit 7, [hl]
    jr z, .success
    ld a, SPRITE_STRUCTURE_SIZE
    add a, l
    ld l, a
    ld a, ACTORS_DATA_SIZE
    add a, e
    ld e, a
    ld a, d
    adc a, $00
    ld d, a
    dec b
    jr nz, .loop
    pop bc
    ret
.success
    pop bc
ENDM
