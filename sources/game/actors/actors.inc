; #############################
; Actors shared pointers and defines
;
;   All actors implementations
;   have access to the actors tables
; #############################

INCLUDE "sprites.inc"
INCLUDE "player_shots.inc"

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
.loop\@
    bit 7, [hl]
    jr z, .success\@
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
    jr nz, .loop\@
    dec b                   ; ensure flag z is not set
.success\@
ENDM

;--------------------------------
; ACTOR_PLAYER_COLLISION_SQUARE(X, Y, XW, YH, .no_collision)
;   Check if the current actor and the player
;   have collided (square bounding box arround actor (X, Y) of width XW and height YH)
;       Checks pixel positions
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

;--------------------------------
; ACTOR_PLAYER_SHOT_COLLISION_SQUARE(XW, YH, .collision, .no_collision)
;       bc should be set to actors' sprite base address
;
;   Check if the current actor bounding box is in collision with one of the player shots
;   If so, set the collide flag for the collided shot and jumps to '.collision'
;   Else, jumps to '.no_collision'
;   The check routine iterates all player shots
;       For each shot, the methodology is as follow :
;           Shot position - Actor position + box - (2*box + 1)
;           if there is a carry then collision
;
;   [a, hl, de, b<- the actor's Y pixel position, c<- the actor's X pixel position]
;--------------------------------
MACRO ACTOR_PLAYER_SHOT_COLLISION_SQUARE
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
    ld d, a                                 ; d <- actor pixel Y position
    ld a, [hl+]
    and a, %11110000
    ld e, a
    ld a, [hl]
    and a, %00001111
    or a, e
    swap a
    ld c, a                                 ; c <- actor pixel X position
    ld b, d                                 ; b <- actor pixel Y position

        ; test against all player shots
    ld hl, ps_status                        ; status table
    ld d, 0                                 ; index count
    ld e, PS_MAX_SHOTS                      ; loop indicator
.loop\@
    bit 7, [hl]                             ; is current shot active ?
    jr nz, .test_shot\@
    inc hl
    inc d
    dec e
    jr nz, .loop\@
    jr \4                                   ; end -> jump to .no_collision
.test_shot\@
        push hl                             ; saves current shot status
        ld h, HIGH(ps_Xposs)
        ld a, LOW(ps_Xposs)
        add a, d
        ld l, a
        ld a, [hl]                          ; a <- current shot X pos
        sub a, c                        ; (- Actor X pos)
        add a, \1                       ; (+ Actor X bounding width)
        sub a, (2*\1 +1)                ; (- (2* Actor X bound width + 1))
        jr nc, .abort_this_collision\@  ; no carry ? -> no X collision

        ld h, HIGH(ps_Yposs)
        ld a, LOW(ps_Yposs)
        add a, d
        ld l, a
        ld a, [hl]                          ; a <- current shot Y pos
        sub a, b                        ; (- Actor Y pos)
        add a, \2                       ; (+ Actor Y bounding height)
        sub a, (2*\2 +1)                ; (- (2* Actor Y bound height + 1))
        jr nc, .abort_this_collision\@  ; no carry ? -> no Y collision

        ; collision found, set player shot collide flag
        pop hl
        set 5, [hl]
        jr \3                               ; found collision -> jump to .collision
.abort_this_collision\@
    pop hl
    inc hl                                  ; next ps_status
    inc d                                   ; next index
    dec e
    jr nz, .loop\@
    jr \4                                   ; end -> jump to .no_collision
ENDM


;----------------------------------------------------------------------
;               ACTORS FUNCTIONS TEMPLATE
;----------------------------------------------------------------------

; Each implemented actor MUST provide at leat TWO functions
;
; ACTOR_request:
;   Should take parameters trough bc, de and stack (hl SHOULD NOT be used to pass parameters)
;   This is the method to call for the creation of a new actor of this type

; ACTOR_handle:
;   Should take as parameters :
;       bc : the actors' sprite base address
;       de : the actors' data base address
;   This method is automatically called by the actor dispatcher


    ENDC ; ACTORS_inc
