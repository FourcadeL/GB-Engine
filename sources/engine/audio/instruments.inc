; -----------------------------------------
; Definition of values and structures
; for instruments hardware
; -----------------------------------------


    IF !DEF(INSTRUMENTS_INC)
INSTRUMENTS_INC = 1

def BLANK_NOTE = %01011111

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          STRUCTURES                                     | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+
; instrument structure

;-------------------
RSRESET
CH_flags                    RB 1    ; channel flags %Sbbbbyxa
;                                                    |    |||-> new note set
;                                                    |    ||-> new volume set
;                                                    |    |-> new instrument set
;                                                    |-> Global state changed (needs a hardware update ?)
CH_note_value               RB 1    ; channel note to play
CH_curr_instrument_index    RB 1
CH_hardware_registers       RB 5    ; 5 saved register NRX0 - NRX1 - NRX2 - NRX3 - NRX4 to use as parameters for the note
CH_curr_volume              RB 1    ; channel current volume

SIZEOF_instrument_struct    RB 0

    ENDC ;INSTRUMENT_INC