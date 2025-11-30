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
;   set c to actor index
;
;   if free actor found -> flag z is set as a return
;       else -> flag z is not set
;   [a, bc, hl, de]
;----------------------
MACRO ACTOR_FIND_FREE
    ld hl, Actors_sprite_first_entry
    ld de, Actors_data_table
    ld b, ACTORS_NB
    ld c, 0
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
    inc c
    dec b
    jr nz, .loop
    dec b                   ; ensure flag z is not set
.success
ENDM

;--------------------------------
; ACTOR_PLAYER_COLLISION_SQUARE(X, Y, XW, YH, .no_collision)
;   Check if the current actor and the player
;   have collided (square bounding box arround actor (X, Y) of width XW and height YH)
;       Checks pixel posiitons
;   flag c is set if collision occured
;   [a, hl]
;--------------------------------
MACRO ACTOR_PLAYER_COLLISION_SQUARE
    ld hl, player_state
    bit 4, [hl]                             ; check if player is dying
    jr nz, \5
    ld hl, player_pixel_Xpos
    ld a, \1
    sub a, [hl]
    add a, Player_hitbox_width/2 + \3 /2
    cp a, Player_hitbox_width + \3
    jr nc, \5                               ; return no carry flag

    ld hl, player_pixel_Ypos
    ld a, \2
    sub a, [hl]
    add a, Player_hitbox_height/2 + \4 /2
    cp a, Player_hitbox_height + \4
    jr nc, \5
ENDM
    
    


    ENDC ; ACTORS_inc
