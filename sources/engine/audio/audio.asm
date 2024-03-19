;#####################################
;definition audio (compléter engine.inc)
;audio contient les fonctions de manipulation et de gestion des sons, ainsi que tout le moteur sonore associé
;#####################################


	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"
	INCLUDE "debug.inc"
	INCLUDE "utils.inc"
	INCLUDE "tracker.inc"


def BLANK_NOTE = %01010100 



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
;- Audio_init(b=trackers speed)       
;-		Initialisation basique des registres audio (peut être modifié)
;-		volumes max toutes les chaines sur tout les terminaux
;  		
; 		Initialises tracker speed to b
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
	ld hl, _trackers_flags
	res 7, [hl] ; reset tracker stepped
	ret

; ------------------------------------------------------------------------
; Audio_load_song(hl = songAddr)
; Initializes channels trackers with block start addr at song addr
; Song addr contains $WWWW ; $XXXX ; $YYYY ; $ZZZZ (little endian)
; 			CH1 : $WWWW
; 			CH2 : $XXXX
; 			CH3 : $YYYY
; 			CH4 : $ZZZZ
;--------------------------------------------------------------------------
Audio_load_song::
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ; de <- $WWWW
	ld bc, _CH1_track
	push hl
	call tracker_init ; CH1 set
	pop hl
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ; de <- $XXXX
	push hl
	ld bc, _CH2_track
	call tracker_init ; CH2 set
	pop hl
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ; de <- $YYYY
	ld bc, _CH3_track
	push hl
	call tracker_init ; CH3 set
	pop hl
	ld a, [hl+]
	ld e, a
	ld d, [hl] ; de <- $ZZZZ
	ld bc, _CH4_track
	call tracker_init ; CH4 set
	ret

; -----------------------------------------------
; Audio_start_song
;		Start trackers to start playing audio
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

; -----------------------------------------------
; Audio_set_instruments_sheet_pointer(de = pointer)
; 	/!\ de must be a 6 ALIGNED pointer (%XX000000)
; -----------------------------------------------
Audio_set_instruments_sheet_pointer::
	ld hl, _instruments_sheet_pointer
	ld a, e
	ld [hl+], a
	ld [hl], d
	ret


;--------------------------------------------------------------------------
;- Audio_update()       
;-		Called once per frame
; 		Handle tracker updates
; 		Handle Volume and instrument changes (notes parameters)
; 		Handle audio register and frequencies updates
;--------------------------------------------------------------------------
Audio_update::
	call handle_new_notes
	call handle_trackers
.loop_for_parameters
	call handle_note_parameters
	ld hl, _trackers_flags
	bit 5, [hl]
	jr nz, .loop_for_parameters ; loop (multiple parameters command can chain)
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

	ld hl, _trackers_flags
	set 7, [hl] ; tracker stepped
	ret

; --------------------------------------------------------------------
; handle_new_notes()
; 	if tracker has been stepped and a tracker is in a new note step
; 		updates hardware register for new note
; --------------------------------------------------------------------
handle_new_notes:
	ld hl, _trackers_flags
	bit 7, [hl]
	ret z ; no trackers step -> return
	res 7, [hl] ; note handling -> reset tracker step flag

	ld bc, _CH1_track
	call tracker_new_note_state
	jr nz, .skip_CH1_new_note
	call _update_CH1_note
.skip_CH1_new_note

	ld bc, _CH2_track
	call tracker_new_note_state
	jr nz, .skip_CH2_new_note
	call _update_CH2_note
.skip_CH2_new_note

	ld bc, _CH3_track
	call tracker_new_note_state
	jr nz, .skip_CH3_new_note
	call _update_CH3_note
.skip_CH3_new_note

	ld bc, _CH4_track
	call tracker_new_note_state
	jr nz, .skip_CH4_new_note
	call _update_CH4_note
.skip_CH4_new_note
	ret

