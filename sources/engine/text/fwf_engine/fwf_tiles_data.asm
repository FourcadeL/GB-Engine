;####################################
; Tiles data for fwf
;####################################

    SECTION "fwf_tiles_code", ROM0

;-----------------------------
;- GET_TILE_DATA_ADDR(l = tile ascii ID) -> hl = tile data pointer
;-----------------------------
fwf_get_tile_data_addr::
    ld h, HIGH(FWF_tiles_lookup)
    ld a, [hl]
    swap a
    ld b, a
    and a, %11110000
    ld l, a
    ld a, b
    and a, %00001111
    add a, HIGH(FWF_tiles_data)
    ld h, a
    ret


    SECTION "fwf_tiles_lookup", ROMX, ALIGN[8]
FWF_tiles_lookup:
    DB LOW(UNKNOWN_tile >> 4) ;$00
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4) ;$10
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(BLANK_tile >> 4) ;$20
    DB LOW(EXCLAMATION_tile >> 4)
    DB LOW(QUOTE_tile >> 4)
    DB LOW(HASHTAG_tile >> 4)
    DB LOW(DOLLAR_tile >> 4)
    DB LOW(PERCENT_tile >> 4)
    DB LOW(AMPERSTAND_tile >> 4)
    DB LOW(APOSTROPHE_tile >> 4)
    DB LOW(OPARENTH_tile >> 4)
    DB LOW(CPARENTH_tile >> 4)
    DB LOW(STAR_tile >> 4)
    DB LOW(PLUS_tile >> 4)
    DB LOW(COMMA_tile >> 4)
    DB LOW(MINUS_tile >> 4)
    DB LOW(DOT_tile >> 4)
    DB LOW(SLASH_tile >> 4)
    DB LOW(ZERO_tile >> 4) ;$30
    DB LOW(ONE_tile >> 4)
    DB LOW(TWO_tile >> 4)
    DB LOW(THREE_tile >> 4)
    DB LOW(FOUR_tile >> 4)
    DB LOW(FIVE_tile >> 4)
    DB LOW(SIX_tile >> 4)
    DB LOW(SEVEN_tile >> 4)
    DB LOW(EIGHT_tile >> 4)
    DB LOW(NINE_tile >> 4)
    DB LOW(COLON_tile >> 4)
    DB LOW(SCOLON_tile >> 4)
    DB LOW(LESSER_tile >> 4)
    DB LOW(EQUAL_tile >> 4)
    DB LOW(GREATER_tile >> 4)
    DB LOW(QUESTION_tile >> 4)
    DB LOW(AROBASE_tile >> 4) ;$40
    DB LOW(A_tile >> 4)
    DB LOW(B_tile >> 4)
    DB LOW(C_tile >> 4)
    DB LOW(D_tile >> 4)
    DB LOW(E_tile >> 4)
    DB LOW(F_tile >> 4)
    DB LOW(G_tile >> 4)
    DB LOW(H_tile >> 4)
    DB LOW(I_tile >> 4)
    DB LOW(J_tile >> 4)
    DB LOW(K_tile >> 4)
    DB LOW(L_tile >> 4)
    DB LOW(M_tile >> 4)
    DB LOW(N_tile >> 4)
    DB LOW(O_tile >> 4)
    DB LOW(P_tile >> 4) ;$50
    DB LOW(Q_tile >> 4)
    DB LOW(R_tile >> 4)
    DB LOW(S_tile >> 4)
    DB LOW(T_tile >> 4)
    DB LOW(U_tile >> 4)
    DB LOW(V_tile >> 4)
    DB LOW(W_tile >> 4)
    DB LOW(X_tile >> 4)
    DB LOW(Y_tile >> 4)
    DB LOW(Z_tile >> 4)
    DB LOW(OBRACKET_tile >> 4)
    DB LOW(BACKSLASH_tile >> 4)
    DB LOW(CBRACKET_tile >> 4)
    DB LOW(CIRCUMFLEX_tile >> 4)
    DB LOW(UNDERSCORE_tile >> 4)
    DB LOW(BACK_APOSTROPHE_tile >> 4) ;$60
    DB LOW(a_tile >> 4)
    DB LOW(b_tile >> 4)
    DB LOW(c_tile >> 4)
    DB LOW(d_tile >> 4)
    DB LOW(e_tile >> 4)
    DB LOW(f_tile >> 4)
    DB LOW(g_tile >> 4)
    DB LOW(h_tile >> 4)
    DB LOW(i_tile >> 4)
    DB LOW(j_tile >> 4)
    DB LOW(k_tile >> 4)
    DB LOW(l_tile >> 4)
    DB LOW(m_tile >> 4)
    DB LOW(n_tile >> 4)
    DB LOW(o_tile >> 4)
    DB LOW(p_tile >> 4) ;$70
    DB LOW(q_tile >> 4)
    DB LOW(r_tile >> 4)
    DB LOW(s_tile >> 4)
    DB LOW(t_tile >> 4)
    DB LOW(u_tile >> 4)
    DB LOW(v_tile >> 4)
    DB LOW(w_tile >> 4)
    DB LOW(x_tile >> 4)
    DB LOW(y_tile >> 4)
    DB LOW(z_tile >> 4)
    DB LOW(OCBRACKET_tile >> 4)
    DB LOW(VBAR_tile >> 4)
    DB LOW(CCBRACKET_tile >> 4)
    DB LOW(TILDE_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(CCEDILLA_tile >> 4) ;$80
    DB LOW(uTREM_tile >> 4)
    DB LOW(eAIG_tile >> 4)
    DB LOW(aCARET_tile >> 4)
    DB LOW(aTREM_tile >> 4)
    DB LOW(aGRAV_tile >> 4)
    DB LOW(aRING_tile >> 4)
    DB LOW(cCEDILLA_tile >> 4)
    DB LOW(eCARET_tile >> 4)
    DB LOW(eTREM_tile >> 4)
    DB LOW(eGRAV_tile >> 4)
    DB LOW(iTREM_tile >> 4)
    DB LOW(iCARET_tile >> 4)
    DB LOW(iGRAV_tile >> 4)
    DB LOW(ATREM_tile >> 4)
    DB LOW(ARING_tile >> 4)
    DB LOW(EAIG_tile >> 4) ;$90
    DB LOW(aeSYM_tile >> 4)
    DB LOW(AESYM_tile >> 4)
    DB LOW(oCARET_tile >> 4)
    DB LOW(oTREM_tile >> 4)
    DB LOW(oGRAV_tile >> 4)
    DB LOW(uCARET_tile >> 4)
    DB LOW(uGRAV_tile >> 4)
    DB LOW(yTREM_tile >> 4)
    DB LOW(OTREM_tile >> 4)
    DB LOW(UTREM_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(aAIG_tile >> 4) ;$A0
    DB LOW(iAIG_tile >> 4)
    DB LOW(oAIG_tile >> 4)
    DB LOW(uAIG_tile >> 4)
    DB LOW(nTILDE_tile >> 4)
    DB LOW(NTILDE_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(IQUESTION_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4) ;$B0
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4) ;$C0
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4) ;$D0
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4) ;$E0
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4) ;$F0
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4)
    DB LOW(UNKNOWN_tile >> 4) ;$FF

    SECTION "fwf_tiles_data", ROMX, ALIGN[8]
