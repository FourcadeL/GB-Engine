;#####################################
;definition sprite (compléter engine.inc)
;sprite contient les fonctions de manipulation des sprites
;#####################################


;terminology :
;OBJECT -> OAM element 
;sprite -> group of OBJECTs (strictly display infos, no behaviours or animations here)



;compilation variables
max_sprites EQU 10	;nombre max de sprites gérés
mode_16 	EQU 0 	;mode d'affichage OBJ 8*16 (0-> mode 8*8  1-> mode 8*16)




	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"
	INCLUDE "macros.inc"
	INCLUDE "debug.inc"




;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          STRUCTURES                                     | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+
;sprite élément structure
;-----------
RSRESET
sprt_info_byte		RB 1  	;byte d'info sur les caractéristiques du sprite %O V H P D xx F   O->obj to bg priority	V->vertical flip 	H->horizontal flip 	P->palette 	D->display 	F->free (is reset if this slot is empty)
sprt_size 			RB 1 	;byte d'info sur la dimention globale (taille max 8*8 OBJ) %hhhh llll 		h->hauteur 	l->largeur
sprt_nb_obj 		RB 1 	;byte d'info sur le nombre d'objet composant le sprite (redondant avec sprite size mais plus rapide pour itérer)
sprt_X_pos			RB 1	;position X du sprite (point en haut à gauche)
sprt_Y_pos			RB 1	;position Y du sprite (point en haut à gauche)
sprt_OAM_addr		RB 2	;adresse en OAM (mirror ou se trouve le sprite) (big endian)
SIZEOF_sprt_struct	RB 0
;-----------




;/!\ les structures seront potentiellement avec des trous mais l'OAM est toujoures de la forme (xxxxxxxxxx|0000000)
; lors de la suppression d'un sprite on décale ceux qui suivent dans l'OAM et on met à jour le pointeur vers l'OAM pour les sprites affectés

;/!\ grosses améliorations possibles, la partie Haute de l'adresse dans l'OAM mirror est toujours $C0 (car alignée)

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FUNCTIONS                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "Sprite_Functions",ROM0


;--------------------------------------------------------------------------
;- Sprite_init()       
;-			Initialisation basique de l'environnement d'affichage des sprites
;- 	-mise à 0 de l'OAM mirror
;-  -initialisation des variables utilisées des variables utilisées
;-  -activation de l'affichage des sprites par le PPU                         -
;--------------------------------------------------------------------------
Sprite_init::
	;mise à 0 de l'OAM mirror
	ld 		d, $00
	ld 		hl, OAM_mirror
	ld 		bc, OAM_mirror_end - OAM_mirror
	call 	memset

	;mise à 0 des variables
	ld 		d, $00
	ld 		hl, Sprite_vars_start
	ld 		bc,	Sprite_vars_end - Sprite_vars_start
	call 	memset

	;OAM libre à la base de l'OAM mirror
	ld 		hl, _free_OAM_addr
	ld 		b, HIGH(OAM_mirror)
	ld 		a, LOW(OAM_mirror)
	ldi		[hl], a
	ld 		[hl], b

	;activation de l'affichage des sprites par le PPU
	ld 		a, [rLCDC]
	IF 		mode_16 == 1
		or 	a, LCDCF_OBJ16
	ELSE
		or 	a, LCDCF_OBJ8
	ENDC
	or 		a, LCDCF_OBJON
	ld 		[rLCDC], a
	PRINT_DEBUG "Sprite init done"

	ret

