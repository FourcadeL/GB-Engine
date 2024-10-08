; ############################################
; Audio SFX handler
; Define interface functions for play
; of SFX
;   (Priority is taken over notes played by "instruments"
;    then handle is returned)
; ############################################


; AUTOMATON STATES :
;   IDLE    : Wait for next SFX
;   INIT    : Will initialize env for SFX PLAY
;   PLAYING : Set audio registers for play
;   DELAY   : Delay before next audio registers values
;   CONTROL : Will read a control byte
;   FINISH  : Will finish playing and return handle to instruments
DEF SFXH_IDLE_STATE = %00000001
DEF SFXH_INIT_STATE = %00000010
DEF SFXH_PLAYING_STATE = %00000100
DEF SFXH_DELAY_STATE = %00001000
DEF SFXH_CONTROL_STATE = %00010000
DEF SFXH_FINISH_STATE = %00100000

INCLUDE "hardware.inc"
INCLUDE "debug.inc"



    SECTION "sfx_handler_code", ROM0
set_idle_state:
    ld a, SFXH_IDLE_STATE
    jr set_state
set_init_state:
    ld a, SFXH_INIT_STATE
    jr set_state
set_playing_state:
    ld a , SFXH_PLAYING_STATE
    jr set_state
set_delay_state:
    ld a, SFXH_DELAY_STATE
    jr set_state
set_control_state:
    ld a, SFXH_CONTROL_STATE
    jr set_state
set_finish_state:
    ld a, SFXH_FINISH_STATE
    ; jr set_state
set_state:
    ld [_sfx_automaton_state], a
    ret

;------------------------------
; sfx_update()
; master routine for sfx
; do current state actions
;------------------------------
sfx_update::
    ld a, [_sfx_automaton_state]
    cp a, SFXH_IDLE_STATE
    ret z ; no action for idle
    cp a, SFXH_DELAY_STATE
    jr z, update_delay ; do delay
    cp a, SFXH_PLAYING_STATE
    jr z, update_playing ; copy new values into audio registers
    cp a, SFXH_CONTROL_STATE
    jr z, update_control ; read control byte
    cp a, SFXH_INIT_STATE
    jr z, update_init ; initialize values and take handle (return handle if priority needed)
    cp a, SFXH_FINISH_STATE
    jr z, update_finish ; return instrument handle
    ret ; just in case but should'nt reach

;--------------------
; update_delay()
; decrease delay counter
; if zero -> execute playing state
;--------------------
update_delay:
    ld hl, _wait_counter
    dec [hl]
    ret nz
    call set_playing_state
    jr sfx_update



    SECTION "sfx_handler_variables", WRAM0
_sfx_automaton_state:           DS 1 ; automaton current state
_sfx_effect_control_byte:       DS 1 ; currently playing sfx description byte
_sfx_requested_control_byte:    DS 1 ; currently requested sfx to play
_wait_counter:                  DS 1 ; current value of the wait counter
_sfx_read_addr:                 DS 2 ; addr of current pointer to sfx description table