FWF_tiles_data:
BLANK_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
UNKNOWN_tile:
    DB $FF,$FF,$00,$00,$FF,$FF,$00,$00
    DB $FF,$FF,$00,$00,$FF,$FF,$00,$00

ZERO_tile:
    DB $00,$00,$38,$38,$64,$64,$64,$64
    DB $64,$64,$64,$64,$64,$64,$38,$38
ONE_tile:
    DB $00,$00,$18,$18,$38,$38,$58,$58
    DB $18,$18,$18,$18,$18,$18,$3C,$3C
TWO_tile:
    DB $00,$00,$3C,$3C,$46,$46,$06,$06
    DB $0C,$0C,$10,$10,$20,$20,$7E,$7E
THREE_tile:
    DB $00,$00,$3C,$3C,$46,$46,$06,$06
    DB $3C,$3C,$06,$06,$46,$46,$3C,$3C
FOUR_tile:
    DB $00,$00,$0C,$0C,$1C,$1C,$2C,$2C
    DB $4C,$4C,$7C,$7C,$0C,$0C,$0C,$0C
FIVE_tile:
    DB $00,$00,$7E,$7E,$60,$60,$60,$60
    DB $7C,$7C,$02,$02,$42,$42,$3C,$3C
SIX_tile:
    DB $00,$00,$3C,$3C,$62,$62,$60,$60
    DB $7C,$7C,$62,$62,$62,$62,$3C,$3C
SEVEN_tile:
    DB $00,$00,$7E,$7E,$06,$06,$06,$06
    DB $0C,$0C,$0C,$0C,$18,$18,$18,$18
