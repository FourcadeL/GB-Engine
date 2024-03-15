
    SECTION "gradius song lookup", ROMX
gradius::
	DB HIGH(_tracker_main_1), HIGH(_track_main_2), HIGH(_track_main_3), HIGH(_tracker_blank_track)

    SECTION "track 0", ROMX, ALIGN[8]
_tracker_blank_track:
    DB %11111111 ; set waiting time to 127
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %01010100 ; play blank note
    DB %10000100 ; total return

    SECTION "tracker main 1", ROMX, ALIGN[8]
_tracker_main_1:
    DB %01110000 ; set instrument 0
    DB %01101110 ; set volume 14
    DB %10101110 ; set repeat counter 14
    DB %10000001 ; return tracker set
    DB %10001011 ; call to block
    DB HIGH(_gradius_main)
    DB %10000111 ; conditional return tracker
    DB %10001011 ; call to block
    DB HIGH(_tracker_blank_track)

    SECTION "track main 2", ROMX, ALIGN[8]
_track_main_2:
    DB %01110000 ; set instrument 0
    DB %01101010 ; set volume 10
    DB %10101110 ; set repeat counter 14
    DB %10000001 ; return tracker set
    DB %10001011 ; call to block
    DB HIGH(_gradius_main_2)
    DB %10000111 ; conditional return tracker
    DB %10001011 ; call to block
    DB HIGH(_tracker_blank_track)

    SECTION "track main 3", ROMX, ALIGN[8]
_track_main_3:
    DB %01110010 ; set instrument 2
    DB %10101110 ; set repeat counter 14
    DB %10000001 ; return tracker set
    DB %10001011 ; call to block
    DB HIGH(_gradius_bass)
    DB %10000111 ; conditional return tracker
    DB %10001011 ; call to block
    DB HIGH(_tracker_blank_track)




    SECTION "track gradius", ROMX, ALIGN[8]
_gradius_main:
    DB %11000001 ; wait 1
    DB %00100100
    DB %11000010 ; wait 2
    DB %00100100
    DB %11000000 ; wait 0
    DB %00100100
    DB %11000001 ; wait 1
    DB %00100100
    DB %00100110
    DB %00100110
    DB %00011111
    DB %00011111
    DB %00100111
    DB %11000011 ; wait 3
    DB %00100111
    DB %11000001 ; wait 1
    DB %00100111
    DB %00101001
    DB %00101001
    DB %11000000 ; wait 0
    DB %00011111
    DB %11000001 ; wait 1
    DB %00011111
    DB %11000000 ; wait 0
    DB %00011111
    ; ------L
    DB %11000111 ; wait 7
    DB %00101011
    DB %11000000 ; wait 0
    DB %00101001
    DB %00101000
    DB %00100100
    DB %11000100 ; wait 4
    DB %00011111
    DB %11000000 ; wait 0
    DB %00011101
    DB %00011100
    DB %00011000
    DB %11000100 ; wait 4
    DB %00010011
    DB %11000010 ; wait 2
    DB %00011100
    DB %00011111
    DB %11000001 ; wait 1
    DB %00100100
    ; --------L
    DB %11000111 ; wait 7
    DB %00101011
    DB %11000000 ; wait 0
    DB %00101001
    DB %00101000
    DB %00100100
    DB %11000100 ; wait 4
    DB %00011111
    DB %11000000 ; wait 0
    DB %00011101
    DB %00011100
    DB %00011000
    DB %11000100 ; wait 4
    DB %00010011
    DB %11000010 ; wait 2
    DB %00011111
    DB %00100100
    DB %11000001 ; wait 1
    DB %00101000
    DB %11000111 ; wait 7
    DB %00101011
    DB %11000000 ; wait 0
    DB %00101001
    DB %00101000
    DB %00100100
    DB %11000010 ; wait 2
    DB %00011101
    DB %11000000 ; wait 0
    DB %00011010
    DB %00011100
    ; --------------L
    DB %11000010 ; wait 2
    DB %00011101
    DB %00011100
    DB %11000001 ; wait 1
    DB %00011101
    DB %11000010 ; wait 2
    DB %00011111
    DB %00011101
    DB %11000001 ; wait 1
    DB %00011111
    DB %11000000 ; wait 0
    DB %00100000
    DB %00100010
    DB %00100100
    DB %00100110
    DB %00100111
    DB %00100110
    DB %00100100
    DB %00100010
    DB %00100000
    DB %00100010
    DB %00100000
    DB %00011111
    DB %00011101
    DB %00011111
    DB %00011101
    DB %00011011
    ; ----------L
    DB %11000010 ; wait 2
    DB %00011010
    DB %00011101
    DB %00100010
    DB %00100111
    DB %11000011 ; wait 3
    DB %00101100
    DB %11000111 ; wait 7
    DB %00101011
    DB %11000000 ; wait 0
    DB %00101001
    DB %00101000
    DB %00100100
    DB %11000001 ; wait 1
    DB %00011111
    DB %11000000 ; wait 0
    DB %00011111
    DB %11000001 ; wait 1
    DB %00100100
    ; -----------L
    DB %11000000 ; wait 0
    DB %00100110
    DB %11000001 ; wait 1
    DB %00100111
    DB %11000100 ; wait 4
    DB %00100111
    DB %11000000 ; wait 0
    DB %00100111
    DB %11000001 ; wait 1
    DB %00101001
    DB %11000100 ; wait 4
    DB %00101001
    DB %11000000 ; wait 0
    DB %00101001
    DB %11000001 ; wait 1
    DB %00101011
    DB %00101011
    DB %11000000 ; wait 0
    DB %00101001
    DB %11001000 ; wait 8
    DB %00101011
    DB %11000000 ; wait 0
    DB %01010100 ; play blank note
    DB %10001000 ; block end

    SECTION "track gradius 2", ROMX, ALIGN[8]
