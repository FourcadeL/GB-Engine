; ###################
; Audio Tracker
; Track an audio track
; formated as described in notes
;   (a current state of implemented behaviours will be listed here)
; ###################

; /!\ MULTIPLE TRACKERS CAN BE INSTANCIATED SO MEMORY MANAGEMENT
; UNDER THE SAME STRUCTURE IS DONE FOR EVERY INSTANCES


; TRACKER STATES :
;   PLAY : Active State
;   DELAY : Delay before next note
;   END : No activity
DEF ATRACKER_PLAY_STATE = %00000001
DEF ATRACKER_DELAY_STATE = %0000010
DEF ATRACKER_NEW_NOTE_STATE = %00000100
DEF ATRACKER_FETCH_STATE = %01000000
DEF ATRACKER_END_STATE = %10000100


INCLUDE "hardware.inc"
INCLUDE "debug.inc"
INCLUDE "tracker.inc"
INCLUDE "instruments.inc"

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
    ld c, ATRACKER_PLAY_STATE
    jr set_state
set_delay_state:
    ld c, ATRACKER_DELAY_STATE
    jr set_state
set_new_note_state:
    ld c, ATRACKER_NEW_NOTE_STATE
    jr set_state
set_end_state:
    ld c, ATRACKER_END_STATE
    jr set_state
set_fetch_state::
    ld c, ATRACKER_FETCH_STATE
    ; jr set_state
set_state:
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_state
    ld [hl], c
    ret

; -------------------------------
; tracker_init(StackPush : $XXXX(addr of instrument handler)
;                          $YYYY(addr of tracker block)
;                           bc = addr of working tracker to initialize) 
;   init a tracker at addr bc
;   for track block in de
;   with instrument handler in
;   every other values are set to 0 (except stack save and tracker state)
; -------------------------------
tracker_init::
    call set_current_working_tracker
    ld hl, sp+2
    ld a, [hl+]
    ld e, a
    ld d, [hl] ; de <- addr of tracker block
    GET_CURRENT_TRACKER_ELEM_ADDR block_Laddr
    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl+], a
    ld b, SIZEOF_tracker_struct - 2
    ld d, $00
    call memset_fast

    ld hl, sp+4
    ld a, [hl+]
    ld e, a
    ld d, [hl] ; de <- addr of instrument handler
    GET_CURRENT_TRACKER_ELEM_ADDR instrument_handler_addr
    ld a, e
    ld [hl+], a
    ld [hl], d
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_stack_base
    ld d, h
    ld e, l
    GET_CURRENT_TRACKER_ELEM_ADDR stack_save
    ld a, e
    ld [hl+], a
    ld [hl], d
    call set_end_state
    ret

; -------------------------------
; tracker_start(bc = addr of working tracker to start)
;   tracker at bc is set to fetch_state
; -------------------------------
tracker_start::
    call set_current_working_tracker
    call set_fetch_state
    ret

; -------------------------------
; tracker_stop(bc = addr of working tracker to pause)
;   tracker at bc plays blank note then set itself to end state
; -------------------------------
tracker_stop::
    call set_current_working_tracker
    GET_CURRENT_TRACKER_ELEM_ADDR instrument_handler_addr
    ld a, [hl+]
    ld e, a
    ld d, [hl] ; de <- instrument handler addr
    ld hl, CH_flags
    add hl, de
    set 0, [hl] ; new note flag for handler
    ld hl, CH_note_value
    add hl, de
    ld [hl], BLANK_NOTE ; blank note to play in handler
    call set_end_state
    ret



; --------------------------------------------------------
; tracker_new note_state(bc = addr of working tracker)
;   -> f : Z reset if tracker is in new note state
; --------------------------------------------------------
tracker_new_note_state::
    call set_current_working_tracker
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_state
    ld a, [hl]
    cp a, ATRACKER_NEW_NOTE_STATE
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
tracker_update::
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_state
    ld a, [hl]
    cp a, ATRACKER_END_STATE
    ret z
    cp a, ATRACKER_NEW_NOTE_STATE
    jr z, update_new_note; do wait time after new note (can be 0)
    cp a, ATRACKER_DELAY_STATE
    jr z, update_delay
    cp a, ATRACKER_PLAY_STATE
    ; jr z; UNUSED STATE ?
    cp a, ATRACKER_FETCH_STATE
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
    GET_CURRENT_TRACKER_ELEM_ADDR block_Laddr
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a ; de <- block base addr
    ld c, [hl] ; c <- tracker value
    inc [hl] ; tracker counter update
    ld h, d
    ld l, e
    ld b, $00
    add hl, bc
    ld a, [hl] ; a <- tracker instruction
    bit 7, a
    jr z, _note_instruction_read ;v-- else : control instruction 
    bit 6, a
    jp nz, _set_delay_counter_instruction
    bit 5, a
    jp nz, _set_repeat_counter_instruction
    bit 3, a
    jp nz, _block_control_instruction
    bit 2, a
    jp nz, _return_instruction
    bit 0, a
    jp nz, _return_tracker_set
    PRINT_DEBUG "W [invalid inst]"
    jr fetch_routine ; if reached -> unknown instruction, fetch next one

