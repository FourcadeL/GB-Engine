;#####################################
;definition video (se réferrer à engine.inc)
;video contient les fonctions de manipulation des sprites et du background (/!\ la plupart doivent être appelées en VBLANK)
;#####################################


	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FUNCTIONS                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "Video_Functions",ROM0



;--------------------------------------------------------------------------
;- wait_ly(b = ly à attendre)                                       -
;--------------------------------------------------------------------------

wait_ly::

	ld		c,rLY & $FF

.pas_le_bon_ly:
	ld		a,[$FF00+c]
	cp		a,b
	jr		nz,.pas_le_bon_ly

	ret



;--------------------------------------------------------------------------
;- wait_frames(e) = nb de frames à attendre)                                   -
;--------------------------------------------------------------------------

wait_frames::

    call    wait_vbl
    dec     e
    jr      nz,wait_frames

    ret



;--------------------------------------------------------------------------
;- screen_off()                                                           -
;--------------------------------------------------------------------------

screen_off::

    ld      a,[rLCDC]
    ; sauvegarde des attributs
    ld		[_screen_control_save], a

    and     a,LCDCF_ON
    ret     z ; LCD already OFF


    ld      b,$91
    call    wait_ly


    xor     a,a
    ld      [rLCDC], a ;Shutdown LCD

    ret



;--------------------------------------------------------------------------
;- screen_restart()                                                           -
;--------------------------------------------------------------------------

screen_restart::

	ld		a, [_screen_control_save]
	or		a, LCDCF_ON ; pour être sûr de bien redémarrer l'écran


	ld		[rLCDC], a ; reprise de l'écran


	ret

	



;--------------------------------------------------------------------------
;- init_DMA()                                        -
;--------------------------------------------------------------------------

init_DMA::
	
	ld		b,__DMA_code_end - __DMA_code
	ld		hl,__DMA_code
	ld		de,DMA_ROUTINE_HRAM
	call	memcopy_fast
	ret



	



;--------------------------------------------------------------------------
;- call_DMA()                                        -
;--------------------------------------------------------------------------


call_DMA::
	ld		a,OAM_mirror >> 8 ;décalé de 8 bits car on ne prends que l'octet le plus significatif sur les deux composant l'adresse
	jp		DMA_ROUTINE_HRAM




;--------------------------------------------------------------------------
;- vram_set()   d = set value	 bc = size      hl = dest address   -
;- effectue une copie vers la vram (attent de pouvoir y accéder)
;--------------------------------------------------------------------------

vram_set::
	ld 		a, [rSTAT]
	bit 	1, a
	jr 		nz, vram_set ; PPU busy

	ld 		[hl], d
	inc 	hl
	dec 	bc
	ld 		a, b
	or 		a, c
	jr 		nz, vram_set
	ret

;--------------------------------------------------------------------
;- vram_set_inc()	d = start value 	bc = size 	hl = dest adress
; @ensures : set vram values to an incrementing value
; [hl] -> |d|d+1|d+2|d+3|d+4|...etc...
;--------------------------------------------------------------------
vram_set_inc::
	ld 		a, [rSTAT]
	bit 	1, a
	jr   	nz, vram_set_inc ; PPU busy

	ld 		[hl], d
	inc 	hl
	inc 	d
	dec 	bc
	ld 		a, b
	or 		a, c
	jr   	nz, vram_set_inc
	ret

;--------------------------------------------------------------------------
;- vram_copy()    bc = size    hl = source address    de = dest address   -
;- effectue une copie vers la vram (attent de pouvoir y accéder)
;--------------------------------------------------------------------------

vram_copy::

    ld      a,[rSTAT]
    bit     1,a
    jr      nz,vram_copy ; Not mode 0 or 1

    ldi      a,[hl]
    ld      [de],a
    inc     de
    dec     bc
    ld      a,b
    or      a,c
    jr      nz,vram_copy
    ret

;--------------------------------------------------------------------------
;- vram_copy_fast()    c = size    hl = source address    de = dest address   -
;- effectue une copie vers la vram (attent de pouvoir y accéder)
;--------------------------------------------------------------------------

vram_copy_fast::

    ld      a,[rSTAT]
    bit     1,a
    jr      nz,vram_copy_fast ; Not mode 0 or 1

    ldi      a,[hl]
    ld      [de],a
    inc     de
    dec     c
    jr      nz,vram_copy_fast
    ret

;--------------------------------------------------------------------------
;- tilemap_bg_block_copy()    b = height, c = width  d = y pos(from top) e = x pos(from left) hl = source address-
;- effectue une copie vers la tilemap du background (attend de pouvoir y accéder)
;- copie b*c bytes (tile number) en mettant en place les bonnes dimensions
;--------------------------------------------------------------------------

tilemap_bg_block_copy::

	push 	bc
	ld 		a, d
	ld 		b, e
	sla 	a;<- d*2
	swap 	a
	ld 		e, a
	and 	a, %00001111
	add 	a, $98
.win_entry
	ld 		d, a
	ld 		a, e
	and 	a, %11110000
	add 	a, b
	ld 		e, a
	pop 	bc

	;^ de contient l'adresse de la ligne de départ 
.redo
	push 	bc
	push	de
	call 	vram_copy_fast
	pop 	de
	pop 	bc 
	dec 	b
	ret 	z
	ld 		a, e
	add 	a, $20
	ld 		e, a 
	ld 		a, d
	adc 	a, $00
	ld 		d, a
	jr 		.redo

;--------------------------------------------------------------------------
;- tilemap_win_block_copy()    b = height, c = width  d = y pos(from top) e = x pos(from left) hl = source address-
;- effectue une copie vers la tilemap de la window (attend de pouvoir y accéder)
;- copie b*c bytes (tile number) en mettant en place les bonnes dimensions
;--------------------------------------------------------------------------

tilemap_win_block_copy::
	push 	bc
	ld 		a, d
	ld 		b, e
	sla 	a;<- d*2
	swap 	a
	ld 		e, a
	and 	a, %00001111
	add 	a, $9C
	jr 		tilemap_bg_block_copy.win_entry




;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "Video_Variables",WRAM0[$C000]


OAM_mirror:	DS $A0 ; copiée en OAM par la routine DMA
OAM_mirror_end:


_screen_control_save: DS 1






;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          DMA ROUTINE assembled                           | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+



	SECTION "DMA_ROUTINE_pre", ROM0
__DMA_code:
	ld		[rDMA],a
	ld		a,$28		;delay 200ms
.delay:
	dec		a
	jr		nz,.delay

	ret
__DMA_code_end:







;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          ROUTINE destination                            | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


	SECTION "OAM_DMA_ROUTINE",HRAM[$FF80]

DMA_ROUTINE_HRAM:	DS (__DMA_code_end - __DMA_code)
