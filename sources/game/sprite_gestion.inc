; This files serves as memory map for how the game uses the 20 available sprite slots and the 20 available display lists


;-------------
; Sprite slots
;-------------

; 0 :   slot 0 is always reserved for the player
; 1 :   slot 1 is reserved for simple shots (displayed as 1 non-static display list)
; 2 :   actor slot 1
; 3 :   actor slot 2
; 4 :   actor slot 3
; 5 :   actor slot 4
; 6 :   actor slot 5
; 7 :   actor slot 6
; 8 :   actor slot 7
; 9 :   actor slot 8
; 10 :  actor slot 9
; 11 :  actor slot 10
; 12 :  actor slot 11
; 13 :  actor slot 12
; 14 :  actor slot 13
; 15 :  actor slot 14
; 16 :  actor slot 15
; 17 :  actor slot 16
; 18 :
; 19 : slot 15 is reserved for player shots (displayed as 1 non-static display list)



;--------------
; Display list
;--------------

; 0 :   Player display list addr (modified by player routines)
; 1 :   Simple shots display list (points to WRAM and dynamically constructed)
; 2 :   Rolling ennemy display list, shared by all ennemies (modified by ennemies routine) 
; 3 :   Default actor display list
; 4 :   Default actor display list
; 5 :   Default actor display list
; 6 :   Default actor display list
; 7 :   Default actor display list
; 8 :   Default actor display list
; 9 :   Default actor display list
; 10 :  Default actor display list
; 11 :  Default actor display list
; 12 :  Default actor display list
; 13 :  Default actor display list
; 14 :  Default actor display list
; 15 :  Default actor display list
; 16 :  Default actor display list
; 17 :  Default actor display list
; 18 :  Default actor display list
; 19 :  Player shots display list (points to WRAM and dynamically constructed)
; 20 :  Explosion frame 1
; 21 :  Explosion frame 2
; 22 :  Explosion frame 3
; 23 :  Explosion frame 4
; 24 :  Explosion frame 5
; 25 :  Explosion frame 6
; 26 :
; 27 :
; 28 :
; 29 :
; 30 :
; 31 :



