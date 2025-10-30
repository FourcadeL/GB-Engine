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
;       +---+---+           Will be stored as : | 3 | 4 | 5 | 9
;
;               This allows loading of lower and upper parts of the block independently


;       ------------------
;       II Rows encoding
;       ------------------
;
;       Levels rows are encoded as REUSABLE block rows
;       A block row is at most 16 blocks wide and at least 10 blocks wide
;       Block row width is defined in the BG_ROW_WIDTH compilation constant

;       +---+---+---+---+---+---+---+---+---+---+---+
;  ri   | 3 | 6 | 3 | 1 | 7 | . | . | . | . | . | . |
;       +---+---+---+---+---+---+---+---+---+---+---+
;
;       Each row can be refered to as a 0 based indexing

;       ------------------
;       III Enemy encoding
;       ------------------
;
;       Not Yet defined
;       Will most likely be encoded as rows too

;       --------------------
;       IV Levels encoding
;       --------------------
;
;       Levels are encoded as a stream of row indexes

        DEF BG_ROW_WIDTH EQU 10
