; #####################################
; Sprite handler
; Defines main sprite control routines
;######################################


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

;------------------------------------------------
; Sprites_clear()
;	Mark all sprites as inactives and not displayed
;	(status byte = $00)
;------------------------------------------------
Sprites_clear::
	ld	b, MAX_SPRITE_NUMBER
	ld	h, HIGH(Sprite_table)
	ld	a, $00
.loop	
	ld	l, a
	ld	[hl], $00
	dec	b
	ret	z
	add	a, SPRITE_STRUCTURE_SIZE	; sprite structure is 8 bytes long
	jr	.loop


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
		; TODO : display code goes here
.skip_display
	ld	hl, _current_sprite_index
	inc	[hl]
	ld	a, [hl]
	ld	l, a
	sla	l
	sla	l
	sla	l
	cp	MAX_SPRITE_NUMBER
	jr	nz, .loop_on_sprites
;;;;;;;TODO

;------------------------------------------
; Sprites_mask()
;	masks remaining unused objects
;------------------------------------------
Sprites_mask:
;; TODO mask code goes here (get remaining nb of objects, get current low of SOAM)
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