; -------------------------
; _note_instruction_read(a = instruction read)
;       %0110XXXX are volume control notes
;       %0101XXXX are instrument control notes
;       otherwise : standard note
;           set note in instrument handler
;           set new note flag in instrument handler
;           set tracker state to ATRACKER_NEW_NOTE_STATE
; returns handle
; -------------------------
_note_instruction_read:
    ld c, a
    and a, %11110000
    cp a, %01100000
    jr z, _volume_control_note
    cp a, %01110000
    jr z, _instrument_control_note
    ; standard note
        GET_CURRENT_TRACKER_ELEM_ADDR instrument_handler_addr
        ld a, [hl+]
        ld e, a
        ld d, [hl] ; de <- instrument handler addr
        ld hl, CH_flags
        add hl, de
        set 0, [hl]
        ld hl, CH_note_value
        add hl, de
        ld [hl], c
        call set_new_note_state
    ret

;--------------------
;_volume_control_note(c = instruction read)
; set new volume in instrument handler
; set new volume flag in instrument handler
; fetch next instruction
;---------------------
_volume_control_note:
    ld a, c
    and a, %00001111
    ld c, a
    GET_CURRENT_TRACKER_ELEM_ADDR instrument_handler_addr
    ld a, [hl+]
    ld e, a
    ld d, [hl] ; de <- instrument handler addr
    ld hl, CH_flags
    add hl, de
    set 1, [hl]
    ld hl, CH_curr_volume
    add hl, de
    ld [hl], c
    jp fetch_routine

;--------------------
;_instrument_control_note(c = instruction read)
; set new instrument in instrument handler
; set new instrument flag in instrument handler
; fetch next instruction
;---------------------
_instrument_control_note:
    ld a, c
    and a, %00001111
    ld c, a
    GET_CURRENT_TRACKER_ELEM_ADDR instrument_handler_addr
    ld a, [hl+]
    ld e, a
    ld d, [hl] ; de <- instrument handler addr
    ld hl, CH_flags
    add hl, de
    set 2, [hl]
    ld hl, CH_curr_instrument_index
    add hl, de
    ld [hl], c
    jp fetch_routine

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
    jp fetch_routine

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
    jp fetch_routine


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
    jp z, fetch_routine ; don't repeat, pass to next fecth
.absolute
    ld d, $00 ; default tracker new value
    bit 1, c
    jr z, .global_return ; reset tracker to 0
    GET_CURRENT_TRACKER_ELEM_ADDR return_tracker_value
    ld d, [hl]
.global_return
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_value
    ld [hl], d ; set tracker value to computed position
    jp fetch_routine

; ------------------------
; _return_tracker_set
; set return_tracker_value to tracker value + 1
; keep tracker in fetch state
; fetch next instruction
; ------------------------
_return_tracker_set:
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_value
    ld c, [hl]
    GET_CURRENT_TRACKER_ELEM_ADDR return_tracker_value
    ld [hl], c
    jp fetch_routine


;------------------------
; _block_control_instruction(a = instruction read)
; do control of tracker block instruction
; block control instruction : %00001?bb (+ $XX $XX)
;   bb : 
;       00 -> block end (returned to pushed block), if empty stack : ATRACKER_END_STATE
;       01 -> reset block stack
;       10 -> jump to tracker block $XX
;       11 -> call to tracker block $XX
; -----------------------
_block_control_instruction:
    bit 1, a
    jp nz, _new_block_instruction
    bit 0, a
    jr nz, .reset_block_stack ; 00 -> block end
    GET_CURRENT_TRACKER_ELEM_ADDR stack_save
    ld a, [hl+]
    ld d, [hl]
    ld e, a ; de <- stack pointer save
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_stack_base
    ld a, l
    cp a, e
    jr nz, .pop_and_swap 
        call set_end_state ; empty stack just stop tracker and return
        ret
