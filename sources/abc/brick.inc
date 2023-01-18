;#################################
;definition des différents types de briques
;#################################

;L'ID 0 CORRESPOND À : PAS DE BRIQUE

; chacune possède : un ID (7 bits)
; un ID de tile à utiliser (base)
;   chaque brique nécessitant deux tiles on ne donne que le premier
;   le second se déduit par baseID + 1
; l'ID remplaçant sa destruction

    IF !DEF(BRICK_INC)
BRICK_INC = 1

; structure (l'ID de la brique est l'offset dans le tableau + 1)
;-----
RSRESET
brck_base_tile      RB 1
brck_next_id        RB 1
SIZEOF_brck_struct  RB 0
;-----
SIZEOF_BRCK_STRUCT EQU SIZEOF_brck_struct

    ENDC