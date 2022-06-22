;#########################################################
; 		Définition de macros et valeurs pour débeug plus facilement
;#########################################################


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                            MACROs                  | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

	IF !DEF(DEBUG_INC)
DEBUG_INC SET 1


;------------------------------------------------------------------------------------------------
;- SET_BREAK
;-
;- permet d'insérer un breakpoint sur bgb
;-
;------------------------------------------------------------------------------------------------
SET_BREAK : MACRO
	ld 		b, b
	jr 		.end\@
	dw 		$6464
	dw 		$0000
.end\@
ENDM




;----------------------------------------------------------------------
;- PRINT_DEBUG(message) 
;-
;- permet d'afficher un message de debug à l'exécution (ainsi que des valeurs en cours)
;- invocation :
;- 			PRINT_DEBUG "message"
;-
;- affichage de valeurs :
;- 		- affichage de registres : %r%
;- 		- affichage d'une adresse mémoire : %($addr)%
;- 		- affichage de résultats d'opérations possibles expl : %($C000) + 2%
;-
;- peuvent être évalué
;- CPU registers: AF, BC, DE, HL, SP, PC, B, C, D, E, H, L, A, ZERO, ZF, Z, CARRY, CY, IME, ALLREGS
;- other state values: ROMBANK, XRAMBANK, SRAMBANK, WRAMBANK, VRAMBANK, TOTALCLKS, LASTCLKS, CLKS2VBLANK
;----------------------------------------------------------------------
PRINT_DEBUG : MACRO
	ld 		d, d
	jr 		.end\@
	dw 		$6464
	dw 		$0000
	db 		\1
.end\@
ENDM


;----------------------------------------------------------------------
;- PRINT_DEBUG_TABL(addr_start, nb_elements) 
;-
;- permet d'afficher le contenu d'un tableau en mémoire
;----------------------------------------------------------------------
PRINT_DEBUG_TABL : MACRO
	IF 		\2 > 13
		PRINTT "ERREUR demande affichage d'un tableau de taille trop grande à l'exécution (la taille est > 13)\nCet affichage est ignoré\n"
	ELSE
	ld 		d, d
	jr 		.end\@
	dw 		$6464
	dw 		$0000
ADDR = \1 
	REPT \2 ; pour chaque élément
		db 		"%($", "{X:ADDR}", ")%"
ADDR = ADDR + 1
	ENDR
.end\@
	ENDC
ENDM



ENDC
