;#####################################
;definition main (se réferrer à engine.inc)
;#####################################





	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"
	INCLUDE "debug.inc"




;---------------------------------------------
;- Main()
;---------------------------------------------



	SECTION "Main",ROM0


Main::

	call 	Main_init
	PRINT_DEBUG "Main Init Done"


.loop
	call 	Audio_update
	call 	wait_vbl
	nop
	jr .loop



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
	ld 		bc, _test_data_end - _test_data_start
	ld		hl, _test_data_start
	ld		de, _VRAM + $1000
	call 	vram_copy

	;initialisation du moteur audio
	PRINT_DEBUG "audio init call"
    call    Audio_init

    PRINT_DEBUG "audio init done"



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

	; initialisation de l'automate vwf
	call 	vwf_init




	; on rétablit les interrupts
	ei
	ret ; retour à l'exécution







	;-----------------------------
	;    test data
	;-----------------------------


	SECTION "Test_data", ROM0

_test_data_start:
INCBIN "./engine/engine_data/test_tileset.bin"
_test_data_end:
