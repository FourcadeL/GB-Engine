; #############################""
; définiiton vwf (compléter engine.ing)
; explications : 
;       à l'initialisation on définit un buffer placé à un certain inderx de la itlemap
;       avec une dimension d'un certain nombre de tiles
;       +----------------------> x
;       | .curseur
;       |
;       |
;       |
;       v y
;
;           le curseur permet de placer une lettre et est déplacé à chaque écriture





;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FUNCTIONS                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+
    
    SECTION "vwf_functions", ROM0
;----------------------------------------------------------------------
;- vwf_init()
;-      initialisation de l'environnement d'écriture
;- réserve les tiles pour le buffer
;- fait correspondre la tilemap au buffer d'écriture
;----------------------------------------------------------------------
vwf_init::
;#TODO

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          VARIABLES                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

    SECTION "vwf_data", WRAM0
vwf_vars_start:
; buffer variables : variables de définition du buffer (taille, placement et tiles du tileset à utiliser)
_buffer_size_x:     DS 1    ; taille (px) du buffer en largeur
_buffer_size_y:     DS 1    ; taille (px) du buffer en hauteur
_tile0_idx:         DS 1    ; index de la première tile du buffer
    
; cursor variables : variables de tracking de la position du curseur et de l'état de l'automate
_cursor_pos_x:      DS 1    ; position x (px) du curseur
_cursor_pos_y:      DS 1    ; position y (px) du curseur
    
    
    SECTION "vwf_characters_data", ROM0


;; this section defines characters for the vwf engine
    ;; for each one the standart is :
        ;; width * height byte (in pixels) : type %wwwwhhhh
        ;; data (in 1BPP format) with no margin on the character
        ;; from top to botom from left to right
        ;; ----------> |
        ;; ----------> |
        ;; ----------> |
        ;; ----------> |
        ;; ----------> v
A:
    DB $47, %0110100110011111100110011001
B:
    DB $47, %1110100110011110100110011110
C:
    DB $47, %0110100110001000100010010110
D:
    DB $47, %1110100110011001100110011110
E:
    DB $47, %1111100010001110100010001111
F:
    DB $47, %1111100010001110100010001000
G:
    DB $47, %0110100110001011100110010110
H:
    DB $47, %1001100110011111100110011001
I:
    DB $37, %111010010010010010111
J:
    DB $47, %0111001000100010001010100100
K:
    DB $47, %1001101011001010101010011001
L:
    DB $47, %1000100010001000100010001111
M:
    DB $57, %10001110111010110001100011000110001
N:
    DB $57, %10001110011100110101100111001110001
O:
    DB $47, %0110100110011001100110010110
P:
    DB $47, %1110100110011110100010001000
Q:
    DB $47, %0110100110011001110110100111
R:
    DB $47, %1110100110011110100110011001
S:
    DB $47, %0110100110000110000110010110
T:
    DB $57, %11111001000010000100001000010000100
U:
    DB $47, %1001100110011001100110010110
V:
    DB $57, %10001100011000101010010100101000100
W:
    DB $57, %10001100011000110001101011010101010
X:
    DB $57, %10001100010101000100010101000110001
Y:
    DB $57, %10001100011000101010001000010000100
Z:
    DB $47, %1111000100100100010010001111