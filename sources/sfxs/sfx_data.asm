; ---------------------------------------------------------------------
; This file defines the SFX lookup table and Register value tables
; only 32 differnt SFX lookups can be defined
; See notes for detail
;   Each data segment is as follows :
;       $xx, $xx, $xx, $xx, $xx : 5 bytes for register values NRx0, NRx1, NRx2, NRx3, NRx4
;       $cc : 1 control byte : delay before next register update (except for last segment)
;   Each data table is ended by $FF, $dd where $dd is the delay before giving back the handle for song playback
; ----------------------------------------------------------------------


    SECTION "SFX_lookup", ROMX, ALIGN[6]
sfx_lookup::
    DB LOW(sfx_data_0), HIGH(sfx_data_0)
    DB LOW(sfx_data_1), HIGH(sfx_data_1)
    DB LOW(sfx_data_2), HIGH(sfx_data_2)
    DB LOW(sfx_data_3), HIGH(sfx_data_3)
    DB LOW(sfx_data_4), HIGH(sfx_data_4)
    DB LOW(sfx_data_5), HIGH(sfx_data_5)
    DB LOW(sfx_data_6), HIGH(sfx_data_6)
    DB LOW(sfx_data_7), HIGH(sfx_data_7)
    DB LOW(sfx_data_8), HIGH(sfx_data_8)
    DB LOW(sfx_data_9), HIGH(sfx_data_9)
    DB LOW(sfx_data_10), HIGH(sfx_data_10)
    DB LOW(sfx_data_11), HIGH(sfx_data_11)
    DB LOW(sfx_data_12), HIGH(sfx_data_12)
    DB LOW(sfx_data_13), HIGH(sfx_data_13)
    DB LOW(sfx_data_14), HIGH(sfx_data_14)
    DB LOW(sfx_data_15), HIGH(sfx_data_15)
    DB LOW(sfx_data_16), HIGH(sfx_data_16)
    DB LOW(sfx_data_17), HIGH(sfx_data_17)
    DB LOW(sfx_data_18), HIGH(sfx_data_18)
    DB LOW(sfx_data_19), HIGH(sfx_data_19)
    DB LOW(sfx_data_20), HIGH(sfx_data_20)
    DB LOW(sfx_data_21), HIGH(sfx_data_21)
    DB LOW(sfx_data_22), HIGH(sfx_data_22)
    DB LOW(sfx_data_23), HIGH(sfx_data_23)
    DB LOW(sfx_data_24), HIGH(sfx_data_24)
    DB LOW(sfx_data_25), HIGH(sfx_data_25)
    DB LOW(sfx_data_26), HIGH(sfx_data_26)
    DB LOW(sfx_data_27), HIGH(sfx_data_27)
    DB LOW(sfx_data_28), HIGH(sfx_data_28)
    DB LOW(sfx_data_29), HIGH(sfx_data_29)
    DB LOW(sfx_data_30), HIGH(sfx_data_30)
    DB LOW(sfx_data_31), HIGH(sfx_data_31)


    SECTION "SFX_values_table", ROMX
sfx_data_0:
    ; nintendo logo sfx
    DB $00, $80, $F3, $83, $87, $03
    DB $00, $80, $F3, $C1, $87, $FF, $1F
sfx_data_1:
    DB %00100100, %11001000, $F4, $93, $83, $05
    DB %00100100, %11001000, $F4, $93, $84, $01
    DB %00100100, %11001000, $94, $93, $84, $FF, $10
sfx_data_2:
    DB %01011011, %01001000, $F2, $FF, $86, $02
    DB %01011011, %01001000, $F2, $FF, $87, $01
    DB %01011011, %01001000, $F2, $FF, $87, $FF, $10
sfx_data_3:
; shot sfx (ch1) work to do
    DB %00101110, %00011111, $61, $A0, $C7, $03
    DB %00011101, %00011011, $61, $A0, $C7, $FF, $04
sfx_data_4:
; blast sfx (ch4) work to do
    DB $00, $03, $93, %01111110, $C0, $02
    DB $00, $03, $93, %10011010, $C0, $FF, $05
sfx_data_5:
sfx_data_6:
    DB $00, $03, $93, %00011101, $C0, $FF, $05
sfx_data_7:
    DB $00, $03, $93, %11011100, $C0, $FF, $05
sfx_data_8:
    DB $00, $03, $93, %01011111, $C0, $FF, $05
sfx_data_9:
    DB $00, $03, $93, %10011010, $C0, $FF, $05
sfx_data_10:
    DB $00, $03, $93, %10011010, $C0, $FF, $05
sfx_data_11:
sfx_data_12:
sfx_data_13:
sfx_data_14:
sfx_data_15:
sfx_data_16:
sfx_data_17:
sfx_data_18:
sfx_data_19:
sfx_data_20:
sfx_data_21:
sfx_data_22:
sfx_data_23:
sfx_data_24:
sfx_data_25:
sfx_data_26:
sfx_data_27:
sfx_data_28:
sfx_data_29:
sfx_data_30:
sfx_data_31:
    DB $00, $00, $00, $00, $00, $FF, $00

