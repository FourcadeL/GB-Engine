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
INCLUDE "utils.inc"
INCLUDE "instruments.inc"



    SECTION "sfx_handler_code", ROM0

; ---------------------------
; sfx_request(a = sfx id)
;   description is %ccpxxxxx
;       cc is the channel of sfx : 00 = ch1 | 01 = ch2 | 10 = ch3 | 11 = ch4
;       p is the priority : 1 = can't bu cut | 0 = can be cut
;       xxxxx is the index in sfx lookup
; 
; set in init state with newly requested sfx
; ---------------------------
sfx_request::
    ld [_sfx_requested_control_byte], a
    MEMBSET [_sfx_saved_state_b_request], [_sfx_automaton_state]
    jr set_init_state ; saves a "ret"
    ; ret


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


;--------------------
; update_delay()
; decrease delay counter
; if zero -> execute playing state
;--------------------
update_delay:
    ld hl, _wait_counter
    dec [hl]
    ret nz ; yield if counter != 0
    call set_playing_state
    jr sfx_update

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


; -----------------
; update_finish()
; decrease wait counter
; when 0 : return handle to instrument
; reset currently playing priority bit
; -----------------
update_finish:
    ld hl, _wait_counter
    dec [hl]
    ret nz ; yield if counter != 0
    call return_current_handle ; return channel handle of currently playing sfx
    ld hl, _sfx_effect_control_byte
    res 5, [hl] ; reset priority
    jr set_idle_state
    ; ret



;----------------------
; update_init()
; see if requested sfx has priority
; True : return currently playing sfx handle, initialize new sfx and set to playing state
; False : restore previous state do update
;----------------------
update_init:
    ld hl, _sfx_effect_control_byte
    bit 5, [hl]
    jr z, .interrupt_current_play
    ; restore previous state and continue
    MEMBSET [_sfx_automaton_state], [_sfx_saved_state_b_request]
    jr sfx_update
.interrupt_current_play
    ; return handle of currently playing sfx
    call return_current_handle
    ld a, [_sfx_requested_control_byte]
    ld [_sfx_effect_control_byte], a
    ; compute new sfx read addr
    and a, %00011111
    sla a
    ld hl, sfx_lookup
    add a, l
    ld l, a
    ; set next read addr to value at lookup
    ld a, [hl+]
    ld d, [hl]
    ld hl, _sfx_read_addr
    ld [hl+], a
    ld [hl], d
    ; take handle of currently playing sfx
    call take_current_handle
    call set_playing_state
    jr sfx_update

; --------------------
; update_control()
; read control byte (increment next read addr)
;   -> if $FF : read another control and set finishing state
;   -> if $XX : set wait_counter and go in delay state
; --------------------
update_control:
    ld hl, _sfx_read_addr
    ld a, [hl+]
    ld h, [hl]
    ld l, a ; hl <- addr of next byte to read
    ld a, [hl+]
    cp a, $FF
    jr nz, .control_read
    ld a, [hl]
    inc a
    ld [_wait_counter], a
    jr set_finish_state ; jump to skip a ret instruction
    ; ret
.control_read
    ; save new read adddr (hl) to _sfx_read_addr
    ld d, h
    ld e, l
    ld hl, _sfx_read_addr
    ld [hl], e
    inc hl
    ld [hl], d ; save complete
    inc a
    ld [_wait_counter], a
    call set_delay_state
    jr sfx_update

; -------------------
; update_playing()
; read and set 4 or 5 bytes of NRXX
; (dependence on _sfx_effect_control_byte)
; -------------------
update_playing:
    ld hl, _sfx_read_addr
    ld a, [hl+]
    ld h, [hl]
    ld l, a ; hl <- addr of next instruction read
    ld a, [_sfx_effect_control_byte]
    and a, %11000000 ; mask for channel control bits
    cp a, %00000000
    jr z, .update_playingCH1
    cp a, %01000000
    jr z, .update_playingCH2
    cp a, %10000000
    jr z, .update_playingCH3
    ; cp a, %11000000
    ; jr z, update_playingCH4
.update_playingCH4
    inc hl ; ignore first byte
    MEMBSET [rNR41], [hl+]
    MEMBSET [rNR42], [hl+]
    MEMBSET [rNR43], [hl+]
    MEMBSET [rNR44], [hl+]
    jr .finalize_playing
.update_playingCH1
    MEMBSET [rNR10], [hl+]
    MEMBSET [rNR11], [hl+]
    MEMBSET [rNR12], [hl+]
    MEMBSET [rNR13], [hl+]
    MEMBSET [rNR14], [hl+]
    jr .finalize_playing
.update_playingCH2
    inc hl ; ignore first byte
    MEMBSET [rNR21], [hl+]
    MEMBSET [rNR22], [hl+]
    MEMBSET [rNR23], [hl+]
    MEMBSET [rNR24], [hl+]
    jr .finalize_playing
.update_playingCH3
    inc hl ; ignore first byte
    MEMBSET [rNR31], [hl+]
    MEMBSET [rNR32], [hl+]
    MEMBSET [rNR33], [hl+]
    MEMBSET [rNR34], [hl+]
    ; jr .finalize_playing
.finalize_playing
    ; save next read addr
    ld a, l
    ld b, h
    ld hl, _sfx_read_addr
    ld [hl+], a
    ld [hl], b
    jp set_control_state ; jump to skip a "ret" instruction
    ; ret


; ----------------------
; return_current_handle
;   return handle on channel of
;   currently playing sfx
; ----------------------
return_current_handle:
    ld a, [_sfx_effect_control_byte]
    and a, %11000000
    cp a, %00000000
    jr z, .ch1Handle
    cp a, %01000000
    jr z, .ch2Handle
    cp a, %10000000
    jr z, .ch3Handle
    ; cp a, %11000000
    ; jr z, .ch4Handle
.ch4Handle
    ld hl, _CH4_instru + CH_flags
    res 6, [hl]
    ret
.ch1Handle
    ld hl, _CH1_instru + CH_flags
    res 6, [hl]
    ret
.ch2Handle
    ld hl, _CH2_instru + CH_flags
    res 6, [hl]
    ret
.ch3Handle
    ld hl, _CH3_instru + CH_flags
    res 6, [hl]
    ret

; ------------------------
; take_current_handle
;   take handle on channel of
;   currently playing sfx
; ------------------------
take_current_handle:
    ld a, [_sfx_effect_control_byte]
    and a, %11000000
    cp a, %00000000
    jr z, .ch1Handle
    cp a, %01000000
    jr z, .ch2Handle
    cp a, %10000000
    jr z, .ch3Handle
    ; cp a, %11000000
    ; jr z, .ch4Handle
.ch4Handle
    ld hl, _CH4_instru + CH_flags
    set 6, [hl]
    ret
.ch1Handle
    ld hl, _CH1_instru + CH_flags
    set 6, [hl]
    ret
.ch2Handle
    ld hl, _CH2_instru + CH_flags
    set 6, [hl]
    ret
.ch3Handle
    ld hl, _CH3_instru + CH_flags
    set 6, [hl]
    ret




    SECTION "sfx_handler_variables", WRAM0
_sfx_automaton_state:           DS 1 ; automaton current state
_sfx_effect_control_byte:       DS 1 ; currently playing sfx description byte
_sfx_requested_control_byte:    DS 1 ; currently requested sfx to play
_sfx_saved_state_b_request:     DS 1 ; saved automaton state when a sfx is requested
_wait_counter:                  DS 1 ; current value of the wait counter
_sfx_read_addr:                 DS 2 ; addr of current pointer to sfx description table