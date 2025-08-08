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
;- getInput() @PAD contient les inputs lus
;--------------------------------------------


getInput::

    ld      a,[PAD_hold]
    ld      c,a             ;c = anciennes valeurs

    ld      a,$10
    ld      [rP1], a        ;P14 (sélection des bouttons en lecture)

    ld      a,[rP1]
    ld      a,[rP1]
    cpl                     ; complément de a (zero = pressé, on inverse ça)
    and     a,$0F           ;4 premiers bits
    swap    a               ;les 4 bits lus deviennent ceux de poids fort
    ld      b,a
    ld      a,$20
    ld      [rP1], a        ;P15 (sélection du D_PAD en lecture)
    ld      a,[rP1]
    ld      a,[rP1]
    ld      a,[rP1]
    ld      a,[rP1]
    cpl
    and     a,$0F
    or      a,b             ;combinaison de ce qui a été lu auparavant avec ce que l'on vient de lire

    ld      [PAD_hold],a    ;sauvegarde de ce qui est maintenu à cette frame

    ld      b,a             ; b = ce qui est tenu à cette frame
    ld      a,c             ; c contient l'ancienne valeur de ce qui était tenu
    cpl                     ; a <- not a
    and     a,b             ; ce qui sont pressés sont ceux qui n'étaient pas pressés à la frame précédente et pressés à celle-ci

    ld      [PAD_pressed],a ;sauvegarde de ce qui vient d'être pressé

    and     $00             ; ld a, $00
    ld      [rP1],a         ;RESET de l'adresse de lecture

    ret







;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+



    SECTION "IO_Variables",WRAM0

PAD_hold::      DS 1
PAD_pressed::   DS 1
