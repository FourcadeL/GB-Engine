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



SECTION "instruments lookup", ROMX, ALIGN[6]
_instruments_lookup::
	DB LOW(inst_1), HIGH(inst_1)
	DB LOW(inst_2), HIGH(inst_2)
	DB LOW(inst_3), HIGH(inst_3)
	DB LOW(inst_4), HIGH(inst_4)

SECTION "instruments", ROMX
inst_1:
	DB $00, $80, $50, $80
inst_2:
	DB $00, $C0, $F1, $C0
inst_3:
	DB $00, $10, $20, $80
inst_4:
	DB $00, $00, $F0, $C0

	SECTION "songs lookup", ROMX
song_0::
	DB LOW(Smain1), HIGH(Smain1), LOW(empty), HIGH(empty), LOW(Smainwave), HIGH(Smainwave), LOW(empty), HIGH(empty)
song_1::
	DB LOW(Gmain1), HIGH(Gmain1), LOW(Gmain2), HIGH(Gmain2), LOW(Gwave), HIGH(Gwave), LOW(empty), HIGH(empty)
song_2::
	DB LOW(GTransMain1), HIGH(GTransMain1), LOW(GTransMain2), HIGH(GTransMain2), LOW(GTransWave), HIGH(GTransWave), LOW(empty), HIGH(empty)
song_3::
	DB LOW(empty), HIGH(empty), LOW(empty), HIGH(empty), LOW(empty), HIGH(empty), LOW(mainNoise), HIGH(mainNoise)
song_4::
	DB LOW(SCL1), HIGH(SCL1), LOW(SCL2), HIGH(SCL2), LOW(SCLW), HIGH(SCLW), LOW(empty), HIGH(empty)


	SECTION "songblock_0", ROMX
Smain1:
	DB $70 ; Set Instrument(0) 
	DB $6A ; Set Volume(10) 
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
	DB $6A ; Set Volume(10) 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_1", ROMX
Smainwave:
	DB $72 ; Set Instrument(2) 
	DB $62 ; Set Volume(2) 
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
	DB $6A ; Set Volume(10) 
	DB $70 ; Set Instrument(0) 
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
	DB $5F ; _ 
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
	DB $5F ; _ 
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
	DB $5F ; _ 
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
	DB $5F ; _ 
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
	DB $5F ; _ 
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
	DB $5F ; _ 
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
	DB $5F ; _ 
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
	DB $5F ; _ 
	DB $84 ; GlobalRepeat 
	DB $6A ; Set Volume(10) 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_7", ROMX
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
	DB $5F ; _ 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $1F ; G4 
	DB $C3 ; Set wait (3). . . 
	DB $5F ; _ 
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
	DB $5F ; _ 
	DB $C0 ; Set wait (0) 
	DB $29 ; F5 
	DB $28 ; E5 
	DB $24 ; C5 
	DB $1F ; G4 
	DB $C3 ; Set wait (3). . . 
	DB $5F ; _ 
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
	DB $5F ; _ 
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
	DB $5F ; _ 
	DB $84 ; GlobalRepeat 
	DB $6A ; Set Volume(10) 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_8", ROMX
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
	DB $5F ; _ 
	DB $84 ; GlobalRepeat 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_9", ROMX