; -------------------------------------------
; handle_note_parameters()
;  		If tracker has been stepped, tracker is in new note state
; 		and the note is a contrôl note
; 		execute contrôl and force step tracker again until new note
; -------------------------------------------
handle_note_parameters:
	ld hl, _trackers_flags
	bit 7, [hl]
	ret z ; no tracker step -> return
	res 5, [hl] ; reset parameter set flag

	ld bc, _CH1_track
	call tracker_new_note_state
	jr nz, .skip_CH1
	call tracker_get_note
	cp a, (BLANK_NOTE + 1)
	jr c, .skip_CH1 ; carry -> standard note
	call _update_CH1_parameter
	call set_fetch_state
	call tracker_update
	ld hl, _trackers_flags
	set 5, [hl] ; set modified parameter flag
.skip_CH1

	ld bc, _CH2_track
	call tracker_new_note_state
	jr nz, .skip_CH2
	call tracker_get_note
	cp a, (BLANK_NOTE + 1)
	jr c, .skip_CH2 ; carry -> standard note
	call _update_CH2_parameter
	call set_fetch_state
	call tracker_update
	ld hl, _trackers_flags
	set 5, [hl] ; set modified parameter flag
.skip_CH2

	ld bc, _CH3_track
	call tracker_new_note_state
	jr nz, .skip_CH3
	call tracker_get_note
	cp a, (BLANK_NOTE + 1)
	jr c, .skip_CH3 ; carry -> standard note
	call _update_CH3_parameter
	call set_fetch_state
	call tracker_update
	ld hl, _trackers_flags
	set 5, [hl] ; set modified parameter flag
.skip_CH3

	ld bc, _CH4_track
	call tracker_new_note_state
	jr nz, .skip_CH4
	call tracker_get_note
	cp a, (BLANK_NOTE + 1)
	jr c, .skip_CH4 ; carry -> standard note
	call _update_CH4_parameter
	call set_fetch_state
	call tracker_update
	ld hl, _trackers_flags
	set 5, [hl] ; set modified parameter flag
.skip_CH4
	ret

; --------------------------------------
; notes parameters update
; 		handle note parameter
; --------------------------------------
; ----------------------------------------------------------------------------
; _update_CH1_parameter(a = note parameter) |current working tracker is CH1|
; 	update instrument and hardware register for channel 1
; ----------------------------------------------------------------------------
_update_CH1_parameter:
	bit 5, a
	jr z, .3bitParameter
	bit 4, a
	jr z, .volumeParameter
		; instrumentParameter
		call _get_instrument_pointer ; hl <- pointer to new_instrument
		call _set_CH1_instrument
		ret
.volumeParameter
	ld hl, _CH1_instrument
	inc hl
	inc hl
	call _set_instrument_volume
	ret
.3bitParameter
	; unused
	ret

; ----------------------------------------------------------------------------
; _update_CH2_parameter(a = note parameter) |current working tracker is CH2|
; 	update instrument and hardware register for channel 2
; ----------------------------------------------------------------------------
_update_CH2_parameter:
	bit 5, a
	jr z, .3bitParameter
	bit 4, a
	jr z, .volumeParameter
		; instrumentParameter
		call _get_instrument_pointer ; hl <- pointer to new_instrument
		call _set_CH2_instrument
		ret
.volumeParameter
	ld hl, _CH2_instrument
	inc hl
	call _set_instrument_volume
	ret
.3bitParameter
	; unused
	ret

; ----------------------------------------------------------------------------
; _update_CH3_parameter(a = note parameter) |current working tracker is CH3|
; 	update instrument and hardware register for channel 3
; ----------------------------------------------------------------------------
_update_CH3_parameter:
	bit 5, a
	jr z, .3bitParameter
	bit 4, a
	jr z, .volumeParameter
		; instrumentParameter
		call _get_instrument_pointer ; hl <- pointer to new_instrument
		call _set_CH3_instrument
		ret
.volumeParameter
	ld hl, _CH3_instrument
	inc hl
	call _set_instrument_volume
	ret
.3bitParameter
	; unused
	ret

