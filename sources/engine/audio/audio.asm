;#####################################
;definition audio (compléter engine.inc)
;audio contient les fonctions de manipulation et de gestion des sons, ainsi que tout le moteur sonore associé
;#####################################


	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"
	INCLUDE "debug.inc"
	INCLUDE "utils.inc"




;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          STRUCTURES                                     | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+
;tracker variables structure (same for all three channels)
;-----------
RSRESET
block_addr			RB 2
tracker				RB 1
restart_note		RB 1
curr_note			RB 1
curr_instr			RB 1
curr_effect			RB 1
wait_timer			RB 1
repeat_counter		RB 1
return_tracker		RB 1
SIZEOF_trackstruct	RB 0
;-----------








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
;- Audio_init()       
;-			Initialisation basique des registres audio (peut être modifié)
;-			volumes max toutes les chaines sur tout les terminaux                                -
;--------------------------------------------------------------------------

Audio_init::

	ld		a, $FF
	ld		[rNR52], a

	MEMBSET [rNR50], $77 ; max volume and no external input
	MEMBSET [rNR51], $FF ; all channels on all terminals
	
	;------engine variables initialisation-----

	ld		a, $00
	ld		[_update_frame + 1], a ; counter

	ld		a, $01 ; initialisation des timers
	ld		[_CH1_track + wait_timer], a
	ld		[_CH2_track + wait_timer], a
	ld		[_CH3_track + wait_timer], a
	ld		[_CH4_track + wait_timer], a
	

	ret












;--------------------------------------------------------------------------
;- Audio_update()       
;-			  Doit être appelé une fois par frame pour gérer les sons     -
;--------------------------------------------------------------------------

Audio_update::

	ld		hl, _update_frame
	ldi		a, [hl]
	ld		b, [hl] ; counter
	inc		b
	ld		[hl], b ; counter
	cp		a, b
	jr		nz, .skip_song_engine
	ld		a, $00
	ld		[hl], a ; counter

	;------engine execution------
	;===tracker_update===
	;CH1
	ld		hl, _CH1_track + wait_timer
	ld		a, [hl]
	dec		a
	ld		[hl], a
	cp		a, $00	; calcul de temps ok (le compteur est mis à 2, une frame est sautée + lecture de l'instruction d'attente, donc 2)
	jr		nz, .skip_CH1_update
	ld		a, $01
	ld		[hl], a
	;------execution-----
	ld		de, _CH1_track
	call 	Audio_tracker_step
	;--------------------
.skip_CH1_update


	;CH2
	ld		hl, _CH2_track + wait_timer
	ld		a, [hl]
	dec		a
	ld		[hl], a
	cp		a, $00
	jr		nz, .skip_CH2_update
	ld		a, $01
	ld		[hl], a
	;------execution-----
	ld		de, _CH2_track
	call	Audio_tracker_step
	;--------------------
.skip_CH2_update

	
	;CH3
	ld		hl, _CH3_track + wait_timer
	ld		a, [hl]
	dec		a
	ld		[hl], a
	cp		a, $00
	jr		nz, .skip_CH3_update
	ld		a, $01
	ld		[hl], a
	;------execution-----
	ld		de, _CH3_track
	call	Audio_tracker_step
	;--------------------
.skip_CH3_update


	;CH4
	ld		hl, _CH4_track + wait_timer
	ld		a, [hl]
	dec		a
	ld		[hl], a
	cp		a, $00
	jr		nz, .skip_CH4_update
	ld		a, $01
	ld		[hl], a
	;------execution-----
	ld		de, _CH4_track
	call	Audio_tracker_step
	;--------------------
.skip_CH4_update


	;===hardware_update===
	call	Audio_hardware_update
	


	;-----------------------------
.skip_song_engine:
	ret









;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FONCTIONS UTILITAIRES                          | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

;------------------------------------------------------------------------------------------
;- Audio_hardware_update()  
;-			  asigns : modifie la structure associée à la chaine
;-   		modifie les registres hardware en fonction des
;-			informations du tracker en mémoire										   -
;------------------------------------------------------------------------------------------

Audio_hardware_update::
	;===CH1===
	ld		de, _CH1_track
	ld		hl, restart_note
	add		hl, de
	ld		a, [hl]
	cp		a, $00
	jr		z, .not_new_note_CH1 ;new note to play ?
	;----note_update----
	ld		a, $00
	ld		[hl], a	;new note bool reset
	ld		hl, curr_note
	add		hl, de
	ld		a, [hl]
	call	Audio_get_note_frequency12
	ld		a, [rNR14]
	and		a, %01000000
	or		a, %10000000
	or		a, b
	ld		[rNR14], a
	ld		a, c
	ld		[rNR13], a
.not_new_note_CH1
	;----effect_update----

	;===CH2===
	ld		de, _CH2_track
	ld		hl, restart_note
	add		hl, de
	ld		a, [hl]
	cp		a, $00
	jr		z, .not_new_note_CH2 ;new note to play ?
	;----note_update----
	ld		a, $00
	ld		[hl], a	;new note bool reset
	ld		hl, curr_note
	add		hl, de
	ld		a, [hl]
	call	Audio_get_note_frequency12
	ld		a, [rNR24]
	and		a, %01000000
	or		a, %10000000
	or		a, b
	ld		[rNR24], a
	ld		a, c
	ld		[rNR23], a
.not_new_note_CH2
	;----effect_update----

	;===CH3===
	ld		de, _CH3_track
	ld		hl, restart_note
	add		hl, de
	ld		a, [hl]
	cp		a, $00
	jr		z, .not_new_note_CH3 ;new note to play ?
	;----note_update----
	ld		a, $00
	ld		[hl], a	;new note bool reset
	ld		hl, curr_note
	add		hl, de
	ld		a, [hl]
	call	Audio_get_note_frequency12
	ld		a, [rNR34]
	and		a, %01000000
	or		a, %10000000
	or		a, b
	ld		[rNR34], a
	ld		a, c
	ld		[rNR33], a
.not_new_note_CH3
	;----effect_update----

	;===CH4===
	ld		de, _CH4_track

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


_counter: 	DS 1

_note:		DS 1



;engine variables
;update frame est le nombre de frames attendues entre chaques update du moteur audio
;update frame + 1 = compteur (compteur des frames passées avant update)
_update_frame:	DS 2


;channel 1 variables
_CH1_track:			DS SIZEOF_trackstruct

;channel 2 variables
_CH2_track:			DS SIZEOF_trackstruct

;channel 3 variables
_CH3_track:			DS SIZEOF_trackstruct

;channel 4 variables
_CH4_track:			DS SIZEOF_trackstruct




