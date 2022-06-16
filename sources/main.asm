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
	





;---------------------------------------------
;- Main_init()
; fonction d'initialisation des ressources pour le démarrage du programme
; La fonction rétablit les interrupts
;---------------------------------------------


Main_init::
	; initialisations 
	

	;initialisation du moteur audio
    	call    Audio_init



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






	; on rétablit les interrupts
	ei
	ret ; retour à l'exécution