mainNoise:
	DB $73 ; Set Instrument(3) 
	DB $C3 ; Set wait (3). . . 
	DB $00 ; C2 
	DB $01 ; C#2 
	DB $02 ; D2 
	DB $03 ; D#2 
	DB $04 ; E2 
	DB $05 ; F2 
	DB $06 ; F#2 
	DB $07 ; G2 
	DB $08 ; G#2 
	DB $09 ; A2 
	DB $0A ; A#2 
	DB $0B ; B2 
	DB $0C ; C3 
	DB $0D ; C#3 
	DB $0E ; D3 
	DB $0F ; D#3 
	DB $10 ; E3 
	DB $11 ; F3 
	DB $12 ; F#3 
	DB $13 ; G3 
	DB $14 ; G#3 
	DB $15 ; A3 
	DB $16 ; A#3 
	DB $17 ; B3 
	DB $18 ; C4 
	DB $19 ; C#4 
	DB $1A ; D4 
	DB $1B ; D#4 
	DB $1C ; E4 
	DB $1D ; F4 
	DB $1E ; F#4 
	DB $1F ; G4 
	DB $20 ; G#4 
	DB $21 ; A4 
	DB $22 ; A#4 
	DB $23 ; B4 
	DB $24 ; C5 
	DB $25 ; C#5 
	DB $26 ; D5 
	DB $27 ; D#5 
	DB $28 ; E5 
	DB $29 ; F5 
	DB $2A ; F#5 
	DB $2B ; G5 
	DB $2C ; G#5 
	DB $2D ; A5 
	DB $2E ; A#5 
	DB $2F ; B5 
	DB $30 ; C6 
	DB $31 ; C#6 
	DB $32 ; D6 
	DB $33 ; D#6 
	DB $34 ; E6 
	DB $35 ; F6 
	DB $36 ; F#6 
	DB $37 ; G6 
	DB $38 ; G#6 
	DB $39 ; A6 
	DB $3A ; A#6 
	DB $3B ; B6 
	DB $3C ; C7 
	DB $3D ; C#7 
	DB $3E ; D7 
	DB $3F ; D#7 
	DB $40 ; E7 
	DB $41 ; F7 
	DB $42 ; F#7 
	DB $43 ; G7 
	DB $44 ; G#7 
	DB $45 ; A7 
	DB $46 ; A#7 
	DB $47 ; B7 
	DB $48 ; C8 
	DB $49 ; C#8 
	DB $4A ; D8 
	DB $4B ; D#8 
	DB $4C ; E8 
	DB $4D ; F8 
	DB $4E ; F#8 
	DB $4F ; G8 
	DB $50 ; G#8 
	DB $51 ; A8 
	DB $52 ; A#8 
	DB $53 ; B8 
	DB $54 ; C9 
	DB $55 ; C#9 
	DB $56 ; D9 
	DB $57 ; D#9 
	DB $58 ; E9 
	DB $59 ; F9 
	DB $5A ; F#9 
	DB $5B ; G9 
	DB $5C ; G#9 
	DB $5D ; A9 
	DB $84 ; GlobalRepeat 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_10", ROMX