;--------------------------------------------------------------------------
;- Sprite_new_entry(b = byte infos, c = byte dimensions)
;- 			b : %O V H P D xxx
;-				-> O bg priority : 0 = above 1 = behind
;-				-> V vertical flip
;- 				-> H horizontal flip
;- 				-> P palette
;- 				-> D display
;-			c : %hhhh llll 		h = hauteur l = largeur
;-	ajout d'un sprite dans un slot libre 
;- = a <- ID si l'instantiation s'est bien passée
;-   a <- $FF si pas d'instantiation (plus de place / OAM pleine / etc)  
;-
;- 				- vérifie que le nombre de sprite n'est pas dépassé
;- 				- trouve un index de libre (ind)
;- 				- calcul le nombre d'objets nécessaires à partir de c
;- 				- écrit dans le tableau (à l'index ind) -> b, c et le nb d'objets calculés
;-              - vérifie qu'il y a assez d'OBJ disponibles dans l'OAM mirror
;- 				- si ^ OK:
;- 					-> incrémente le nombre de sprites total
;- 					-> add le nombre d'objets utilisés
;- 					-> écrit les dernières infos dans le sprite pool : sprite utilisé et OAM_addr
;- 					-> écrit la nouvelle valeur de _free_OAM_addr
;--------------------------------------------------------------------------
Sprite_new::
	;b ne doit pas forcer la prise d'un slot
	ld 		a, b
	and 	a, %11111110
	ld 		b, a
	;vérifie que le nombre de sprite n'est pas dépassé
	ld 		a, [_nb_sprites]
	cp 		a, max_sprites
	jp 		nc, .error 		; si >= max_sprt retourne une erreur

	;vérifie que la taille demandée n'est pas 0
	ld 		a, c
	and 	%00001111
	jp 		z, .error 		; si largeur = 0 -> erreur
	ld 		a, c
	and 	%11110000
	jr 		z, .error 		; si hauteur = 0 -> erreur

	;trouve un index libre dans la pool
	ld 		d, 0
	ld 		hl, _Sprite_pool
	ADD_U16_hl_val sprt_info_byte
.loop
	bit 	0, [hl]
	jr 		z, .found_idx
	inc 	d
	ADD_U16_hl_val SIZEOF_sprt_struct
	jr 		.loop
.found_idx ;d contient l'index libre

	;calcul du nombre d'objets en fonction de la taille a<-
	push 	bc
	push 	de
	push 	hl
	ld 		a, c
	and 	a, %11110000
	srl 	a
	srl 	a
	srl 	a
	srl 	a
	ld 		b, a
	ld 		a, c
	and 	a, %00001111
	ld 		c, a
	call 	mult_u8 		; hauteur * largeur pour trouver le nombre d'objets
	pop 	hl
	pop 	de
	pop 	bc

	;écriture des infos (attr, dimensions et nombre d'obj) dans l'entrée du tableau /!\ pas encore marqué comme utilisé
	ld 		[hl], b
	inc  	hl 					; /!\ ici on suppose que sprt_size est juste apres sprt_info_byte dans le tableau
	ld 		[hl], c
	inc 	hl 					; /!\ ici on suppose que sprt_nb_obj est juste apres sprt_info_byte dans le tableau
	ld 		[hl], a

	

	;vérifie qu'il y a assez de place dans l'OAM pour la taille demandée
	ld  	e, a 			; e <- nombre d'objets utilisés
	ld 		a, [_nb_used_objects]
	add 	a, e 			; a <- nombre objets déjà pris + nb obj utilisés
	cp 		a, 41
	jr 		nc, .error 		; si >= 41 retourne une erreur



	;tous les tests ont été passés on peut instancier le sprite


	;incrémente le nombre de sprite instanciés
	ld 		hl, _nb_sprites
	inc 	[hl]

	;met à jour le nombre d'objets utilisés
	ld 		a, [_nb_used_objects]
	add 	a, e
	ld 		[_nb_used_objects], a


	push 	de
	ld 		hl, _Sprite_pool
	ld 		b, d
	ld 		c, SIZEOF_sprt_struct
	call 	tab_offset 		;calcul de l'adresse dans le sprite_pool
	;marque l'entrée comme prise /!\ suppose que sprt_info_byte est le premier octet du tableau
	set 	0, [hl] 
	ld 		de, sprt_OAM_addr
	add 	hl, de
	;écrit sprt_OAM_addr
	ld 		de, _free_OAM_addr
	ld 		a, [de]
	ld 		c, a
	ldi 	[hl], a
	inc 	de
	ld 		a, [de]
	ld 		b, a
	ld 		[hl], a
	pop 	de

	;écrit la nouvelle valeur de _free_OAM_addr
	ld 		h, b
	ld 		l, c
	ld 		b, e
	ld 		c, 4
	push 	de
	call 	tab_offset
	pop 	de

	ld 		bc, _free_OAM_addr
	ld 		a, l
	ld 		[bc], a
	inc 	bc
	ld 		a, h
	ld 		[bc], a

	;retourne l'index du sprite attribué
	ld 		a, d

	ret
.error
	ld 		a, $FF
	ret



;--------------------------------------------------------------------------
;- Sprite_delete_entry(b = index)
;- 		retire un sprite (déjà occupé) du pool
;- 		retour :    a = $00   	OK
;- 					a = $FF 	KO
;-
;- exécution :
;- 			- vérifie que l'index est valide
;- 			- vérifie que le sprite à retirer est attribué
;- 			- marque le sprite comme libre
;- 			- décrémente le nombre de sprites instanciés
;- 			- décrémente le nombre d'objets utilisés
;- 			- met à jour l'adresse libre dans l'OAM
;- 			- décale les objets utilisés dans l'OAM
;- 			- met à zero les valeurs restantes dans l'OAM
;- 			- pour tous les sprites dont les objets suivaient dans l'OAM décale sprt_OAM_addr du nombre d'objets libérés
;--------------------------------------------------------------------------
Sprite_delete_entry::
	;vérifie que l'index est valide
	ld 		a, b
	cp 		a, max_sprites
	jp 	 	nc, .error
	;vérifie que le sprite à retirer est attribué
	push 	bc
	ld 		hl, _Sprite_pool
	ld 		c, SIZEOF_sprt_struct
	call 	tab_offset
	pop 	bc
	bit 	0, [hl] 		;/!\ suppose que sprt_info_byte est le premier élément de la structure
	jp 		z, .error 		;si index déjà libre -> erreur
	;marque le sprite comme libre
	res 	0, [hl] 							;test pas d'explosion jusqu'ici

	;----------
	ld 		de, sprt_nb_obj
	add 	hl, de
	ld 		b, [hl]
	ld 		de, sprt_OAM_addr - sprt_nb_obj
	add 	hl, de
	ldi 	a, [hl]
	ld 		e, a
	ld 		d, [hl]
	;---------- b = nb_d'objets | de = adresse utilisée en OAM

	;décrémente le nombre de sprites instanciés
	ld 		hl, _nb_sprites
	dec 	[hl]

	;met à jour le nombre d'objets utilisés
	ld 		hl, _nb_used_objects
	ld 		a, [hl]
	sub 	a, b
	ld 		[hl], a

	;met à jour l'adresse libre dans l'OAM
	push 	bc
	push 	de
	ld 		hl, _free_OAM_addr
	ldi 	a, [hl]
	ld 		e, a
	ld 		d, [hl] ;de <- ancienne addr libre

	ld 		c, 4
	call 	mult_u8
	ld 		c, a 	;c <- indice à soustraire a l'adresse de l'objet libre

	ld 		a, e
	sub 	a, c
	ld 		e, a
	ld 		a, d
	sbc 	a, $00
	ld 		d, a 	;de <- nouvelle addr libre

	ld 		hl, _free_OAM_addr
	ld 		a, e
	ldi 	[hl], a
	ld 		[hl], d

	pop 	de
	pop 	bc


	;décale les objets utilisés dans l'OAM
	push 	bc
	push  	de

	ld 		c, 4
	call 	mult_u8
	ld 		h, d
	ld 		l, e
	add 	a, l
	ld 		l, a
	ld 		a, h
	adc  	a, $00
	ld 		h, a ; hl <- adresse de l'objet juste après le sprite dans l'OAM | de <- adresse du premier objet du sprite dans l'OAM
						;mettre dans b OAM_mirror_end - hl
	push 	de 					;(peut être superflu)
	ld 		de, OAM_mirror_end
	ld 		a, e
	sub 	a, l
	ld 		b, a
	pop 	de
			; hl = addr du premier objet apres le sprite obj | de = addr du premier objet du sprite | b = nombre d'octets à copier
				;si b = 0 on ne copie rien mais on supprime dans l'étape d'après
		ld 		a, b
		or 		a
		jr 		z, .no_decalage
	call 	memcopy_fast   	;après cet appel de contient l'adresse suivante dans l'OAM (à partir de laquelle il faut écraser)
.no_decalage

	;met à zero les valeurs restantes dans l'OAM (cache les sprite inutilisés)
	push 	de
		;mettre dans b : (OAM_mirror_end - de)/4
	ld 		bc, OAM_mirror_end
	ld 		a, c
	sub 	a, e
	ld 		b, a
	srl 	b
	srl 	b
	pop 	hl
		; hl = addr du premier objet non utilisé | b = nombre objets à cacher
	call 	hide_objects
	

	

	;pour tous les sprites dont les objets suivaient dans l'OAM décale sprt_OAM_addr du nombre d'objets libérés
	ld 		hl, _Sprite_pool
	ADD_U16_hl_val sprt_OAM_addr


	pop 	de
	pop 	bc
	ld 		c, 4
	call 	mult_u8
	ld 		b, a
	ld 		c, max_sprites

		;b = offset à retirer aux adresses | c = nombre d'itérations | de = adresse OAM du sprite libéré | hl = addr du premier attribut à tester
.loop_change_sprt_OAM_addr
	push 	bc
	push 	hl
	ldi 	a, [hl]
	ld 		h, [hl]
	ld 		l, a
		; hl <- addr en OAM du sprite testé
		; si hl > de hl = hl - b*
	ld 		a, l
	sub 	a, e
	ld 		a, h
	sbc 	a, d
	jr 		c, .ignore_addr_shift ; si hl - de -> carry alors de > hl -> pas de modif
		;bc = hl - b puis écriture dans la valeur push
		ld 		a, l
		sub 	a, b
		ld 		c, a
		ld 		a, h
		sbc 	a, $00
		ld 		b, a
		pop 	hl
		push 	hl
		ld 		[hl], c
		inc 	hl
		ld 		[hl], b

.ignore_addr_shift

	pop 	hl
	pop 	bc
	ADD_U16_hl_val SIZEOF_sprt_struct
	dec 	c
	jr 		nz, .loop_change_sprt_OAM_addr	

	ld 		a, $00
	ret
.error
	ld 		a, $FF
	ret








;--------------------------------------------------------------------------
;- Sprite_set_tiles(b = sprite index ; hl = table of tiles_IDs)       
;-			assigne aux objets composant le sprite les IDs des tiles le composant
;-   ex :
;-      hl -> $xx | $yy | $zz | ...
;-      objets composant le sprite : [<-$xx] [<-$yy] [<-$zz]
;-	ret  : 	a = $00 	OK
;- 			a = $FF 	KO
;--------------------------------------------------------------------------
Sprite_set_tiles::
	;vérifie que b est un index correct
	ld 		a, b
	cp 		a, max_sprites
	jr 		nc, .error

	;vérifie que l'objet demandé est assigné
	push 	hl
	ld 		hl, _Sprite_pool
	ld 		c, SIZEOF_sprt_struct
	call 	tab_offset
	pop 	de
	bit 	0, [hl]
	jr 		z, .error

	push 	hl
	;récupère le nombre d'objets composants
	ADD_U16_hl_val sprt_nb_obj
	ld 		b, [hl]
	pop 	hl
	;récupère l'adresse du premier objet en OAM
	ADD_U16_hl_val sprt_OAM_addr
	ldi 	a, [hl]
	ld 		h, [hl]
	ld 		l, a

		; hl = adresse du premier objet en OAM | de = ptr table des tiles_IDs | b = nombre d'objets composants
	ADD_U16_hl_val 2 	; objets : | %YYYYYYYY | %XXXXXXXX | %tile | %attributes |
.loop_set_tiles
	ld 		a, [de]
	ld 		[hl], a
	ADD_U16_hl_val 4 	; objet suivant
	inc 	de
	dec 	b
	jr 		nz, .loop_set_tiles
	ld 		a, $00
	ret
.error
	ld 		a, $FF
	ret




;--------------------------------------------------------------------------
;- Sprite_update_OAM(b = sprite index)       
;-			met en place les variables nécessaires à l'affichage correct des objets composant le sprite
;- 				- position de tous les objets (si affichage ou non)
;-				- flip h ou/et v
;- 				- attributs : priorité bg, palette 
;-
;- 	retour : 	a = $00 	OK
;- 				a = $FF 	KO
;--------------------------------------------------------------------------
Sprite_update_OAM::
	;vérifie que b est un index valide
	ld 		a, b
	cp 		a, max_sprites
	jP 		nc, .error

	;calcul l'adresse de l'entrée dans le sprite pool
	ld 		hl, _Sprite_pool
	ld 		c, SIZEOF_sprt_struct
	call 	tab_offset 			; hl <- adresse de l'entrée dans le sprite pool

	;vérifie que l'objet à cette adresse est instancié
	;/!\ on suppose que sprt_info_byte est le premier byte de la structure
	bit  	0, [hl]
	jp 		z, .error

	push 	hl
	;si le bit display est à zero, on met les coordonnées Y à zero afin de "cacher" le sprite
		;/!\ on suppose que sprt_info_byte est le premier byte de la structure
	bit 	3, [hl]
	jr 		nz, .sprite_is_displayed
		;cacher le sprite
		ADD_U16_hl_val sprt_nb_obj
		ld 		b, [hl] 				;b <- nb objets
		pop 	hl
		ADD_U16_hl_val sprt_OAM_addr
		ldi 	a, [hl]
		ld 		h, [hl]
		ld 		l, a 					;hl <- adresse du premier objet
		call 	hide_objects
		ld 		a, $00
		ret
.sprite_is_displayed
	;afficher le sprite
	pop 	hl 			; hl <- adresse de l'entrée dans le sprite pool
	; pour le chargement, on suppose que les attributs sont dans cet ordre :
		; sprt_info_byte
		; sprt_size
		; sprt_nb_obj
		; sprt_X_pos
		; sprt_Y_pos
		; sprt_OAM_addr
		; SIZEOF_sprt_struct
	ldi 	a, [hl]
	and 	a, %11110000
	ld 		c, a
	ldi 	a, [hl]
	ld 		b, a
	inc 	hl
	ldi 	a, [hl]
	ld 		d, a
	ldi 	a, [hl]
	ld 		e, a
	ldi 	a, [hl]
	ld 		h, [hl]
	ld 		l, a
	call 	iterY_start
	ld 		a, $00
	ret

.error
	ld 		a, $FF
	ret



;--------------------------------------------------------------------------
;- Sprite_set_Xpos(b = sprite index, c = Xpos)       
;-			met à jour la position du sprite (après avoir vérifié la validité de l'index)
;- 			/!\ ne met pas à jour la position dans l'OAM
;-
;- 	retour : 	a = $00 	OK
;- 				a = $FF 	KO
;--------------------------------------------------------------------------
Sprite_set_Xpos::
	;vérifie que b est un index valide
	ld 		a, b
	cp 		a, max_sprites
	jP 		nc, .error

	push 	bc
	;calcul l'adresse de l'entrée dans le sprite pool
	ld 		hl, _Sprite_pool
	ld 		c, SIZEOF_sprt_struct
	call 	tab_offset 			; hl <- adresse de l'entrée dans le sprite pool

	pop 	bc

	;vérifie que l'objet à cette adresse est instancié
	;/!\ on suppose que sprt_info_byte est le premier byte de la structure
	bit  	0, [hl]
	jp 		z, .error

	ADD_U16_hl_val sprt_X_pos
	ld 		[hl], c
	ld 		a, $00

	ret
.error
	ld 		a, $FF
	ret

;--------------------------------------------------------------------------
;- Sprite_set_Ypos(b = sprite index, c = Ypos)       
;-			met à jour la position du sprite (après avoir vérifié la validité de l'index)
;- 			/!\ ne met pas à jour la position dans l'OAM
;-
;- 	retour : 	a = $00 	OK
;- 				a = $FF 	KO
;--------------------------------------------------------------------------
Sprite_set_Ypos::
	;vérifie que b est un index valide
	ld 		a, b
	cp 		a, max_sprites
	jP 		nc, .error

	push 	bc
	;calcul l'adresse de l'entrée dans le sprite pool
	ld 		hl, _Sprite_pool
	ld 		c, SIZEOF_sprt_struct
	call 	tab_offset 			; hl <- adresse de l'entrée dans le sprite pool

	pop 	bc

	;vérifie que l'objet à cette adresse est instancié
	;/!\ on suppose que sprt_info_byte est le premier byte de la structure
	bit  	0, [hl]
	jp 		z, .error

	ADD_U16_hl_val sprt_Y_pos
	ld 		[hl], c
	ld 		a, $00

	ret
.error
	ld 		a, $FF
	ret


;--------------------------------------------------------------------------
;- Sprite_set_attr(b = sprite index, c = attr)       
;-			met à jour les attributs du sprite (après avoir vérifié la validité de l'index)
;- 			/!\ ne met pas à jour l'OAM
;-
;- 	retour : 	a = $00 	OK
;- 				a = $FF 	KO
;--------------------------------------------------------------------------
Sprite_set_attr::
	;vérifie que b est un index valide
	ld 		a, b
	cp 		a, max_sprites
	jP 		nc, .error

	push 	bc
	;calcul l'adresse de l'entrée dans le sprite pool
	ld 		hl, _Sprite_pool
	ld 		c, SIZEOF_sprt_struct
	call 	tab_offset 			; hl <- adresse de l'entrée dans le sprite pool

	pop 	bc

	;vérifie que l'objet à cette adresse est instancié
	;/!\ on suppose que sprt_info_byte est le premier byte de la structure
	bit  	0, [hl]
	jp 		z, .error

	ld 		a, c
	or 	 	a, %00000001   	; le sprite est instancié, il faut qu'il le reste
	ld 		[hl], a
	ld 		a, $00
	ret
.error
	ld 		a, $FF
	ret


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FONCTIONS AUXILLIAIRES                         | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+




;--------------------------------------------------------------------------
;- iterY et iterX (fonctionnent ensemble)
;- itèrent sur les objets d'un sprite afin de placer les positions et les attributs corrects en fonction des flip
;- exemple sur un 2*2 : (placement des sprites (position avec ordre dans l'OAM))
;- 		normal : 			Xflip :
;- 			1 	2 				2 	1
;- 			3 	4 				4 	3
;-
;- 		Yflip 				XYflip
;- 			3 	4 				4 	3
;- 			1 	2 				2 	1
;-
;- la fonction à appeler pour le placement est iterY_start et attends les registres suivants :
;- 		b = dimensions du sprite (sprt_size)
;- 		c = attributs du sprite (sprt_info_byte %11110000)
;- 		d = Xpos du sprite (sprt_X_pos)
;- 		e = Ypos du sprite (sprt_Y_pos)
;- 		hl = adresse du premier objet du sprite (sprt_OAM_addr)
;--------------------------------------------------------------------------
iterY_start:
	bit 	6, c
	jr 		z, .noflip_start
		;flip : la position Y commence à la fin (e = e + hauteur*8) ou hauteur*16 si mode 8*16
		IF mode_16 == 1
			ld 		a, b
			and 	a, %11110000 	; a <- hauteur * 16
		ELSE
			ld 		a, b
			swap 	a
			and 	a, %00001111 	; a <- hauteur
			sla 	a 		;a*2
			sla 	a 		;a*4
			sla 	a 		;a*8
		ENDC
		add 	a, e
		ld 		e, a
.noflip_start
iterY:
	push 	bc
	push 	de
	ld 		a, b
	and 	a, %00001111
	ld 		b, a
	call 	iterX_start
	pop 	de
	pop 	bc
	bit 	6, c
	jr 		z, .notflip
		;flip Ypos -
		IF mode_16 == 1
			ld 		a, e
			sub 	a, 16
		ELSE
			ld 		a, e
			sub 	a, 8
		ENDC
		jr 		.end_branch
.notflip
		;pas de flip Ypos +
		IF mode_16 == 1
			ld 		a, e
			add 	a, 16
		ELSE
			ld 		a, e
			add 	a, 8
		ENDC
.end_branch
	ld 		e, a
	ld 		a, b
	sub 	a, $10
	ld 		b, a
	cp 		a, $10
	jr 		nc, iterY
	ret
iterX_start:
	bit 	5, c
	jr 		z, .noflip_start
		;flip : la position X commence de la fin (d = d+8*(b-1))
		ld 		a, b
		dec 	a
		sla 	a 		;a*2
		sla 	a 		;a*4
		sla 	a  		;a*8
		add 	a, d
		ld 		d, a
.noflip_start
iterX:
	ld 		a, e
	ldi 	[hl], a
	ld 		a, d
	ldi 	[hl], a
	inc 	hl
	ld 		a, c
	ldi 	[hl], a
	bit 	5, c
	jr 		z, .noflip
		; flip Xpos -= 8
		ld 		a, d
		sub 	a, $08
		jr 		.end_branch
.noflip
		; pas de flip X pos += 8
		ld 		a, d
		add 	a, $08
.end_branch
	ld 		d, a
	dec 	b
	jr 		nz, iterX
	ret





;--------------------------------------------------------------------------
;- hide_objects(b = nb_objects, hl = addr du premier objet)       
;-			cache les b objets partant de celui à hl
;- 			en mettant les coordonnées Y à zero
;-
;--------------------------------------------------------------------------
hide_objects:
	; Y coord est le premier bit des objets
	ld 		a, b
	or 		a, a 		; si b est nul, retourne
	ld 		a, $00
.loop
	ret 	z
	ld 		[hl], a
	inc 	hl
	inc 	hl
	inc 	hl
	inc 	hl 		;objet suivant
	dec 	b
	jr 		.loop

; b index du sprite à tester (met la valeur b+1 dans les 4 bytes des objets composant le sprite)
set_test::
	;si b est plus grand que max_sprite, retourne
	ld 		a, b
	cp 		a, max_sprites
	ret 	nc
	push 	bc
	ld 		hl, _Sprite_pool
	ld 		c, SIZEOF_sprt_struct
	call 	tab_offset
	push 	hl
	ADD_U16_hl_val sprt_nb_obj
	ld 		b, [hl]
	pop 	hl
	ADD_U16_hl_val sprt_OAM_addr
	ldi 	a, [hl]
	ld 		h, [hl]
	ld 		l, a
	pop 	de
	ld 		a, d
	inc 	a
.loop
	ldi 	[hl], a
	ldi 	[hl], a
	inc 	hl
	ldi 	[hl], a
	dec 	b
	jr 		nz, .loop
	ret


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "Sprite_Variables",WRAM0
Sprite_vars_start:
;tableau des blocks contenant les infos pour les sprites en cours
_Sprite_pool:		DS SIZEOF_sprt_struct*max_sprites

_nb_sprites:		DS 1 	;nombre de sprites instanciés
_nb_used_objects: 	DS 1 	; nombre d'objets actuellement utilisés
_free_OAM_addr: 	DS 2 	;adresse libre de l'OAM (mirror) (big endian)
Sprite_vars_end:

