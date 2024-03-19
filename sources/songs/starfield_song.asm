; this song file was generate using ARIA
; for any informations please see :
; https://github.com/FourcadeL/aria
; 
; This aims to streamline music composition for the GB-engine tracker automaton
; implemented by : https://github.com/FourcadeL/GB-Engine
; 
; 
; ----------------
; --- song file --
; ----------------



SECTION "instruments sheet", ROMX, ALIGN[6]
_instruments_sheet::
	 DB $00, $80, $50, $80
	 DB $00, $C0, $F1, $C0
	 DB $00, $10, $20, $80


	SECTION "songs lookup", ROMX
song_0::
	DB LOW(Smain1), HIGH(Smain1), LOW(empty), HIGH(empty), LOW(Smainwave), HIGH(Smainwave), LOW(empty), HIGH(empty)
song_1::
	DB LOW(Gmain1), HIGH(Gmain1), LOW(Gmain2), HIGH(Gmain2), LOW(Gwave), HIGH(Gwave), LOW(empty), HIGH(empty)


	SECTION "songblock_0", ROMX
Smain1:
	DB $70 ; Set Instrument(0) 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C0 ; Set wait (0) 
	DB $24 ; C5 
	DB $28 ; E5 
	DB $2B ; G5 
	DB $30 ; C6 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C0 ; Set wait (0) 
	DB $24 ; C5 
	DB $27 ; D#5 
	DB $2C ; G#5 
	DB $30 ; C6 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C0 ; Set wait (0) 
	DB $22 ; A#4 
	DB $26 ; D5 
	DB $29 ; F5 
	DB $2E ; A#5 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C0 ; Set wait (0) 
	DB $24 ; C5 
	DB $26 ; D5 
	DB $2B ; G5 
	DB $30 ; C6 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C0 ; Set wait (0) 
	DB $23 ; B4 
	DB $26 ; D5 
	DB $2B ; G5 
	DB $2F ; B5 
	DB $87 ; TrackRepeatCond 
	DB $8B ; Call(SthemeA1) 
	DB LOW(SthemeA1), HIGH(SthemeA1)
	DB $8B ; Call(SthemeB1) 
	DB LOW(SthemeB1), HIGH(SthemeB1)
	DB $84 ; GlobalRepeat 
	DB $88 ; End 

	SECTION "songblock_1", ROMX
Smainwave:
	DB $72 ; Set Instrument(2) 
	DB $64 ; Set Volume(4) 
	DB $CF ; Set wait (15). . . . . . . . . . . . . . . 
	DB $0C ; C3 
	DB $08 ; G#2 
	DB $0A ; A#2 
	DB $07 ; G2 
	DB $8B ; Call(SthemeAwave) 
	DB LOW(SthemeAwave), HIGH(SthemeAwave)
	DB $8B ; Call(SthemeBwave) 
	DB LOW(SthemeBwave), HIGH(SthemeBwave)
	DB $84 ; GlobalRepeat 
	DB $88 ; End 

	SECTION "songblock_2", ROMX
SthemeA1:
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C4 ; Set wait (4). . . . 
	DB $1C ; E4 
	DB $C0 ; Set wait (0) 
	DB $1D ; F4 
	DB $1F ; G4 
	DB $24 ; C5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $2B ; G5 
	DB $C4 ; Set wait (4). . . . 
	DB $1B ; D#4 
	DB $C0 ; Set wait (0) 
	DB $1D ; F4 
	DB $20 ; G#4 
	DB $24 ; C5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $27 ; D#5 
	DB $C4 ; Set wait (4). . . . 
	DB $1A ; D4 
	DB $C0 ; Set wait (0) 
	DB $1B ; D#4 
	DB $1D ; F4 
	DB $22 ; A#4 
	DB $C2 ; Set wait (2). . 
	DB $29 ; F5 
	DB $27 ; D#5 
	DB $C1 ; Set wait (1). 
	DB $29 ; F5 
	DB $C3 ; Set wait (3). . . 
	DB $26 ; D5 
	DB $23 ; B4 
	DB $1F ; G4 
	DB $1D ; F4 
	DB $87 ; TrackRepeatCond 
	DB $88 ; End 

	SECTION "songblock_3", ROMX