GTransMain1:
	DB $70 ; Set Instrument(0) 
	DB $6E ; Set Volume(14) 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $C2 ; Set wait (2). . 
	DB $20 ; G#4 
	DB $C0 ; Set wait (0) 
	DB $20 ; G#4 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $22 ; A#4 
	DB $22 ; A#4 
	DB $1B ; D#4 
	DB $1B ; D#4 
	DB $23 ; B4 
	DB $C3 ; Set wait (3). . . 
	DB $23 ; B4 
	DB $C1 ; Set wait (1). 
	DB $23 ; B4 
	DB $25 ; C#5 
	DB $25 ; C#5 
	DB $C0 ; Set wait (0) 
	DB $1B ; D#4 
	DB $C1 ; Set wait (1). 
	DB $1B ; D#4 
	DB $C0 ; Set wait (0) 
	DB $1B ; D#4 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $27 ; D#5 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $24 ; C5 
	DB $20 ; G#4 
	DB $C4 ; Set wait (4). . . . 
	DB $1B ; D#4 
	DB $C0 ; Set wait (0) 
	DB $19 ; C#4 
	DB $18 ; C4 
	DB $14 ; G#3 
	DB $C4 ; Set wait (4). . . . 
	DB $0F ; D#3 
	DB $C2 ; Set wait (2). . 
	DB $18 ; C4 
	DB $1B ; D#4 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $27 ; D#5 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $24 ; C5 
	DB $20 ; G#4 
	DB $C4 ; Set wait (4). . . . 
	DB $1B ; D#4 
	DB $C0 ; Set wait (0) 
	DB $19 ; C#4 
	DB $18 ; C4 
	DB $14 ; G#3 
	DB $C4 ; Set wait (4). . . . 
	DB $0F ; D#3 
	DB $C2 ; Set wait (2). . 
	DB $1B ; D#4 
	DB $20 ; G#4 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $27 ; D#5 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $24 ; C5 
	DB $20 ; G#4 
	DB $C2 ; Set wait (2). . 
	DB $19 ; C#4 
	DB $C0 ; Set wait (0) 
	DB $16 ; A#3 
	DB $18 ; C4 
	DB $C2 ; Set wait (2). . 
	DB $19 ; C#4 
	DB $18 ; C4 
	DB $C1 ; Set wait (1). 
	DB $19 ; C#4 
	DB $C2 ; Set wait (2). . 
	DB $1B ; D#4 
	DB $19 ; C#4 
	DB $C1 ; Set wait (1). 
	DB $1B ; D#4 
	DB $C0 ; Set wait (0) 
	DB $1C ; E4 
	DB $1E ; F#4 
	DB $20 ; G#4 
	DB $22 ; A#4 
	DB $23 ; B4 
	DB $22 ; A#4 
	DB $20 ; G#4 
	DB $1E ; F#4 
	DB $1C ; E4 
	DB $1E ; F#4 
	DB $1C ; E4 
	DB $1B ; D#4 
	DB $19 ; C#4 
	DB $1B ; D#4 
	DB $19 ; C#4 
	DB $17 ; B3 
	DB $C2 ; Set wait (2). . 
	DB $16 ; A#3 
	DB $19 ; C#4 
	DB $1E ; F#4 
	DB $23 ; B4 
	DB $C3 ; Set wait (3). . . 
	DB $28 ; E5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $27 ; D#5 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $24 ; C5 
	DB $20 ; G#4 
	DB $C1 ; Set wait (1). 
	DB $1B ; D#4 
	DB $C0 ; Set wait (0) 
	DB $1B ; D#4 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $C0 ; Set wait (0) 
	DB $22 ; A#4 
	DB $C1 ; Set wait (1). 
	DB $23 ; B4 
	DB $C4 ; Set wait (4). . . . 
	DB $23 ; B4 
	DB $C0 ; Set wait (0) 
	DB $23 ; B4 
	DB $C1 ; Set wait (1). 
	DB $25 ; C#5 
	DB $C4 ; Set wait (4). . . . 
	DB $25 ; C#5 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $C1 ; Set wait (1). 
	DB $27 ; D#5 
	DB $27 ; D#5 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $27 ; D#5 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $84 ; GlobalRepeat 
	DB $6A ; Set Volume(10) 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_11", ROMX
