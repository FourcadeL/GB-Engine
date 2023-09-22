;####################################################
; Definition des caractères ASCII étendus à utiliser
;####################################################


    IF !DEF(CHARMAP_INC)
CHARMAP_INC = 1

NEWCHARMAP EASCII

CHARMAP "Ç", $80
CHARMAP ,$81
CHARMAP ,$81
CHARMAP ,$81
CHARMAP ,$81

ENDC ; CHARMAP_INC