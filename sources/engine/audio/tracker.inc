; ------------------------------------------------------
; Definition of values and structures
; for audio patterns tracker
; ------------------------------------------------------


    IF!DEF(TRACKER_INC)
TRACKER_INC = 1


; MAXIMUM RECURCIVE STACK SIZE
DEF ATRACKER_MAXIMUM_RECURSIVE_STACK_SIZE = 3

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          STRUCTURES                                     | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+
;tracker éléments structure
;-----------
RSRESET
block_Laddr             RB 1 ; Low byte of block addr
block_Haddr             RB 1 ; High byte of block addr
tracker_value           RB 1 ; current value of tracker on the 256 steps
tracker_state           RB 1 ; current state of the tracker
current_note            RB 1 ; currently playing note
delay_value             RB 1 ; current value of the default delay
delay_counter           RB 1 ; current delay counter
repeat_counter          RB 1 ; current value of the default repeat
return_tracker_value    RB 1 ; current value of the return tracker (tracker to return to on instruction)
stack_save              RB 2 ; SP of the current recursive stack (little endian)
tracker_stack           RB 6*ATRACKER_MAXIMUM_RECURSIVE_STACK_SIZE ; recursive stack of the tracker
tracker_stack_base      RB 0
SIZEOF_tracker_struct	RB 0
;-----------


    ENDC ;HARDWARE_INC