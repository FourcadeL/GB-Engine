;#####################################
;definition init (se réferrer à engine.inc)
;init sert à mettre en place le header de la ROM, les vecteurs d'interrupt et les fonctions de bas niveau d'exécution
;#####################################


	INCLUDE "hardware.inc"
	INCLUDE "engine.inc"


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                              RESTART VECTORS                            | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+



    SECTION "RST_00",ROM0[$0000]
    ret ; Reserved for interrupt handler. If an interrupt vector is $0000 it
        ; jumps here and returns.

    SECTION "RST_08",ROM0[$0008]
    jp      hl ; Reserved for interrupt handler. (Or any other function that
               ; uses CALL_HL permet de faire un call plus rapidement)

    SECTION "RST_10",ROM0[$0010]
    ret

    SECTION "RST_18",ROM0[$0018]
    ret

    SECTION "RST_20",ROM0[$0020]
    ret

    SECTION "RST_28",ROM0[$0028]
    ret

    SECTION "RST_30",ROM0[$0030]
    ret

    SECTION "RST_38",ROM0[$0038]
    jp      Reset


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                             INTERRUPT VECTORS                           | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

    SECTION "VBL Interrupt Vector",ROM0[$0040]
    push    hl
    ld 		hl, _vbl_flag ;flag d'exécution d'un vblank
    ld 		[hl], 1
    jr      int_VBlank

    SECTION "LCD Interrupt Vector",ROM0[$0048]
    push    hl
    ld      hl,LCD_handler
    jr      int_Common

    SECTION "TIM Interrupt Vector",ROM0[$0050]
    push    hl
    ld      hl,TIM_handler
    jr      int_Common

    SECTION "SIO Interrupt Vector",ROM0[$0058]
    push    hl
    ld      hl,SIO_handler
    jr      int_Common

    SECTION "JOY Interrupt Vector",ROM0[$0060]
    push    hl
    ld      hl,JOY_handler
    jr      int_Common


;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                             INTERRUPT HANDLER                           | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

;cette partie est placée ici car il n'y a pas la place d'écrire le code dans 8 octets
int_VBlank:
	ld 		hl,VBL_handler

int_Common:
    push    af

    ;récupère l'adresse de la fonction à exécuter
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a

    ;sauvegarde des registres restants
    push    bc
    push    de
    ;appel de hl
    CALL_HL
    ;récupération des registres
    pop     de
    pop     bc

    pop     af
    pop     hl

    ;retour à l'exécution et réactivation des interrupts
    reti

;--------------------------------------------------------------------------
;- wait_vbl()                                                             -
;--------------------------------------------------------------------------

wait_vbl::

    ld      hl,_vbl_flag
    ld      [hl],0

.not_yet:
    halt
    bit     0,[hl]
    jr      z,.not_yet

    ret






;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                              CARTRIDGE HEADER                           | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

    SECTION "Cartridge Header",ROM0[$0100]

    nop
    jp      StartPoint

    NINTENDO_LOGO

    ;        0123456789ABC
    DB      "GAME_T1      "
    DW      $0000
    DB      $00 ;GBC flag (DMG compatible)
    DB      $00,$00,$00 ;SuperGameboy
    DB      CART_ROM_MBC5_RAM_BAT ;CARTTYPE (MBC5+RAM+BATTERY)
    DB      $00          ;ROMSIZE
    DB      CART_RAM_64K ;RAMSIZE (8KB)

    DB      $01 ;Destination (0 = Japan, 1 = Non Japan)
    DB      $00 ;Manufacturer
    DB      $00 ;Version
    DB      $00 ;Complement check
    DW      $0000 ;Checksum






;+-----------------------------------------------------------------------------+
;| +-------------------------------------------------------------------------+ |
;| |                                START ROUTINE                            | |
;| +-------------------------------------------------------------------------+ |
;+-----------------------------------------------------------------------------+

    SECTION "Program Start",ROM0[$0150]

StartPoint:


    di ; no interupts during startup

    call screen_off ; screen of before VRAM or memory manipulation

    ; RAM cleanup
    ld d, $00
    ld hl, _RAM
    ld bc, $2000
    call memset
    
    ; random seed init (seed is A = $55 ; B = $F3 ; C = $1A)
    ld hl, RandomA
    ld [hl], $55
    ld hl, RandomB
    ld [hl], $F3
    ld hl, RandomC
    ld [hl], $1A

    ; VRAM cleanup
    ld d, $00
    ld hl, _VRAM
    ld bc, $2000
    call memset

    ; copy DMA routine into HRAM
    call init_DMA

	; main call
	call Main

	jp Reset ; just in case but shouldn't reach



;--------------------------------------------------------------------------
;- Reset()                                                                -
;--------------------------------------------------------------------------

Reset::
    jp      $0100



;--------------------------------------------------------------------------
;- irq_set_VBL()    bc = function pointer                                 -
;- irq_set_LCD()    bc = function pointer                                 -
;- irq_set_TIM()    bc = function pointer                                 -
;- irq_set_SIO()    bc = function pointer                                 -
;- irq_set_JOY()    bc = function pointer                                 -
;--------------------------------------------------------------------------

irq_set_VBL::

    ld      hl,VBL_handler
    jr      irq_set_handler

irq_set_LCD::

    ld      hl,LCD_handler
    jr      irq_set_handler

irq_set_TIM::

    ld      hl,TIM_handler
    jr      irq_set_handler

irq_set_SIO::

    ld      hl,SIO_handler
    jr      irq_set_handler

irq_set_JOY::

    ld      hl,JOY_handler
;    jr      irq_set_handler

irq_set_handler:  ; hl = dest handler    bc = function pointer

    ld      [hl],c
    inc     hl
    ld      [hl],b

    ret





;--------------------------------------------------------------------------
;-                               Variables                                -
;--------------------------------------------------------------------------


    SECTION "StartupVars",WRAM0

_vbl_flag:   DS 1

VBL_handler:    DS 2
LCD_handler:    DS 2
TIM_handler:    DS 2
SIO_handler:    DS 2
JOY_handler:    DS 2


;utilisation potentielle d'un stack à part en WorkRam

;    SECTION "Stack",WRAM0[$CE00]

;Stack:    DS $200
;StackTop: ; At address $D000