; ----------------------------------------------------------------------------
; _update_CH4_parameter(a = note parameter) |current working tracker is CH4|
; 	update instrument and hardware register for channel 4
; ----------------------------------------------------------------------------
_update_CH4_parameter:
	bit 5, a
	jr z, .3bitParameter
	bit 4, a
	jr z, .volumeParameter
		; instrumentParameter
		call _get_instrument_pointer ; hl <- pointer to new_instrument
		call _set_CH4_instrument
		ret
.volumeParameter
	ld hl, _CH4_instrument
	inc hl
	call _set_instrument_volume
	ret
.3bitParameter
	; unused
	ret

; ------------------------
; notes update
; 	handle blank note
; 	use data from instrument saved parameters
; ------------------------
; --------------------------------------------------------------------
; _update_CH1_note() |current working tracker must have been initialized to CH1 tracker|
; 		updates hardware registers for channel 1 to play
; 		the note of the currently working tracker
; -----------------------------------------------------------------
_update_CH1_note:
	call tracker_get_note
	ld hl, _CH1_blank_instrument
	cp a, BLANK_NOTE ; is blank note
	jr z, .set_registers
		; note is not blank -> get frequency and use standard CH1 instrument
		call Audio_get_note_frequency12
		ld hl, _CH1_instrument
.set_registers
	MEMBSET [rNR10], [hl+]
	MEMBSET [rNR11], [hl+]
	MEMBSET [rNR12], [hl+]
	MEMBSET [rNR13], c
	ld a, b
	and %00000111
	or [hl]
	ld [rNR14], a
	ret

; ------------------------------------------------------------------
; _update_CH2_note() |current working tracker must have been initialized to CH2 tracker|
; 		updates hardware registers for channel 2 to play
; 		the note of the currently working tracker
; -----------------------------------------------------------------
_update_CH2_note:
	call tracker_get_note
	ld hl, _CH2_blank_instrument
	cp a, BLANK_NOTE ; is blank note
	jr z, .set_registers
		; note is not blank -> get frequency and use standard CH2 instrument
		call Audio_get_note_frequency12
		ld hl, _CH2_instrument
.set_registers
	MEMBSET [rNR21], [hl+]
	MEMBSET [rNR22], [hl+]
	MEMBSET [rNR23], c
	ld a, b
	and %00000111
	or [hl]
	ld [rNR24], a
	ret

; ------------------------------------------------------------------
; _update_CH3_note() |current working tracker must have been initialized to CH3 tracker|
; 		updates hardware registers for channel 3 to play
; 		the note of the currently working tracker
; -----------------------------------------------------------------
_update_CH3_note:
	call tracker_get_note
	ld hl, _CH3_blank_instrument
	cp a, BLANK_NOTE ; is blank note
	jr z, .set_registers
		; note is not blank -> get frequency and use standard CH3 instrument
		call Audio_get_note_frequency3
		ld hl, _CH3_instrument
.set_registers
	MEMBSET [rNR31], [hl+]
	MEMBSET [rNR32], [hl+]
	MEMBSET [rNR33], c
	ld a, b
	and %00000111
	or [hl]
	ld [rNR34], a
	ret

; ------------------------------------------------------------------
; _update_CH4_note() |current working tracker must have been initialized to CH4 tracker|
; 		updates hardware registers for channel 4 to play
; 		the note of the currently working tracker
; -----------------------------------------------------------------
_update_CH4_note:
	call tracker_get_note
	ld hl, _CH4_blank_instrument
	cp a, BLANK_NOTE ; is blank note
	jr z, .set_registers
		; note is not blank -> get frequency and use standard CH4 instrument
		call Audio_get_note_frequency4
		ld hl, _CH4_instrument
.set_registers
	MEMBSET [rNR41], [hl+]
	MEMBSET [rNR42], [hl+]
	MEMBSET [rNR43], c
	ld a, b
	and %00000111
	or [hl]
	ld [rNR44], a
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


; ---------------------------------
; _set_CH2_instrument(hl = pointer to instrument data)
; ---------------------------------
_set_CH2_instrument:
	ld de, _CH2_instrument
	inc hl
	jr __set_CH_instrument_common
