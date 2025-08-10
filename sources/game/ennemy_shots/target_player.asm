; ###############################
; Target Player
;
;   This file provide the basic code and routines
;   for the calculation and request of ennemy shots
;   targetted at the player
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
;           |       |   E   |       |
;           |       |       |       |
;   --------+-------+-------+-------+-------
;           |       |       |       |
;           |       |       |       | Player
;           |       |       |       |
;   --------+-------+-------+-------+-------
;           |       |       |       |
;           |       |       |       |
;           |       |       |       |
;
;   By computing the position of the Player
;   in the grid relative to the Ennemy we can
;   associate a normalized speed vector
;
;   Grid is mirrored arround the ennemy :
;       The offset computation is P - E
;       if there is a carry then the used vector is mirrored
;
;   Stored vector values are 8bit and are converted into 16bit on the fly
;   Stored vector are normalized to their greatest value and should be scaled accordingly
;   by arithmetical right shifts
;
;   Grid arround the ennemy is 19 * 19, this means we want to store a
;   10 * 10 grid in melory
;   Since every entry is 2 bytes long we need to store two tables
;   This aligns in table with : %xxxxyyyy
;       where xxxx is the x part of P-E and yyyy is the y part of P-E
; ###############################

;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                     RAM                  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

    SECTION "Target_player_variables", WRAM0

tp_work_flags:  DS 1 ; byte of work flags
;       %??????wh
;              |+-> Height (Y) carry when computing P-E offset
;              |
;              +----> Width (X) carry when computing P-E offset



;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |                     ROM                  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

    SECTION "Target_player_code", ROMX

; ----------------------------------------------
; TP_request_shot_toward_player(b = XStartPos, c = YStrartPos, d = speed)
;
;   Request a shot from position in bc
;   Targetted at the player position
;   Speed can range from 0 to 3 (2 bits)
; ----------------------------------------------
TP_request_shot_toward_player::
        ; set starting position
    push bc
    ld hl, es_request_Ypos
    ld e, c
    swap e
    ld a, e
    and a, %11110000
    ld [hl+], a
    ld a, e
    and a, %00001111
    ld [hl+], a         ; Now hl=es_request_Xpos
    ld e, b
    swap e
    ld a, e
    and a, %11110000
    ld [hl+], a
    ld a, e
    and a, %00001111
    ld [hl+], a
    pop bc              ; bc = starting pos

    ld a, b
    and a, %11110000
    swap a
    ld b, a
    ld a, c
    and a, %11110000
    swap a
    ld c, a

        ; compute offsets
    ld hl, tp_work_flags
    ld a, [player_pixel_Xpos]   ; compute X offset
    and a, %11110000
    swap a
    sub a, b
    res 1, [hl]
    jr nc, .noCarryCorrectionX
        set 1, [hl]     ; mark carry for X
        cpl a
        inc a           ; positive value of a
.noCarryCorrectionX
    swap a
    ld b, a

    ld a, [player_pixel_Ypos]   ; compute Y offset
    and a, %11110000
    swap a
    sub a, c
    res 0, [hl]
    jr nc, .noCarryCorrectionY
        set 0, [hl]     ; mark carry for Y
        cpl a
        inc a           ; positive value of a
.noCarryCorrectionY

        ; compute table addr
    or a, b             ; a should be %xxxxyyyy
    and a, %11111111
    ret z               ; don't request shot if offset is 0

        ; find X and Y vector values
        ; vector table according to speed
    ld l, a
    ld a, d
    and a, %00000011
    ld d, a
    ld a, HIGH(Target_player_vectors_X_lut)
    add a, d
    ld h, a
    ld b, [hl]
    ld a, HIGH(Target_player_vectors_Y_lut)
    add a, d
    ld h, a
    ld c, [hl]

        ; Correct vector mirroring if needed
    ld hl, tp_work_flags
    ld d, $00
    bit 1, [hl]
    jr z, .noXMirror
        ld a, b
        cpl a
        inc a
        ld b, a
        dec d
.noXMirror
    ld e, $00
    bit 0, [hl]
    jr z, .noYMirror
        ld a, c
        cpl a
        inc a
        ld c, a
        dec e
.noYMirror
    

        ; Set speed vector in memory
    ld hl, es_request_Yspeed
    ld a, c             ; Y speed
    ld [hl+], a
    ld a, e
    ld [hl+], a

    ld a, b             ; X speed
    ld [hl+], a
    ld a, d
    ld [hl], a

        ; Set request flag
    ld hl, es_request_status
    set 7, [hl]
    ret





    SECTION "Target_player_luts", ROMX, ALIGN[8]

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
Target_player_vectors_X_lut:    ; (8 aligned)
initCosTableMacro 6
initCosTableMacro 14
initCosTableMacro 22
initCosTableMacro 30

Target_player_vectors_Y_lut:    ; (8 aligned)
initSinTableMacro 6
initSinTableMacro 14
initSinTableMacro 22
initSinTableMacro 30