SthemeAwave:
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $0C ; C3 
	DB $0C ; C3 
	DB $0C ; C3 
	DB $0C ; C3 
	DB $0C ; C3 
	DB $0C ; C3 
	DB $C0 ; Set wait (0) 
	DB $0C ; C3 
	DB $18 ; C4 
	DB $C1 ; Set wait (1). 
	DB $0C ; C3 
	DB $08 ; G#2 
	DB $08 ; G#2 
	DB $08 ; G#2 
	DB $08 ; G#2 
	DB $08 ; G#2 
	DB $08 ; G#2 
	DB $C0 ; Set wait (0) 
	DB $08 ; G#2 
	DB $14 ; G#3 
	DB $C1 ; Set wait (1). 
	DB $08 ; G#2 
	DB $0A ; A#2 
	DB $0A ; A#2 
	DB $0A ; A#2 
	DB $0A ; A#2 
	DB $0A ; A#2 
	DB $0A ; A#2 
	DB $C0 ; Set wait (0) 
	DB $0A ; A#2 
	DB $16 ; A#3 
	DB $C1 ; Set wait (1). 
	DB $0A ; A#2 
	DB $07 ; G2 
	DB $07 ; G2 
	DB $07 ; G2 
	DB $07 ; G2 
	DB $C0 ; Set wait (0) 
	DB $07 ; G2 
	DB $13 ; G3 
	DB $C1 ; Set wait (1). 
	DB $07 ; G2 
	DB $C0 ; Set wait (0) 
	DB $0B ; B2 
	DB $17 ; B3 
	DB $C1 ; Set wait (1). 
	DB $0B ; B2 
	DB $87 ; TrackRepeatCond 
	DB $88 ; End 

	SECTION "songblock_4", ROMX
SthemeB1:
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C0 ; Set wait (0) 
	DB $24 ; C5 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $26 ; D5 
	DB $C2 ; Set wait (2). . 
	DB $27 ; D#5 
	DB $26 ; D5 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $C1 ; Set wait (1). 
	DB $22 ; A#4 
	DB $C0 ; Set wait (0) 
	DB $22 ; A#4 
	DB $C1 ; Set wait (1). 
	DB $22 ; A#4 
	DB $26 ; D5 
	DB $C2 ; Set wait (2). . 
	DB $27 ; D#5 
	DB $26 ; D5 
	DB $C1 ; Set wait (1). 
	DB $22 ; A#4 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $C0 ; Set wait (0) 
	DB $20 ; G#4 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $26 ; D5 
	DB $C2 ; Set wait (2). . 
	DB $27 ; D#5 
	DB $26 ; D5 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $C1 ; Set wait (1). 
	DB $1F ; G4 
	DB $C0 ; Set wait (0) 
	DB $1F ; G4 
	DB $C1 ; Set wait (1). 
	DB $1F ; G4 
	DB $26 ; D5 
	DB $C2 ; Set wait (2). . 
	DB $27 ; D#5 
	DB $27 ; D#5 
	DB $C1 ; Set wait (1). 
	DB $25 ; C#5 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C0 ; Set wait (0) 
	DB $24 ; C5 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $26 ; D5 
	DB $C2 ; Set wait (2). . 
	DB $27 ; D#5 
	DB $26 ; D5 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $C1 ; Set wait (1). 
	DB $22 ; A#4 
	DB $C0 ; Set wait (0) 
	DB $22 ; A#4 
	DB $C1 ; Set wait (1). 
	DB $22 ; A#4 
	DB $26 ; D5 
	DB $C2 ; Set wait (2). . 
	DB $27 ; D#5 
	DB $26 ; D5 
	DB $C1 ; Set wait (1). 
	DB $22 ; A#4 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $C1 ; Set wait (1). 
	DB $21 ; A4 
	DB $C0 ; Set wait (0) 
	DB $21 ; A4 
	DB $C1 ; Set wait (1). 
	DB $21 ; A4 
	DB $26 ; D5 
	DB $C2 ; Set wait (2). . 
	DB $27 ; D#5 
	DB $26 ; D5 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C2 ; Set wait (2). . 
	DB $24 ; C5 
	DB $29 ; F5 
	DB $2B ; G5 
	DB $30 ; C6 
	DB $C3 ; Set wait (3). . . 
	DB $32 ; D6 
	DB $88 ; End 

	SECTION "songblock_5", ROMX
SthemeBwave:
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $08 ; G#2 
	DB $C0 ; Set wait (0) 
	DB $0F ; D#3 
	DB $14 ; G#3 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $07 ; G2 
	DB $C0 ; Set wait (0) 
	DB $0F ; D#3 
	DB $13 ; G3 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $05 ; F2 
	DB $C0 ; Set wait (0) 
	DB $0C ; C3 
	DB $11 ; F3 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $03 ; D#2 
	DB $C0 ; Set wait (0) 
	DB $0A ; A#2 
	DB $0F ; D#3 
	DB $87 ; TrackRepeatCond 
	DB $C1 ; Set wait (1). 
	DB $03 ; D#2 
	DB $C0 ; Set wait (0) 
	DB $0F ; D#3 
	DB $03 ; D#2 
	DB $03 ; D#2 
	DB $13 ; G3 
	DB $0F ; D#3 
	DB $13 ; G3 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $08 ; G#2 
	DB $C0 ; Set wait (0) 
	DB $0F ; D#3 
	DB $14 ; G#3 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $07 ; G2 
	DB $C0 ; Set wait (0) 
	DB $0F ; D#3 
	DB $13 ; G3 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $05 ; F2 
	DB $C0 ; Set wait (0) 
	DB $0F ; D#3 
	DB $11 ; F3 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $07 ; G2 
	DB $C0 ; Set wait (0) 
	DB $0E ; D3 
	DB $13 ; G3 
	DB $87 ; TrackRepeatCond 
	DB $88 ; End 

	SECTION "songblock_6", ROMX
empty:
	DB $FF ; Set wait (63). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $54 ; _ 
	DB $84 ; GlobalRepeat 

	SECTION "songblock_7", ROMX
Gmain1:
	DB $70 ; Set Instrument(0) 
	DB $6E ; Set Volume(14) 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C2 ; Set wait (2). . 
	DB $24 ; C5 
	DB $C0 ; Set wait (0) 
	DB $24 ; C5 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $26 ; D5 
	DB $26 ; D5 
	DB $1F ; G4 
	DB $1F ; G4 
	DB $27 ; D#5 
	DB $C3 ; Set wait (3). . . 
	DB $27 ; D#5 
	DB $C1 ; Set wait (1). 
	DB $27 ; D#5 
	DB $29 ; F5 
	DB $29 ; F5 
	DB $C0 ; Set wait (0) 
	DB $1F ; G4 
	DB $C1 ; Set wait (1). 
	DB $1F ; G4 
	DB $C0 ; Set wait (0) 
	DB $1F ; G4 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $2B ; G5 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $C4 ; Set wait (4). . . . 
	DB $1F ; G4 
	DB $C0 ; Set wait (0) 
	DB $1D ; F4 
	DB $1C ; E4 
	DB $18 ; C4 
	DB $C4 ; Set wait (4). . . . 
	DB $13 ; G3 
	DB $C2 ; Set wait (2). . 
	DB $1C ; E4 
	DB $1F ; G4 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $2B ; G5 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $C4 ; Set wait (4). . . . 
	DB $1F ; G4 
	DB $C0 ; Set wait (0) 
	DB $1D ; F4 
	DB $1C ; E4 
	DB $18 ; C4 
	DB $C4 ; Set wait (4). . . . 
	DB $13 ; G3 
	DB $C2 ; Set wait (2). . 
	DB $1F ; G4 
	DB $24 ; C5 
	DB $C1 ; Set wait (1). 
	DB $28 ; E5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $2B ; G5 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $C2 ; Set wait (2). . 
	DB $1D ; F4 
	DB $C0 ; Set wait (0) 
	DB $1A ; D4 
	DB $1C ; E4 
	DB $C2 ; Set wait (2). . 
	DB $1D ; F4 
	DB $1C ; E4 
	DB $C1 ; Set wait (1). 
	DB $1D ; F4 
	DB $C2 ; Set wait (2). . 
	DB $1F ; G4 
	DB $1D ; F4 
	DB $C1 ; Set wait (1). 
	DB $1F ; G4 
	DB $C0 ; Set wait (0) 
	DB $20 ; G#4 
	DB $22 ; A#4 
	DB $24 ; C5 
	DB $26 ; D5 
	DB $27 ; D#5 
	DB $26 ; D5 
	DB $24 ; C5 
	DB $22 ; A#4 
	DB $20 ; G#4 
	DB $22 ; A#4 
	DB $20 ; G#4 
	DB $1F ; G4 
	DB $1D ; F4 
	DB $1F ; G4 
	DB $1D ; F4 
	DB $1B ; D#4 
	DB $C2 ; Set wait (2). . 
	DB $1A ; D4 
	DB $1D ; F4 
	DB $22 ; A#4 
	DB $27 ; D#5 
	DB $C3 ; Set wait (3). . . 
	DB $2C ; G#5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $2B ; G5 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $C1 ; Set wait (1). 
	DB $1F ; G4 
	DB $C0 ; Set wait (0) 
	DB $1F ; G4 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C0 ; Set wait (0) 
	DB $26 ; D5 
	DB $C1 ; Set wait (1). 
	DB $27 ; D#5 
	DB $C4 ; Set wait (4). . . . 
	DB $27 ; D#5 
	DB $C0 ; Set wait (0) 
	DB $27 ; D#5 
	DB $C1 ; Set wait (1). 
	DB $29 ; F5 
	DB $C4 ; Set wait (4). . . . 
	DB $29 ; F5 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $C1 ; Set wait (1). 
	DB $2B ; G5 
	DB $2B ; G5 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $2B ; G5 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $84 ; GlobalRepeat 
	DB $88 ; End 

	SECTION "songblock_8", ROMX
