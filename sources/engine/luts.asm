

    INCLUDE "hardware.inc"

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                            SINE LUTS (look up tables)                   | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

    SECTION "SineLUT", ROM0, ALIGN[8]

Sine::
    DB $00,$03,$06,$09,$0c,$0f,$12,$15,$18,$1b,$1e,$21,$24,$27,$2a,$2d
    DB $30,$33,$36,$39,$3b,$3e,$41,$43,$46,$49,$4b,$4e,$50,$52,$55,$57
    DB $59,$5b,$5e,$60,$62,$64,$66,$67,$69,$6b,$6c,$6e,$70,$71,$72,$74
    DB $75,$76,$77,$78,$79,$7a,$7b,$7b,$7c,$7d,$7d,$7e,$7e,$7e,$7e,$7e
    DB $7f,$7e,$7e,$7e,$7e,$7e,$7d,$7d,$7c,$7b,$7b,$7a,$79,$78,$77,$76
    DB $75,$74,$72,$71,$70,$6e,$6c,$6b,$69,$67,$66,$64,$62,$60,$5e,$5b
    DB $59,$57,$55,$52,$50,$4e,$4b,$49,$46,$43,$41,$3e,$3b,$39,$36,$33
    DB $30,$2d,$2a,$27,$24,$21,$1e,$1b,$18,$15,$12,$0f,$0c,$09,$06,$03
    DB $00,$fd,$fa,$f7,$f4,$f1,$ee,$eb,$e8,$e5,$e2,$df,$dc,$d9,$d6,$d3
    DB $d0,$cd,$ca,$c7,$c5,$c2,$bf,$bd,$ba,$b7,$b5,$b2,$b0,$ae,$ab,$a9
    DB $a7,$a5,$a2,$a0,$9e,$9c,$9a,$99,$97,$95,$94,$92,$90,$8f,$8e,$8c
    DB $8b,$8a,$89,$88,$87,$86,$85,$85,$84,$83,$83,$82,$82,$82,$82,$82
    DB $81,$82,$82,$82,$82,$82,$83,$83,$84,$85,$85,$86,$87,$88,$89,$8a
    DB $8b,$8c,$8e,$8f,$90,$92,$94,$95,$97,$99,$9a,$9c,$9e,$a0,$a2,$a5
    DB $a7,$a9,$ab,$ae,$b0,$b2,$b5,$b7,$ba,$bd,$bf,$c2,$c5,$c7,$ca,$cd
    DB $d0,$d3,$d6,$d9,$dc,$df,$e2,$e5,$e8,$eb,$ee,$f1,$f4,$f7,$fa,$fd


;note, pour obtenir la valeur du sinus de a :
;ld     h, HIGH(Sine)
;ld     l, a
;ld     a, [hl]
