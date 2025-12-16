;+---------------------------------------------------------------------+
;| +-----------------------------------------------------------------+ |
;| |                                                                 | |
;| |                       LEVELS ENCODING                           | |
;| |                                                                 | |
;| +-----------------------------------------------------------------+ |
;+---------------------------------------------------------------------+

; Levels are built as 16*16 blocks
; Each block is built from 4 8*8 tiles


;       ----------------
;       I Block encoding
;       ----------------

;       Block are indexed from 0 to 2^6-1
;       Block structures are stored in ROM as a 8 aligned Table containing tiles indexes for the desired block
;
;       Example :
;       +---+---+
;       | 5 | 9 |
;       +---+---+                               +- block addr
;       | 3 | 4 |                               v
;       +---+---+           Will be stored as : | 5 | 9 | 3 | 4
;
;               This allows loading of lower and upper parts of the block independently


;       ------------------
;       II Rows encoding
;       ------------------
;
;       Levels rows are encoded as REUSABLE block rows
;       A block row is 16 blocks wide
;       Block row width is defined in the BG_ROW_WIDTH compilation constant

;       +---+---+---+---+---+---+---+---+---+---+---+
;  ri   | 3 | 6 | 3 | 1 | 7 | . | . | . | . | . | . |
;       +---+---+---+---+---+---+---+---+---+---+---+
;
;       Each row can be refered to as a 0 based indexing

;       ------------------
;       III Actor encoding
;       ------------------
;
;       Not Yet defined
;       Structures pointers are located as the last two bytes of each row

;       --------------------
;       IV Levels encoding
;       --------------------
;
;       Levels are encoded as a stream of row indexes

        DEF BG_ROW_MAX_WIDTH EQU 14
        DEF BG_ROW_WIDTH EQU 10

        STATIC_ASSERT BG_ROW_WIDTH <= BG_ROW_MAX_WIDTH, "BG_ROW_WIDTH too wide"

        DEF BG_ROW_ACTOR_POINTER_OFFSET EQU 14