.pop_and_swap
    di ; critical zone, loose handle of execution stack to handle tracker stack
        ld [_execution_stack_pointer_save], sp ; saved execution stack pointer
        ld h, d
        ld l, e
        ld sp, hl ; sp <- tracker recursive stack
        ; change context --------------------------------

        pop de ; pop repeat_counter and return tracker value
        GET_CURRENT_TRACKER_ELEM_ADDR repeat_counter
        ld a, d
        ld [hl+], a ; set reapeat_counter value
        ld [hl], e ; set return_tracker value

        GET_CURRENT_TRACKER_ELEM_ADDR block_Laddr
        pop de ; pop tracker_value and $XX
        pop bc ; pop block_addr ($HHLL)
        ld a, c
        ld [hl+], a ; set block_Laddr
        ld a, b
        ld [hl+], a ; set block_Haddr
        ld [hl], d ; set tracker_value
        
        GET_CURRENT_TRACKER_ELEM_ADDR stack_save
        ld d, h
        ld e, l ; de is the stack save addr

        ;-----------------------------------------------
        ld hl, sp + 0
        ld a, l
        ld [de], a
        inc de
        ld a, h
        ld [de], a ; saved stack pointer

        ld de, _execution_stack_pointer_save
        ld a, [de]
        ld l, a
        inc de
        ld a, [de]
        ld h, a
        ld sp, hl ; restored execution stack pointer
    ei
    jp fetch_routine
.reset_block_stack
    GET_CURRENT_TRACKER_ELEM_ADDR tracker_stack_base
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    GET_CURRENT_TRACKER_ELEM_ADDR stack_save
    ld a, e
    ld [hl+], a
    ld [hl], d
    jp fetch_routine

;------------------------
; _block_control_instruction(a = instruction read)
; do control of tracker block instruction
; block control instruction : %00001?1b + $ll $HH
;   bb :
;       10 -> jump to tracker block $HHll
;       11 -> call to tracker block $HHll
; -----------------------
_new_block_instruction:
    bit 0, a
    jr z, .new_block_read_and_context_change
    GET_CURRENT_TRACKER_ELEM_ADDR stack_save
    ld a, [hl+]
    ld h, [hl]
    ld l, a ; hl <- stack pointer save
    di ; critical zone, loose handle of execution stack to handle tracker stack
        ld [_execution_stack_pointer_save], sp ; saved execution stack pointer
        ld sp, hl ; sp <- tracker recursive stack

        ; change context --------------------------------

        GET_CURRENT_TRACKER_ELEM_ADDR block_Laddr
        ld a, [hl+]
        ld c, a ; c <- block L addr
        ld a, [hl+]
        ld b, a ; bc <- block addr
        ld d, [hl] ; d <- current tracker
        inc d
        inc d   ; double increment next instruction after addr
        push bc ; pushed block addr
        push de ; pushed tracker value + $XX

        GET_CURRENT_TRACKER_ELEM_ADDR repeat_counter
        ld a, [hl+]
        ld c, [hl]
        ld b, a
        push bc ; pushed repeat counter and return tracker value

        ld d, h
        ld e, l
        inc de ; de is the stack save addr

        ;------------------------------------------------
        ld hl, sp + 0
        ld a, l
        ld [de], a
        inc de
        ld a, h
        ld [de], a ; saved stack pointer

        ld de, _execution_stack_pointer_save
        ld a, [de]
        ld l, a
        inc de
        ld a, [de]
        ld h, a
        ld sp, hl ; restored execution stack pointer
    ei
.new_block_read_and_context_change
    GET_CURRENT_TRACKER_ELEM_ADDR block_Laddr
    push hl
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a ; de <- block base addr
    ld c, [hl] ; c <- tracker value
    ld h, d
    ld l, e
    ld b, $00
    add hl, bc
    ld a, [hl+]
    ld c, a
    ld b, [hl] ; ba <- next block addr
    pop hl
    ld [hl+], a ; set new block Laddr
    ld a, b
    ld [hl+], a ; set new block Haddr
    ld a, $00
    ld [hl], a ; set new tracker to 0
    GET_CURRENT_TRACKER_ELEM_ADDR repeat_counter
    ld a, $00
    ld [hl+], a ; reset repeat_counter
    ld [hl], a ; reset return tracker value
    jp fetch_routine



    SECTION "audio_tracker_variables", WRAM0
_current_tracker_struct_addr: DS 2 ; addr of currently working tracker (little endian)
_execution_stack_pointer_save: DS 2 ; memory location of saved value for stack pointer