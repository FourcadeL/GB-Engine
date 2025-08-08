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

;-------------------------------
; ADD_U16_HL
; Adds a U16 to hl
; [a, hl]
;-------------------------------
MACRO ADD_U16_HL    ;hl <- hl + (value first arg)
    ld      a, l
    add     a, LOW(\1)
    ld      l, a
    ld      a, h
    adc     a, HIGH(\1)
    ld      h, a
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

;---------------------------------
; GET_SINE_A
; Get the sine value of a
; [a, hl]
;---------------------------------
MACRO GET_SINE_A
    ld      h, HIGH(Sine)
    ld      l, a
    ld      a, [hl]
ENDM

;--------------------------
; CALL_HL
; Quickly calls hl by leveraging restart vector  at $0008
;--------------------------
MACRO CALL_HL
    rst     $08
ENDM

ENDC
