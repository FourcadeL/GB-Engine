; ###############################################
; Définition des différentes macros du moteur
; ###############################################


IF !DEF(MACROS_INC)
MACROS_INC = 1

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                            MACROs                                       | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


;permet d'additionner une valeur 16 bit à hl
MACRO ADD_U16_hl_val;hl <- hl + (value first arg)
    ld      a, l
    add     a, LOW(\1)
    ld      l, a
    ld      a, h
    adc     a, HIGH(\1)
    ld      h, a
ENDM

; permet un shift right sur une valeur 16 bit contenue dans ab
; ab <- ab(shift right 1)
MACRO SHIFTR_U16_ab
    srl     a
    rr      b
ENDM


;permet de récupérer a <- sin(a)
MACRO GET_SINE_A
    ld      h, HIGH(Sine)
    ld      l, a
    ld      a, [hl]
ENDM


;macro permettant d'appeler hl un peu plus rapidement
;(nécessite que le vecteur de restart à $0008 soit correctement mis en place)
MACRO CALL_HL
    rst     $08
ENDM



ENDC ; MACROS_INC