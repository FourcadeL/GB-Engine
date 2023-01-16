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



	SECTION "Main",ROM0


Main::

	call 	Main_init
	call 	Sprite_init
	PRINT_DEBUG "Main Init Done"
	call	abc_init
	call 	abc_main

	

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
	or 		LCDCF_BG8800 ; tiles background specifique
	ld		[rLCDC],a

	; association de la routine vblank
	ld bc, Main_VBL_routine
	call irq_set_VBL

	; on rétablit les interrupts
	ei
	ret ; retour à l'exécution



;------------------------
; Main_VBL_routine()
; 	vblank handler
;	simple routine mettant à jour l'OAM par l'appel à call_DMA
;------------------------
Main_VBL_routine::
	call call_DMA
	ret



	;-----------------------------
	;    test data
	;-----------------------------

 	SECTION "Placeholder_Tiles", ROM0

_test_data_start:
INCBIN "./engine/engine_data/test_tileset.bin"
_test_data_end:
