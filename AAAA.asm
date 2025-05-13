         BEGIN

* Student DSECT
STUDENT  DSECT          * 190 bytes
STUNUM   DS    XL2      * roll number
STUNAM	 DS	   CL15     * full name
STUAGE   DS    XL2      * 2 digit age
STUTEL   DS	   XL10     * phone number
STUADR	 DS    CL40     * mailing address
STUCRS   DS    CL3      * course
STUSBJ1  DS    CL20     * subjects
STUSBJ2  DS    CL20
STUSBJ3  DS    CL20
STUSBJ4  DS    CL20     * 152 bytes from here
STUSPR   DS    CL38     * spare 38 bytes
         END

         LA    R1,MI0ACC   * input start address into R1
         LA    R0,MI0CCT   * Total number of bytes char 160
         XR    R2,R2       * Count for forward slashes, initialize to 0
         XR    R3,R3	   * Count for comma
         XR    R4,R4	   * Count for parentheses
         XR    R5,R5       * PAC


* Check PAC A, U, *, D
         CLI   0(R1),X'C1'    * EBCDIC for A
         BE    SUCPAC
         CLI   0(R1),X'E4'
         BE    SUCPAC
         CLI   0(R1),X'5C'
         BE    SUCPAC
         CLI   0(R1),X'C4'
         BE    SUCPAC
         WTO   TEXT='INVALID PAC' * Invalid PAC at beginning of MI0ACC
         EXITC
SUCPAC   EQU   *

         A     R1,1     * Next char

         
* Loops the number of input chars
LOOP     EQU   *
         
* Check for forward slash
         CLI   0(R1),X'61'  * EBCDIC forward slash
         BNE   SLASHES    * skips increment
         A     R2,1		   * Increment forward slash count
SLASHES  EQU   *
         
* Check for comma
         CLI   0(R1),X'6B' * EBCDIC forward slash
         BNE   COMMAS    * skips increment count of comma
         A     R3,1		* Increment forward slash count
COMMAS   EQU   *
         
* Check for open paren
         CLI   0(R1),X'4D'    * EBCDIC open parenthesis
         BE	   OPAREN
         C	   R4,0           * Check if first open parenthesis found
         BE	   PARENS       * skip close check if open not found first

* Check for close paren
         CLI   0(R1),X'5D'    * EBCDIC close parenthesis
         BNE   PARENS         * skips increment
OPAREN   EQU   *
         A	   R4,1
PARENS   EQU   *
         
         A     R1,1		* Increment address for next char
         BCT   R0,LOOP

* Validate number of each special char
         C     R2,6  * 6 SLASH
         BE    SUCSLASH
         WTOPC TEXT='NOT 6 FORWARD SLASHES'
         EXITC
SUCSLASH EQU   *
         
         C     R3,3  * 3 COMMA
         BE    SUCCOMMA
         WTOPC TEXT='NOT 3 COMMAS'
         EXITC
SUCCOMMA EQU   *
         

         C     R4,2  * 2 PARENS
         BE    SUCPAREN
         WTOPC TEXT='NOT OPEN AND CLOSE PAREN PAIR'
         EXITC
SUCPAREN EQU   *


* R2, R3, R4 FREE
         XR    R2,R2
         XR    R3,R3
         XR    R4,R4

* Load entry input into data level memory
         USING STUDENT,R7      * loads R7 with STUDENT DSECT
         GETCC D1,L1       * data level 1 with 381 bytes
         L     R7,CE1CR1   * assign data level to R7


* Validate field lengths
* Name
         LA	   R1,MI0ACC+2      * input name start address into R1
         LR    R2,R1            * copy register, as R2 will have output
         LA    R3,15(R1)      * max num bytes forward as last char
         XR    R0,R0
         IC    R0,X'61'    * fslash ebcdic
         SRST  R2,R3       * R2 now holds address of next fslash

         LR    R3,R2       * Load last address to R3
         SR    R3,R1       * sub first and last addr to get length
         
         C     R3,15       * Check if name length over 15 bytes
         BNH   NAMLEN
         WTOPC TEXT='NAME OVER 15 BYTES'
         EXITC
NAMLEN   EQU   *

         LR    R4,R1       * current iteration address
NAMLOOP  EQU   *           * loops through chars and validates
         CLI   0(R4),X'C1'       * compare with EBCDIC A
         BNL   NAMLOW              * Not lower than A
         WTOPC TEXT='LOW CHAR'
         EXITC
