; This files serves as memory map for how the game uses the 20 available sprite slots and the 20 available display lists


;-------------
; Sprite slots
;-------------

; 0 : slot 0 is always reserved for the player
; 1 : slot 1 is reserved for simple shots (displayed as 1 non-static display list)
; 2 : ennemy slot 1
; 3 : ennemy slot 2
; 4 : ennemy slot 3
; 5 : ennemy slot 4
; 6 : ennemy slot 5
; 7 : ennemy slot 6
; 8 : ennemy slot 7
; 9 : ennemy slot 8
; 10 :
; 11 :
; 12 :
; 13 :
; 14 :
; 15 :
; 16 : explosion slot 1
; 17 : explosion slot 2
; 18 : explosion slot 3
; 19 : explosion slot 4



;--------------
; Display list
;--------------

; 0 : Player display list addr (modified by player routines)
; 1 : Simple sots display list (points to WRAM and dynamically constructed)
; 2 : Rolling ennemy display list, shared by all ennemies (modified by ennemies routine) 
; 3 :
; 4 :
; 5 :
; 6 :
; 7 :
; 8 :
; 9 :
; 10 :
; 11 :
; 12 :
; 13 :
; 14 : Explosion frame 1
; 15 : Explosion frame 2
; 16 : Explosion frame 3
; 17 : Explosion frame 4
; 18 : Explosion frame 5
; 19 : Explosion frame 6



