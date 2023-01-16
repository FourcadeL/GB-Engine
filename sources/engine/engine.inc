;############################################
;Définition des différentes macros, des adresses mémoires et des fonctions du moteur de jeu
;############################################




	IF !DEF(ENGINE_INC)
ENGINE_INC = 1

;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                            MACROs                  | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+


;permet d'additionner une valeur 16 bit à hl
MACRO ADD_U16_hl_val;hl <- hl + (value first arg)
    ld      a, l
    add     a, LOW(\1)
    ld      l, a
    ld      a, h
    adc     a, HIGH(\1)
    ld      h, a
ENDM


;permet de récupérer a <- sin(a)
MACRO GET_SINE_A
    ld      h, HIGH(Sine)
    ld      l, a
    ld      a, [hl]
ENDM


;macro permettant d'appeler hl un peu plus rapidement
;(nécessite que le vecteur de restart à $0008 soit correctement mis en place)
MACRO CALL_HL
    rst     $08
ENDM












;**********************************
;       INIT.ASM
;**********************************

;----------------------------------------------
; fonctions INIT.ASM
;----------------------------------------------

;+---------------------------+
; fonctions permettant d'attacher des fonctions aux vecteur d'interrupts


;- irq_set_VBL( bc = function pointer ) @VBL_handler contient le pointeur vers la fonction à exécuter
;- irq_set_LCD( bc = function pointer ) @LCD_handler contient le pointeur vers la fonction à exécuter
;- irq_set_TIM( bc = function pointer ) @TIM_handler contient le pointeur vers la fonction à exécuter
;- irq_set_SIO( bc = function pointer ) @SIO_handler contient le pointeur vers la fonction à exécuter
;- irq_set_JOY( bc = function pointer ) @JOY_handler contient le pointeur vers la fonction à exécuter

;+---------------------------+

	EXPORT  irq_set_VBL
    EXPORT  irq_set_LCD
    EXPORT  irq_set_TIM
    EXPORT  irq_set_SIO
    EXPORT  irq_set_JOY



;+---------------------------+
;- wait_vbl()
;----------------------------

	EXPORT wait_vbl

;-----------------------------------------------
;- wait_ly(b = ly à attendre)
;- wait_frames(e = nb de frames à attendre)
;-----------------------------------------------


    EXPORT wait_ly
    EXPORT wait_frames



;--------------------------------------------------------------------------
;- Reset()                                                                -
;--------------------------------------------------------------------------

    EXPORT  Reset

;----------------------------------------------
; variables INIT.ASM
;----------------------------------------------


;interupts
; _vbl_flag (1 byte)
EXPORT  VBL_handler ;(2 byte)
EXPORT  LCD_handler ;(2 byte)
EXPORT  TIM_handler ;(2 byte)
EXPORT  SIO_handler ;(2 byte)
EXPORT  JOY_handler ;(2 byte)
























;**********************************
;       UTILS.ASM
;**********************************

;----------------------------------------------
; fonctions UTILS.ASM
;----------------------------------------------
;+----------------------------+
; fonctions de gestion de l'aléatoire
;- generateRandom() a = returned value @tous les registres sont écrasés
;+----------------------------+


	EXPORT generateRandom




;+------------------------------------------+
; fonctions de gestion de la mémoire


;- memset(d = value ; hl = start address ; bc = size)
;- memcopy(bc = size ; hl = source address ; de = destination address)
;- memcopy_fast(b = size ; hl = source address ; de = destination address)
;+------------------------------------------+


    EXPORT memset
    EXPORT memcopy
    EXPORT memcopy_fast



;----------------------------------------------
; variables UTILS.ASM
;----------------------------------------------

;random
    EXPORT RandomX ;(1 byte)
    EXPORT RandomA ;(1 byte)
    EXPORT RandomB ;(1 byte)
    EXPORT RandomC ;(1 byte)




















;**********************************
;       IO.ASM
;**********************************

;----------------------------------------------
; fonctions IO.ASM
;----------------------------------------------


;+---------------------------------------+
; fonction de récupération des inputs

;- getInput() @PAD_hold et PAD_pressed contiennent les inputs lus
;+---------------------------------------+

EXPORT getInput


;----------------------------------------------
; variables IO.ASM
;----------------------------------------------

;inputs
EXPORT PAD_hold ;contient les inputs maintenus
EXPORT PAD_pressed ; contient les inputs préssés à cette frame


;----------------------------------------------
; définitions IO.ASM
;----------------------------------------------

PAD_START   EQU $80
PAD_SELECT  EQU $40
PAD_B       EQU $20
PAD_A       EQU $10
PAD_DOWN    EQU $08
PAD_UP      EQU $04
PAD_LEFT    EQU $02
PAD_RIGHT   EQU $01























;**********************************
;       VIDEO.ASM
;**********************************


;----------------------------------------------
; fonctions VIDEO.ASM
;----------------------------------------------


;+--------------------------------+
;init_DMA() @copie la routine de transfert DMA en HRAM
;call_DMA() @transfert l'OAM_mirror dans l'OAM
;+--------------------------------+

    EXPORT init_DMA
    EXPORT call_DMA





;--------------------------------------------------------------------------
;- screen_off()          @arrête l'écran mais sauvegarde ses attributs pour les rétablir plus tard                                                 
;--------------------------------------------------------------------------

    EXPORT screen_off


;--------------------------------------------------------------------------
;- screen_restart()          @redémarre l'écran avec les attributs qui étaient présents avant sa désactivation                         
;--------------------------------------------------------------------------

    EXPORT screen_restart




;--------------------------------------------------------------------------
;- vram_copy()    bc = size    hl = source address    de = dest address   -
;- effectue une copie vers la vram (attent de pouvoir y accéder)
;--------------------------------------------------------------------------

    EXPORT vram_copy


;--------------------------------------------------------------------------
;- tilemap_copy()    b = width, c = height   hl = source address-
;- effectue une copie vers la tilemap  (attent de pouvoir y accéder)
;- copie b*c bytes (tile number) en mettant en place les bonnes dimensions
;--------------------------------------------------------------------------

    EXPORT tilemap_bg_block_copy






;----------------------------------------------
; variables VIDEO.ASM
;----------------------------------------------


    EXPORT  OAM_mirror ;pointeur vers l'OAM_mirror (doit être aligé à $100) ($A0 bytes)
    EXPORT  OAM_mirror_end




















;**********************************
;       AUDIO.ASM
;**********************************

;----------------------------------------------
; fonctions AUDIO.ASM
;----------------------------------------------

;+--------------------------------------------------------+
;   Audio_off() stop toute l'activitée audio
;   Audio_init() initialise le moteur audio
;   Audio_update() doit être appelé à chaque frame (update de l'état audio)
;+--------------------------------------------------------+

    EXPORT Audio_off
    EXPORT Audio_init
    EXPORT Audio_update

;----------------------------------------------
; variables AUDIO.ASM
;----------------------------------------------








ENDC ; ENGINE_INC


