_gradius_main_2:
    DB %11000001 ; wait 1
    DB 33
    DB %11000010 ; wait 2
    DB 33
    DB %11000000 ; wait 0
    DB 33
    DB %11000001 ; wait 1
    DB 33
    DB 35
    DB 35
    DB 26
    DB 26
    DB 36
    DB %11000011 ; wait 3
    DB 36
    DB %11000001 ; wait 1
    DB 36
    DB 38
    DB 38
    DB %11000000 ; wait 0
    DB 26
    DB %11000001 ; wait 1
    DB 26
    DB %11000000 ; wait 0
    DB 26
    ; ------L
    DB %01101010 ; set volume 10
    DB %11000111 ; wait 7
    DB 40
    DB %11000011 ; wait 3
    DB %01010100 ; play blank
    DB %11000000 ; wait 0
    DB 41
    DB 40
    DB 36
    DB 31
    DB %11000011 ; wait 3
    DB %01010100 ; play blank
    DB %11000000 ; wait 0
    DB 41
    DB 40
    DB 36
    DB 31
    DB %01101010 ; set volume 10
    DB %11000010 ; wait 2
    DB 36
    DB 40
    DB %11000001 ; wait 1
    DB 43
    ; --------L
    DB %11000111 ; wait 7
    DB 40
    DB %11000011 ; wait 3
    DB %01010100 ; play blank
    DB %11000000 ; wait 0
    DB 41
    DB 40
    DB 36
    DB 31
    DB %11000011 ; wait 3
    DB %01010100 ; play blank
    DB %11000000 ; wait 0
    DB 41
    DB 40
    DB 36
    DB 31
    DB %01101010 ; set volume 10
    DB %11000010 ; wait 2
    DB 36
    DB 40
    DB %11000001 ; wait 1
    DB 43
    DB %11000111 ; wait 7
    DB 36
    DB 38
    ; --------------L
    DB 38
    DB 40
    DB %11000011 ; wait 3
    DB 36
    DB 38
    DB 39
    DB 41
    ; --------------L
    DB %11000010 ; wait 2
    DB 43
    DB 24
    DB 29
    DB 34
    DB %11000011 ; wait 3
    DB 39
    DB %01101010 ; set volume 10
    DB %11000111 ; wait 7
    DB 40
    DB %11000101 ; wait 5
    DB %01010100 ; play blank
    DB %11000001 ; wait 1
    DB 27
    ; -----------------L
    DB %11000000 ; wait 0
    DB 29
    DB %11000001 ; wait 1
    DB 31
    DB %11000100 ; wait 4
    DB 31
    DB %11000000 ; wait 0
    DB 31
    DB %11000001 ; wait 1
    DB 33
    DB %11000100 ; wait 4
    DB 33
    DB %11000000 ; wait 0
    DB 38
    DB %11000001 ; wait 1
    DB 40
    DB 40
    DB %11000000 ; wait 0
    DB 38
    DB %11001000 ; wait 8
    DB 40
    DB %11000000 ; wait 0
    DB %01010100 ; play blank note
    DB %10001000 ; block end

    SECTION "track gradius bass", ROMX, ALIGN[8]
_gradius_bass:
    DB %11000001 ; wait 1
    DB 29
    DB %11000010 ; wait 2
    DB 29
    DB %11000000 ; wait 0
    DB 29
    DB %11000001 ; wait 1
    DB 29
    DB 31
    DB 31
    DB 19
    DB 19
    DB 32
    DB %11000011 ; wait 3
    DB 32
    DB %11000001 ; wait 1
    DB 32
    DB 34
    DB 34
    DB %11000000 ; wait 0
    DB 19
    DB %11000001 ; wait 1
    DB 19
    DB %11000000 ; wait 0
    DB 19
    ; -------------L
    DB %11000001 ; wait 1
    DB %10100111 ; set repeat 7
    DB %10000001 ; set return here
    DB 24
    DB 36
    DB %10000111 ; conditionnal return
    ; ------------L
    DB %10100111 ; set repeat 7
    DB %10000001 ; set return here
    DB 22
    DB 34
    DB %10000111 ; conditionnal return
    DB %10100011 ; set repeat 3
    DB %10000001 ; set return here
    DB 21
    DB 33
    DB %10000111 ; conditionnal return
    ;---------------L
    DB %10100001 ; set repeat 1
    DB %10000001 ; set return here
    DB 14
    DB 26
    DB %10000111 ; conditionnal return
    DB %10100001 ; set repeat 1
    DB %10000001 ; set return here
    DB 16
    DB 28
    DB %10000111 ; conditionnal return
    DB %10100011 ; set repeat 3
    DB %10000001 ; set return here
    DB 17
    DB 29
    DB %10000111 ; conditionnal return
    ; ---------------L
    DB %10100011 ; set repeat 3
    DB %10000001 ; set return here
    DB 19
    DB 31
    DB %10000111 ; conditionnal return
    DB %10100011 ; set repeat 3
    DB %10000001 ; set return here
    DB 24
    DB 36
    DB %10000111 ; conditionnal return
    ;-----------------L
    DB 15
    DB 27
    DB 15
    DB %11000000 ; wait 0
    DB 27
    DB 27
    DB %11000001 ; wait 1
    DB 17
    DB 29
    DB 17
    DB %11000000 ; wait 0
    DB 29
    DB 29
    DB 24
    DB %11000001 ; wait 1
    DB 24
    DB 24
    DB %11000000 ; wait 0
    DB 24
    DB %11001000 ; wait 8
    DB 24
    DB %11000000 ; wait 0
    DB %01010100 ; play blank note
    DB %10001000 ; block end
