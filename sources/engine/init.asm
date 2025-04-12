;#####################################
; Init
; 	initial function and memory placement of interrupt code
; 	Initialize ROM header, interrupt vectors and low level routines
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
    ld 		hl, _vbl_flag ; vblank execution flag
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

int_VBlank:
	ld 		hl,VBL_handler

int_Common:
    push    af

    ; retrieve interrupt functio addr
    ld      a,[hl+]
    ld      h,[hl]
    ld      l,a

    ; save registers
    push    bc
    push    de
    ;appel de hl
    CALL_HL

    ; restore registers
    pop     de
    pop     bc

    pop     af
    pop     hl

    ; execution return
    reti

;--------------------------------------------------------------------------
; wait_vbl()
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
    DB      CART_SRAM_8KB ;RAMSIZE (8KB)

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
; Reset()
;--------------------------------------------------------------------------

Reset::
    jp      $0100



;--------------------------------------------------------------------------
; irq_set_VBL(bc = function pointer)
; irq_set_LCD(bc = function pointer)
; irq_set_TIM(bc = function pointer)
; irq_set_SIO(bc = function pointer)
; irq_set_JOY(bc = function pointer)
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
;                                Variables
;--------------------------------------------------------------------------


    SECTION "StartupVars",WRAM0

_vbl_flag:   DS 1

VBL_handler:    DS 2
LCD_handler:    DS 2
TIM_handler:    DS 2
SIO_handler:    DS 2
JOY_handler:    DS 2


; new stack definition in WorkRAM

;    SECTION "Stack",WRAM0[$CE00]

;Stack:    DS $200
;StackTop: ; At address $D000



