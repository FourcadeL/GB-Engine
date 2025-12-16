; ############################
; Generic actor generator
;
;   Will handle regular generation of a new type of actor
;   Then automatically destroy itself
; ############################


INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "utils.inc"
INCLUDE "sprites.inc"
INCLUDE "actors.inc"
INCLUDE "act_generator.inc"


;+----------------------------------------------------------------+
;| +------------------------------------------------------------+ |
;| |                           ROM                              | |
;| +------------------------------------------------------------+ |
;+----------------------------------------------------------------+

    SECTION "Act_generator_code", ROMX

;-------------------------------------------------------
; Act_generator_request (b = number of generation cycles
;                        c = generation timer
;                        de = generation function to call
;                       StackPush : values of b c d e to pass at generation function call
;                           $BBCC
;                           $DDEE)
;--------------------------------------------------------
Act_generator_request::
    push de
    push bc
    ACTOR_FIND_FREE
    jr nz, .abort                               ; no free actor slot ?
        ; hl = sprite slot addr
        ; de = data struct for actor addr
    ; mark actor sprite as used but not displayed
    ld a, %10000000                             ; 7 = active | 0 = not displayed
    ld [hl+], a
    inc hl                                      ; keep display fields blank
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, LOW(Act_generator_handle)             ; set sprite handle function
    ld [hl+], a
    ld [hl], HIGH(Act_generator_handle)


    ; now initilize data values
        ; IN STRUCT ORDER
    ld a, state
    add a, e
    ld h, d
    ld l, e
    ld [hl], GEN_STATE                          ; start in generation state
    inc hl
    pop bc
    ld a, c
    ld [hl+], a                                 ; set generation timer value
    inc hl
    ld a, b
    ld [hl+], a                                 ; set generation counter
    push hl
    ld hl, sp+9
        ; retrieve pushed values
        ld a, [hl-]
        ld b, a
        ld a, [hl-]
        ld c, a
        ld a, [hl-]
        ld d, a
        ld a, [hl]
        ld e, a
    pop hl
    ld [hl], b
    inc hl
    ld [hl], c
    inc hl
    ld [hl], d
    inc hl
    ld [hl], e
    inc hl
    pop de
    ld [hl], e
    inc hl
    ld [hl], d

    ret
.abort
    pop de
    pop bc



;-------------------------------------------------------
; Act_generator_handle(bc = sprite addr, de = actor data addr)
;   handle sprite action
;
;       1 - if wait decrement counter and trigger generation state
;       2 - if generation state decrement counter and generate
;--------------------------------------------------------
Act_generator_handle:
;     ld a, state
;     add a, e
;     ld l, e
;     ld h, d
    ld a, [de]                              ; state is the first data on segment
    cp a, WAIT_STATE
    jr z, wait_handle
;     cp a, GEN_STATE
;     jr z, generate_handle

;-------------------------------------------
; generate_handle(bc = sprite addr, de = actor data addr)
;   reset state to wait
;   reset timer
;   decrement counter
;       if counter is zero destroys itself
;   call function in [gen_function]
;-------------------------------------------
generate_handle:
;     ld a, state
;     add a, e
    ld h, d
    ld l, e
    ld [hl], WAIT_STATE                     ; set state
    inc hl
    ld a, [hl+]                             ; fetch timer value
    ld [hl+], a                             ; set timer value
    dec [hl]                                ; decrement counter
    push hl
    call z, destroy_generator
    pop hl

        ; call generate function with parameters
    inc hl
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    push bc

    ld a, [hl+]
    ld c, a
    ld b, [hl]
    push bc
    pop hl
    pop bc

    jp hl                                   ; call to generation function


;-------------------------------------------
; wait_handle(bc = sprite addr, de = actor data addr)
;   decrement timer
;   set state to generate if timer is exceded
;-------------------------------------------
wait_handle:
    ld a, timer
    add a, e
    ld h, d
    ld l, a
    dec [hl]
    ret nz                                  ; timer not triggered

    ld a, state
    add a, e
    ld l, a
    ld a, GEN_STATE
    ld [hl], a
    ret


;---------------------------------------
; destroy_generator(bc = sprite addr, de = actor data addr)
;   reset active sprite bit
;---------------------------------------
destroy_generator:
    ld h, b
    ld l, c
    res 7, [hl]
    ret
