; ##############################
; Common Utils MACROS
; ##############################

    IF !DEF(UTILS_INC)
DEF UTILS_INC EQU 1

;--------------------------------
;MEMBSET
;set byte of memory \1 to \2 using register a
; [a]
;--------------------------------
MACRO MEMBSET
    ld a, \2
    ld \1, a
ENDM

; ----------------------------------------
; INCREMENT_ADRESS_AT_HL_LITTLE_ENDIAN
; increment value of addr stored at hl
; $XXYY = $XXYY+1
; (stored as $YY $XX)
; [hl, f]
; ----------------------------------------
MACRO INCREMENT_ADRESS_AT_HL_LITTLE_ENDIAN
    inc [hl]
    jr nz, .end\@
    inc hl
    inc [hl]
.end\@
ENDM

; ----------------------------------------
; INCREMENT2_ADRESS_AT_HL_LITTLE_ENDIAN
; increment twice value of addr stored at hl
; $XXYY = $XXYY+2
; (stored as $YY $XX)
; [hl, f]
; ----------------------------------------
MACRO INCREMENT2_ADRESS_AT_HL_LITTLE_ENDIAN
    inc [hl]
    jr z, .halfwork\@
    inc [hl]
    jr nz, .end\@
    inc hl
    inc [hl]
    jr .end\@
.halfwork\@
    inc [hl]
    inc hl
    inc [hl]
.end\@
ENDM

; --------------------------------------
; DECREMENT2_ADRESS_AT_HL_LITTLE_ENDIAN
; decrement twice value of addr stored at hl
; $XXYY = $XXYY - 2
; (stored as $YY $XX)
; [hl, bc]
; ---------------------------------------
MACRO DECREMENT2_ADRESS_AT_HL_LITTLE_ENDIAN
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    dec bc
    dec bc
    ld [hl], c
    inc hl
    ld [hl], b
ENDM


ENDC