NAMLOW   EQU   *
         CLI   0(R4),X'E9'       * compare with EBCDIC Z
         BNH   NAMHIGH           * Not higher than Z
         CLI   0(R4),X'40'       * compare with EBCDIC blank
         BE    NAMHIGH           * pass if blank char
         WTOPC TEXT='HIGH CHAR'
         EXITC
NAMHIGH  EQU   *
         A     R4,1              * increment to next char addr
         BCT   R3,NAMLOOP

* R1 starting address
* R2 end address of fslash
* R0,R3,R4,R5,R6 free
         LR    R0,R2       * R0 now has end addr of fslash, R2 free

         LA    R2,STUNAM   * addr of DL1 CBRW for name
         LA    R3,15       * number of bytes max for name
         
         LR    R4,R1       * actual name start addr
         
         LR    R5,R0       * load last fslash
         S     R5,1        * one char before fslash
         SR    R5,R1       * number of bytes of actual name
         MVI   R5,X'40'    * fill char is blank

         MVCL  R2,R4       * Moved name into DL1 CBRW address


* Age
* R0 starting fslash
* R1 free, but needs new ending fslash
* R2-R6 free
         LR    R1,R0       * incremented addr
* even-odd pairs for MVCL
         LA    R2,STUAGE   * destination addr in DL1 CBRW
         LA    R3,2        * max number of bytes/chars

         LR    R4,R0
         A     R4,1        * starting char addr

AGELOOP  EQU   *
         A     R1,1     * increment char addr

         CLI   0(R1),X'F0'       * compare with EBCDIC 0
         BNL   AGELOW              * Not lower than 0
         WTOPC TEXT='LOW CHAR'
         EXITC
AGELOW   EQU   *

         CLI   0(R1),X'F9'       * compare with EBCDIC 9
         BNH   AGEHIGH           * Not higher than 9
         WTOPC TEXT='HIGH CHAR'
         EXITC
AGEHIGH  EQU   *
         
         CLI   0(R1),X'61'  * EBCDIC forward slash
         BNE   AGELOOP    * Loops if no ending fslash
* R1 now has ending fslash addr
* Calculate number of actual bytes of age
         LR    R5,R1
         S     R5,2
         S     R5,R0       * actual bytes of age

* verify if 2 or under bytes
         C     R5,2       * Check if age length over 2 bytes
         BNH   AGELEN
         WTOPC TEXT='AGE OVER 2 BYTES'
         EXITC
AGELEN   EQU   *

         MVI   R5,X'40'    * fill char is blank

         MVCL  R2,R4       * Moved name into DL1 CBRW address


* Phone number
* R1 starting fslash
* R0 free, but needs new ending fslash
* R2-R6 free
         LR    R0,R1       * copy addr to R0, R1 incremented addr
* even-odd pairs for MVCL
         LA    R2,STUTEL   * destination addr in DL1 CBRW
         LA    R3,10        * max number of bytes/chars

         LR    R4,R0
         A     R4,1        * starting char addr

TELLOOP  EQU   *
         A     R1,1     * increment char addr

         CLI   0(R1),X'F0'       * compare with EBCDIC 0
         BNL   TELLOW              * Not lower than 0
         WTOPC TEXT='LOW CHAR'
         EXITC
TELLOW   EQU   *

         CLI   0(R1),X'F9'       * compare with EBCDIC 9
         BNH   TELHIGH           * Not higher than 9
         WTOPC TEXT='HIGH CHAR'
         EXITC
TELHIGH  EQU   *
         
         CLI   0(R1),X'61'  * EBCDIC forward slash
         BNE   TELLOOP    * Loops if no ending fslash
* R1 now has ending fslash addr
* Calculate number of actual bytes of tel
         LR    R5,R1
         S     R5,2
         S     R5,R0       * actual bytes of tel

* verify if 2 or under bytes
         C     R5,10       * Check if tel length over 10 bytes
         BNH   TELLEN
         WTOPC TEXT='TEL OVER 10 BYTES'
         EXITC
TELLEN   EQU   *

         MVI   R5,X'40'    * fill char is blank

         MVCL  R2,R4       * Moved name into DL1 CBRW address


