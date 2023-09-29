; ###########################################
; test room
; ###########################################



INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "charmap.inc"





;-------------------------------------------
;- Room main
;-------------------------------------------

    SECTION "Room_test", ROM0


room_main::
    call room_init

    ld de, $9801
	; ld hl, _test_text
	ld hl, _text
.loop
	ld a, [hl]
	cp a, "\n"
	jr z, .change_text
	push hl
	ld l, a
	push de
	call fwf_display_char
	ld e, 10
	call wait_frames
	pop de
	inc de
	pop hl
	inc hl
	nop
	jr .loop
.change_text
	call fwf_flush
	ld hl, $9800
	ld d, $00
	ld bc, $0400
	call vram_set
	ld de, $9801
	ld hl, _test_text
	jr .loop


room_init:
    ld c, $01
    call fwf_init
    ret



    SECTION "Test_data", ROM0
    
    
    _text:
        DB "OK! Maintenant il est temps de s'ôter de tous les doutes sur les capacités de ce à quoi pourrait servir le moteur textuel. Ne pas hésiter sur les accents (voilà comme ça), les caractères spéciaux #ilespaspret, les signes en plus @$+ etc..."
        DB "En plus de ça j'ajoute des MAJUSCULE pour GONFLER les TILES UTILISÉES : ça va faire mal ! Alors, on en est où maintenant de compteur ? ça a déjà beugé où bien ça marche de OUF ?\n"
    
    _test_text:
        DB "Bonjour ceci est un test j'ajoute des tiles en plus MAJUSCULE"
        DB "et minuscule pour voir jusqu'ou va tenir mon moteur textuel"
        DB "J'ai l'impression qu'il faut que je commence à écrire beaucoup de merde"
        DB "pour le pousser à bout et finalement dépasser les capacités prévues."
        DB "Là les caractères spéciaux ne sont pas implémentés donc forcément il y a plein"
        DB "de carrés moches et pas jolis"
        DB "J'avoue ne pas avoir d'idée du nombre de caractères réutilisés dans la langue française ..."
        DB "Peut être que là ça a été dépassé et qu'on ne voit plus que des \"carrés moches\" ?"
        DB "Ou alors l'approche est méga robuste et je suis trop heureux !"
        DB "OMG whaou ça marche VrAiMeNt SuPeR BiEn !"
        DB "OBLIgé D'ECRiRe en majUSCUle pour Voir (LeS CAs LIMITES)"
        DB "qmkjswcvxhoniUITD YREVDBFUYWXOI"
        DB "ET MEME COMME ça je l'atteint PAS Qxlnwnds !"
        DB "C'est OUUUUUUUUUUUF JE suis trop trop CONTENT de mon BOULOT !\n"
    