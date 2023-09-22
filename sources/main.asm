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
	ld c, $01
	call fwf_init
	PRINT_DEBUG "FWF Init Done"

	ld de, $9801
	ld hl, _test_text
.loop
	ld a, [hl]
	push hl
	ld l, a
	push de
	call fwf_display_char
	ld e, 40
	call wait_frames
	pop de
	inc de
	pop hl
	inc hl
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
	call irq_set_VBL


	; on rétablit les interrupts
	ei
	ret ; retour à l'exécution







	;-----------------------------
	;    test data
	;-----------------------------
Main_vblk:
	call call_DMA
	ret

	SECTION "Test_data", ROM0

_test_data_start:
INCBIN "./engine/engine_data/test_tileset.bin"
_test_data_end:

_test_text:
	DB "Bonjour ceci est un test j'ajoute des tiles en plus MAJUSCULE"
	DB "et minuscule pour voir jusqu'ou va tenir mon moteur textuel"
	DB "J'ai l'impression qu'il faut que je commence à écrire beaucoup de merde"
	DB "pour le pousser à bout et finalement dépasser les capacités prévues."
	DB "Là les caractères spéciaux ne sont pas implémentés donc forcément il y a plein"
	DB "de carrés moches et pas jolis"
	DB "J'avoue ne pas avoir d'idée du nombre de caractères réutilisés dans la langue française ..."
	DB "Peut être que là ça a été dépassé et qu'on ne voit plus que des carrés moches ?"
	DB "Ou alors l'approche est méga robuste et je suis trop heureux !"
	DB "OMG whaou ça marche VrAiMeNt SuPeR BiEn !"
	DB "OBLIgé D'ECRiRe en majUSCUle pour Voir LeS CAs LIMITES"
	DB "qmkjswcvxhoniUITD YREVDBFUYWXOI"
	DB "ET MEME COMME ça je l'atteint PAS Qxlnwnds !"
	DB "C'est OUUUUUUUUUUUF JE suis trop trop CONTENT de mon BOULOT !"
