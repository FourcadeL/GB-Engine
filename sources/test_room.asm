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
    call getInput
	call fwf_automaton_update
    ld a, [PAD_pressed]
    cp a, PAD_A
    call z, fwf_automaton_awake_from_idle
    call wait_vbl
	jr .loop


room_init:
    ld c, $01
    call fwf_init
    ld a, 20
    call fwf_automaton_set_display_width
    ld a, 9
    call fwf_automaton_set_display_height
    ld a, 8
    call fwf_automaton_set_timer
    ld a, $00
    call fwf_automaton_set_blank_tile_id
    ld de, $9840
    call fwf_automaton_set_display_start_addr
    ld de, _text
    call fwf_automaton_set_read_addr
    call fwf_automaton_init
    ret



    SECTION "Test_data", ROM0
    
    _text:
        DB "J'écris un peu ce qui me passe par la tête...\\t", $20, "J'essaye de tester le moteur textuel sans me forcer non plus \\t", $02
        DB "à utiliser des caractères spéciaux, mais\\t", $20, " en laissant quend même touts\\t", $04, " les accents, les points de ponctuation stpécifiques, les MAJUSCULES "
        DB "et symboles que l'on rencontre normalement dans un texte écrit en français..."
        DB "Est-ce que ça devient trop pour le moteur ? Je ne pense pas. J'ai essayé beaucoup de choses et ça a vraiment l'air d'être robuste. Alors oui forcément ici le text s'écirt en bloc avec des sauts qui ne veulent rien dire !"
        DB "Il manque des estpaces lors de certains sauts de ligne, etc etc. Mais ça c'est surtout parce que je n'ai pas encore implémenté la gestion des caractères spéciqux dans mes routines. Ils sont définis hein, ce n'est pas le problème, "
        DB "mais travailler sur le code pour les gérer est TEEEEEEEEEEEELement difficile."
        DB "Si je continue de garder ma motivation, d'ici quelques jours tout devrais fonctionner sans problèmes et on verra alors des beaux blocs de text bien formatés, avec des controles d'attentes, des variation de vitesse d'affichage et plus encore :) !"

    _text2:
        DB "OK! Maintenant il est temps de s'ôter de tous les doutes sur les capacités de ce à quoi pourrait servir le moteur textuel. Ne pas hésiter sur les accents (voilà comme ça), les caractères spéciaux #ilespaspret, les signes en plus @$+ etc..."
        DB "En plus de ça j'ajoute des MAJUSCULE pour GONFLER les TILES UTILISÉES : ça va faire mal ! Alors, on en est où maintenant de compteur ? ça a déjà beugé où bien ça marche de OUF ?"
    
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
    