EIGHT_tile:
    DB $00,$00,$3C,$3C,$62,$62,$62,$62
    DB $3C,$3C,$62,$62,$62,$62,$3C,$3C
NINE_tile:
    DB $00,$00,$3C,$3C,$46,$46,$46,$46
    DB $3E,$3E,$06,$06,$46,$46,$3C,$3C

A_tile:
    DB $00,$00,$3C,$3C,$62,$62,$62,$62
    DB $7E,$7E,$62,$62,$62,$62,$62,$62
B_tile:
    DB $00,$00,$78,$78,$64,$64,$64,$64
    DB $7C,$7C,$62,$62,$62,$62,$7C,$7C
C_tile:
    DB $00,$00,$3C,$3C,$62,$62,$60,$60
    DB $60,$60,$60,$60,$62,$62,$3C,$3C
D_tile:
    DB $00,$00,$7C,$7C,$62,$62,$62,$62
    DB $62,$62,$62,$62,$62,$62,$7C,$7C
E_tile:
    DB $00,$00,$7E,$7E,$60,$60,$60,$60
    DB $78,$78,$60,$60,$60,$60,$7E,$7E
F_tile:
    DB $00,$00,$7E,$7E,$60,$60,$60,$60
    DB $78,$78,$60,$60,$60,$60,$60,$60
G_tile:
    DB $00,$00,$3C,$3C,$62,$62,$60,$60
    DB $67,$67,$62,$62,$62,$62,$3C,$3C
H_tile:
    DB $00,$00,$62,$62,$62,$62,$62,$62
    DB $7E,$7E,$62,$62,$62,$62,$62,$62
I_tile:
    DB $00,$00,$3C,$3C,$18,$18,$18,$18
    DB $18,$18,$18,$18,$18,$18,$3C,$3C
J_tile:
    DB $00,$00,$1E,$1E,$0C,$0C,$0C,$0C
    DB $0C,$0C,$0C,$0C,$4C,$4C,$38,$38
K_tile:
    DB $00,$00,$62,$62,$64,$64,$68,$68
    DB $78,$78,$64,$64,$64,$64,$62,$62
L_tile:
    DB $00,$00,$60,$60,$60,$60,$60,$60
    DB $60,$60,$60,$60,$60,$60,$7C,$7C
M_tile:
    DB $00,$00,$62,$62,$76,$76,$6A,$6A
    DB $6A,$6A,$6A,$6A,$62,$62,$62,$62
N_tile:
    DB $00,$00,$62,$62,$72,$72,$6A,$6A
    DB $6A,$6A,$66,$66,$66,$66,$62,$62
O_tile:
    DB $00,$00,$3C,$3C,$62,$62,$62,$62
    DB $62,$62,$62,$62,$62,$62,$3C,$3C
P_tile:
    DB $00,$00,$7C,$7C,$62,$62,$62,$62
    DB $7C,$7C,$60,$60,$60,$60,$60,$60
Q_tile:
    DB $00,$00,$3C,$3C,$62,$62,$62,$62
    DB $62,$62,$6A,$6A,$66,$66,$3E,$3E
R_tile:
    DB $00,$00,$7C,$7C,$62,$62,$62,$62
    DB $7C,$7C,$64,$64,$66,$66,$62,$62
S_tile:
    DB $00,$00,$3C,$3C,$62,$62,$60,$60
    DB $3C,$3C,$06,$06,$46,$46,$3C,$3C
T_tile:
    DB $00,$00,$7E,$7E,$18,$18,$18,$18
    DB $18,$18,$18,$18,$18,$18,$18,$18
U_tile:
    DB $00,$00,$62,$62,$62,$62,$62,$62
    DB $62,$62,$62,$62,$62,$62,$3C,$3C
V_tile:
    DB $00,$00,$62,$62,$62,$62,$62,$62
    DB $22,$22,$34,$34,$14,$14,$08,$08
W_tile:
    DB $00,$00,$62,$62,$62,$62,$6A,$6A
    DB $6A,$6A,$6A,$6A,$3E,$3E,$14,$14
X_tile:
    DB $00,$00,$62,$62,$22,$22,$14,$14
    DB $08,$08,$14,$14,$22,$22,$62,$62
Y_tile:
    DB $00,$00,$42,$42,$42,$42,$24,$24
    DB $18,$18,$18,$18,$18,$18,$30,$30
Z_tile:
    DB $00,$00,$7E,$7E,$06,$06,$0C,$0C
    DB $18,$18,$30,$30,$60,$60,$7E,$7E

