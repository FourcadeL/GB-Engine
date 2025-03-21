;####################################################
; Extended ASCII chars to use
;####################################################


; Control instructions
; \n : new lines
; \\0 : end of block text
; \\b[$XXXX] : block of text -> fetch block of text at addr $XXXX then return to current block
; \\w : put text displayer in wait state
; \\f : put text displayer into flush state
; \\t[$XX] : set timer

    IF !DEF(CHARMAP_INC)
DEF CHARMAP_INC EQU 1

NEWCHARMAP EASCII

;STANDARD ASCII
CHARMAP "\\0", $00
CHARMAP "\\b", $02
CHARMAP "\\f", $04
CHARMAP "\\w", $06
CHARMAP "\\t" , $08
CHARMAP "\n", $0A
CHARMAP " ", $20
CHARMAP "!", $21
CHARMAP "\"", $22
CHARMAP "#", $23
CHARMAP "$", $24
CHARMAP "%", $25
CHARMAP "&", $26
CHARMAP "'", $27
CHARMAP "(", $28
CHARMAP ")", $29
CHARMAP "*", $2A
CHARMAP "+", $2B
CHARMAP ",", $2C
CHARMAP "-", $2D
CHARMAP ".", $2E
CHARMAP "/", $2F
CHARMAP "0", $30
CHARMAP "1", $31
CHARMAP "2", $32
CHARMAP "3", $33
CHARMAP "4", $34
CHARMAP "5", $35
CHARMAP "6", $36
CHARMAP "7", $37
CHARMAP "8", $38
CHARMAP "9", $39
CHARMAP ":", $3A
CHARMAP ";", $3B
CHARMAP "<", $3C
CHARMAP "=", $3D
CHARMAP ">", $3E
CHARMAP "?", $3F
CHARMAP "@", $40
CHARMAP "A", $41
CHARMAP "B", $42
CHARMAP "C", $43
CHARMAP "D", $44
CHARMAP "E", $45
CHARMAP "F", $46
CHARMAP "G", $47
CHARMAP "H", $48
CHARMAP "I", $49
CHARMAP "J", $4A
CHARMAP "K", $4B
CHARMAP "L", $4C
CHARMAP "M", $4D
CHARMAP "N", $4E
CHARMAP "O", $4F
CHARMAP "P", $50
CHARMAP "Q", $51
CHARMAP "R", $52
CHARMAP "S", $53
CHARMAP "T", $54
CHARMAP "U", $55
CHARMAP "V", $56
CHARMAP "W", $57
CHARMAP "X", $58
CHARMAP "Y", $59
CHARMAP "Z", $5A
CHARMAP "[", $5B
CHARMAP "\\", $5C
CHARMAP "]", $5D
CHARMAP "^", $5E
CHARMAP "_", $5F
CHARMAP "`", $60
CHARMAP "a", $61
CHARMAP "b", $62
CHARMAP "c", $63
CHARMAP "d", $64
CHARMAP "e", $65
CHARMAP "f", $66
CHARMAP "g", $67
CHARMAP "h", $68
CHARMAP "i", $69
CHARMAP "j", $6A
CHARMAP "k", $6B
CHARMAP "l", $6C
CHARMAP "m", $6D
CHARMAP "n", $6E
CHARMAP "o", $6F
CHARMAP "p", $70
CHARMAP "q", $71
CHARMAP "r", $72
CHARMAP "s", $73
CHARMAP "t", $74
CHARMAP "u", $75
CHARMAP "v", $76
CHARMAP "w", $77
CHARMAP "x", $78
CHARMAP "y", $79
CHARMAP "z", $7A
CHARMAP "\{", $7B
CHARMAP "|", $7C
CHARMAP "\}", $7D
CHARMAP "~", $7E

;EXTENDED ASCII
CHARMAP "Ç", $80
CHARMAP "ü", $81
CHARMAP "é", $82
CHARMAP "â", $83
CHARMAP "ä", $84
CHARMAP "à", $85
CHARMAP "å", $86
CHARMAP "ç", $87
CHARMAP "ê", $88
CHARMAP "ë", $89
CHARMAP "è", $8A
CHARMAP "ï", $8B
CHARMAP "î", $8C
CHARMAP "ì", $8D
CHARMAP "Ä", $8E
CHARMAP "Å", $8F
CHARMAP "É", $90
CHARMAP "æ", $91
CHARMAP "Æ", $92
CHARMAP "ô", $93
CHARMAP "ö", $94
CHARMAP "ò", $95
CHARMAP "û", $96
CHARMAP "ù", $97
CHARMAP "ÿ", $98
CHARMAP "Ö", $99
CHARMAP "Ü", $9A
CHARMAP "á", $A0
CHARMAP "í", $A1
CHARMAP "ó", $A2
CHARMAP "ú", $A3
CHARMAP "ñ", $A4
CHARMAP "Ñ", $A5
CHARMAP "¿", $A8


ENDC ; CHARMAP_INC