;#####################################
; Audio instruments handler
; hardware handling of audio register
; deals with :
; - notes frequency evaluation
; - volume change
; - instruments changes
;#####################################


    INCLUDE "hardware.inc"
    INCLUDE "engine.inc"
    INCLUDE "debug.inc"
    INCLUDE "utils.inc"
    INCLUDE "instruments.inc"



;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FUNCTIONS                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

    SECTION "Instruments_functions", ROM0
;--------------------------------------------------------------------------
; Instruments_update()
; 	Called by audio as much as required
; 	Handle audio register and frequencies updates
;--------------------------------------------------------------------------
Instruments_update::
    call _handle_instruments_changes
    call _handle_note_changes
    call _dynamic_volume_update
    call _handle_volume_changes
    call _handle_hardware   ; only this call is responsible for hardware registers changes, other functions simply update instruments states variables
    ret

_handle_hardware:
    ld hl, _CH1_instru + CH_flags
    bit 7, [hl]
    call nz, _ch1_handle_hardware
    ld hl, _CH2_instru + CH_flags
    bit 7, [hl]
    call nz, _ch2_handle_hardware
    ld hl, _CH3_instru + CH_flags
    bit 7, [hl]
    call nz, _ch3_handle_hardware
    ld hl, _CH4_instru + CH_flags
    bit 7, [hl]
    call nz, _ch4_handle_hardware
    ret

_handle_instruments_changes:
    ld hl, _CH1_instru + CH_flags
    bit 2, [hl]
    call nz, _ch1_instrument_change
    ld hl, _CH2_instru + CH_flags
    bit 2, [hl]
    call nz, _ch2_instrument_change
    ld hl, _CH3_instru + CH_flags
    bit 2, [hl]
    call nz, _ch3_instrument_change
    ld hl, _CH4_instru + CH_flags
    bit 2, [hl]
    call nz, _ch4_instrument_change
    ret

_handle_volume_changes:
    ld hl, _CH1_instru + CH_flags
    bit 1, [hl]
    call nz, _ch1_volume_change
    ld hl, _CH2_instru + CH_flags
    bit 1, [hl]
    call nz, _ch2_volume_change
    ld hl, _CH3_instru + CH_flags
    bit 1, [hl]
    call nz, _ch3_volume_change
    ld hl, _CH4_instru + CH_flags
    bit 1, [hl]
    call nz, _ch4_volume_change
    ret

_handle_note_changes:
    ld hl, _CH1_instru + CH_flags
    bit 0, [hl]
    call nz, _ch1_note_change
    ld hl, _CH2_instru + CH_flags
    bit 0, [hl]
    call nz, _ch2_note_change
    ld hl, _CH3_instru + CH_flags
    bit 0, [hl]
    call nz, _ch3_note_change
    ld hl, _CH4_instru + CH_flags
    bit 0, [hl]
    call nz, _ch4_note_change
    ret


_dynamic_volume_update:
    ld hl, _CH1_instru + CH_VOL_state
    bit 0, [hl]
    call nz, _ch1_dynamic_volume_update
    ld hl, _CH2_instru + CH_VOL_state
    bit 0, [hl]
    call nz, _ch2_dynamic_volume_update
    ld hl, _CH3_instru + CH_VOL_state
    bit 0, [hl]
    call nz, _ch3_dynamic_volume_update
    ld hl, _CH4_instru + CH_VOL_state
    bit 0, [hl]
    call nz, _ch4_dynamic_volume_update
    ret

;------------------ Dynamic volume change routines ----------
_ch1_dynamic_volume_update:
    ld de, _CH1_instru
    jr _common_dynamic_volume_update
_ch2_dynamic_volume_update:
    ld de, _CH2_instru
    jr _common_dynamic_volume_update
_ch3_dynamic_volume_update:
    ld de, _CH3_instru
    jr _common_dynamic_volume_update
_ch4_dynamic_volume_update:
    ld de, _CH4_instru
    ; jr _common_dynamic_volume_update
_common_dynamic_volume_update:
    ld hl, CH_VOL_state
    add hl, de
    push hl
    bit 1, [hl]
        call nz, _common_dynamic_volume_do_wait
    pop hl
    bit 1, [hl]
        ret nz
        ; get current modifier
    ld hl, CH_VOL_modifiers_table
    add hl, de ; hl <- addr of pointer to modifier table
    ld a, [hl+]
    ld b, [hl]
    ld hl, CH_VOL_modifier_index
    add hl, de ; hl <- addr of index to modifier table
    add a, [hl]
    inc [hl]
    jr nc, .finalize_modifier_addr
    inc b
.finalize_modifier_addr
    ld c, a ; bc <- addr to current modifier
    ld a, [bc] ; a <- current modifier
    bit 6, a ; (%01xxxxxx) -> set wait control sequence
        jr nz, _common_dynamic_volume_set_wait
    cp a, %10000000 ; end sequence of modifier table
        jr z, _common_dynamic_volume_shut_off
    and a, %00011111
    ld hl, CH_VOL_base_volume
    add hl, de
    ld b, [hl] ; b <- base volume
        ; ------ apply modifier to base volume
        ; see note on 5 bit modifier for detail 
    add a, b
    push af
    pop hl ; l gives the result of half carry on bit 5
    bit 4, a
    jr z, .set_new_current_volume ; bit 4 to 0 -> addition or substraction is ok
    bit 5, l
    jr z, .semi_overflow_correct_substraction
    ld a, $0F ; correct addition
    jr .set_new_current_volume
.semi_overflow_correct_substraction
    ld a, $00; correct substraction
.set_new_current_volume
    and a, %00001111
    ld hl, CH_curr_volume
    add hl, de
    ld [hl], a
    ld hl, CH_flags
    add hl, de ; hl <- current instrument flags
    set 1, [hl] ; new volume set (should change registers and replay note)
    ret
_common_dynamic_volume_set_wait:
    and a, %00111111
    ld hl, CH_VOL_wait_counter
    add hl, de
    ld [hl], a
    ld hl, CH_VOL_state
    add hl, de
    set 1, [hl]
    ret
_common_dynamic_volume_do_wait:
    ld hl, CH_VOL_wait_counter
    add hl, de ; hl <- addr of channel volume wait counter
    dec [hl]
    ret nz
    ld hl, CH_VOL_state
    add hl, de
    res 1, [hl]
    ret
_common_dynamic_volume_shut_off:
    ld hl, CH_VOL_modifier_index
    add hl, de ; hl <- addr of modifier index
    ld a, $00
    ld [hl], a
    ld hl, CH_VOL_state
    add hl, de
    ld [hl], a ; reset state to stopped
    ret

; ---------------- Hardware change routines ----------
_ch1_handle_hardware:
    res 7, [hl]
    bit 6, [hl]
    ret nz ; return if handle is taken
    ld de, _CH1_instru
    ld hl, CH_note_value
    add hl, de
    ld a, [hl]
    ld hl, _CH1_blank_instrument
    cp a, BLANK_NOTE
    jr z, .set_registers
        ld hl, CH_hardware_registers
        add hl, de
.set_registers
    MEMBSET [rNR10], [hl+]
    MEMBSET [rNR11], [hl+]
    MEMBSET [rNR12], [hl+]
    MEMBSET [rNR13], [hl+]
    MEMBSET [rNR14], [hl]
    ret
_ch2_handle_hardware:
    res 7, [hl]
    bit 6, [hl]
    ret nz ; return if handle is taken
    ld de, _CH2_instru
    ld hl, CH_note_value
    add hl, de
    ld a, [hl]
    ld hl, _CH2_blank_instrument
    cp a, BLANK_NOTE
    jr z, .set_registers
        ld hl, CH_hardware_registers + 1
        add hl, de
.set_registers
    MEMBSET [rNR21], [hl+]
    MEMBSET [rNR22], [hl+]
    MEMBSET [rNR23], [hl+]
    MEMBSET [rNR24], [hl]
    ret
_ch3_handle_hardware:
    res 7, [hl]
    bit 6, [hl]
    ret nz ; return if handle is taken
    ld de, _CH3_instru
    ld hl, CH_note_value
    add hl, de
    ld a, [hl]
    ld hl, _CH3_blank_instrument
    cp a, BLANK_NOTE
    jr z, .set_registers
        ld hl, CH_hardware_registers + 1
        add hl, de
.set_registers
    MEMBSET [rNR31], [hl+]
    MEMBSET [rNR32], [hl+]
    MEMBSET [rNR33], [hl+]
    MEMBSET [rNR34], [hl]
    ret
_ch4_handle_hardware:
    res 7, [hl]
    bit 6, [hl]
    ret nz ; return if handle is taken
    ld de, _CH4_instru
    ld hl, CH_note_value
    add hl, de
    ld a, [hl]
    ld hl, _CH4_blank_instrument
    cp a, BLANK_NOTE
    jr z, .set_registers
        ld hl, CH_hardware_registers + 1
        add hl, de
.set_registers
    MEMBSET [rNR41], [hl+]
    MEMBSET [rNR42], [hl+]
    MEMBSET [rNR43], [hl+]
    MEMBSET [rNR44], [hl]
    ret
; ----------------------------------------------------

; -------------- Note change routines ------------
_ch1_note_change:
    ld hl, _CH1_instru + CH_flags
    res 0, [hl]
    set 7, [hl]
    ld de, _CH1_instru
    ld hl, CH_note_value
    add hl, de
    ld a, [hl]
    push de
    call Audio_get_note_frequency12
    pop de
    jr _common_note_change
_ch2_note_change:
    ld hl, _CH2_instru + CH_flags
    res 0, [hl]
    set 7, [hl]
    ld de, _CH2_instru
    ld hl, CH_note_value
    add hl, de
    ld a, [hl]
    push de
    call Audio_get_note_frequency12
    pop de
    jr _common_note_change
_ch3_note_change:
    ld hl, _CH3_instru + CH_flags
    res 0, [hl]
    set 7, [hl]
    ld de, _CH3_instru
    ld hl, CH_note_value
    add hl, de
    ld a, [hl]
    push de
    call Audio_get_note_frequency3
    pop de
    jr _common_note_change
_ch4_note_change:
    ld hl, _CH4_instru + CH_flags
    res 0, [hl]
    set 7, [hl]
    ld de, _CH4_instru
    ld hl, CH_note_value
    add hl, de
    ld a, [hl]
    push de
    call Audio_get_note_frequency4
    pop de
_common_note_change: ; de is the base addr of instrument to change | bc is the frequency to use
    ld hl, CH_VOL_state
    add hl, de
    set 0, [hl] ; wake up dynamic volume modifier
    res 1, [hl] ; reset wait state of dynamic volume modifier
    ld hl, CH_VOL_modifier_index
    add hl, de
    ld [hl], $00 ; reset modifier index
    ld hl, CH_hardware_registers + 3
    add hl, de
    ld [hl], c
    inc hl
    ld a, [hl]
    and a, %11000000
    or a, b
    ld [hl], a
    ret
; ------------------------------------------------

; ------------- Volume change routines -----------
; change volume in shadow registers
_ch1_volume_change:
    ld hl, _CH1_instru + CH_flags
    ld de, _CH1_instru
    jr _common_volume_change
_ch2_volume_change:
    ld hl, _CH2_instru + CH_flags
    ld de, _CH2_instru
    jr _common_volume_change
_ch3_volume_change:
    ld hl, _CH3_instru + CH_flags
    ld de, _CH3_instru
    jr _common_volume_change
_ch4_volume_change:
    ld hl, _CH4_instru + CH_flags
    ld de, _CH4_instru
_common_volume_change: ; de is the base addr of volume to change instru
    res 1, [hl]
    set 7, [hl]
    ld hl, CH_curr_volume
    add hl, de
    ld b, [hl]
    swap b
    ld hl, CH_hardware_registers + 2
    add hl, de
    ld a, [hl]
    and a, %00001111
    or a, b
    ld [hl], a
    ret
; ------------------------------------------------

; -------------Instrument change routines ---------
; change instruments directly in hardware registers to use
_ch1_instrument_change:
    ld hl, _CH1_instru + CH_flags
    jr _common_instrument_change
_ch2_instrument_change:
    ld hl, _CH2_instru + CH_flags
    jr _common_instrument_change
_ch3_instrument_change:
    ld hl, _CH3_instru + CH_flags
    jr _common_instrument_change
_ch4_instrument_change: 
    ld hl, _CH4_instru + CH_flags

_common_instrument_change: ; hl is the base addr of instrument to change
    res 2, [hl]
    set 7, [hl]
    push hl
    ld b, $00
    ld c, CH_curr_instrument_index
    add hl, bc ; hl <- pointer to instrument to use index
    ld a, [hl] ; a <- instrument to use index
    sla a
    ld h, HIGH(_instruments_lookup) ; /!\ instruments_lookup should be a 6 ALIGNED table
    add a, LOW(_instruments_lookup)
    ld l, a ; hl <- pointer to instrument loockup
    ld a, [hl+]
    ld b, [hl]
    ld c, a ; bc <- pointer to instrument to use
    pop de
    ld hl, CH_hardware_registers ; TODO should be merged with previous values
        ; ------ copy of instrument in shadow hardware registers
    add hl, de ; hl <- pointer to copy data
    ld a, [bc]
    inc bc
    ld [hl+], a ; set of shadow NRX0
    ld a, [bc]
    inc bc
    ld [hl+], a ; set of shadow NRX1
    ld a, [bc]
    inc bc
    ld [hl+], a ; set of shadow NRX2
    inc hl
    ld a, [bc]
    ld [hl], a ; set of shadow NRX4
        ; ------ copy of pointer to volume modulation table
    inc bc ; bc <- volume modulation table pointer
    ld hl, CH_VOL_modifiers_table
    add hl, de ; hl <- pointer to CH_VOL_modifiers_table of current instrument
    ld [hl], c
    inc hl
    ld [hl], b
    ret

; ------------------------------------------------------------

    SECTION "Blank_Instruments", ROMX
; small section of save register for "instruments"
; stopping play of the note on each channel
_CH1_blank_instrument:
    DB %00000000 ; NR10 (no sweep)
    DB %00111111 ; NR11 (duty and smallest length play)
    DB %00001000 ; NR12 (volume = 0 ; sweep up to avoid pop)
    DB %00000000 ; NR13 (empty freq)
    DB %10000000 ; NR14 (retriggers channel to mute audio)
_CH2_blank_instrument:  
    DB %00111111 ; NR21 (duty and smallest length play)
    DB %00001000 ; NR22 (volume = 0 ; sweep up to avoid pop)
    DB %00000000 ; NR23 (empty freq)
    DB %10000000 ; NR24 (retriggers channel to mute audio)
_CH3_blank_instrument:
    DB %11111111 ; NR31 (smallest length play)
    DB %00000000 ; NR32 (volume to 0)
    DB %00000000 ; NR33 (empty freq)
    DB %10000000 ; NR34 (retriggers channel)
_CH4_blank_instrument:
    DB %00111111 ; NR41 (smallest length play)
    DB %00001000 ; NR42 (volume = 0 ; sweep up to avoid pop)
    DB %00000000 ; NR33 (empty freq)
    DB %10000000 ; NR44 (retriggers channel to mute audio)

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

    SECTION "Instruments_Variables", WRAM0

; --------- channel 1 ----------
_CH1_instru::		 DS SIZEOF_instrument_struct
; --------- channel 2 ----------
_CH2_instru::        DS SIZEOF_instrument_struct
; --------- channel 3 ----------
_CH3_instru::        DS SIZEOF_instrument_struct
; --------- channel 4 ----------
_CH4_instru::        DS SIZEOF_instrument_struct
