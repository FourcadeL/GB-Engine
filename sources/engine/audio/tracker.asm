; ###################
; Audio Tracker
; Track an audio track
; formated as described in notes
;   (a current state of implemented behaviours will be listed here)
; ###################

; /!\ MULTIPLE TRACKERS CAN BE INSTANCIATED SO MEMORY MANAGEMENT
; UNDER THE SAME STRUCTURE IS DONE FOR EVERY INSTANCES

; MAXIMUM RECURCIVE STACK SIZE
DEF MAXIMUM_RECURSIVE_STACK_SIZE = 3

; TRACKER STATES :
;   PLAY : Active State
;   DELAY : Delay before next note
;   END : No activity
DEF PLAY_STATE = %00000001
DEF DELAY_STATE = %0000010
DEF NEW_NOTE_STATE = %00000100
DEF FETCH_STATE = %01000000
DEF END_STATE = %10000100


INCLUDE "hardware.inc"


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          STRUCTURES                                     | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+
;tracker éléments structure
;-----------
RSRESET
block_Haddr             RB 1 ; High byte of block addr (since it is ALIGNED no need for the low part)
tracker_value           RB 1 ; current value of tracker on the 256 steps
tracker_state           RB 1 ; current state of the tracker
current_note            RB 1 ; currently playing note
delay_value             RB 1 ; current value of the default delay
delay_counter           RB 1 ; current delay counter
repeat_counter          RB 1 ; current value of the default repeat
return_tracker_value    RB 1 ; current value of the return tracker (tracker to return to on instruction)
stack_save              RB 2 ; SP of the current recursive stack (little endian)
tracker_stack           RB 4*MAXIMUM_RECURSIVE_STACK_SIZE ; recursive stack of the tracker
tracker_stack_base      RB 0
SIZEOF_tracker_struct	RB 0
;-----------

;--------------------------------
; GET_CURRENT_TRACKER_ELEM_ADDR
; set hl to the addr of the element in \1
; for the current tracker
; [hl, af, b]
;--------------------------------
MACRO GET_CURRENT_TRACKER_ELEM_ADDR
    ld hl, _current_tracker_struct_addr
    ld a, [hl+]
    ld b, [hl]
    add a, \1
    ld l, a
    ld a, $00
    adc a, b
    ld h, a
ENDM





    SECTION "audio_tracker_code", ROM0
; -------------------------------
; set_current_working_tracker(bc = current working tracker addr)
; -------------------------------
set_current_working_tracker:
    ld hl, _current_tracker_struct_addr
    ld [hl], c
    inc hl
    ld [hl], b
    ret
set_play_state:
    ld a, PLAY_STATE
    jr set_state
set_delay_state:
    ld a, DELAY_STATE
    jr set_state
set_new_note_state:
    ld a, NEW_NOTE_STATE
    jr set_state
set_end_state:
    ld a, END_STATE
    jr set_state
set_fetch_state:
    ld a, FETCH_STATE
    ; jr set_state
set_state:
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_state
    ld [hl], a
    ret

; -------------------------------
; tracker_init(bc = addr of working tracker to initialize, e = High addr of first tracker block)
;   init a tracker at addr bc
;   for track block in de
;   every other values are set to 0 (except stack save and tracker state)
; -------------------------------
tracker_init::
    call set_current_working_tracker
    GET_CURRENT_TRACKER_ELEM_ADDR block_Haddr
    ld a, e
    ld [hl+], a
    ld b, SIZEOF_tracker_struct - 1
    ld d, $00
    call memset_fast
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_stack_base
    ld de, hl
    GET_CURRENT_TRACKER_ELEM_ADDR stack_save
    ld a, e
    ld [hl+], a
    ld [hl], d
    call set_fetch_state
    ret

; ---------------------------
; tracker_step(bc = addr of working tracker to update)
; ---------------------------
tracker_step::
    call set_current_working_tracker
; --------------------------
; tracker_update
; update state of current working tracker
; --------------------------
tracker_update:
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_state
    ld a, [hl]
    cp a, END_STATE
    ret z
    cp a, NEW_NOTE_STATE
    jr z, update_new_note; do wait time after new note (can be 0)
    cp a, DELAY_STATE
    jr z, update_delay
    cp a, PLAY_STATE
    jr z; UNUSED STATE ?
    cp a, FETCH_STATE
    jr z, fetch_routine
    ret ; just in case but shouldn't reach

