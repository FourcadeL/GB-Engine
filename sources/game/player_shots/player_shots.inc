; ############################
; Player shots shared pointers
;
;   All sub shots implementations
;   should have access to these tables
;   for creation of new shots
; ############################

    IF!DEF(PLAYER_SHOTS_INC)
DEF PLAYER_SHOTS_INC EQU 1


DEF ES_MAX_SHOTS EQU 16

EXPORT ps_status
EXPORT ps_Xposs
EXPORT ps_Yposs

    ENDC ; PLAYER_SHOTS_INC

