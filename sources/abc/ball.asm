; Fonctions et routines pour la gestion de balles


; -----constantes physiques-------------
BALL_X_SPEED EQU %00000010
BALL_Y_SPEED EQU %00000010
; --------------------------------------

SECTION "ball_functions", ROMX


SECTION "ball_variables", WRAM0

ball_pos_x: DS 2
ball_pos_y: DS 2

; les positions sur l'écran sont ramenées à 8bits
; par des opérations de shift sur la position détaillée
ball_screen_pos_x: DS 1
ball_screen_bos_y: DS 1