a_tile:
    DB $00,$00,$00,$00,$18,$18,$24,$24
    DB $04,$04,$1C,$1C,$24,$24,$1C,$1C
b_tile:
    DB $00,$00,$00,$00,$00,$00,$20,$20
    DB $20,$20,$38,$38,$24,$24,$38,$38
c_tile:
    DB $00,$00,$00,$00,$00,$00,$18,$18
    DB $24,$24,$20,$20,$24,$24,$18,$18
d_tile:
    DB $00,$00,$00,$00,$00,$00,$04,$04
    DB $04,$04,$1C,$1C,$24,$24,$1C,$1C
e_tile:
    DB $00,$00,$00,$00,$00,$00,$18,$18
    DB $24,$24,$3C,$3C,$20,$20,$18,$18
f_tile:
    DB $00,$00,$00,$00,$18,$18,$24,$24
    DB $20,$20,$30,$30,$20,$20,$20,$20
g_tile:
    DB $00,$00,$00,$00,$1C,$1C,$24,$24
    DB $1C,$1C,$04,$04,$24,$24,$18,$18
h_tile:
    DB $00,$00,$00,$00,$00,$00,$20,$20
    DB $20,$20,$38,$38,$24,$24,$24,$24
i_tile:
    DB $00,$00,$00,$00,$00,$00,$10,$10
    DB $00,$00,$10,$10,$10,$10,$10,$10
j_tile:
    DB $00,$00,$00,$00,$08,$08,$00,$00
    DB $08,$08,$08,$08,$28,$28,$10,$10
k_tile:
    DB $00,$00,$00,$00,$00,$00,$28,$28
    DB $28,$28,$30,$30,$28,$28,$28,$28
l_tile:
    DB $00,$00,$00,$00,$00,$00,$10,$10
    DB $10,$10,$10,$10,$10,$10,$10,$10
m_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $68,$68,$54,$54,$54,$54,$54,$54
n_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $30,$30,$28,$28,$28,$28,$28,$28
o_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $18,$18,$24,$24,$24,$24,$18,$18
p_tile:
    DB $00,$00,$00,$00,$00,$00,$38,$38
    DB $24,$24,$38,$38,$20,$20,$20,$20
q_tile:
    DB $00,$00,$00,$00,$00,$00,$1C,$1C
    DB $24,$24,$1C,$1C,$04,$04,$04,$04
r_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $28,$28,$30,$30,$20,$20,$20,$20
s_tile:
    DB $00,$00,$00,$00,$00,$00,$1C,$1C
    DB $20,$20,$18,$18,$04,$04,$38,$38
t_tile:
    DB $00,$00,$00,$00,$00,$00,$10,$10
    DB $38,$38,$10,$10,$10,$10,$08,$08
u_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $24,$24,$24,$24,$24,$24,$1C,$1C
v_tile:
    DB $00,$00,$00,$00,$00,$00,$24,$24
    DB $24,$24,$24,$24,$14,$14,$08,$08
w_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $44,$44,$44,$44,$54,$54,$28,$28
x_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $28,$28,$10,$10,$10,$10,$28,$28
y_tile:
    DB $00,$00,$00,$00,$00,$00,$24,$24
    DB $24,$24,$18,$18,$08,$08,$10,$10
z_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $3C,$3C,$08,$08,$10,$10,$3C,$3C

; SYMBOLS
EXCLAMATION_tile:
    DB $00,$00,$18,$18,$18,$18,$18,$18
    DB $18,$18,$00,$00,$18,$18,$18,$18
QUOTE_tile:
    DB $00,$00,$28,$28,$28,$28,$28,$28
    DB $00,$00,$00,$00,$00,$00,$00,$00
HASHTAG_tile:
    DB $00,$00,$00,$00,$24,$24,$7E,$7E
    DB $24,$24,$24,$24,$7E,$7E,$24,$24
DOLLAR_tile:
    DB $00,$00,$38,$38,$54,$54,$50,$50
    DB $38,$38,$14,$14,$54,$54,$38,$38
PERCENT_tile:
    DB $00,$00,$20,$20,$52,$52,$24,$24
    DB $08,$08,$12,$12,$25,$25,$42,$42
AMPERSTAND_tile:
    DB $00,$00,$00,$00,$30,$30,$48,$48
    DB $30,$30,$4C,$4C,$4C,$4C,$3A,$3A
APOSTROPHE_tile:
    DB $00,$00,$20,$20,$20,$20,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