GTransMain2:
	DB $70 ; Set Instrument(0) 
	DB $69 ; Set Volume(9) 
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
	DB $16 ; A#3 
	DB $16 ; A#3 
	DB $20 ; G#4 
	DB $C3 ; Set wait (3). . . 
	DB $20 ; G#4 
	DB $C1 ; Set wait (1). 
	DB $20 ; G#4 
	DB $22 ; A#4 
	DB $22 ; A#4 
	DB $C0 ; Set wait (0) 
	DB $16 ; A#3 
	DB $C1 ; Set wait (1). 
	DB $16 ; A#3 
	DB $C0 ; Set wait (0) 
	DB $16 ; A#3 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $24 ; C5 
	DB $C3 ; Set wait (3). . . 
	DB $5F ; _ 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $24 ; C5 
	DB $20 ; G#4 
	DB $1B ; D#4 
	DB $C3 ; Set wait (3). . . 
	DB $5F ; _ 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $24 ; C5 
	DB $20 ; G#4 
	DB $1B ; D#4 
	DB $C2 ; Set wait (2). . 
	DB $20 ; G#4 
	DB $24 ; C5 
	DB $C1 ; Set wait (1). 
	DB $27 ; D#5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $24 ; C5 
	DB $C3 ; Set wait (3). . . 
	DB $5F ; _ 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $24 ; C5 
	DB $20 ; G#4 
	DB $1B ; D#4 
	DB $C3 ; Set wait (3). . . 
	DB $5F ; _ 
	DB $C0 ; Set wait (0) 
	DB $25 ; C#5 
	DB $24 ; C5 
	DB $20 ; G#4 
	DB $1B ; D#4 
	DB $C2 ; Set wait (2). . 
	DB $20 ; G#4 
	DB $24 ; C5 
	DB $C1 ; Set wait (1). 
	DB $27 ; D#5 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $20 ; G#4 
	DB $22 ; A#4 
	DB $22 ; A#4 
	DB $24 ; C5 
	DB $C3 ; Set wait (3). . . 
	DB $20 ; G#4 
	DB $22 ; A#4 
	DB $23 ; B4 
	DB $25 ; C#5 
	DB $C2 ; Set wait (2). . 
	DB $27 ; D#5 
	DB $14 ; G#3 
	DB $19 ; C#4 
	DB $1E ; F#4 
	DB $C3 ; Set wait (3). . . 
	DB $23 ; B4 
	DB $C7 ; Set wait (7). . . . . . . 
	DB $24 ; C5 
	DB $C5 ; Set wait (5). . . . . 
	DB $5F ; _ 
	DB $C1 ; Set wait (1). 
	DB $17 ; B3 
	DB $C0 ; Set wait (0) 
	DB $19 ; C#4 
	DB $C1 ; Set wait (1). 
	DB $1B ; D#4 
	DB $C4 ; Set wait (4). . . . 
	DB $1B ; D#4 
	DB $C0 ; Set wait (0) 
	DB $1B ; D#4 
	DB $C1 ; Set wait (1). 
	DB $1D ; F4 
	DB $C4 ; Set wait (4). . . . 
	DB $1D ; F4 
	DB $C0 ; Set wait (0) 
	DB $22 ; A#4 
	DB $C1 ; Set wait (1). 
	DB $24 ; C5 
	DB $24 ; C5 
	DB $C0 ; Set wait (0) 
	DB $22 ; A#4 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $24 ; C5 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $84 ; GlobalRepeat 
	DB $6A ; Set Volume(10) 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_12", ROMX
GTransWave:
	DB $72 ; Set Instrument(2) 
	DB $C1 ; Set wait (1). 
	DB $19 ; C#4 
	DB $C2 ; Set wait (2). . 
	DB $19 ; C#4 
	DB $C0 ; Set wait (0) 
	DB $19 ; C#4 
	DB $C1 ; Set wait (1). 
	DB $19 ; C#4 
	DB $1B ; D#4 
	DB $1B ; D#4 
	DB $0F ; D#3 
	DB $0F ; D#3 
	DB $1C ; E4 
	DB $C3 ; Set wait (3). . . 
	DB $1C ; E4 
	DB $C1 ; Set wait (1). 
	DB $1C ; E4 
	DB $1E ; F#4 
	DB $1E ; F#4 
	DB $C0 ; Set wait (0) 
	DB $0F ; D#3 
	DB $C1 ; Set wait (1). 
	DB $0F ; D#3 
	DB $C0 ; Set wait (0) 
	DB $0F ; D#3 
	DB $A7 ; RepeatSet(7) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $14 ; G#3 
	DB $20 ; G#4 
	DB $87 ; TrackRepeatCond 
	DB $A7 ; RepeatSet(7) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $12 ; F#3 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $11 ; F3 
	DB $1D ; F4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $0A ; A#2 
	DB $16 ; A#3 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $0C ; C3 
	DB $18 ; C4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $0D ; C#3 
	DB $19 ; C#4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $0F ; D#3 
	DB $1B ; D#4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C1 ; Set wait (1). 
	DB $14 ; G#3 
	DB $20 ; G#4 
	DB $87 ; TrackRepeatCond 
	DB $0B ; B2 
	DB $17 ; B3 
	DB $0B ; B2 
	DB $C0 ; Set wait (0) 
	DB $17 ; B3 
	DB $17 ; B3 
	DB $C1 ; Set wait (1). 
	DB $0D ; C#3 
	DB $19 ; C#4 
	DB $0D ; C#3 
	DB $C0 ; Set wait (0) 
	DB $19 ; C#4 
	DB $19 ; C#4 
	DB $14 ; G#3 
	DB $C1 ; Set wait (1). 
	DB $14 ; G#3 
	DB $14 ; G#3 
	DB $C0 ; Set wait (0) 
	DB $14 ; G#3 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $14 ; G#3 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $84 ; GlobalRepeat 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_13", ROMX
