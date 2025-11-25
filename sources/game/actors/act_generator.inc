; #########################


    IF !DEF(ACT_GENERATOR_INC)
DEF ACT_GENERATOR_INC EQU 1

; GENERATOR STATES :
;   WAITING
;   GENERATION
DEF WAIT_STATE                  EQU %00000001
DEF GEN_STATE                   EQU %00000010


;+----------------------------------------------------------------------+
;| +------------------------------------------------------------------+ |
;| |                          STRUCTURES                              | |
;| +------------------------------------------------------------------+ |
;+----------------------------------------------------------------------+

; generator data structure
RSRESET
DEF state                   RB 1 ; status byte
DEF timer_value             RB 1 ; timer reset value
DEF timer                   RB 1 ; timer left before next generation trigger
DEF counter                 RB 1 ; number of generation cycles left
DEF gen_register_b          RB 1 ; register parameter for gen_function_call
DEF gen_register_c          RB 1 ; register parameter for gen_function_call
DEF gen_register_d          RB 1 ; register parameter for gen_function_call
DEF gen_register_e          RB 1 ; register parameter for gen_function_call
DEF gen_function            RB 2 ; function to call at each generator trigger

DEF SIZEOF_generator_data   RB 0

STATIC_ASSERT SIZEOF_generator_data <= ACTORS_DATA_SIZE, "Data struct for generator is too large"


    ENDC ; ACT_GENERATOR_INC
