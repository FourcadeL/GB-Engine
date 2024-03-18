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
	DB HIGH(main1), HIGH(empty), HIGH(mainwave), HIGH(empty)


	SECTION "songblock_0", ROMX, ALIGN[8]
main1:
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
	DB $8B ; Call(themeA1) 
	DB HIGH(themeA1)
	DB $8B ; Call(themeB1) 
	DB HIGH(themeB1)
	DB $84 ; GlobalRepeat 
	DB $88 ; End 

	SECTION "songblock_1", ROMX, ALIGN[8]
mainwave:
	DB $72 ; Set Instrument(2) 
	DB $64 ; Set Volume(4) 
	DB $CF ; Set wait (15). . . . . . . . . . . . . . . 
	DB $0C ; C3 
	DB $08 ; G#2 
	DB $0A ; A#2 
	DB $07 ; G2 
	DB $8B ; Call(themeAwave) 
	DB HIGH(themeAwave)
	DB $8B ; Call(themeBwave) 
	DB HIGH(themeBwave)
	DB $84 ; GlobalRepeat 
	DB $88 ; End 

	SECTION "songblock_2", ROMX, ALIGN[8]
themeA1:
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

	SECTION "songblock_3", ROMX, ALIGN[8]
themeAwave:
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

	SECTION "songblock_4", ROMX, ALIGN[8]
themeB1:
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

	SECTION "songblock_5", ROMX, ALIGN[8]
themeBwave:
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

	SECTION "songblock_6", ROMX, ALIGN[8]
empty:
	DB $FF ; Set wait (63). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $54 ; _ 
	DB $84 ; GlobalRepeat 

