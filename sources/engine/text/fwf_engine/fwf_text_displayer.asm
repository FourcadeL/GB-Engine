; ########################
; Fixed Width Font 
; Text displayer AUTOMATON
; #########################

; AUTOMATON states :
;   DISP : display next char
;   FETCH : fetch next text instruction
;   TIMER : timer wait before diplaying next char
;   IDLE : waiting to be awoken by call
;   FLUSH : reset text box
;   END : no activity
DEF DISP_STATE = %00000001
DEF TIMER_STATE = %00000010
DEF IDLE_STATE = %00000100
DEF FLUSH_STATE = %00001000
DEF FETCH_STATE = %01000000
DEF END_STATE = %10000000


INCLUDE "hardware.inc"
INCLUDE "charmap.inc"

    SECTION "fwf_automaton_code",  ROM0

set_disp_state:
    ld a, DISP_STATE
    jr set_state
set_timer_state:
    ld a, TIMER_STATE
    jr set_state
set_idle_state:
    ld a, IDLE_STATE
    jr set_state
set_flush_state:
    ld a, FLUSH_STATE
    jr set_state
set_end_state:
    ld a, END_STATE
    jr set_state
set_fetch_state:
    ld a, FETCH_STATE
    ; jr set_state
set_state:
    ld hl, _displayer_state
    ld [hl], a
    ret


fwf_automaton_update::
    ld a, [_displayer_state]
    cp a, END_STATE
    ret z
    cp a, DISP_STATE
    jr z, display_char ; TODO
    cp a, TIMER_STATE
    jr z, update_timer ; TODO
    cp a, IDLE_STATE
    jr z, check_idle ; TODO
    cp a, FLUSH_STATE
    jr z, do_flush ; TODO
    cp a, FETCH_STATE
    jr z, fetch_state ; TODO
    ret ; juste in case but shouldn't reach

display_char:
update_timer:
check_idle:
do_flush:
fetch_state:

    SECTION "fwf_automaton_variables", WRAM0

_displayer_state: DS 1
_displayer_start_display_addr: DS 2 ; big endian
_displayer_max_display_addr: DS 2 ; big endian
_blank_tile: DS 1 ; blank tile to use when flushing
_current_addr_dest: DS 2 ; big endian
_current_addr_read: DS 2 ; big endian

    SECTION "fwf_automaton_text_stack", WRAM0

