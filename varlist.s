**********************************
* List Applesoft Variables       *
**********************************
* Use CTRL-S to halt the display *
*                                *
* Lists variables in order of    *
* creation - simple variables    *
* first, then arrays (soon)      *
**********************************

               DSK   PROG#060300    ; Type = 06 (bin), Aux = 0300 (org)
               ORG   $300

* Zero page locations
VARTAB         EQU   $0069
ARYTAB         EQU   $006B
STREND         EQU   $006D
LOWTR          EQU   $009B          ; Temp pointer
VPNT           EQU   $00A0          ; FAC+3

* Applesoft routines
FOUT           EQU   $ED34          ; Convert FAC to string, return in Y (msb), A (lsb)
STRLIT         EQU   $E3E7          ; Create a temp string in FAC 3, 4 pointed at by Y,A (null terminated)
STRPRT         EQU   $DB3D          ; Print string in FAC 3, 4 (pointing at length + pointer)
GIVAYF         EQU   $E2F2          ; Convert the signed int in Y, A to a float in FAC
LOADFACFROMYA  EQU   $EAF9          ; Load FAC with the real pointed at by Y, A
OUTDO          EQU   $DB5C          ; Print the character in A
CRDO           EQU   $DAFB          ; Print CR

* Main program
               LDA   VARTAB         ; init lowtr with vartab
               LDX   VARTAB+1
LOOPX          STX   LOWTR+1        ; STX first so we can optionally hit it
LOOP           STA   LOWTR
               CMP   ARYTAB         ; see if we hit ARYTAB
               BNE   DOLOOP
               CPX   ARYTAB+1
               BNE   DOLOOP
               RTS                  ; TODO: deal with arrays eventually
DOLOOP         LDY   #1             ; This saves us one INY
               LDX   #0             ; Variable type, init and assume real
               LDA   (LOWTR)
               BPL   NOTINT         ; No high bit set, then it's string or real
               INX                  ; Definitely an INT
NOTINT         JSR   OUTDO
               LDA   (LOWTR),Y
               BPL   NOTSTR         ; No high bit set? It's real
               INX
NOTSTR         JSR   OUTDO
               CPX   #1             ; X - 1: -1 = Real, 0 = String, 1 = Int
               BMI   DOREAL         ; 0 - 1 = -1 : real
               BNE   DOINT          ; 2 - 1 = 1 : int

* Handle strings
               LDA   #'$'
               JSR   OUTDO
               JSR   GETPTR
               STA   VPNT
               STY   VPNT+1
               BRA   OUTPUT

* Handle integers
DOINT          LDA   #'%'
               JSR   OUTDO
               INY
               LDA   (LOWTR),Y      ; get the MSB of the int
               TAX                  ; keep in X for now
               INY
               LDA   (LOWTR),Y      ; get the LSB of the int
               TAY                  ; Move into Y
               TXA                  ; Move the MSB back into A
               JSR   GIVAYF         ; convert to real
               BRA   FP2STR         ; now deal with converting real to string

* Handle reals
DOREAL         JSR   GETPTR
               JSR   LOADFACFROMYA
FP2STR         JSR   FOUT
               JSR   STRLIT

* Output the value
OUTPUT         LDA   #'='
               JSR   OUTDO
               JSR   STRPRT         ; TODO: print leading/trailing quote?
               JSR   CRDO

               LDA   LOWTR          ; increment lowtr by 7
               LDX   LOWTR+1
               CLC
               ADC   #7
               BCC   LOOP
               INX
               BRA   LOOPX

* Puts the pointer to the variable data in Y, A
* Assumes LOWTR is pointing at the variable table entry
GETPTR         LDA   LOWTR
               LDY   LOWTR+1
               CLC
               ADC   #2
               BCC   NOCARRY
               INY
NOCARRY        RTS