SCL1:
	DB $70 ; Set Instrument(0) 
	DB $67 ; Set Volume(7) 
	DB $A7 ; RepeatSet(7) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $14 ; G#3 
	DB $19 ; C#4 
	DB $1C ; E4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $15 ; A3 
	DB $19 ; C#4 
	DB $1C ; E4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $15 ; A3 
	DB $1A ; D4 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $14 ; G#3 
	DB $18 ; C4 
	DB $1E ; F#4 
	DB $14 ; G#3 
	DB $19 ; C#4 
	DB $1C ; E4 
	DB $14 ; G#3 
	DB $19 ; C#4 
	DB $1B ; D#4 
	DB $12 ; F#3 
	DB $18 ; C4 
	DB $1B ; D#4 
	DB $10 ; E3 
	DB $14 ; G#3 
	DB $19 ; C#4 
	DB $A2 ; RepeatSet(2) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $14 ; G#3 
	DB $19 ; C#4 
	DB $1C ; E4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $14 ; G#3 
	DB $1B ; D#4 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $14 ; G#3 
	DB $19 ; C#4 
	DB $1C ; E4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $15 ; A3 
	DB $19 ; C#4 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $14 ; G#3 
	DB $17 ; B3 
	DB $1C ; E4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $15 ; A3 
	DB $17 ; B3 
	DB $1B ; D#4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $14 ; G#3 
	DB $17 ; B3 
	DB $1C ; E4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $13 ; G3 
	DB $17 ; B3 
	DB $1C ; E4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $13 ; G3 
	DB $17 ; B3 
	DB $1D ; F4 
	DB $87 ; TrackRepeatCond 
	DB $13 ; G3 
	DB $18 ; C4 
	DB $1C ; E4 
	DB $13 ; G3 
	DB $17 ; B3 
	DB $1C ; E4 
	DB $13 ; G3 
	DB $19 ; C#4 
	DB $1C ; E4 
	DB $12 ; F#3 
	DB $19 ; C#4 
	DB $1C ; E4 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $12 ; F#3 
	DB $17 ; B3 
	DB $1A ; D4 
	DB $87 ; TrackRepeatCond 
	DB $13 ; G3 
	DB $17 ; B3 
	DB $19 ; C#4 
	DB $10 ; E3 
	DB $17 ; B3 
	DB $19 ; C#4 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $12 ; F#3 
	DB $17 ; B3 
	DB $1A ; D4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $12 ; F#3 
	DB $16 ; A#3 
	DB $19 ; C#4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $17 ; B3 
	DB $1A ; D4 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $17 ; B3 
	DB $1B ; D#4 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $17 ; B3 
	DB $1C ; E4 
	DB $1F ; G4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $17 ; B3 
	DB $1B ; D#4 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $17 ; B3 
	DB $1C ; E4 
	DB $1F ; G4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $17 ; B3 
	DB $1B ; D#4 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $17 ; B3 
	DB $1A ; D4 
	DB $1D ; F4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $17 ; B3 
	DB $19 ; C#4 
	DB $20 ; G#4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $15 ; A3 
	DB $19 ; C#4 
	DB $1E ; F#4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $13 ; G3 
	DB $17 ; B3 
	DB $1A ; D4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $12 ; F#3 
	DB $15 ; A3 
	DB $1B ; D#4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $0D ; C#3 
	DB $12 ; F#3 
	DB $15 ; A3 
	DB $87 ; TrackRepeatCond 
	DB $0D ; C#3 
	DB $12 ; F#3 
	DB $14 ; G#3 
	DB $0D ; C#3 
	DB $11 ; F3 
	DB $14 ; G#3 
	DB $8A ; Jump(SCL1bis) 
	DB LOW(SCL1bis), HIGH(SCL1bis)
	DB $6A ; Set Volume(10) 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_14", ROMX
