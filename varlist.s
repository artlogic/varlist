**********************************
* List Applesoft Variables       *
**********************************
* Use CTRL-S to halt the display *
*                                *
* Lists variables in order of    *
* creation - simple variables    *
* first, then arrays (soon)      *
**********************************

               DSK   VARLIST#060300  ; Type = 06 (bin), Aux = 0300 (org)
               TYP   BIN
               ORG   $300

* Zero page locations
VARTAB         EQU   $0069
ARYTAB         EQU   $006B
STREND         EQU   $006D
LOWTR          EQU   $009B          ; Temp pointer
VPNT           EQU   $00A0          ; FAC+3

* Pointers to data
FNSTR          EQU   $D1E9          ; The location of the FN token string in memory  

* Applesoft routines
FOUT           EQU   $ED34          ; Convert FAC to string, return in Y (MSB), A (LSB)
STRLIT         EQU   $E3E7          ; Create a temp string in FAC 3, 4 pointed at by Y,A (null terminated)
STRLTX         EQU   STRLIT+2       ; like STRLIT, but specify the end delim in X
STRPRT         EQU   $DB3D          ; Print string in FAC 3, 4 (pointing at length + pointer)
GIVAYF         EQU   $E2F2          ; Convert the signed int in Y, A to a float in FAC
LOADFACFROMYA  EQU   $EAF9          ; Load FAC with the real pointed at by Y, A
OUTDO          EQU   $DB5C          ; Print the character in A
CRDO           EQU   $DAFB          ; Print CR

* Main program
               LDA   VARTAB         ; initialize LOWTR with VARTAB
               LDX   VARTAB+1
LOOPX          STX   LOWTR+1        ; STX first so we can optionally hit it
LOOP           STA   LOWTR
               CMP   ARYTAB         ; see if we hit ARYTAB
               BNE   DOLOOP
               CPX   ARYTAB+1
               BNE   DOLOOP
               RTS                  ; TODO: deal with arrays eventually
DOLOOP         LDY   #0             ; index for variable entry
               JSR   OUTCHAR        ; print first char of variable
               BPL   REALSTR        ; if high bit clear, it's a real or string
               JSR   OUTCHAR        ; print second char of func or int variable 
               BPL   DOFUNC         ; high bits 1, 0 - DEF FN
               BMI   DOINT          ; high bits 1, 1 - int (could be BRA on 65C02)
REALSTR        JSR   OUTCHAR        ; print second char of real or str variable
               BPL   DOREAL         ; high bits 0, 0 - real (otherwise string)

* Handle strings
               JSR   GETPTR
               STA   VPNT
               STY   VPNT+1
               LDA   #'$'
POUTPUT        JSR   OUTDO
               BNE   OUTPUT         ; always

* Handle functions - just print like so: A()=FN
DOFUNC         LDA   #<FNSTR        ; load the LSB of FNSTR
               LDY   #>FNSTR        ; and the MSB
               LDX   #'S'           ; and the end character of the next token
               JSR   STRLTX         ; jump into the middle of STRLIT
               LDA   #'('           ; print the parenths
               JSR   OUTDO
               LDA   #')'
               BNE   POUTPUT        ; let the string routine handle the last bit

* Handle integers
DOINT          LDA   (LOWTR),Y      ; get the MSB of the int
               TAX                  ; keep in X for now
               INY
               LDA   (LOWTR),Y      ; get the LSB of the int
               TAY                  ; Move into Y
               TXA                  ; Move the MSB back into A
               JSR   GIVAYF         ; convert to real
               LDA   #'%'
               JSR   OUTDO
               BNE   FP2STR         ; always branch to the real to string conversion

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

* Move to the next entry
               LDA   LOWTR          ; increment lowtr by 7
               LDX   LOWTR+1        ; and leave it in X, A
               CLC
               ADC   #7
               BCC   LOOP
               INX
               BCS   LOOPX          ; always

* Puts the pointer to the variable data in Y, A
* Assumes LOWTR is pointing at the variable table entry
GETPTR         LDA   LOWTR
               LDY   LOWTR+1
               CLC
               ADC   #2
               BCC   NOCARRY
               INY
NOCARRY        RTS

* Outputs the character pointed at by (LOWTR),Y
* OUTDO messes with A, so we preserve it in X
* Also increment Y
OUTCHAR        LDA   (LOWTR),Y
               TAX
               JSR   OUTDO
               INY
               TXA
               RTS


