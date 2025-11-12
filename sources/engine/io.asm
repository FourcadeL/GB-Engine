;#####################################
;definition io (se réferrer à engine.inc)
;io contient les fonctions d'input/output (en particulier les bouttons et le cable link quand implémenté)
;#####################################



    INCLUDE "hardware.inc"
    INCLUDE "engine.inc"


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                             FUNCTIONS                                   | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+



    SECTION "IO_Functions",ROM0


;--------------------------------------------
;- getInput()
;-  @PAD variables will contain read inputs
;--------------------------------------------


getInput::

    ld      a,[PAD_hold]
    ld      c,a             ; c <- old values

    ld      a,$10
    ld      [rP1], a        ; P14 (set KEYS in read mode)

    ld      a,[rP1]
    ld      a,[rP1]
    cpl                     ; (zero = pressed, invert bits)
    and     a,$0F           ; 4 bits mask
    swap    a
    ld      b,a
    ld      a,$20
    ld      [rP1], a        ; P15 (set DPAD in read mode)
    ld      a,[rP1]
    ld      a,[rP1]
    ld      a,[rP1]
    ld      a,[rP1]
    cpl
    and     a,$0F
    or      a,b             ; combine keys and dpad

    ld      [PAD_hold], a   ; save of held keys

    ld      b,a             ; b <- what is held at this frame
    ld      a,c             ; c is the old held value
    cpl     a
    and     a,b             ; keys pressed not held on previous frame

    ld      [PAD_pressed], a; save pressed keys

    and     $00             ; ld a, $00
    ld      [rP1],a         ; RESET read addr

    ret







;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+



    SECTION "IO_Variables",WRAM0

PAD_repeat_speed:   DS 1            ; repeat framerule speed
PAD_hold::          DS 1            ; keys holded this frame
PAD_pressed::       DS 1            ; keys pressed this frame
PAD_repeat::        DS 1            ; keys auto-repeated this frame