* Address
* R1 starting fslash
* R0 free, but needs new ending fslash
* R2-R6 free
         LR    R0,R1       * copy addr to R0, R1 incremented addr
* even-odd pairs for MVCL
         LA    R2,STUADR   * destination addr in DL1 CBRW
         LA    R3,40        * max number of bytes/chars

         LR    R4,R0
         A     R4,1        * starting ( addr

         CLI   0(R4),X'4D'    * EBCDIC for (
         BE    ADROPAR        * check if ( is present
         WTOPC TEXT='ADR OPEN PARENTHESES MISSING'
         EXITC
ADROPAR  EQU   *
         

ADRLOOP  EQU   *
         A     R1,1     * increment char addr

         CLI   0(R1),X'E9'       * compare with EBCDIC Z
         BNL   ADRALP             * Not lower than Z
         CLI   0(R1),X'C1'       * compare with EBCDIC A
         BNL   ADRALP            * Not lower than A
         WTOPC TEXT='ADDRESS IS NOT IN ALPHABET'
         EXITC
ADRALP   EQU   *

         CLI   0(R1),X'F9'       * compare with EBCDIC 9
         BNL   ADRNUM             * Not lower than 9
         CLI   0(R1),X'F1'       * compare with EBCDIC 1
         BNL   ADRNUM            * Not lower than 1
         WTOPC TEXT='ADDRESS IS NOT NUMBER'
         EXITC
ADRNUM   EQU   *
         
         CLI   0(R1),X'40'       * compare with EBCDIC blank
         BE    ADRSPL           * equals blank
         CLI   0(R1),X'60'       * compare with EBCDIC /
         BE    ADRSPL           * equals /
         CLI   0(R1),X'61'       * compare with EBCDIC -
         BE    ADRSPL           * equals -
         WTOPC TEXT='ADR INVALID CHAR'
         EXITC
ADRSPL   EQU   *
         
         CLI   0(R1),X'5D'  * EBCDIC )
         BNE   ADRLOOP    * Loops if no ending ) close parentheses
* R1 now has ending ) addr
* Calculate number of actual bytes
         LR    R5,R1
         S     R5,R0       * actual bytes
         S     R5,3        * deduct start and end // and start (

* verify bytes
         C     R5,R3       * Check if length over 
         BNH   ADRLEN
         WTOPC TEXT='ADR OVER 40 BYTES'
         EXITC
