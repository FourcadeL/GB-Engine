;#####################################
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
;- Instruments_update()       
;-		Called by audio as much as required
;       to update audio hardware registers
; 		Handle audio register and frequencies updates
;--------------------------------------------------------------------------
Instruments_update::
    call _handle_instruments_changes
    call _handle_volume_changes
    call _handle_note_changes
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

; ---------------- Hardware change routines ----------
_ch1_handle_hardware:
    res 7, [hl]
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
; because instruments are still just hardware default values
; and we have no fine handling of volume
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
; because instruments are still just hardware default values
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
    sla a
    ld b, HIGH(_instruments_sheet) ; /!\ instruments_sheet should be a 6 ALIGNED table
    add a, LOW(_instruments_sheet)
    ld c, a ; bc <- instrument pointer
    pop de
    ld hl, CH_hardware_registers ; TODO should be merged with previous values
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