; ---------------------------------
; _set_CH3_instrument(hl = pointer to instrument data)
; ---------------------------------
_set_CH3_instrument:
	ld de, _CH3_instrument
	inc hl
	jr __set_CH_instrument_common
; ---------------------------------
; _set_CH4_instrument(hl = pointer to instrument data)
; ---------------------------------
_set_CH4_instrument:
	ld de, _CH4_instrument
	inc hl
	jr __set_CH_instrument_common
; ---------------------------------
; _set_CH1_instrument(hl = pointer to instrument data)
; ---------------------------------
_set_CH1_instrument:
	ld de, _CH1_instrument
	ld a, [hl+]
	ld [de], a
	inc de
__set_CH_instrument_common:
	ld b, 3
	call memcopy_fast
	ret

; ----------------------------------------
; _set_instrument_volume(a = volume contrôl byte, hl = pointer to memory update)
; 		sets new volume value on bytes %XXXX.... of shadow NRX2
; ----------------------------------------
_set_instrument_volume:
	and a, %00001111
	swap a
	ld b, a
	ld a, [hl]
	and a, %00001111
	or a, b
	ld [hl], a
	ret

; ---------------------------------------------
; _get_instrument_pointer(a = instrument instruction) -> hl = pointer to 4 bytes instrument(based on the "instrument sheet pointer")
; ---------------------------------------------
_get_instrument_pointer:
	and a, %00001111
	sla a
	sla a ; a <- a*4
	ld b, a
	ld hl, _instruments_sheet_pointer
	ld a, [hl+]
	or a, b
	ld h, [hl]
	ld l, a
	ret

	SECTION "Blank_Instruments", ROMX
	; small section of save register for "instruments"
	; stopping play of the note on each channel
_CH1_blank_instrument:
	DB %00000000 ; NR10 (no sweep)
	DB %00111111 ; NR11 (duty and smallest length play)
	DB %00001000 ; NR12 (volume = 0 ; sweep up to avoid pop)
	DB %10000000 ; NR14 (retriggers channel to mute audio)
_CH2_blank_instrument:
	DB %00111111 ; NR21 (duty and smallest length play)
	DB %00001000 ; NR22 (volume = 0 ; sweep up to avoid pop)
	DB %10000000 ; NR14 (retriggers channel to mute audio)
_CH3_blank_instrument:
	DB %11111111 ; NR31 (smallest length play)
	DB %00000000 ; NR32 (volume to 0)
	DB %10000000 ; NR34 (retriggers channel)
_CH4_blank_instrument:
	DB %00111111 ; NR41 (smallest length play)
	DB %00001000 ; NR42 (volume = 0 ; sweep up to avoid pop)
	DB %10000000 ; NR44 (retriggers channel to mute audio)


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "Audio_Variables",WRAM0

_trackers_speed:		DS 1 ; update speed of tracker (0 -> once per call, 1 -> every two call, etc)
_trackers_update_counter:	DS 1 ; update counter of tracker
_trackers_flags:	DS 1 ; %bxcxxxxx -> b : 1 if tracker has been stepped
;							 -> c : 1 if a note parameter has been updated
_instruments_sheet_pointer: DS 2 ; addr pointer to the page of instruments (6 ALIGN : %XXXXXXXX %XX000000)

_CH1_instrument: DS 4 ; saved register of NR10 - NR11 - NR12 and NR14  to use as parameters for the note
_CH2_instrument: DS 3 ; saved register of NR21 NR22 NR24 to use as parameters for the new note
_CH3_instrument: DS 3 ; saved registers NR31 NR32 NR34 to use as parameters fot new note
_CH4_instrument: DS 3 ; saved registers NR41 NR42 NR44 to use as parameters for new note

;channel 1 tracker
_CH1_track:			DS SIZEOF_tracker_struct

;channel 2 tracker
_CH2_track:			DS SIZEOF_tracker_struct

;channel 3 tracker
_CH3_track:			DS SIZEOF_tracker_struct

;channel 4 tracker
_CH4_track:			DS SIZEOF_tracker_struct