ADRLEN   EQU   *

         MVI   R5,X'40'    * fill char is blank
         A     R4,1        * at starting char instead of (

         MVCL  R2,R4       * Moved name into DL1 CBRW address


* Course
         A     R1,1  * R1 starting fslash
* R0 free, but needs new ending fslash
* R2-R6 free
         LR    R0,R1       * incremented addr
* even-odd pairs for MVCL
         LA    R2,STUCRS   * destination addr in DL1 CBRW
         LA    R3,3        * max number of bytes/chars

         LR    R4,R0
         A     R4,1        * starting char addr
         LA    R5,3        * number of bytes

CRSLOOP  EQU   *
         A     R1,1     * increment char addr

         CLI   0(R1),X'C1'       * compare with EBCDIC A
         BNL   CRSLOW              * Not lower than A
         WTOPC TEXT='LOW CHAR'
         EXITC
CRSLOW   EQU   *
         CLI   0(R1),X'E9'       * compare with EBCDIC Z
         BNH   CRSHIGH           * Not higher than Z
         WTOPC TEXT='HIGH CHAR'
         EXITC
CRSHIGH  EQU   *
         
         CLI   0(R1),X'61'  * EBCDIC forward slash
         BNE   CRSLOOP    * Loops if no ending fslash
* R1 now has ending fslash addr
* Calculate number of actual bytes
         LR    R5,R1
         S     R5,2
         S     R5,R0       * actual bytes

* verify if 2 or under bytes
         C     R5,3       * Check if length equal to 3 bytes
         BE    CRSLEN
         WTOPC TEXT='AGE OVER 2 BYTES'
         EXITC
CRSLEN   EQU   *

         MVI   R5,X'40'    * fill char is blank
* fill char not needed as number of bytes should equal 3 at all times
         MVCL  R2,R4       * Moved name into DL1 CBRW address

* Subjects
* R1 starting fslash
* RO free, but needs next end fslash
* R2-R6 free

* SBJ1
* find different subjects and assign to dsect memory
* MVCL prep, even-odd pairs
* R2, R3
         LA    R2,STUSBJ1
         LA    R3,20

* R4
         LR    R4,R1    * assign with starting slash
         A     R4,1     * starting char
         
* R5 calculate actual bytes
         LR    R5,R4
         A     R5,30    * max bytes of subject plus overhead
         XR    R0,R0
         IC    R0,X'6B' * ebcdic comma
         SRST  R5,R4    * R5 holds address of comma
         LR    R1,R5    * save comma for following SBJ2
         S     R5,1
         SR    R5,R4    * R5 has number of bytes the subject holds

         C     R5,20    * check if bytes is over 20 bytes or chars
         BE    SBJ1CHK
         WTOPC TEXT='SBJ1 INPUT LENGTH IS OVER 20 CHARS'
SBJ1CHK  EQU   *

         MVI   R5,X'40' * fill blank char

         MVCL  R2,R4    * STUSBJ1 now holds input subject value

* SBJ2
* find different subjects and assign to dsect memory
* MVCL prep, even-odd pairs
* R2, R3
         LA    R2,STUSBJ2
         LA    R3,20

* R4
         LR    R4,R1    * assign with starting slash
         A     R4,1     * starting char
         
* R5, calculate actual bytes
         LR    R5,R4
         A     R5,30    * max bytes of subject plus overhead
         XR    R0,R0
         IC    R0,X'6B' * ebcdic comma
         SRST  R5,R4    * R5 holds address of comma
         LR    R1,R5    * save comma for following SBJ3
         S     R5,1
         SR    R5,R4    * R5 has number of bytes the subject holds

         C     R5,20    * check if bytes is over 20 bytes or chars
         BE    SBJ2CHK
         WTOPC TEXT='SBJ2 INPUT LENGTH IS OVER 20 CHARS'
SBJ2CHK  EQU   *

         MVI   R5,X'40' * fill blank char

         MVCL  R2,R4    * STUSBJ2 now holds input subject value

* SBJ3
* find different subjects and assign to dsect memory
* MVCL prep, even-odd pairs
* R2, R3
         LA    R2,STUSBJ3
         LA    R3,20

* R4 
         LR    R4,R1    * assign with starting slash
         A     R4,1     * starting char
         
* R5, calculate actual bytes
         LR    R5,R4
         A     R5,30    * max bytes of subject plus overhead
         XR    R0,R0
         IC    R0,X'6B' * ebcdic comma
         SRST  R5,R4    * R5 holds address of comma
         LR    R1,R5    * save comma for following SBJ4
         S     R5,1
         SR    R5,R4    * R5 has number of bytes the subject holds

         C     R5,20    * check if bytes is over 20 bytes or chars
         BE    SBJ3CHK
         WTOPC TEXT='SB3 INPUT LENGTH IS OVER 20 CHARS'
SBJ3CHK  EQU   *

         MVI   R5,X'40' * fill blank char

         MVCL  R2,R4    * STUSBJ3 now holds input subject value

* SBJ4
* find different subjects and assign to dsect memory
* MVCL prep, even-odd pairs
* R2, R3
         LA    R2,STUSBJ4
         LA    R3,20

* R4
         LR    R4,R1    * assign with starting slash
         A     R4,1     * starting char
         
* R5, calculate actual bytes
         LR    R5,R4
         A     R5,30    * max bytes of subject plus overhead
         XR    R0,R0
         IC    R0,X'6B' * ebcdic comma
         SRST  R5,R4    * R5 holds address of comma
         S     R5,1
         SR    R5,R4    * R5 has number of bytes the subject holds

         C     R5,20    * check if bytes is over 20 bytes or chars
         BE    SBJ4CHK
         WTOPC TEXT='SBJ4 INPUT LENGTH IS OVER 20 CHARS'
SBJ4CHK  EQU   *

         MVI   R5,X'40' * fill blank char

         MVCL  R2,R4    * STUSBJ3 now holds input subject value

* Completed storing all inputs
* Now, validate CRS with SBJ combinations

         LA    R0,4        * iterate count
         LA    R1,STUSBJ4 * dynamic address for SBJs

* check if CME, SCI, or ART only
         CLC   STUCRS,=C'CME'
         BE    CRSCME
         CLC   STUCRS,=C'SCI'
         BE    CRSSCI
         CLC   STUCRS,=C'ART'
         BE    CRSART
         WTOPC TEXT='CRS NOT CME, SCI, OR ART'  * Error
         EXITC

* Logic for CME, loop
CRSCME   EQU   *
         CLC   R1,=C'BUSINESS LAW'
         BE    CMEFND
         CLC   R1,=C'ECONOMICS'
         BE    CMEFND
         CLC   R1,=C'MATHS'
         BE    CMEFND
         CLC   R1,=C'TALLY'
         BE    CMEFND
         CLC   R1,=C'LANGUAGE'
         BE    CMEFND
         CLC   R1,=C'ACCOUNTANCY'
         BE    CMEFND
         CLC   R1,=C'BUSINESS STUDIES'
         BE    CMEFND
         WTOPC TEXT='INVALD SBJ AND CME COMBINATION'  * Error
         EXITC
CMEFND   EQU   *

         C     R0,3
         BNE   ITER3
         LA    R1,STUSBJ3
ITER3    EQU   *

         C     R0,2
         BNE   ITER2
         LA    R1,STUSBJ2
ITER2    EQU   *

         C     R0,1
         BNE   ITER1
         LA    R1,STUSBJ1
ITER1    EQU   *

         BCT   R0,CRSCME


CRSSCI   EQU   *
         CLC   R1,=C'MATHS'
         BE    SCIFND
         CLC   R1,=C'PHYSICS'
         BE    SCIFND
         CLC   R1,=C'ECONOMICS'
         BE    SCIFND
         CLC   R1,=C'BIOLOGY'
         BE    SCIFND
         CLC   R1,=C'INFORMATION TECHNOLO'   * Information Technology
         BE    SCIFND                        * too long, over 20 bytes
         CLC   R1,=C'LANGUAGE'
         BE    SCIFND
         WTOPC TEXT='INVALD SBJ AND SCI COMBINATION'  * Error
         EXITC
SCIFND   EQU   *

         C     R0,3
         BNE   ITER3
         LA    R1,STUSBJ3
ITER3    EQU   *

         C     R0,2
         BNE   ITER2
         LA    R1,STUSBJ2
ITER2    EQU   *

         C     R0,1
         BNE   ITER1
         LA    R1,STUSBJ1
ITER1    EQU   *

         BCT   R0,CRSSCI

CRSART   EQU   *
         CLC   R1,=C'HISTORY'
         BE    ARTFND
         CLC   R1,=C'SOCIOLOGY'
         BE    ARTFND
         CLC   R1,=C'GEOGRAPHY'
         BE    ARTFND
         CLC   R1,=C'FINE ARTS'
         BE    ARTFND
         CLC   R1,=C'MUSIC'
         BE    ARTFND
         CLC   R1,=C'POLITICAL SCIENCE'
         BE    ARTFND
         CLC   R1,=C'COMPUTER SCIENCE'
         BE    ARTFND
         CLC   R1,=C'REGIONAL LANGUAGE'
         BE    ARTFND
         CLC   R1,=C'PHYSICAL EDUCATION'
         BE    ARTFND
         WTOPC TEXT='INVALD SBJ AND ART COMBINATION'  * Error
         EXITC
ARTFND   EQU   *

         C     R0,3
         BNE   ITER3
         LA    R1,STUSBJ3
ITER3    EQU   *

         C     R0,2
         BNE   ITER2
         LA    R1,STUSBJ2
ITER2    EQU   *

         C     R0,1
         BNE   ITER1
         LA    R1,STUSBJ1
ITER1    EQU   *

         BCT   R0,CRSART


* ENTRC to next program with A, U, *, D functionalities

         LA    R1,MI0ACC

* Add
         CLI   0(R1),X'C1'    * EBCDIC for A
         BNE   ADD            * Skip
         ENTRC BBBB
ADD      EQU   *

* Update
         CLI   0(R1),X'E4'
         BNE   UPD
         ENTRC BBBB
UPD      EQU   *

* Display
         CLI   0(R1),X'5C'
         BNE   DISP
         ENTRC CCCC
DISP     EQU   *

* Delete
         CLI   0(R1),X'C4'
         BNE   DEL
         ENTRC DDDD
DEL      EQU   *


* SUCCESS
         WTOPC TEXT='EXECUTED SUCCESSFULLY'
         EXITC 

         FINIS