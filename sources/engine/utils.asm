;#####################################
;definition utils (se réferrer à engine.inc)
;utils contient les fonctions utilitaires nécessaires au bon fonctionnement du programme
;#####################################


	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FUNCTIONS                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "Utils_Functions",ROM0





;----------------------------------------------------------------------
;- memset(d = value ; hl = start address ; bc = taille à copier)
;----------------------------------------------------------------------


memset::
	ld		[hl],d
	inc 	hl
	dec		bc
	ld		a,b
	or		a,c
	jp		nz,memset
	ret



;----------------------------------------------------------------------
;- memcopy(bc = size ; hl = source address ; de = destination address)
;----------------------------------------------------------------------


memcopy::
	ldi		a,[hl]
	ld		[de], a
	inc 	de
	dec 	bc
	ld		a,b
	or 		a,c
	jr		nz, memcopy
	ret




;--------------------------------------------------------------------------
;- memcopy_fast(b = size ; hl = source address ; de = destination address)
;--------------------------------------------------------------------------

memcopy_fast::
	ldi		a,[hl]
	ld		[de],a
	inc		de
	dec		b
	jr		nz, memcopy_fast
	ret


;--------------------------------------------------------------------------
;- mult_u8(b = n1, c = n2) -> a = n1 * n2 (retour sur 8 bits)
;--------------------------------------------------------------------------

mult_u8::
	ld 		a, $00
	bit 	0, c
	jr 		z, .i0
	add 	a, b
.i0
	sla 	b
	bit 	1, c
	jr 		z, .i1
	add 	a, b
.i1
	sla 	b
	bit 	2, c
	jr 		z, .i2
	add 	a, b
.i2
	sla 	b
	bit 	3, c
	jr 		z, .i3
	add 	a, b
.i3
	sla 	b
	bit 	4, c
	jr 		z, .i4
	add 	a, b
.i4
	sla 	b
	bit 	5, c
	jr 		z, .i5
	add 	a, b
.i5
	sla 	b
	bit 	6, c
	jr 		z, .i6
	add 	a, b
.i6
	sla 	b
	bit 	7, c
	jr 		z, .i7
	add 	a, b
.i7
	ret

;--------------------------------------------------------------------------
;- mult_u816(b = n1, c = n2) -> hl = n1 * n2 (retour sur 16 bits)
;--------------------------------------------------------------------------
mult_u816::
	ld 		d, $00
	ld 		e, b
	ld 		hl, $00
	sra 	c
	jr 		nc, .i0 		;bit 0
	add 	hl, de
.i0
	sla 	e
	rl 		d
	sra 	c
	jr 		nc, .i1 		;bit 1
	add 	hl, de
.i1
	sla 	e
	rl 		d
	sra 	c
	jr 		nc, .i2 		;bit 2
	add 	hl, de
.i2
	sla 	e
	rl 		d
	sra 	c
	jr 		nc, .i3 		;bit 3
	add 	hl, de
.i3
	sla 	e
	rl 		d
	sra 	c
	jr 		nc, .i4 		;bit 4
	add 	hl, de
.i4
	sla 	e
	rl 		d
	sra 	c
	jr 		nc, .i5 		;bit 5
	add 	hl, de
.i5
	sla 	e
	rl 		d
	sra 	c
	jr 		nc, .i6 		;bit 6
	add 	hl, de
.i6
	sla 	e
	rl 		d
	sra 	c
	jr 		nc, .i7 		;bit 7
	add 	hl, de
.i7
	ret

;----------------------------------------
;- tab_offset(b = num element, c = elem size (in bytes), hl = bse addr)
;- 		retourne l'adresse du b_ieme elem de taille c dans le tableau
;-  	hl = hl + b*c
;----------------------------------------

tab_offset::
	push 	hl
	;calcule b * c
	call 	mult_u816
	pop 	de
	add 	hl, de 
	ret


;----------------------------------------
;- generateRandom() a = returned value
;----------------------------------------


generateRandom::
	ld 		hl, RandomX
	ld 		a, [hl]
	inc 	a
	ld 		e, a
	ld 		a, [RandomC]
	ld 		d, a
	ld 		a, [RandomA]
	xor 	d
	xor 	e
	ld 		b, a
	ld 		[hl], e
	inc 	hl
	ld 		a, [RandomB]
	add 	b
	ld 		c, a
	srl 	a
	xor 	b
	add 	d
	ld 		[hl], b ; ecriture de _RandomA
	inc 	hl
	ld 		[hl], c ; ecriture de _RandomB
	inc 	hl
	ld 		[hl], a ; ecriture de _RandomC
	ret ; a contient bien la valeur de C






;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+





	SECTION "Utils_Variables", WRAM0

RandomX:		DS 1
RandomA:		DS 1
RandomB:		DS 1
RandomC:		DS 1















