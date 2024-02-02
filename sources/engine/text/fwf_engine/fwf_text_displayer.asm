; ########################
; Fixed Width Font 
; Text displayer AUTOMATON
; #########################

; MAXIMUM RECURSIVE STACK SIZE
DEF MAXIMUM_RECURSIVE_STACK_SIZE = 4

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

MACRO INCREMENT_ADRESS_AT_HL_LITTLE_ENDIAN
    inc [hl]
    jr nz, .end\@
    inc hl
    inc [hl]
.end\@
ENDM

MACRO INCREMENT2_ADRESS_AT_HL_LITTLE_ENDIAN
    inc [hl]
    jr z, .halfwork\@
    inc [hl]
    jr nz, .end\@
    inc hl
    inc [hl]
    jr .end\@
.halfwork\@
    inc [hl]
    inc hl
    inc [hl]
.end\@
ENDM

MACRO DECREMENT2_ADRESS_AT_HL_LITTLE_ENDIAN
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    dec bc
    dec bc
    ld [hl], c
    inc hl
    ld [hl], b
ENDM

    SECTION "fwf_automaton_code",  ROM0
;----------------------------------------------------------
; Automaton related code
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

;----------------------------------------
;- fwf_automaton_set_display_width(a = width)
;----------------------------------------
fwf_automaton_set_display_width::
    ld hl, _displayer_line_width
    jr set_value
;----------------------------------------
;- fwf_automaton_set_display_height(a = height)
;----------------------------------------
fwf_automaton_set_display_height::
    ld hl, _displayer_nb_rows
    jr set_value
;----------------------------------------
;- fwf_automaton_set_timer(a = time value)
;----------------------------------------
fwf_automaton_set_timer::
    ld hl, _current_timer_value
    ld b, $00
    ld [hl], b
    ld hl, _displayer_timer
    jr set_value
;----------------------------------------
;- fwf_automaton_set_blank_tile_id(a = tile id)
;----------------------------------------
fwf_automaton_set_blank_tile_id::
    ld hl, _blank_tile_id
    ; jr set_value
set_value:
    ld [hl], a
    ret
;----------------------------------------
;- fwf_automaton_set_display_start_addr(de = start addr)
;----------------------------------------
fwf_automaton_set_display_start_addr::
    ld hl, _displayer_start_display_addr
    jr set_addr
;----------------------------------------
;- fwf_automaton_set_read_addr(de = read addr)
;----------------------------------------  
fwf_automaton_set_read_addr::
    ld hl, _current_read_addr
    ; jr set_addr
set_addr:
    ld [hl], e
    inc hl
    ld [hl], d
    ret

fwf_automaton_awake_from_idle::
    ld hl, _current_idle_state
    set 0, [hl]
    ret

;----------------------------------
;- fwf_automaton_is_stopped() -> z set : automaton is stopped | nz set : automaton is active
;----------------------------------
fwf_automaton_is_stopped::
    ld hl, _displayer_state
    ld a, END_STATE
    cp a, [hl]
    ret

fwf_automaton_init::
    call update_display_addr_start_return
    ld a, $00
    ld [_current_timer_value], a
    ld [_current_stack_size], a
    ld hl, _current_stack_addr
    ld [hl], LOW(_fwf_text_stack)
    inc hl
    ld [hl], HIGH(_fwf_text_stack)
    call set_flush_state
    ret

fwf_automaton_update::
    ld a, [_displayer_state]
    cp a, END_STATE
    ret z
    cp a, DISP_STATE
    jp z, display_char
    cp a, TIMER_STATE
    jr z, update_timer
    cp a, IDLE_STATE
    jr z, check_idle
    cp a, FLUSH_STATE
    jr z, do_flush
    cp a, FETCH_STATE
    jr z, fetch_routine
    ret ; juste in case but shouldn't reach


update_timer:
    ld a, [_current_timer_value]
    ld hl, _displayer_timer
    cp a, [hl]
    jr z, .timer_trip
    inc a
    ld [_current_timer_value], a
    ret
.timer_trip
    ld a, $00
    ld [_current_timer_value], a
    call set_disp_state
    jr fwf_automaton_update

check_idle:
    ld hl, _current_idle_state
    bit 7, [hl]
    jr nz, .already_idle
    ld a, %10000000
    ld [hl], a
.already_idle
    bit 0, [hl]
    ret z ; waiting awake
    ld a, $00
    ld [hl], a
    call set_fetch_state
    ret

do_flush:
    ld hl, _displayer_line_width
    ld c, [hl]
    ld hl, _displayer_nb_rows
    ld b, [hl]
    ld hl, _blank_tile_id
    ld d, [hl]
    ld hl, _displayer_start_display_addr
    ld a, [hli]
    ld h, [hl]
    ld l, a
    call tilemap_block_set
    call fwf_flush
    call update_display_addr_start_return
    call set_fetch_state
    jr fwf_automaton_update

fetch_routine:
    ld hl, _current_read_addr
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    cp a, $20 ; check for control character
    jr c, .control_char_handler
    call set_timer_state
    jr fwf_automaton_update
.control_char_handler
    ld hl, _current_read_addr
    INCREMENT_ADRESS_AT_HL_LITTLE_ENDIAN
    cp a, "\\0" ; end char
    jr z, control_end_char
    cp a, "\\b" ; text block char
    jp z, control_text_block_char
    cp a, "\\f" ; flush char
    jr z, control_flush_char
    cp a, "\\w" ; wait char
    jr z, control_wait_char
    cp a, "\\t" ; timer char
    jr z, control_timer_char
    cp a, "\n" ; newline char
    jr z, control_newline_char
    ret ; juste in case but shouldn't reach

display_char:
    ld hl, _current_read_addr
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld hl, _current_display_addr
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld l, a
    call fwf_display_char
    ld hl, _current_read_addr
    INCREMENT_ADRESS_AT_HL_LITTLE_ENDIAN
    call update_display_addr_new_char
    call set_fetch_state
    ld a, [_current_display_row]
    ld b, a
    ld a, [_current_display_col]
    or a, b
    jp nz, fwf_automaton_update
    call set_flush_state
    jp fwf_automaton_update

;---------------------------------------------------------
control_end_char: ; behaviour for control char "\\0"
    call set_end_state
    ld hl, _current_stack_size
    ld a, [hl]
    cp a, $00
    ret z ; nothing left to display
    dec [hl] ; pop addr for text stack
    ld hl, _current_stack_addr
    DECREMENT2_ADRESS_AT_HL_LITTLE_ENDIAN
    ld hl, _current_stack_addr
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld h, b
    ld l, c
    ld e, [hl]
    inc hl
    ld d, [hl]
    call fwf_automaton_set_read_addr ; read_addr <- de
    call set_fetch_state
    jp fwf_automaton_update
control_flush_char: ; behaviour for control char "\\f"
    call set_flush_state
    ret
control_wait_char: ; behaviour for control character char "\\w"
    call set_idle_state
    ret
control_newline_char: ; behaviour for control character char "\n"
    call update_display_addr_new_line
    ld a, [_current_display_row]
    ld b, a
    ld a, [_current_display_col]
    or a, b
    ret nz
    call set_flush_state ; last line exeeded
    ret
control_timer_char: ; behaviour for control character char "\\t"
    ld hl, _current_read_addr
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    call fwf_automaton_set_timer
    ld hl, _current_read_addr
    INCREMENT_ADRESS_AT_HL_LITTLE_ENDIAN
    jp fwf_automaton_update
control_text_block_char: ; behaviour for control char "\\b"
    ld hl, _current_stack_size
    ld a, MAXIMUM_RECURSIVE_STACK_SIZE
    cp a, [hl]
    ret z ; max stack size exceeded
    inc [hl]
    ld hl, _current_read_addr
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld h, b
    ld l, c
    ld e, [hl]
    inc hl
    ld d, [hl] ; de <- read addr of next block
    inc hl ; hl <- read addr to push onto the stack
    push hl
    call fwf_automaton_set_read_addr
    ld hl, _current_stack_addr
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld h, b
    ld l, c
    pop de
    ld [hl], e
    inc hl
    ld [hl], d
    inc hl
    ld b, h
    ld c, l
    ld hl, _current_stack_addr
    ld [hl], c
    inc hl
    ld [hl], b
    jp fwf_automaton_update
;---------------------------------------------------------
; Displayer related code    
update_display_addr_new_char:
    ld a, [_current_display_col]
    inc a
    ld hl, _displayer_line_width
    cp a, [hl]
    jr z, update_display_addr_new_line
    ld [_current_display_col], a
    ld hl, _current_display_addr
    INCREMENT_ADRESS_AT_HL_LITTLE_ENDIAN
    ret
update_display_addr_new_line:
    ld a, [_current_display_col]
    cp a, $00 ; no blank new line
    ret z
    ld a, [_current_display_row]
    inc a
    ld hl, _displayer_nb_rows
    cp a, [hl]
    jr z, update_display_addr_start_return
    ld [_current_display_row], a
    ld hl, _current_display_col
    ld a, $20
    sub [hl]
    ld b, a
    ld a, $00
    ld [_current_display_col], a
    ld hl, _current_display_addr
    ld a, [hl]
    add a, b
    ld [hli], a
    ret nc
    inc [hl]
    ret
update_display_addr_start_return:
    ld hl, _displayer_start_display_addr
    ld a, [hli]
    ld b, [hl]
    ld hl, _current_display_addr
    ld [hli], a
    ld [hl], b
    ld a, $00
    ld hl, _current_display_col
    ld [hl], a
    ld hl, _current_display_row
    ld [hl], a
    ret



;---------------------------------------------------------
    SECTION "fwf_automaton_variables", WRAM0

_displayer_state: DS 1
_displayer_start_display_addr: DS 2 ; little endian
_displayer_timer: DS 1 ; delay beetween char timer
_current_timer_value: DS 1
_current_display_addr: DS 2 ; little endian
_displayer_line_width: DS 1
_current_display_col: DS 1
_displayer_nb_rows: DS 1
_current_display_row: DS 1
_blank_tile_id: DS 1 ; blank tile to use when flushing
_current_read_addr: DS 2 ; little endian
_current_idle_state: DS 1 ; %E000000W E -> entry : is set when entering idle state | W -> wake : when set, exit idle state
_current_stack_size: DS 1 ; current size of the stack
_current_stack_addr: DS 2; little endian


    SECTION "fwf_automaton_text_stack", WRAM0

_fwf_text_stack: DS MAXIMUM_RECURSIVE_STACK_SIZE*2
_fwf_text_stack_top:
