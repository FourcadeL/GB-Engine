;#####################################
; Audio handler
; Defines the main audio control routines
;#####################################


    INCLUDE "hardware.inc"
    INCLUDE "engine.inc"
    INCLUDE "debug.inc"
    INCLUDE "utils.inc"
    INCLUDE "tracker.inc"


def BLANK_NOTE = %01011111



;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FUNCTIONS                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


    SECTION "Audio_Functions", ROM0



;--------------------------------------------------------------------------
; Audio_off()       
;   Stops all audio activity
;   (overwrites audio control registers)                                -
;--------------------------------------------------------------------------

Audio_off::

    ld      a, $00
    ld      [rNR50], a  ;stop master volume and external inputs
    ld      [rNR51], a  ;no outputs to SO1 and SO2
    ld      [rNR52], a  ;stop de tous les circuits audios
    ret




;--------------------------------------------------------------------------
; Audio_init(b=trackers speed)       
;   Initialises audio registers and channels trackers
;   Initialises tracker speed to b
;--------------------------------------------------------------------------
Audio_init::
    MEMBSET [rNR52], $FF ; enable all channels
    MEMBSET [rNR50], $77 ; max volume and no external input
    MEMBSET [rNR51], $FF ; all channels on all terminals

    ; ---- init variables -----
    ld hl, _trackers_speed
    ld [hl], b          ; init tracker speed
    ld hl, _trackers_update_counter
    ld a, $01
    ld [hl], a          ; reset counter (1 to force update of first frame)
    ld hl, _trackers_flags
    res 7, [hl]         ; reset tracker stepped
    ret

; ------------------------------------------------------------------------
; Audio_load_song(hl = songAddr)
;   Initialises channels trackers with block start addr at song addr
;   Song addr contains $WWWW ; $XXXX ; $YYYY ; $ZZZZ (little endian)
;           CH1 : $WWWW
;           CH2 : $XXXX
;           CH3 : $YYYY
;           CH4 : $ZZZZ
;--------------------------------------------------------------------------
Audio_load_song::
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a             ; de <- $WWWW
    push hl
    ld bc, _CH1_instru
    push bc
    push de
    ld bc, _CH1_track
    call tracker_init   ; CH1 set
    pop de
    pop de
    pop hl
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a             ; de <- $XXXX
    push hl
    ld bc, _CH2_instru
    push bc
    push de
    ld bc, _CH2_track
    call tracker_init   ; CH2 set
    pop de
    pop de
    pop hl
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a             ; de <- $YYYY
    push hl
    ld bc, _CH3_instru
    push bc
    push de
    ld bc, _CH3_track
    call tracker_init   ; CH3 set
    pop de
    pop de
    pop hl
    ld a, [hl+]
    ld e, a
    ld d, [hl]          ; de <- $ZZZZ
    ld bc, _CH4_instru
    push bc
    push de
    ld bc, _CH4_track
    call tracker_init   ; CH4 set
    pop de
    pop de
    ret

; -----------------------------------------------
; Audio_start_song
;   Start trackers
;------------------------------------------------
Audio_start_song::
    ld bc, _CH1_track
    call tracker_start
    ld bc, _CH2_track
    call tracker_start
    ld bc, _CH3_track
    call tracker_start
    ld bc, _CH4_track
    call tracker_start
    ret

; ------------------------------------------------
; Audio_stop_song
;   Play blank note on each instrument
;   And set trackers to end state
; ------------------------------------------------
Audio_stop_song::
    ld bc, _CH1_track
    call tracker_stop
    ld bc, _CH2_track
    call tracker_stop
    ld bc, _CH3_track
    call tracker_stop
    ld bc, _CH4_track
    call tracker_stop
    ret

;--------------------------------------------------------------------------
; Audio_update()       
;   Called once per frame
;   Handle sfx automaton update [registers update]
;   Handle instruments update (note, volume, instrument changes) [registers update]
;   Handle tracker updates
;   Handle Volume and instrument changes (notes parameters)
;   Handle audio register and frequencies updates
;--------------------------------------------------------------------------
Audio_update::
    call sfx_update
    call Instruments_update
    call handle_trackers
    ret

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FONCTIONS UTILITAIRES                          | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


;------------------------------------------------------------------------------------------
; handle_trackers()  
;   if tracker counter tripped update all channels trackers
;   set bit 7 of _tracker_stepped if stepped
;------------------------------------------------------------------------------------------
handle_trackers:
    ld hl, _trackers_update_counter
    dec [hl]
    ret nz ; no counter trip
    ld a, [_trackers_speed]
    inc a
    ld [hl], a ; reset counter

    ld bc, _CH1_track
    call tracker_step
    ld bc, _CH2_track
    call tracker_step
    ld bc, _CH3_track
    call tracker_step
    ld bc, _CH4_track
    call tracker_step

    ld hl, _trackers_flags
    set 7, [hl] ; tracker stepped
    ret

;------------------------------------------------------------------------------------------
; Audio_set_CH3_wave_pattern(hl = pattern addr)
;    expected pattern size is 16 bytes
;    CH3 is disabled during pattern copy to avoid audio pop
;    sound output levels are reset after function call
;------------------------------------------------------------------------------------------
Audio_set_wave_pattern::
    ; reset output level to prevent audio pop
    MEMBSET [rNR32], $00
    MEMBSET [rNR34], $80
    ; disable DAC
    MEMBSET [rNR30], $00
    ;pattern copy
    ld      de, _AUD3WAVERAM
    ld      b, $10
    call memcopy_fast
    ; enable DAC
    MEMBSET [rNR30], $80
    ret



;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


    SECTION "Audio_Variables", WRAM0

_trackers_speed:            DS 1 ; update speed of tracker (0 -> once per call, 1 -> every two call, etc)
_trackers_update_counter:   DS 1 ; update counter of tracker
_trackers_flags:            DS 1 ; %bxxxxxxx -> b : 1 if tracker has been stepped

;channel 1 tracker
_CH1_track:                 DS SIZEOF_tracker_struct

;channel 2 tracker
_CH2_track:                 DS SIZEOF_tracker_struct

;channel 3 tracker
_CH3_track:                 DS SIZEOF_tracker_struct

;channel 4 tracker
_CH4_track:                 DS SIZEOF_tracker_struct




