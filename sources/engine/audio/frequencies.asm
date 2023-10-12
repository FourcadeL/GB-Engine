;#############################
; audio frequencies
; definition of functions for
; getting the correct frequencies
; out of a note number
;##############################

    INCLUDE "hardware.inc"
    INCLUDE "engine.inc"
    INCLUDE "debug.inc"

;-------------notes table---------------------
; Note   | Value | GB frequency value (ch1 and 2)
; C2     |0|000 00101100|
; C#2/Db2|1|000 10011101|
; D2     |2|001 00000111|
; D#2/Eb2|3|001 01101011|
; E2     |4|001 11001010|
; F2     |5|010 00100011|
; F#2/Gb2|6|010 01110111|
; G2     |7|010 11000111|
; G#2/Ab2|8|011 00010010|
; A2     |9|011 01011000|
; A#2/Bb2|10|011 10011011|
; B2     |11|011 11011010|
; C3     |12|100 00010110|
; C#3/Db3|13|100 01001110|
; D3     |14|100 10000011|
; D#3/Eb3|15|100 10110101|
; E3     |16|100 11100101|
; F3     |17|101 00010001|
; F#3/Gb3|18|101 00111100|
; G3     |19|101 01100011|
; G#3/Ab3|20|101 10001001|
; A3     |21|101 10101100|
; A#3/Bb3|22|101 11001110|
; B3     |23|101 11101101|
; C4     |24|110 00001011|
; C#4/Db4|25|110 00100111|
; D4     |26|110 01000010|
; D#4/Eb4|27|110 01011011|
; E4     |28|110 01110010|
; F4     |29|110 10001001|
; F#4/Gb4|30|110 10011110|
; G4     |31|110 10110010|
; G#4/Ab4|32|110 11000100|
; A4     |33|110 11010110|
; A#4/Bb4|34|110 11100111|
; B4     |35|110 11110111|
; C5     |36|111 00000110|
; C#5/Db5|37|111 00010100|
; D5     |38|111 00100001|
; D#5/Eb5|39|111 00101101|
; E5     |40|111 00111001|
; F5     |41|111 01000100|
; F#5/Gb5|42|111 01001111|
; G5     |43|111 01011001|
; G#5/Ab5|44|111 01100010|
; A5     |45|111 01101011|
; A#5/Bb5|46|111 01110011|
; B5     |47|111 01111011|
; C6     |48|111 10000011|
; C#6/Db6|49|111 10001010|
; D6     |50|111 10010000|
; D#6/Eb6|51|111 10010111|
; E6     |52|111 10011101|
; F6     |53|111 10100010|
; F#6/Gb6|54|111 10100111|
; G6     |55|111 10101100|
; G#6/Ab6|56|111 10110001|
; A6     |57|111 10110110|
; A#6/Bb6|58|111 10111010|
; B6     |59|111 10111110|
; C7     |60|111 11000001|
; C#7/Db7|61|111 11000101|
; D7     |62|111 11001000|
; D#7/Eb7|63|111 11001011|
; E7     |64|111 11001110|
; F7     |65|111 11010001|
; F#7/Gb7|66|111 11010100|
; G7     |67|111 11010110|
; G#7/Ab7|68|111 11011001|
; A7     |69|111 11011011|
; A#7/Bb7|70|111 11011101|
; B7     |71|111 11011111|
; C8     |72|111 11100001|
; C#8/Db8|73|111 11100010|
; D8     |74|111 11100100|
; D#8/Eb8|75|111 11100110|
; E8     |76|111 11100111|
; F8     |77|111 11101001|
; F#8/Gb8|78|111 11101010|
; G8     |79|111 11101011|
; G#8/Ab8|80|111 11101100|
; A8     |81|111 11101101|
; A#8/Bb8|82|111 11101110|
; B8     |83|111 11101111|
;----------------------------------

    SECTION "Frequencies_Functions", ROM0

;------------------------------------------------------------------------------------------
;- Audio_get_note_frequency12(a = note index) -> bc = gb frequency of note (11 bits)      
;- return the gb frequency to use for specified note
;- (channel 1 and 2)
;- for channel 3 : everything is shifted one octave down :
; C3 is C2, F4 is F3 ets ...
;------------------------------------------------------------------------------------------
Audio_get_note_frequency12::
    ;---high part---
	ld		b, %00000111
	cp		a, %00100100 ;111
	jr		nc, .correct_high_part
	dec		b
	cp		a, %00011000 ; 110
	jr		nc, .correct_high_part
	dec		b
	cp		a, %00010001 ; 101
	jr		nc, .correct_high_part
	dec		b
	cp		a, %00001100 ; 100
	jr		nc, .correct_high_part
	dec 	b
	cp 		a, %00001000 ; 011
	jr		nc, .correct_high_part
	dec		b
	cp		a, %00000101 ; 010
	jr		nc, .correct_high_part
	dec		b
	cp		a, %00000010 ; 001
	jr		nc, .correct_high_part
	dec  	b
.correct_high_part		;b output is ok
	;---low part---
    ; table is aligned $XX00
	ld		h, HIGH(__Audio_Frequencies12_Table_start)
	ld		l, a
	ld		c, [hl]
	ret



    SECTION "Audio_Frequencies_Table12", ROM0, ALIGN[8]
; audio frequencies for channels 1 and 2 Only the low byte is stored to save storage space
; the three high bits will be computed using other means
; section is aligned so address caclulation is straight forward and quicker

__Audio_Frequencies12_Table_start:
INCBIN "audio_table.bin"