update_new_note:
    call set_delay_state
    PRINT_DEBUG "D : new note"
    jr tracker_update

update_delay:
    GET_CURRENT_TRACKER_ELEM_ADDR delay_counter
    push hl
    ld a, [hl]
    push af
    GET_CURRENT_TRACKER_ELEM_ADDR delay_value
    pop af
    cp a, [hl]
    pop hl
    jr z, .timer_trip
    inc [hl]
    ret
.timer_trip
    ld a, $00
    ld [hl], a
    call set_fetch_state
    jr tracker_update

; --------------------------
; fetch_routine
; - fetch next instruction
; - update memory state
; --------------------------
fetch_routine:
    GET_CURRENT_TRACKER_ELEM_ADDR block_Haddr
    ld a, [hl+]
    ld b, [hl]
    inc [hl] ; tracker counter update
    ld l, b
    ld h, a
    ld a, [hl] ; a <- tracker instruction
    bit 7, a
    jr z, _note_instruction_read ;v-- else : control instruction 
    bit 6, a
    jr nz, _set_delay_counter_instruction
    bit 5, a
    jr nz, _set_repeat_counter_instruction
    bit 3, a
    jr nz, _block_control_instruction
    bit 2, a
    jr nz, _return_instruction
    bit 0, a
    jr nz, _return_tracker_set
    PRINT_DEBUG "W [invalid inst]"
    jr fetch_routine ; if reached -> unknown instruction, fetch next one

; -------------------------
; _note_instruction_read(a = instruction read)
; set note in tracker memory
; set tracker state to NEW_NOTE_STATE
; returns handle
; -------------------------
_note_instruction_read:
    ld c, a
    GET_CURRENT_TRACKER_ELEM_ADDR current_note
    ld [hl], c
    call set_new_note_state
    ret

; --------------------------
; _set_delay_counter_instruction(a = instruction read)
; set delay counter to a | %00XXXXXX
; keep tracker in fetch state
; fetch next instruction
; --------------------------
_set_delay_counter_instruction:
    and a, %00111111
    ld c, a
    GET_CURRENT_TRACKER_ELEM_ADDR delay_value
    ld [hl], c
    jr fetch_routine

; ----------------------
; _set_repeat_counter_instruction(a = instruction read)
;   set repeat counter to a | %000xxxxx
;   keep tracker in fetch state
;   fetch next instruction
; ----------------------
_set_repeat_counter_instruction:
    and a, %00011111
    ld c, a
    GET_CURRENT_TRACKER_ELEM_ADDR repeat_counter
    ld [hl], c
    jr fetch_routine


; ------------------------
; _return_instruction(a = instruction read)
;   return instruction : %000001bb
;   do return instruction
;   bb :
;       -> 00 : global return, tracker <-0
;       -> 01 : conditionnal global, if repeat_counter <= 0, tracker <- 0 (decrease repeat counter)
;       -> 10 : partial return, tracker <- return_tracker_value
;       -> 11 : conditionnal partial, if repeat_counter <= 0, tracker <- return_tracker_value (decrease repeat counter)
; keep tracker in fetch state
; fetch next instruction
; ------------------------
_return_instruction:
    and a, %00000011
    ld c, a
    bit 0, a
    jr z, .absolute ; absolute return, do not test repeat
    GET_CURRENT_TRACKER_ELEM_ADDR repeat_counter
    ld a, [hl]
    dec [hl]
    cp a, $00
    jr z, fetch_routine ; don't repeat, pass to next fecth
.absolute
    ld d, $00 ; default tracker new value
    bit 1, c
    jr z, .global_return ; reset tracker to 0
    GET_CURRENT_TRACKER_ELEM_ADDR return_tracker_value
    ld d, [hl]
.global_return
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_value
    ld [hl], d ; set tracker value to computed position
    jr fetch_routine

; ------------------------
; _return_tracker_set
; set return_tracker_value to tracker value + 1
; keep tracker in fetch state
; fetch next instruction
; ------------------------
_return_tracker_set:
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_value
    ld c, [hl]
    inc c
    GET_CURRENT_TRACKER_ELEM_ADDR return_tracker_value
    ld [hl], c
    jr fetch_routine


