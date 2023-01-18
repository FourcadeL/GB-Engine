; Table de correspondance des infos et comportements des briques

INCLUDE "brick.inc"

SECTION "brick_table_info", ROMX

brick_table_info::
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