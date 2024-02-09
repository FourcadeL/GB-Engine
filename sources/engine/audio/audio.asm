;#####################################
;definition audio (compléter engine.inc)
;audio contient les fonctions de manipulation et de gestion des sons, ainsi que tout le moteur sonore associé
;#####################################


	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"
	INCLUDE "debug.inc"
	INCLUDE "utils.inc"
	INCLUDE "tracker.inc"






;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FUNCTIONS                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "Audio_Functions",ROM0



;--------------------------------------------------------------------------
;- Audio_off()       
;-			Stops all audio activity (overwrites audio control registers)                                -
;--------------------------------------------------------------------------

Audio_off::

	ld		a, $00
	ld		[rNR50], a	;stop master volume and external inputs
	ld		[rNR51], a  ;no outputs to SO1 and SO2
	ld		[rNR52], a	;stop de tous les circuits audios
	ret




;--------------------------------------------------------------------------
;- Audio_init(b=trackers speed ; StackPush : $WWXX $YYZZ)       
;-		Initialisation basique des registres audio (peut être modifié)
;-		volumes max toutes les chaines sur tout les terminaux
;  		
; 		Initialises tracker speed to b
; 		Initializes channels trackers with block start addr pushed on stack
; 			CH1 : $WW
; 			CH2 : $XX
; 			CH3 : $YY
; 			CH4 : $ZZ
;--------------------------------------------------------------------------
Audio_init::
	MEMBSET [rNR52], $FF ; enable all channels
	MEMBSET [rNR50], $77 ; max volume and no external input
	MEMBSET [rNR51], $FF ; all channels on all terminals

	; ---- init variables -----
	ld hl, _trackers_speed
	ld [hl], b ; init tracker speed
	ld hl, _trackers_update_counter
	ld a, $01
	ld [hl], a ; reset counter (1 to force update of first frame)
	ld hl, _trackers_stepped
	res 7, [hl] ; reset tracker stepped

	; ---- init 4 channel trackers -------
	ld bc, _CH1_track
	ld hl, sp+5
	ld a, [hl-]
	ld e, a ; e <- $WW
	push hl
	call tracker_init ; CH1 init

	pop hl
	ld bc, _CH2_track
	ld a, [hl-]
	ld e, a ; e <- $XX
	push hl
	call tracker_init ; CH2 init

	pop hl
	ld bc, _CH3_track
	ld a, [hl-]
	ld e, a ; e <- $YY
	push hl
	call tracker_init ; CH3 init

	pop hl
	ld bc, _CH4_track
	ld e, [hl] ; e <- $ZZ
	call tracker_init

	ret




;--------------------------------------------------------------------------
;- Audio_update()       
;-		Called once per frame
; 		Handle tracker updates
; 		Handle audio register and frequencies updates
;--------------------------------------------------------------------------
Audio_update::
	call handle_trackers
	call handle_new_notes
	ret






;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FONCTIONS UTILITAIRES                          | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


;------------------------------------------------------------------------------------------
;- handle_trackers()  
;-	if tracker counter tripped update all channels trackers
; 		set bit 7 of _tracker_stepped if stepped
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

	ld hl, _trackers_stepped
	set 7, [hl] ; tracker stepped
	ret

; --------------------------------------------------------------------
; handle_new_notes()
; 	if tracker has been stepped and a tracker is in a new note step
; 		updates hardware register for new note
; --------------------------------------------------------------------
handle_new_notes:
	ld hl, _trackers_stepped
	bit 7, [hl]
	ret z ; no trackers step -> return
	res 7, [hl] ; note handling -> reset tracker step flag

	ld bc, _CH1_track
	call tracker_new_note_state
	jr nz, .skip_CH1_new_note
	call tracker_get_note
	call Audio_get_note_frequency12
	call _update_CH1_freq
.skip_CH1_new_note

	ld bc, _CH2_track
	call tracker_new_note_state
	jr nz, .skip_CH2_new_note
	call tracker_get_note
	call Audio_get_note_frequency12
	call _update_CH2_freq
.skip_CH2_new_note

	ld bc, _CH3_track
	call tracker_new_note_state
	jr nz, .skip_CH3_new_note
	call tracker_get_note
	call Audio_get_note_frequency3
	call _update_CH3_freq
.skip_CH3_new_note

	ld bc, _CH4_track
	call tracker_new_note_state
	jr nz, .skip_CH4_new_note
	call tracker_get_note
	call Audio_get_note_frequency4
	call _update_CH4_freq
.skip_CH4_new_note
	ret

; ------------------------
; frequencies updates
; 	fixed instrument parameters now
; 	to be implemented later
; ------------------------
_update_CH1_freq:
	MEMBSET [rNR10], $00
    MEMBSET [rNR11], $80
    MEMBSET [rNR12], $F1
    MEMBSET [rNR13], c
    ld a, b
    or %11000000
    ld [rNR14], a
	ret
_update_CH2_freq:
	ret
_update_CH3_freq:
	ret
_update_CH4_freq:
	ret
;------------------------------------------------------------------------------------------
;- Audio_set_CH3_wave_pattern(hl = pattern addr)
; expected pattern size is 16 bytes
;- CH3 is disabled during pattern copy to avoid audio pop
;- sound output levels are reset after function call
;------------------------------------------------------------------------------------------
Audio_set_wave_pattern::
	; reset output level to prevent audio pop
	MEMBSET [rNR32], $00
	MEMBSET [rNR34], $80
	; disable DAC
	MEMBSET [rNR30], $00
	;pattern copy
	ld		de, _AUD3WAVERAM
	ld		b, $10
	call memcopy_fast
	; enable DAC
	MEMBSET [rNR30], $80
	ret






;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "Audio_Variables",WRAM0

_trackers_speed:		DS 1 ; update speed of tracker (0 -> once per call, 1 -> every two call, etc)
_trackers_update_counter:	DS 1 ; update counter of tracker
_trackers_stepped:	DS 1 ; %bxxxxxxx -> b : 1 if tracker has been stepped

;channel 1 tracker
_CH1_track:			DS SIZEOF_tracker_struct

;channel 2 tracker
_CH2_track:			DS SIZEOF_tracker_struct

;channel 3 tracker
_CH3_track:			DS SIZEOF_tracker_struct

;channel 4 tracker
_CH4_track:			DS SIZEOF_tracker_struct




