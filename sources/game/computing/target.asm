; ###############################
; Target
;
;   This file provide the basic code and routines
;   for the calculation and request of a displacement vector
;   targetting a specific position
;
;   A "grid-computing" is applied with a static speed vector
;   pre-computed in the LUT for each section of the grid
;
;
;   Example :
;
;
;           |       |       |       |
;           |       |       |       |
;           |       |       |       |
;   --------+-------+-------+-------+-------
;           |       |       |       |
;           |       |       |       |
;           |       |       |       |
;   --------+-------+-------+-------+-------
;           |       |       |       |
;           |       |Source |       |
;           |       |       |       |
;   --------+-------+-------+-------+-------
;           |       |       |       |
;           |       |       |       | Target
;           |       |       |       |
;   --------+-------+-------+-------+-------
;           |       |       |       |
;           |       |       |       |
;           |       |       |       |
;
;   By computing the position of the Traget
;   in the grid relative to the Source we can
;   associate a normalized speed vector
;
;   Grid is mirrored arround the Source :
;       The offset computation is T - S
;       if there is a carry then the used vector is mirrored
;
;   Stored vector values are 8bit and are converted into 16bit on the fly
;   Multiple vectors norms are stored as offsets in the tables
;
;
;   Grid arround the Source is 19 * 19, this means we want to store a
;   10 * 10 grid in memory
;   Since every entry is 2 bytes long we need to store two tables
;   This aligns in table with : %xxxxyyyy
;       where xxxx is the x part of P-E and yyyy is the y part of P-E
; ###############################

;+------------------------------------------------------------------------+
;| +--------------------------------------------------------------------+ |
;| |                     RAM                                            | |
;| +--------------------------------------------------------------------+ |
;+------------------------------------------------------------------------+

    SECTION "Target_variables", WRAM0

t_work_flags:  DS 1 ; byte of work flags
;       %??????wh
;              |+-> Height (Y) carry when computing T-S offset
;              |
;              +----> Width (X) carry when computing T-S offset



;+------------------------------------------------------------------------+
;| +--------------------------------------------------------------------+ |
;| |                     ROM                                            | |
;| +--------------------------------------------------------------------+ |
;+------------------------------------------------------------------------+

    SECTION "Target_player_code", ROMX

; ----------------------------------------------
; Target_get_displacement_vector(b = XStartPos, c = YStartPos,
;       d = XTargetPos, e = YTargetPos, a = speed)
;
;   -> bc = X_displacement_vector (16 bits)
;      de = Y_displacement_vector (16 bits)
;   -> flags : z set if null vector as an output
;
;   Request the displacement vector from 8 bit position bc
;   to 8 bit position de
;   Speed can range from 0 to 3 (2 bits)
; ----------------------------------------------
; TODO test
Target_get_displacement_vector::
        ; truncate positions to 4 strong bits
    push af

    ld a, b
    and a, %11110000
    swap a
    ld b, a

    ld a, c
    and a, %11110000
    swap a
    ld c, a

        ; compute offsets (%xxxxyyyy table entry)
    ld hl, t_work_flags
        ; X offset
    ld a, d
    and a, %11110000
    swap a
    sub a, b
    res 1, [hl]
    jr nc, .noCarryCorrectionX
        set 1, [hl]     ; mark carry for X (inverted table)
        cpl a
        inc a           ; positive table offset
.noCarryCorrectionX
    swap a
    ld b, a             ; %xxxx???? set

    pop af
    ld d, a             ; stores speed in d

    ld a, e
    and a, %11110000
    swap a
    sub a, c
    res 0, [hl]
    jr nc, .noCarryCorrectionY
        set 0, [hl]     ; mark carry for Y (inverted table)
        cpl a
        inc a           ; positive table offset
.noCarryCorrectionY
    or a, b             ; %xxxx???? set
    and a, %11111111
    ret z               ; offset is zero : return with z flag set

        ; find displacement vector values according to offset and speed
    ld l, a
    ld a, d             ; speed
    and a, %00000011
    ld d, a
    add a, HIGH(Target_vectors_X_lut)
    ld h, a
    ld c, [hl]

    ld a, d
    add a, HIGH(Target_vectors_Y_lut)
    ld h, a
    ld b, [hl]

        ; compute output vector values (correct values if mirroring)
    ld hl, t_work_flags
    ld d, $00
    ld e, b
    ld b, d
    bit 0, [hl]
    jr z, .noYMirror
        ld a, e
        cpl a
        inc a
        dec d
        ld e, a
.noYMirror
    bit 1, [hl]
    jr z, .noXMirror
        ld a, c
        cpl a
        inc a
        dec b
        ld c, a
.noXMirror
    xor a
    dec a               ; set nz flag
    ret




    SECTION "Target_luts", ROMX, ALIGN[8]

MACRO initCosTableMacro
    FOR X, 16
        FOR Y, 16
            DEF ANGLE = ATAN(DIV(Y,X))
            DEF COMPCOS = COS(ANGLE)
            DEF VAL = MUL(\1, COMPCOS)
            DB VAL
        ENDR
    ENDR
ENDM

MACRO initSinTableMacro
    FOR X, 16
        FOR Y, 16
            DEF ANGLE = ATAN(DIV(Y,X))
            DEF COMPSIN = SIN(ANGLE)
            DEF VAL = MUL(\1, COMPSIN)
            DB VAL
        ENDR
    ENDR
ENDM

; Defining of 4 tables each with increasing norm for increasing speed
; Norm should always be lesser than 127 (signed integer)

; Each value is 1 byte, indexed as %xxxxyyyy
Target_vectors_X_lut:    ; (8 aligned)
initCosTableMacro 6
initCosTableMacro 14
initCosTableMacro 22
initCosTableMacro 30

Target_vectors_Y_lut:    ; (8 aligned)
initSinTableMacro 6
initSinTableMacro 14
initSinTableMacro 22
initSinTableMacro 30
