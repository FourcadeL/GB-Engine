; ###############################
; Target Player
;
;	This file provide the basic code and routines
;	for the basic calculattion and request of ennemy shots
;	targetted at the player
;
;	The defining of unitarian vectors is done in static lookup tables
;
;	tables are defined for angles form 0 to pi/2
;	and symetry is applied to cover 2pi
; ###############################



;+--------------------------------------------------------------------------+
;| +----------------------------------------------------------------------+ |
;| |					 ROM 											  | |
;| +----------------------------------------------------------------------+ |
;+--------------------------------------------------------------------------+

	SECTION "Target_player_code", ROMX


	SECTION "Target_player_luts", ROMX, ALIGN[8]

; Each value is 2 bytes, indexed as : %fffxxyy0
;	xx is the x difference for vector computation (2 bits)
;	yy is he y difference for vector computation (2 bits)
;	fff is the scaling factor of the resulting vector (3 bits)
;
; A vector value is first the y vector coordinates
; and then the x vector coordinates

Target_player_vectors_lut::
FOR factor, 1, 8
	FOR x, 4
		FOR y, 4
			DB factor*SIN(y/4)
			DB factor*COS(1-x/4)
		ENDR
	ENDR
ENDR