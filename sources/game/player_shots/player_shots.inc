; ############################
; Player shots shared pointers
;
;   All sub shots implementations
;   should have access to these tables
;   for creation of new shots
; ############################

    IF!DEF(PLAYER_SHOTS_INC)
DEF PLAYER_SHOTS_INC EQU 1


DEF PS_MAX_SHOTS EQU 16

EXPORT ps_status
EXPORT ps_Xposs
EXPORT ps_Yposs


STATIC_ASSERT PS_MAX_SHOTS == 16, "Player shot tables (status, Ypos and Xpos) must be aligned (see player_shots.asm)"

    ENDC ; PLAYER_SHOTS_INC

