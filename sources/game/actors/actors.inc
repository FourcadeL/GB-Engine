; #############################
; Actors shared pointers and defines
;
;   All actors implementations
;   have access to the actors tables
; #############################

    IF!DEF(ACTORS_INC)
DEF ACTORS_INC EQU 1
;   ---- DEFINES ----

DEF Actors_sprite_first_entry EQUS "Sprite_table + 2*8"
DEF Actors_displayList_first_entry EQUS "DisplayList_table + 2*2"

DEF ACTORS_NB EQU 16
DEF ACTORS_DATA_SIZE EQU 64

;   ---- EXPORTS ----

EXPORT Actors_data_table


;   ---- MACROS ----

;----------------------
; ACTOR_FIND_FREE
;   find the first free actor slot
;   set hl to addr of free sprite
;   set de to addr of free actor table slot
;
;   if free actor found -> flag z is set as a return
;       else -> flag z is not set
;   [a, b, hl, de]
;----------------------
MACRO ACTOR_FIND_FREE
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
    dec b                   ; unsure flag z is not set
.success
ENDM

    ENDC ; ACTORS_inc
