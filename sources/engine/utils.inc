; ##############################
; Common Utils MACROS
; ##############################

    IF !DEF(UTILS_INC)
UTILS_INC = 1

;--------------------------------
;MEMBSET
;set byte of memory \1 to \2 using register a
;--------------------------------
MACRO MEMBSET
    ld a, \2
    ld \1, a
ENDM


ENDC