;------------------------
; _block_control_instruction(a = instruction read)
; do control of tracker block instruction
; block control instruction : %00001?bb (+ $XX)
;   bb : 
;       00 -> block end (returned to pushed block), if empty stack : END_STATE
;       01 -> reset block stack
;       10 -> jump to tracker block $XX
;       11 -> call to tracker block $XX
; -----------------------
_block_control_instruction:
    bit 1, a
    jr nz, _new_block_instruction
    bit 0, a
    jr nz, .reset_block_stack ; 00 -> block end
    GET_CURRENT_TRACKER_ELEM_ADDR stack_save
    ld a, [hl+]
    ld d, [hl]
    ld e, a ; de <- stack pointer save
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_stack_base
    ld a, l
    cp a, e
    jr nz, .pop_and_swap ; empty stack just stop tracker and return
        call set_end_state
        ret
.pop_and_swap
    di ; critical zone, loose handle of execution stack to handle tracker stack
        ld [_execution_stack_pointer_save], sp ; saved execution stack pointer
        ld l, [de] ; de is stack_save addr
        inc de
        ld h, [de]
        ld sp, hl ; sp <- tracker recursive stack

        pop de ; pop repeat_counter and return tracker value
        GET_CURRENT_TRACKER_ELEM_ADDR block_Haddr
        pop bc ; pop block_Haddr and tracker value
        ld a, b
        ld [hl+], a
        ld [hl], c
        GET_CURRENT_TRACKER_ELEM_ADDR repeat_counter
        ld a, d
        ld [hl+], a
        ld [hl], e
        inc hl ; hl is the stack save addr

        ld de, hl
        ld hl, sp
        ld a, l
        ld [de], a
        inc de
        ld a, h
        ld [de], a ; saved stack pointer

        ld de, _execution_stack_pointer_save
        ld l, [de]
        inc de
        ld h, [de]
        ld sp, hl ; restored execution stack pointer
    ei
    jr fetch_routine
.reset_block_stack
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_stack_base
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    GET_CURRENT_TRACKER_ELEM_ADDR stack_save
    ld a, e
    ld [hl+], a
    ld [hl], d
    jr fetch_routine

;------------------------
; _block_control_instruction(a = instruction read)
; do control of tracker block instruction
; block control instruction : %00001?1b + $XX
;   bb :
;       10 -> jump to tracker block $XX
;       11 -> call to tracker block $XX
; -----------------------
_new_block_instruction:
    bit 0, a
    jr z, .new_block_read_and_context_change
    GET_CURRENT_TRACKER_ELEM_ADDR stack_save
    ld a, [hl+]
    ld d, [hl]
    ld e, a ; de <- stack pointer save
    di ; critical zone, loose handle of execution stack to handle tracker stack
        ld [_execution_stack_pointer_save], sp ; saved execution stack pointer
        ld l, [de] ; de is stack_save addr
        inc de
        ld h, [de]
        ld sp, hl ; sp <- tracker recursive stack

        GET_CURRENT_TRACKER_ELEM_ADDR block_Haddr
        ld a, [hl+]
        ld c, [hl]
        inc c
        ld b, a
        push bc ; pushed block H addr and tracker

        GET_CURRENT_TRACKER_ELEM_ADDR repeat_counter
        ld a, [hl+]
        ld c, [hl]
        ld b, a
        push bc ; pushed repeat counter and return tracker value

        inc hl ; hl is the stack save addr
        ld de, hl
        ld hl, sp
        ld a, l
        ld [de], a
        inc de
        ld a, h
        ld [de], a ; saved stack pointer

        ld de, _execution_stack_pointer_save
        ld l, [de]
        inc de
        ld h, [de]
        ld sp, hl ; restored execution stack pointer
    ei
.new_block_read_and_context_change
    GET_CURRENT_TRACKER_ELEM_ADDR block_Haddr
    push hl
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    ld a, [hl] ; a <- next block H addr
    pop hl
    ld [hl+], a ; set new block addr
    ld a, $00
    ld [hl], a ; set new tracker to 0
    GET_CURRENT_TRACKER_ELEM_ADDR repeat_counter
    ld a, $00
    ld [hl+], a ; reset repeat_counter
    ld [hl], a ; reset return tracker value
    jr fetch_routine



    SECTION "audio_tracker_variables", WRAM0
_current_tracker_struct_addr: DS 2 ; addr of currently working tracker (little endian)
_execution_stack_pointer_save: DS 2 ; memory location of saved value for stack pointer