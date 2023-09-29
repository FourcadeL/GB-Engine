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

.loop
	call fwf_automaton_update
    call wait_vbl
	jr .loop


room_init:
    ld c, $01
    call fwf_init
    ld a, 18
    call fwf_automaton_set_display_width
    ld a, 10
    call fwf_automaton_set_display_height
    ld a, 2
    call fwf_automaton_set_timer
    ld a, $00
    call fwf_automaton_set_blank_tile_id
    ld de, $9841
    call fwf_automaton_set_display_start_addr
    ld de, _text
    call fwf_automaton_set_read_addr
    call fwf_automaton_init
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
    