OPARENTH_tile:
    DB $00,$00,$08,$08,$10,$10,$10,$10
    DB $10,$10,$10,$10,$10,$10,$08,$08
CPARENTH_tile:
    DB $00,$00,$10,$10,$08,$08,$08,$08
    DB $08,$08,$08,$08,$08,$08,$10,$10
STAR_tile:
    DB $00,$00,$00,$00,$28,$28,$10,$10
    DB $28,$28,$00,$00,$00,$00,$00,$00
PLUS_tile:
    DB $00,$00,$00,$00,$00,$00,$10,$10
    DB $10,$10,$7C,$7C,$10,$10,$10,$10
COMMA_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$20,$20,$20,$20,$40,$40
MINUS_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$7C,$7C,$00,$00,$00,$00
DOT_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$40,$40
SLASH_tile:
    DB $00,$00,$04,$04,$08,$08,$08,$08
    DB $10,$10,$20,$20,$20,$20,$40,$40
COLON_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $20,$20,$00,$00,$20,$20,$00,$00
SCOLON_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $20,$20,$00,$00,$20,$20,$40,$40
LESSER_tile:
    DB $00,$00,$00,$00,$00,$00,$08,$08
    DB $10,$10,$60,$60,$10,$10,$08,$08
EQUAL_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $3C,$3C,$00,$00,$3C,$3C,$00,$00
GREATER_tile:
    DB $00,$00,$00,$00,$00,$00,$10,$10
    DB $08,$08,$06,$06,$08,$08,$10,$10
QUESTION_tile:
    DB $00,$00,$38,$38,$44,$44,$04,$04
    DB $08,$08,$10,$10,$00,$00,$10,$10
AROBASE_tile:
    DB $00,$00,$00,$00,$3C,$3C,$42,$42
    DB $9A,$9A,$AA,$AA,$9A,$9A,$44,$44
OBRACKET_tile:
    DB $00,$00,$00,$00,$18,$18,$10,$10
    DB $10,$10,$10,$10,$10,$10,$18,$18
BACKSLASH_tile:
    DB $00,$00,$20,$20,$10,$10,$10,$10
    DB $08,$08,$04,$04,$04,$04,$02,$02
CBRACKET_tile:
    DB $00,$00,$00,$00,$18,$18,$08,$08
    DB $08,$08,$08,$08,$08,$08,$18,$18
CIRCUMFLEX_tile:
    DB $00,$00,$10,$10,$28,$28,$44,$44
    DB $00,$00,$00,$00,$00,$00,$00,$00
UNDERSCORE_tile:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$7E,$7E
BACK_APOSTROPHE_tile:
    DB $00,$00,$08,$08,$04,$04,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
OCBRACKET_tile:
    DB $00,$00,$08,$08,$10,$10,$10,$10
    DB $20,$20,$10,$10,$10,$10,$08,$08
VBAR_tile:
    DB $00,$00,$10,$10,$10,$10,$10,$10
    DB $10,$10,$10,$10,$10,$10,$10,$10
CCBRACKET_tile:
    DB $00,$00,$10,$10,$08,$08,$08,$08
    DB $04,$04,$08,$08,$08,$08,$10,$10
TILDE_tile:
    DB $00,$00,$00,$00,$00,$00,$30,$30
    DB $49,$49,$06,$06,$00,$00,$00,$00

; EXTENDED SYMBOLS
CCEDILLA_tile:
    DB $00,$00,$3C,$3C,$62,$62,$60,$60
    DB $60,$60,$62,$62,$3C,$3C,$08,$08
uTREM_tile:
    DB $00,$00,$00,$00,$24,$24,$00,$00
    DB $24,$24,$24,$24,$24,$24,$1C,$1C
eAIG_tile:
    DB $00,$00,$08,$08,$10,$10,$18,$18
    DB $24,$24,$3C,$3C,$20,$20,$18,$18
aCARET_tile:
    DB $00,$00,$18,$18,$24,$24,$18,$18
    DB $04,$04,$1C,$1C,$24,$24,$1C,$1C
aTREM_tile:
    DB $00,$00,$14,$14,$00,$00,$18,$18
    DB $04,$04,$1C,$1C,$24,$24,$1C,$1C
aGRAV_tile:
    DB $00,$00,$10,$10,$08,$08,$18,$18
    DB $04,$04,$1C,$1C,$24,$24,$1C,$1C
aRING_tile:
    DB $08,$08,$14,$14,$08,$08,$18,$18
    DB $04,$04,$1C,$1C,$24,$24,$1C,$1C
