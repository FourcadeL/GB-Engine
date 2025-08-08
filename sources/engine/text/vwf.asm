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

    INCLUDE "hardware.inc"
    INCLUDE "engine.inc"
    INCLUDE "debug.inc"


    ; données par défaut
DEF default_space       EQU 2   ; nombre de pixels de chaque espace
DEF default_line        EQU 8   ; nombre de pixels de chaque lignes


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                          FUNCTIONS                                      | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+
    
    SECTION "vwf_functions", ROM0

;----------------------------------------------------------------------
;- vwf_init() c = number of pixels in width ; d = number of pixels in height ; b = idx of first buffer tile
;-      initialisation de l'environnement d'écriture
;- réserve les tiles pour le buffer
;- fait correspondre la tilemap au buffer d'écriture
;----------------------------------------------------------------------
vwf_init::
    ;#TODO test
    ld      hl, _buffer_size_x
    ld      [hl], c
    ld      hl, _buffer_size_y
    ld      [hl], d
    ld      hl, _tile0_idx
    ld      [hl], b
    ld      a, $00
    ld      [_cursor_pos_x], a
    ld      [_cursor_pos_y], a
    
    ld      c, $10
    call    mult_u816 ; finds in hl the address of the tile idx0
    ld      a, [rLCDC]
    and     LCDCF_BG8000
    jr      nz, .pass_addr_correction
    ld      bc, $1000
    add     hl, bc
.pass_addr_correction
    ld      b, h
    ld      c, l
    ld      hl, _tile0_addr
    ld      a, c
    ld      [hl+], a
    ld      [hl], b

    ret

;--------------------------------------------------------
;- vwf_display_buffer(hl)
;-  associe le buffer à la tilemap
;-  à partir de l'adresse hl
;--------------------------------------------------------
vwf_display_buffer::
    PRINT_DEBUG "displaying buffer"
    ;; calcul du nombre de tiles en largeur et en hauteur
    ld      a, [_buffer_size_x]
    srl     a
    srl     a
    srl     a
    ld      c, a ; c <- largeur
    ld      a, [_buffer_size_y]
    srl     a
    srl     a
    srl     a
    ld      b, a ; b <- hauteur
    ld      a, [_tile0_idx]
    ld      d, a
.loop
    push    bc
    push    hl    
    ld      b, 0
    call    vram_set_inc
    pop     hl
    ld      bc, $0020
    add     hl, bc
    pop     bc
    dec     b
    jr      nz, .loop
    ret

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
_tile0_addr:        DS 2    ; adresse de la première tile du buffer (big endian)
    
; cursor variables : variables de tracking de la position du curseur et de l'état de l'automate
_cursor_pos_x:      DS 1    ; position x (px) du curseur
_cursor_pos_y:      DS 1    ; position y (px) du curseur
    

; styling variables : variable de définition des comportements à adopter
;   (espacement des lettre, taille d'une nouvelle ligne, etc)
_space_size:        DS 1    ; taille d'un espace (px)
_newline_height:     DS 1    ; nombre de pixels à descendre pour une nouvelle ligne
    
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
A_char:
    DB $47, %01101001, %10011111, %10011001, %1001
B_char:
    DB $47, %11101001, %10011110, %10011001, %1110
C_char:
    DB $47, %01101001, %10001000, %10001001, %0110
D_char:
    DB $47, %11101001, %10011001, %10011001, %1110
E_char:
    DB $47, %11111000, %10001110, %10001000, %1111
F_char:
    DB $47, %11111000, %10001110, %10001000, %1000
G_char:
    DB $47, %01101001, %10001011, %10011001, %0110
H_char:
    DB $47, %10011001, %10011111, %10011001, %1001
I_char:
    DB $37, %11101001, %00100100, %10111
J_char:
    DB $47, %01110010, %00100010, %00101010, %0100
K_char:
    DB $47, %10011010, %11001010, %10101001, %1001
L_char:
    DB $47, %10001000, %10001000, %10001000, %1111
M_char:
    DB $57, %10001110, %11101011, %00011000, %11000110, %001
N_char:
    DB $57, %10001110, %01110011, %01011001, %11001110, %001
O_char:
    DB $47, %01101001, %10011001, %10011001, %0110
P_char:
    DB $47, %11101001, %10011110, %10001000, %1000
Q_char:
    DB $47, %01101001, %10011001, %11011010, %0111
R_char:
    DB $47, %11101001, %10011110, %10011001, %1001
S_char:
    DB $47, %01101001, %10000110, %00011001, %0110
T_char:
    DB $57, %11111001, %00001000, %01000010, %00010000, %100
U_char:
    DB $47, %10011001, %10011001, %10011001, %0110
V_char:
    DB $57, %10001100, %01100010, %10100101, %00101000, %100
W_char:
    DB $57, %10001100, %01100011, %00011010, %11010101, %010
X_char:
    DB $57, %10001100, %01010100, %01000101, %01000110, %001
Y_char:
    DB $57, %10001100, %01100010, %10100010, %00010000, %100
Z_char:
    DB $47, %11110001, %00100100, %01001000, %1111

a_char:
    DB $45, %01100001, %01111001, %0111
b_char:
    DB $35, %10010011, %0101110
c_char:
    DB $45, %01101001, %10001001, %0110
d_char:
    DB $35, %00100101, %1101011
e_char:
    DB $45, %01101001, %11101000, %0110
f_char:
    DB $23, %01101110, %10
g_char:
    DB $45, %01101001, %01110001, %0110
h_char:
    DB $35, %10010011, %0101101
i_char:
    DB $15, %10111
j_char:
    DB $36, %00100000, %10011010, %10
k_char:
    DB $35, %10010111, %0110101
l_char:
    DB $15, %11111
m_char:
    DB $54, %01010101, %01101011, %0101
n_char:
    DB $34, %01110110, %1101
o_char:
    DB $44, %01101001, %10010110
p_char:
    DB $35, %11010111, %0100100
q_char:
    DB $35, %01110101, %1001001
r_char:
    DB $34, %10111010, %0100
s_char:
    DB $35, %01110001, %0001110
t_char:
    DB $35, %01011101, %0010001
u_char:
    DB $34, %10110110, %1011
v_char:
    DB $34, %10110110, %1010
w_char:
    DB $54, %10001101, %01101010, %1010
x_char:
    DB $34, %10101001, %0101
y_char:
    DB $35, %10110101, %0010100
z_char:
    DB $35, %11100101, %0100111
