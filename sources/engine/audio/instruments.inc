; -----------------------------------------
; Definition of values and structures
; for instruments hardware
; -----------------------------------------


    IF !DEF(INSTRUMENTS_INC)
DEF INSTRUMENTS_INC EQU 1

def BLANK_NOTE = %01011111

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          STRUCTURES                                     | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+
; instrument structure

;-------------------
RSRESET
DEF CH_flags                    RB 1    ; channel flags %SHbbbyxa
;                                                    ||   |||-> new note set
;                                                    ||   ||-> new volume set
;                                                    ||   |-> new instrument set
;                                                    ||
;                                                    ||-> Handle taken (while this bit is set, no hardware update will occur)
;                                                    |-> Global state changed (needs a hardware update ?)
DEF CH_note_value               RB 1    ; channel note to play
DEF CH_curr_instrument_index    RB 1
DEF CH_hardware_registers       RB 5    ; 5 saved register NRX0 - NRX1 - NRX2 - NRX3 - NRX4 to use as parameters for the note
DEF CH_curr_volume              RB 1    ; channel current volume

    ;---------dynamic volume dedicated variables--------
DEF CH_VOL_state                RB 1    ; dynamic volume state flag %bbbbbbwa
;                                                                      ||-> active : when set current volume will be modified
;                                                                      |-> wait state : when set dynamic volume automaton is on wait
DEF CH_VOL_wait_counter         RB 1    ; counter wait before next dynamic volume update
DEF CH_VOL_base_volume          RB 1    ; base volume of the channel when a note is triggered
DEF CH_VOL_modifier_index       RB 1    ; index to modifier
DEF CH_VOL_modifiers_table      RB 2    ; pointer to the modifiers table
    ;---------------------------------------------------
DEF SIZEOF_instrument_struct    RB 0

    ENDC ;INSTRUMENT_INC


; NOTES for instrument dynamic volume :
; Each instrument is associated with a dynamic volume update sequence after its 4 bytes of instrument declaration
; the instruction sequence is terminated with byte %1000000 (volume modifier is set to idle until next note)
;   instruments have a base current volume (on 4 bits)
;   volume modifier allows modification of played volume :
;   (played volume = base volume + 5bit signed modifier)
; the instruction are as follow :
; %10000000 -> sequence terminaison string
; %000xxxxx -> modifier value 5 bit modifier for volume (signed value)
; %01xxxxxx -> wait instruction : will wait xxxxxx update tick before next volume update
; (/!\ %01000001 is the smallest duration  %01000000 will actually wait for %111111 ticks)