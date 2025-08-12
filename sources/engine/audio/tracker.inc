; ------------------------------------------------------
; Definition of values and structures
; for audio patterns tracker
; ------------------------------------------------------


    IF!DEF(TRACKER_INC)
DEF TRACKER_INC EQU 1


; MAXIMUM RECURCIVE STACK SIZE
DEF ATRACKER_MAXIMUM_RECURSIVE_STACK_SIZE = 3

;+----------------------------------------------------------------------+
;| +------------------------------------------------------------------+ |
;| |                          STRUCTURES                              | |
;| +------------------------------------------------------------------+ |
;+----------------------------------------------------------------------+

;tracker éléments structure
;-----------
RSRESET
DEF block_Laddr             RB 1 ; Low byte of block addr
DEF block_Haddr             RB 1 ; High byte of block addr
DEF tracker_value           RB 1 ; current value of tracker on the 256 steps
DEF tracker_state           RB 1 ; current state of the tracker
DEF instrument_handler_addr RB 2 ; associated instrument handler addr (littel endian)
DEF delay_value             RB 1 ; current value of the default delay
DEF delay_counter           RB 1 ; current delay counter
DEF repeat_counter          RB 1 ; current value of the default repeat
DEF return_tracker_value    RB 1 ; current value of the return tracker (tracker to return to on instruction)
DEF stack_save              RB 2 ; SP of the current recursive stack (little endian)
DEF tracker_stack           RB 6*ATRACKER_MAXIMUM_RECURSIVE_STACK_SIZE ; recursive stack of the tracker
DEF tracker_stack_base      RB 0
DEF SIZEOF_tracker_struct   RB 0
;-----------


    ENDC ; TRACKER_INC
