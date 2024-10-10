;#####################################
;definition main (se réferrer à engine.inc)
;#####################################





	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"
	INCLUDE "debug.inc"
	INCLUDE "charmap.inc"




;---------------------------------------------
;- Main()
;---------------------------------------------



	SECTION "Main", ROM0


Main::

	call 	Main_init
	PRINT_DEBUG "Main Init Done"
	; call room_main
	call snd_test_main
	ret

	


;---------------------------------------------
;- Main_init()
; fonction d'initialisation des ressources pour le démarrage du programme
; La fonction rétablit les interrupts
;---------------------------------------------


Main_init::
	; initialisations 
	
	; écriture des tiles de test
	ld 		bc, _test_data_end - _test_data_start
	ld		hl, _test_data_start
	ld		de, _VRAM
	call 	vram_copy
	ld 		bc, _test_data_end - _test_data_start
	ld		hl, _test_data_start
	ld		de, _VRAM + $0800
	call 	vram_copy



	; registre d'interupts sélection
	ld		a,IEF_VBLANK   ; enable VBLANK interrupt
	ld		[rIE],a


	; attributs palettes background/windows
	ld 		a, %11100100
	ld 		[rBGP], a ; palette BG


	; attributs palettes objets
	ld		a, %11100100
	ld		[rOBP0], a ; palette 0

	ld		a, %11100100
	ld		[rOBP1], a ; palette 1

	; redémarrage de l'écran
	ld		a,LCDCF_ON ; écran activé
	or 		LCDCF_BGON ; arriere plan activé
	or		LCDCF_OBJON ; objects affichés
	or		LCDCF_OBJ8 ; objects de type 8*8
	ld		[rLCDC],a

	ld bc, Main_vblk
	call irq_set_VBL ; set global VBlank


	; on rétablit les interrupts
	ei
	ret ; retour à l'exécution


; --------------------------
; Main VBlank routine to use 
; Global VBlank
; --------------------------
Main_vblk:
	; Video / VRAM actions
	call call_DMA
	call fwf_automaton_update
	; Audio / Non VRAM actions
	call Audio_update
	ret




	;-----------------------------
	;    test data
	;-----------------------------

 	SECTION "Placeholder_Tiles", ROM0

_test_data_start:
INCBIN "./engine/engine_data/test_tileset.bin"
_test_data_end: