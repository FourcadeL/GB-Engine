; #####################################
; Sprite handler
; Defines main sprite control routines
;######################################

; terminology :
;	object -> One OAM element
;	sprite -> A group of objects with associated behaviours

INCLUDE "hardware.inc"
INCLUDE "debug.inc"
INCLUDE "sprites.inc"

;+---------------------------------------------------------------------+
;| +-----------------------------------------------------------------+ |
;| |                                                                 | |
;| |                      SPRITES FUNCTION                           | |
;| |                                                                 | |
;| +-----------------------------------------------------------------+ |
;+---------------------------------------------------------------------+


	SECTION "Sprites_Functions", ROM0

;------------------------------------------
; Sprites_init()
;	Sets up correct objects size
;	Clear sprites table
;------------------------------------------
Sprites_init::
	; setup of correct object mode
	ld	a, [rLCDC]
IF		MODE_16 == 1
	or	a, LCDCF_OBJ16
ELSE
	and a, %11111011	; not LCDCF_OBJ8
ENDC
	or	a, LCDCF_OBJON
	ld	[rLCDC], a
	; ret ; no ret since sprite table is cleared after init



;------------------------------------------------
; Sprites_clear()
;	Mark all sprites as inactives and not displayed
;	(status byte = $00)
;	Set next _low_SOAM value to $00
;------------------------------------------------
Sprites_clear::
	ld	b, MAX_SPRITE_NUMBER
	ld	h, HIGH(Sprite_table)
	ld	a, $00
.loop	
	ld	l, a
	ld	[hl], $00
	add	a, SPRITE_STRUCTURE_SIZE	; sprite structure is 8 bytes long
	dec	b
	jr	nz, .loop
	ld	hl, _current_low_SOAM
	ld	[hl], $00
	ret	


;------------------------------------------------
; Sprites_display_current(b = Xpos, c = Ypos, a = displayList index)
;	requires : _current_sprite_status_byte set up
;	Sets up objects of sprites in SOAM
;------------------------------------------------
Sprites_display_current:
	add	a, a		; get low addr of displayList
	ld	h, HIGH(DisplayList_table)
	ld	l, a
	ld	e, [hl]
	inc	l
	ld	d, [hl]		; de is addr to displayList

	ld	a, [de]
	or	a
	ret	z		; return if no objects in displayList

	inc	de
	ld	[_current_sprite_nb_of_objects], a
	ld	h, HIGH(Shadow_OAM)
	ld	a, [_current_low_SOAM]
	ld	l, a
.loopOnObjects
	ld	a, [de]		; Y pos offset
	inc	de
	add	a, c
	add	a, $10		; 16 px offset for Y top screen
	cp	$A0
	jr	nc, .skipDisplayCauseY
	ld	[hl+], a
	ld	a, [de]
	inc	de
	add	a, b
	add	a, $08		; 8 px offset for X left screen
	cp	$A8
	jr	nc, .skipDisplayCauseX
	ld	[hl+], a
	ld	a, [de]
	inc	de
	ld	[hl+], a
	ld	a, [de]
	inc	de
	ld	[hl+], a

	ld	a, [_nb_remaining_free_objects]
	dec	a
	ld	[_nb_remaining_free_objects], a
	jr	z, .noFreeObjects
	ld	a, $18		; next object is 6 ahead
	add	l
	cp	$A0
	jr	c, .skipOverflowCase
	sub	$A0
.skipOverflowCase
	ld	[_current_low_SOAM], a
	ld	l, a
.afterSkipEntry
	ld	a, [_current_sprite_nb_of_objects]
	dec	a
	ret	z		; no more objects to display
	ld	[_current_sprite_nb_of_objects], a
	jr	.loopOnObjects


.skipDisplayCauseY
	inc	de
	inc	de
	inc	de
	jr	.afterSkipEntry
.skipDisplayCauseX
	inc	de
	inc	de
	dec	hl
	jr	.afterSkipEntry
	
.noFreeObjects
	ld	a, [_current_low_SOAM]
	pop	bc				; prevent execution return to sprite multiplex
	jr	Sprites_finalize_multiplexing



;------------------------------------------------
; Sprites_multiplex()
;	Constructs all objets for displayed sprites in
;	shadow OAM
;	
;	Changes start addr for object priority cycling
;-----------------------------------------------
Sprites_multiplex::
	ld 	a, $28	; starts with 40 free objects
	ld	[_nb_remaining_free_objects], a
	ld	h, HIGH(Sprite_table)
	ld	a, $00
	ld	[_current_sprite_index], a
	ld	l, a
.loop_on_sprites		; hl is the base addr of current object
	bit	0, [hl]		; display bit ?	
	jr	z, .skip_display
	ld	a, [hl+]
	ld	[_current_sprite_status_byte], a
	ld	a, [hl+]		; display list index of sprite
	ld	c, [hl]		; low Y pos of sprite
	inc	l
	inc	l
	ld	b, [hl]		; low X pos of sprite
	call	Sprites_display_current
.skip_display
	ld	hl, _current_sprite_index
	inc	[hl]
	ld	a, [hl]
	ld	h, HIGH(Sprite_table)
	ld	l, a
	sla	l
	sla	l
	sla	l
	cp	MAX_SPRITE_NUMBER
	jr	nz, .loop_on_sprites
; 	no return since remaining sprites should be masked after loop

;------------------------------------------
; Sprites_mask()
;	masks remaining unused objects
;------------------------------------------
Sprites_mask:
	ld	h, HIGH(Shadow_OAM)
	ld	a, [_current_low_SOAM]
	ld	l, a
	ld	a, [_nb_remaining_free_objects]
	ld	c, a
.loop
	ld	[hl], $00	; set y pos of object out of bound
	ld	a, $1C		; next object is +7
	add	l
	cp	$A0		; did we overflow SOAM
	jr	c, .skipOverflowCase
	sub	$A0
.skipOverflowCase
	ld	l, a
	dec	c
	jr	nz, .loop
;	no ret since we have to finalize multiplexing

;----------------------------------------------
; Sprites_finalize_multiplexing(a = current low of SOAM)
;	sets up new SOAM low for next object population
;----------------------------------------------
Sprites_finalize_multiplexing::
	add	a, $5C		; next starting object is +27
	ld	[_current_low_SOAM], a
	cp	$A0
	ret	c		; new current low OAM is valid
	sub	$A0
	ld	[_current_low_SOAM], a
	ret

;+---------------------------------------------------------------------+
;| +-----------------------------------------------------------------+ |
;| |                                                                 | |
;| |                       SPRITES VARIABLES                         | |
;| |                                                                 | |
;| +-----------------------------------------------------------------+ |
;+---------------------------------------------------------------------+

	SECTION "Sprites_Variables", WRAM0

_nb_remaining_free_objects:		DS 1 ; number of remaining free objects of shadow OAM in current multiplex pass
_current_sprite_index:			DS 1 ; index of currently considered sprite
_current_sprite_status_byte:		DS 1 ; status byte value of currently processed sprite
_current_sprite_nb_of_objects:		DS 1 ; number of objects to display in currents sprite
_current_low_SOAM:			DS 1 ; value of current low os shadow OAM


;+---------------------------------------------------------------------+
;| +-----------------------------------------------------------------+ |
;| |                                                                 | |
;| |                       DYNAMIC TABLES                            | |
;| |                                                                 | |
;| +-----------------------------------------------------------------+ |
;+---------------------------------------------------------------------+

;-------------------------------
; Sprite table attributes
;	- has room for 20 active sprites
;	- each sprite has 8 descriptive bytes
;		- b0 : Status
;			% a??????d
;			  |      +-> display status : 1 = display
;			  |
;			  +--------> active status : 1 = active
;		- b1 : Display list index
;		- b2 : Y pos low
;		- b3 : ???
;		- b4 : X pos low
;		- b5 : ???
;-------------------------------

	SECTION "Sprite_Table", WRAM0, align[8]
Sprite_table::
	DS	MAX_SPRITE_NUMBER*8


;--------------------------------
; Display list table
;	This is a table of 2 bytes addresses
;	to display lists data
;--------------------------------

	SECTION "DisplayList_Table", WRAM0, align[8]
DisplayList_table::
	DS	MAX_DISPLAYLIST_NUMBER*2

;+---------------------------------------------------------------------+
;| +-----------------------------------------------------------------+ |
;| |                                                                 | |
;| |                       SYSTEM  TABLES                            | |
;| |                                                                 | |
;| +-----------------------------------------------------------------+ |
;+---------------------------------------------------------------------+


	SECTION "Shadow_OAM", WRAM0, align[8]
Shadow_OAM::
	DS	$A0