SCL1bis:
	DB $C3 ; Set wait (3). . . 
	DB $12 ; F#3 
	DB $15 ; A3 
	DB $19 ; C#4 
	DB $15 ; A3 
	DB $19 ; C#4 
	DB $1E ; F#4 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $19 ; C#4 
	DB $1E ; F#4 
	DB $21 ; A4 
	DB $87 ; TrackRepeatCond 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $19 ; C#4 
	DB $20 ; G#4 
	DB $23 ; B4 
	DB $87 ; TrackRepeatCond 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $19 ; C#4 
	DB $1E ; F#4 
	DB $21 ; A4 
	DB $87 ; TrackRepeatCond 
	DB $18 ; C4 
	DB $1E ; F#4 
	DB $21 ; A4 
	DB $19 ; C#4 
	DB $1E ; F#4 
	DB $21 ; A4 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $C3 ; Set wait (3). . . 
	DB $1B ; D#4 
	DB $1E ; F#4 
	DB $20 ; G#4 
	DB $87 ; TrackRepeatCond 
	DB $88 ; End 

	SECTION "songblock_15", ROMX
SCL2:
	DB $70 ; Set Instrument(0) 
	DB $6A ; Set Volume(10) 
	DB $A3 ; RepeatSet(3) 
	DB $81 ; SetReturnTrack 
	DB $EF ; Set wait (47). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $5F ; _ 
	DB $87 ; TrackRepeatCond 
	DB $A2 ; RepeatSet(2) 
	DB $81 ; SetReturnTrack 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $5F ; _ 
	DB $87 ; TrackRepeatCond 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $20 ; G#4 
	DB $C2 ; Set wait (2). . 
	DB $20 ; G#4 
	DB $E2 ; Set wait (34). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $20 ; G#4 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $20 ; G#4 
	DB $C2 ; Set wait (2). . 
	DB $20 ; G#4 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $20 ; G#4 
	DB $21 ; A4 
	DB $20 ; G#4 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $1E ; F#4 
	DB $23 ; B4 
	DB $1C ; E4 
	DB $A5 ; RepeatSet(5) 
	DB $81 ; SetReturnTrack 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $5F ; _ 
	DB $87 ; TrackRepeatCond 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $1F ; G4 
	DB $C2 ; Set wait (2). . 
	DB $1F ; G4 
	DB $E2 ; Set wait (34). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $1F ; G4 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $1F ; G4 
	DB $C2 ; Set wait (2). . 
	DB $1F ; G4 
	DB $E3 ; Set wait (35). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $1F ; G4 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $1E ; F#4 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $1E ; F#4 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $1F ; G4 
	DB $1C ; E4 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $1E ; F#4 
	DB $1E ; F#4 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $17 ; B3 
	DB $A1 ; RepeatSet(1) 
	DB $81 ; SetReturnTrack 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $5F ; _ 
	DB $87 ; TrackRepeatCond 
	DB $23 ; B4 
	DB $E3 ; Set wait (35). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $24 ; C5 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $22 ; A#4 
	DB $E2 ; Set wait (34). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $23 ; B4 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $23 ; B4 
	DB $E3 ; Set wait (35). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $24 ; C5 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $22 ; A#4 
	DB $D6 ; Set wait (22). . . . . . . . . . . . . . . . . . . . . . 
	DB $23 ; B4 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $D6 ; Set wait (22). . . . . . . . . . . . . . . . . . . . . . 
	DB $23 ; B4 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $23 ; B4 
	DB $21 ; A4 
	DB $1F ; G4 
	DB $1E ; F#4 
	DB $D6 ; Set wait (22). . . . . . . . . . . . . . . . . . . . . . 
	DB $19 ; C#4 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $CA ; Set wait (10). . . . . . . . . . 
	DB $19 ; C#4 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $19 ; C#4 
	DB $A2 ; RepeatSet(2) 
	DB $81 ; SetReturnTrack 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $5F ; _ 
	DB $87 ; TrackRepeatCond 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $25 ; C#5 
	DB $C2 ; Set wait (2). . 
	DB $25 ; C#5 
	DB $E2 ; Set wait (34). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $25 ; C#5 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $C8 ; Set wait (8). . . . . . . . 
	DB $25 ; C#5 
	DB $C2 ; Set wait (2). . 
	DB $25 ; C#5 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $25 ; C#5 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $24 ; C5 
	DB $25 ; C#5 
	DB $E2 ; Set wait (34). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $27 ; D#5 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $27 ; D#5 
	DB $28 ; E5 
	DB $6A ; Set Volume(10) 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_16", ROMX
