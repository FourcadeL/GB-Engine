;#################################
;definition des différents types de briques
;#################################

;L'ID 0 CORRESPOND À : PAS DE BRIQUE

; chacune possède : un ID (7 bits)
; un ID de tile à utiliser (base)
;   chaque brique nécessitant deux tiles on ne donne que le premier
;   le second se déduit par baseID + 1
; l'ID remplaçant sa destruction

; structure (l'ID de la brique est l'offset dans le tableau + 1)
;-----
RSRESET
brck_base_tile      RB 1
brck_next_id        RB 1
SIZEOF_brck_struct  RB 0
;-----

SECTION "brick_table_info", ROMX

birck_table_info::
    DS 2 ; offset à l'entrée du tableau pour que les
        ;ID des briques correspondent dirrectement à leur ID
    ; brique de base, détruite en un coup
    DB $86
    DB $00
    ; brique "3 crans" état 3
    DB $90
    DB $00
    ; brique "3 crans" état 2
    DB $8E
    DB $02
    ; brique "3 crans" état 1
    DB $8C
    DB $03