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

    ;---------dynamic volume dedicated variables--------
CH_VOL_state                RB 1    ; dynamic volume state flag %bbbbbbwa
;                                                                      ||-> active : when set current volume will be modified
;                                                                      |-> wait state : when set dynamic volume automaton is on wait
CH_VOL_wait_counter         RB 1    ; counter wait before next dynamic volume update
CH_VOL_base_volume          RB 1    ; base volume of the channel when a note is triggered
CH_VOL_modifier_index       RB 1    ; index to modifier
CH_VOL_modifiers_table      RB 2    ; pointer to the modifiers table
    ;---------------------------------------------------
SIZEOF_instrument_struct    RB 0

    ENDC ;INSTRUMENT_INC