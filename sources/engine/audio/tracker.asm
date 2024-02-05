; ###################
; Audio Tracker
; Track an audio track
; formated as described in notes
;   (a current state of implemented behaviours will be listed here)
; ###################

; /!\ MULTIPLE TRACKERS CAN BE INSTANCIATED SO MEMORY MANAGEMENT
; UNDER THE SAME STRUCTURE IS DONE FOR EVERY INSTANCES

; MAXIMUM RECURCIVE STACK SIZE
DEF MAXIMUM_RECURSIVE_STACK_SIZE = 4

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
stack_size              RB 1 ; size of the current recursive stack
tracker_stack           RB 2*MAXIMUM_RECURSIVE_STACK_SIZE ; recursive stack of the tracker
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
set_fetch_state:
    ld a, FETCH_STATE
    ; jr set_state
set_state:
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_state
    ld [hl], a
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
    bit 2, a
    jr nz, _return_instruction
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

    SECTION "audio_tracker_variables", WRAM0
_current_tracker_struct_addr: DS 2 ; addr of currently working tracker (little endian)