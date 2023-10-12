; ###########################################
; test room
; ###########################################



INCLUDE "hardware.inc"
INCLUDE "engine.inc"
INCLUDE "debug.inc"
INCLUDE "charmap.inc"
INCLUDE "utils.inc"





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
    call fwf_automaton_is_stopped
    jr z, .load_next_text
	jr .loop
.load_next_text
    ld e, 20
    call wait_frames
    ld de, _text2
    call fwf_automaton_set_read_addr
    call fwf_automaton_init
    jr .loop

room_init:
    ld c, $01
    call fwf_init
    ld a, 20
    call fwf_automaton_set_display_width
    ld a, 9
    call fwf_automaton_set_display_height
    ld a, $20
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

    _small_text:
        DB "HIHI !\n\\b"
        DW _small_text2
        DB "\\0"
    
    _small_text2:
        DB "HOHO !\\b"
        DW _small_text3
        DB "\\0"

    _small_text3:
        DB "HEHE !\n\\b"
        DW _small_text33
        DB "\\0"

    _small_text33:
        DB "fin ?\n\\b"
        DW _small_text4
        DB "\\0"

    _small_text4:
        DB "fin\\0"
    
    _text:
        DB "ABCDEFGAAAAAAA"
        DB "\\t", $20, "Essai : \\b"
        DW _small_text
        DB " et un petit\\t", 4, "plus\\0"
        DB "Attention !!!\nJe vais flush !\n(en tout cas juste après avoir fini de parler pour ne rien dire)\\w\\f"
        DB "J'écris un peu\n\\wce qui\nme passe par\nla tête...\n\\t", $20, "J'essaye de\ntester le\nmoteur textuel\nsans me forcer\nnon plus \\w\\t", $02
        DB "à utiliser\ndes caractères\nspéciaux, mais\n\\t", $16, "en laissant\nquand même tous\\t", $04, "\nles accents,\nles points de\nponctuation\nspécifiques,\nles MAJUSCULES...\\f"
        DB "et symboles que\\fl'on rencontre normalement\\fdans un texte écrit en français...\\f"
        DB "Est-ce que ça\ndevient trop pour le moteur ? Je ne pense pas.\nJ'ai essayé beaucoup de choses\net ça a vraiment l'air d'être robuste.\nAlors oui forcément\\fici le text s'éctit en bloc\navec des sauts qui ne\nveulent rien dire !\\f"
        DB "Il manque des estpaces lors de certains sauts de ligne, etc etc. Mais ça c'est surtout parce que je n'ai pas encore implémenté la gestion des caractères spéciqux dans mes routines. Ils sont définis hein, ce n'est pas le problème, "
        DB "mais travailler sur le code pour les gérer est TEEEEEEEEEEEELement difficile."
        DB "Si je continue de garder ma motivation, d'ici quelques jours tout devrais fonctionner sans problèmes et on verra alors des beaux blocs de text bien formatés, avec des controles d'attentes, des variation de vitesse d'affichage et plus encore :) !"

    _text2:
        DB "OK! Maintenant il est temps de s'ôter de tous les doutes sur les capacités de ce à quoi pourrait servir le moteur textuel. Ne pas hésiter sur les accents (voilà comme ça), les caractères spéciaux #ilespaspret, les signes en plus @$+ etc..."
        DB "En plus de ça j'ajoute des MAJUSCULE pour GONFLER les TILES UTILISÉES : ça va faire mal ! Alors, on en est où maintenant de compteur ? ça a déjà beugé où bien ça marche de OUF ?\\0"
    
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
    