SCLW:
	DB $72 ; Set Instrument(2) 
	DB $EF ; Set wait (47). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $0D ; C#3 
	DB $0B ; B2 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $09 ; A2 
	DB $06 ; F#2 
	DB $D6 ; Set wait (22). . . . . . . . . . . . . . . . . . . . . . 
	DB $08 ; G#2 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $08 ; G#2 
	DB $EF ; Set wait (47). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $0D ; C#3 
	DB $0C ; C3 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $0D ; C#3 
	DB $12 ; F#3 
	DB $D6 ; Set wait (22). . . . . . . . . . . . . . . . . . . . . . 
	DB $0B ; B2 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $0B ; B2 
	DB $EE ; Set wait (46). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $10 ; E3 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $EF ; Set wait (47). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $10 ; E3 
	DB $0E ; D3 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $0C ; C3 
	DB $0B ; B2 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $0A ; A#2 
	DB $0B ; B2 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $04 ; E2 
	DB $07 ; G2 
	DB $D6 ; Set wait (22). . . . . . . . . . . . . . . . . . . . . . 
	DB $06 ; F#2 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $06 ; F#2 
	DB $FB ; Set wait (59). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $0B ; B2 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $10 ; E3 
	DB $13 ; G3 
	DB $10 ; E3 
	DB $FB ; Set wait (59). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $0B ; B2 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $10 ; E3 
	DB $13 ; G3 
	DB $10 ; E3 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $0B ; B2 
	DB $08 ; G#2 
	DB $05 ; F2 
	DB $06 ; F#2 
	DB $0B ; B2 
	DB $0C ; C3 
	DB $D6 ; Set wait (22). . . . . . . . . . . . . . . . . . . . . . 
	DB $01 ; C#2 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $01 ; C#2 
	DB $EF ; Set wait (47). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $06 ; F#2 
	DB $11 ; F3 
	DB $D7 ; Set wait (23). . . . . . . . . . . . . . . . . . . . . . . 
	DB $12 ; F#3 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $0F ; D#3 
	DB $0D ; C#3 
	DB $E2 ; Set wait (34). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $0C ; C3 
	DB $C0 ; Set wait (0) 
	DB $5F ; _ 
	DB $CB ; Set wait (11). . . . . . . . . . . 
	DB $0C ; C3 
	DB $70 ; Set Instrument(0) 
	DB $88 ; End 

	SECTION "songblock_17", ROMX
empty:
	DB $FF ; Set wait (63). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
	DB $5F ; _ 
	DB $84 ; GlobalRepeat 
	DB $88 ; End 