Gmain2:
	DB $70 ; Set Instrument(0) 
	DB $69 ; Set Volume(9) 
	DB $C1 ; Set wait (1). 
	DB $21 ; A4 
	DB $C2 ; Set wait (2). . 
	DB $21 ; A4 
	DB $C0 ; Set wait (0) 
	DB $21 ; A4 
	DB $C1 ; Set wait (1). 
	DB $21 ; A4 
	DB $23 ; B4 
	DB $23 ; B4 
	DB $1A ; D4 
	DB $1A ; D4 
	DB $24 ; C5 
	DB $C3 ; Set wait (3). . . 
	DB $24 ; C5 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $26 ; D5 
	DB $26 ; D5 
	DB $C0 ; Set wait (0) 
	DB $1A ; D4 
	DB $C1 ; Set wait (1). 
	DB $1A ; D4 
	DB $C0 ; Set wait (0) 
	DB $1A ; D4 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $28 ; E5 
	DB $C3 ; Set wait (3). . . 
	DB $54 ; _ 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $1F ; G4 
	DB $C3 ; Set wait (3). . . 
	DB $54 ; _ 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $1F ; G4 
	DB $C2 ; Set wait (2). . 
	DB $24 ; C5 
	DB $28 ; E5 
	DB $C1 ; Set wait (1). 
	DB $2B ; G5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $28 ; E5 
	DB $C3 ; Set wait (3). . . 
	DB $54 ; _ 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $1F ; G4 
	DB $C3 ; Set wait (3). . . 
	DB $54 ; _ 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $1F ; G4 
	DB $C2 ; Set wait (2). . 
	DB $24 ; C5 
	DB $28 ; E5 
	DB $C1 ; Set wait (1). 
	DB $2B ; G5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $24 ; C5 
	DB $26 ; D5 
	DB $26 ; D5 
	DB $28 ; E5 
	DB $C3 ; Set wait (3). . . 
	DB $24 ; C5 
	DB $26 ; D5 
	DB $27 ; D#5 
	DB $29 ; F5 
	DB $C2 ; Set wait (2). . 
	DB $2B ; G5 
	DB $18 ; C4 
	DB $1D ; F4 
	DB $22 ; A#4 
	DB $C3 ; Set wait (3). . . 
	DB $27 ; D#5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $28 ; E5 
	DB $C5 ; Set wait (5). . . . . 
	DB $54 ; _ 
	DB $C1 ; Set wait (1). 
	DB $1B ; D#4 
	DB $C0 ; Set wait (0) 
	DB $1D ; F4 
	DB $C1 ; Set wait (1). 
	DB $1F ; G4 
	DB $C4 ; Set wait (4). . . . 
	DB $1F ; G4 
	DB $C0 ; Set wait (0) 
	DB $1F ; G4 
	DB $C1 ; Set wait (1). 
	DB $21 ; A4 
	DB $C4 ; Set wait (4). . . . 
	DB $21 ; A4 
	DB $C0 ; Set wait (0) 
	DB $26 ; D5 
	DB $C1 ; Set wait (1). 
	DB $28 ; E5 
	DB $28 ; E5 
	DB $C0 ; Set wait (0) 
	DB $26 ; D5 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $28 ; E5 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $84 ; GlobalRepeat 
	DB $88 ; End 

	SECTION "songblock_9", ROMX
Gwave:
	DB $72 ; Set Instrument(2) 
	DB $C1 ; Set wait (1). 
	DB $1D ; F4 
	DB $C2 ; Set wait (2). . 
	DB $1D ; F4 
	DB $C0 ; Set wait (0) 
	DB $1D ; F4 
	DB $C1 ; Set wait (1). 
	DB $1D ; F4 
	DB $1F ; G4 
	DB $1F ; G4 
	DB $13 ; G3 
	DB $13 ; G3 
	DB $20 ; G#4 
	DB $C3 ; Set wait (3). . . 
	DB $20 ; G#4 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $22 ; A#4 
	DB $22 ; A#4 
	DB $C0 ; Set wait (0) 
	DB $13 ; G3 
	DB $C1 ; Set wait (1). 
	DB $13 ; G3 
	DB $C0 ; Set wait (0) 
	DB $13 ; G3 
	DB $A7 ; RepeatSet(7) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $18 ; C4 
	DB $24 ; C5 
	DB $87 ; TrackRepeatCond 
	DB $A7 ; RepeatSet(7) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $16 ; A#3 
	DB $22 ; A#4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $15 ; A3 
	DB $21 ; A4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $0E ; D3 
	DB $1A ; D4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $10 ; E3 
	DB $1C ; E4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $11 ; F3 
	DB $1D ; F4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $13 ; G3 
	DB $1F ; G4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $18 ; C4 
	DB $24 ; C5 
	DB $87 ; TrackRepeatCond 
	DB $0F ; D#3 
	DB $1B ; D#4 
	DB $0F ; D#3 
	DB $C0 ; Set wait (0) 
	DB $1B ; D#4 
	DB $1B ; D#4 
	DB $C1 ; Set wait (1). 
	DB $11 ; F3 
	DB $1D ; F4 
	DB $11 ; F3 
	DB $C0 ; Set wait (0) 
	DB $1D ; F4 
	DB $1D ; F4 
	DB $18 ; C4 
	DB $C1 ; Set wait (1). 
	DB $18 ; C4 
	DB $18 ; C4 
	DB $C0 ; Set wait (0) 
	DB $18 ; C4 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $18 ; C4 
	DB $C0 ; Set wait (0) 
	DB $54 ; _ 
	DB $84 ; GlobalRepeat 
	DB $88 ; End 