cCEDILLA_tile:
    DB $00,$00,$18,$18,$24,$24,$20,$20
    DB $24,$24,$18,$18,$08,$08,$10,$10
eCARET_tile:
    DB $00,$00,$18,$18,$24,$24,$18,$18
    DB $24,$24,$3C,$3C,$20,$20,$18,$18
eTREM_tile:
    DB $00,$00,$14,$14,$00,$00,$18,$18
    DB $24,$24,$3C,$3C,$20,$20,$18,$18
eGRAV_tile:
    DB $00,$00,$10,$10,$08,$08,$18,$18
    DB $24,$24,$3C,$3C,$20,$20,$18,$18
iTREM_tile:
    DB $00,$00,$00,$00,$00,$00,$28,$28
    DB $00,$00,$10,$10,$10,$10,$10,$10
iCARET_tile:
    DB $00,$00,$00,$00,$10,$10,$28,$28
    DB $00,$00,$10,$10,$10,$10,$10,$10
iGRAV_tile:
    DB $00,$00,$00,$00,$20,$20,$10,$10
    DB $00,$00,$10,$10,$10,$10,$10,$10
ATREM_tile:
    DB $14,$14,$00,$00,$3C,$3C,$62,$62
    DB $62,$62,$7E,$7E,$62,$62,$62,$62
ARING_tile:
    DB $08,$08,$14,$14,$08,$08,$3C,$3C
    DB $62,$62,$62,$62,$7E,$7E,$62,$62
EAIG_tile:
    DB $08,$08,$10,$10,$7C,$7C,$60,$60
    DB $78,$78,$60,$60,$60,$60,$7C,$7C
aeSYM_tile:
    DB $00,$00,$00,$00,$00,$00,$64,$64
    DB $1A,$1A,$7E,$7E,$98,$98,$76,$76
AESYM_tile:
    DB $00,$00,$7F,$7F,$CC,$CC,$CC,$CC
    DB $FE,$FE,$CC,$CC,$CC,$CC,$CF,$CF
oCARET_tile:
    DB $00,$00,$18,$18,$24,$24,$00,$00
    DB $18,$18,$24,$24,$24,$24,$18,$18
oTREM_tile:
    DB $00,$00,$00,$00,$24,$24,$00,$00
    DB $18,$18,$24,$24,$24,$24,$18,$18
oGRAV_tile:
    DB $00,$00,$10,$10,$08,$08,$00,$00
    DB $18,$18,$24,$24,$24,$24,$18,$18
uCARET_tile:
    DB $00,$00,$18,$18,$24,$24,$00,$00
    DB $24,$24,$24,$24,$24,$24,$1C,$1C
uGRAV_tile:
    DB $00,$00,$10,$10,$08,$08,$00,$00
    DB $24,$24,$24,$24,$24,$24,$1C,$1C
yTREM_tile:
    DB $00,$00,$24,$24,$00,$00,$24,$24
    DB $24,$24,$18,$18,$08,$08,$10,$10
OTREM_tile:
    DB $14,$14,$00,$00,$3C,$3C,$62,$62
    DB $62,$62,$62,$62,$62,$62,$3C,$3C
UTREM_tile:
    DB $24,$24,$00,$00,$62,$62,$62,$62
    DB $62,$62,$62,$62,$62,$62,$3C,$3C
aAIG_tile:
    DB $08,$08,$10,$10,$00,$00,$18,$18
    DB $04,$04,$1C,$1C,$24,$24,$1C,$1C
iAIG_tile:
    DB $00,$00,$00,$00,$08,$08,$10,$10
    DB $00,$00,$10,$10,$10,$10,$10,$10
oAIG_tile:
    DB $00,$00,$08,$08,$10,$10,$00,$00
    DB $18,$18,$24,$24,$24,$24,$18,$18
uAIG_tile:
    DB $00,$00,$08,$08,$10,$10,$00,$00
    DB $24,$24,$24,$24,$24,$24,$1C,$1C
nTILDE_tile:
    DB $00,$00,$28,$28,$50,$50,$00,$00
    DB $30,$30,$28,$28,$28,$28,$28,$28
NTILDE_tile:
    DB $14,$14,$28,$28,$00,$00,$62,$62
    DB $72,$72,$6A,$6A,$66,$66,$62,$62
IQUESTION_tile:
    DB $00,$00,$08,$08,$00,$00,$08,$08
    DB $18,$18,$20,$20,$22,$22,$1C,$1C
