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
	ld hl, sp+4
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





;------------------------------------------------------------------------------------------
;- Audio_tracker_step(de = adresse de la structure de tracker de la chaine)  
;-			  asigns : modifie la structure associée à la chaine
;-   												   -
;------------------------------------------------------------------------------------------

Audio_tracker_step::
	ld		hl, block_addr
	add		hl, de
	ld		b, [hl]
	inc 	hl
	ld		c, [hl]
	ld		hl, tracker
	add		hl, de
	ld		a, [hl]
	;increment tracker
	inc		[hl]
	;instruction addr
	add		a, c
	ld		c, a
	ld		a, $00
	adc		a, b
	ld		b, a
	ld		a, [bc]
	cp		a, %10000000
	jr		nc, .control
	;~note information~
	ld		hl, curr_note
	add		hl, de
	ld		[hl], a
	ld		hl, restart_note
	add		hl, de
	inc		[hl]
	ret
.control
	;~control information~
	cp		a, %11000000
	jr		c, .not_wait_control
	;|-> temps d'attente sur la chaine
	and		a, %00111111
	ld		hl, wait_timer
	add		hl, de
	ld		[hl], a
	ret
.not_wait_control
	cp		a, %10100000
	jr		c, .not_repeat_control
	;|-> repeat set value
	and		a, %00011111
	ld		hl, repeat_counter
	add		hl, de
	ld		[hl], a
	jr		Audio_tracker_step	;read next instruction byte
.not_repeat_control
	cp		a, %10010000
	jr		c, .not_instrument_control
	;|-> instrument set value
	and		a, %00001111
	ld		hl, curr_instr
	add		hl, de
	ld		[hl], a
	jr		Audio_tracker_step	;read next instruction byte
.not_instrument_control
	cp		a, %10001000
	jr		c, .not_effect_control
	;|-> effect set value
	and		a, %00000111
	ld		hl, curr_effect
	add		hl, de
	ld		[hl], a
	jr		Audio_tracker_step	;read next instruction byte
.not_effect_control
	cp		a, %10000111
	jr		c, .not_total_return_cond
	;|-> retour total conditionnel
	ld		hl, repeat_counter
	add		hl, de
	ld		a, [hl]
	or		a, a
	jr		z, Audio_tracker_step	;condition not matched, read next
	dec		[hl]
	ld		hl, tracker
	add		hl, de
	ld		[hl], $00
	jr		Audio_tracker_step	;condition matched, read next (0)
.not_total_return_cond
	cp		a, %10000110
	jr		c, .not_total_return
	;|-> retour total
	ld		hl, tracker
	add		hl, de
	ld		[hl], $00
	jr		Audio_tracker_step	;returned, read next
.not_total_return
	cp		a, %10000101
	jr		c, .not_return_cond
	;|-> retour conditionnel
	ld		hl, repeat_counter
	add		hl, de
	ld		a, [hl]
	or		a, a
	jp		z, Audio_tracker_step	;condition not matched, read next
	dec		[hl]
	ld		hl, return_tracker
	add		hl, de
	ld		a, [hl]
	ld		hl, tracker
	add		hl, de
	ld		[hl], a
	jp		Audio_tracker_step	;condition matched, read next (saved)
.not_return_cond
	cp		a, %10000100
	jr		c, .not_return
	;|-> retour
	ld		hl, return_tracker
	add		hl, de
	ld		a, [hl]
	ld		hl, tracker
	add		hl, de
	ld		[hl], a
	jp		Audio_tracker_step	;returned, read next
.not_return
	cp		a, %10000011
	jr		c, .not_next_block
	;|-> next block (bc already contains current instruction's address)
	ld		hl, block_addr
	add		hl, de
	inc		bc
	ld		a, [bc]
	ldi		[hl], a
	inc		bc
	ld		a, [bc]
	ld		[hl], a
	ld		hl, tracker
	add		hl, de
	ld		[hl], $00
	jp		Audio_tracker_step	;next block prepared, read next
.not_next_block
	cp		a, %10000010
	jr		c, .not_unused
	;|-> unused
.not_unused
	cp		a, %10000001
	jr		c, .not_return_set
	;|-> return tracker set
	ld		hl, tracker
	add		hl, de
	ld		a, [hl]
	ld		hl, return_tracker
	add		hl, de
	ld		[hl], a
	jp		Audio_tracker_step	;saved, read next
.not_return_set
	;|-> stop actual note

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




