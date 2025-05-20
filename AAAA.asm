         BEGIN
* modularize program
* basr to repeated work
* Student DSECT
STUDENT  DSECT
STUNUM   DS    XL2      * roll number
STUNAM   DS    CL15     * full name
STUAGE   DS    XL2      * 2 digit age
STUTEL   DS    XL10     * phone number
STUADR   DS    CL40     * mailing address
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

* Load entry input into data level memory
         USING STUDENT,R7  * loads R7 with STUDENT DSECT
         GETCC D1,L1       * data level 1 with 381 bytes
         L     R7,CE1CR1   * assign data level to R7


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
SPCLOP     EQU   *
         
* Check for forward slash
         CLI   0(R1),X'61'    * EBCDIC forward slash
         BNE   SLASHES        * skips increment
         A     R2,1		      * Increment forward slash count
SLASHES  EQU   *
         
* Check for comma
         CLI   0(R1),X'6B' * EBCDIC forward slash
         BNE   COMMAS      * skips increment count of comma
         A     R3,1        * Increment forward slash count
COMMAS   EQU   *
         
* Check for open paren
         CLI   0(R1),X'4D'    * EBCDIC open parenthesis
         BE    OPAREN
         C     R4,0           * Check if first open parenthesis found
         BE    PARENS         * skip cpar check if opar not found first

* Check for close paren
         CLI   0(R1),X'5D'    * EBCDIC close parenthesis
         BNE   PARENS         * skips increment
OPAREN   EQU   *
         A     R4,1
PARENS   EQU   *
         
         A     R1,1           * Increment address for next char
         BCT   R0,SPCLOP

         LA    R1,MI0ACC      * reset to start entry

* Branch to * and D entry validation, as it requires different format
         CLI   0(R1),X'C1' * A
         BE    AUPASS
         CLI   0(R1),X'E4' * U
         BE    AUPASS
         B     DDPASS      * Branch to * and D entry validation
AUPASS   EQU   *
         
* Check number of special chars of at least these registers
         LA    R12,6
         XR    R13,R13
         XR    R14,R14
         CLI   0(R1),X'E4'
         BE    UPZERO      * UPDATE HAVE 0 COMMA OR PARENTHESES
         LA    R13,3
         LA    R14,2
UPZERO   EQU   *
         BAS   R15,SPCSEC  * Branch to special char section

* Update only
         CLI   0(R1),X'E4'
         A     R1,2        * next section start char
         BNE   UPSTRT

* Course
* Alpha section subroutine
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
         LA    R2,STUSPR   * Store into different spare location
         LA    R3,3
         BAS   R15,ALPSEC  * CRS validated and stored
* R1: next section star char

* Roll number
* Number section
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
         LA    R2,STUNUM
         LA    R3,2
         BAS   R15,NUMSEC  * NUM validated and stored
* R1: next section star char

UPSTRT   EQU   *

* Add and Update now

* Name
* Alpha section subroutine
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
         LA    R2,STUNAM
         LA    R3,15
         BAS   R15,ALPSEC  * NAM validated and stored
* R1: next section star char

* Age
* Number section
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
         LA    R2,STUAGE
         LA    R3,2
         BAS   R15,NUMSEC  * AGE validated and stored
* R1: next section star char

* Phone number
* Number section
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
         LA    R2,STUTEL
         LA    R3,10
         BAS   R15,NUMSEC  * TEL validated and stored
* R1: next section star char

* Address
* Address section subroutine
* R1: starting ( char
* R15: branch back
         BAS   R15,ADRSEC  * ADR validated and stored
  
* Course
* Alpha section subroutine
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
         LA    R2,STUCRS
         LA    R3,3
         BAS   R15,ALPSEC  * CRS validated and stored
* R1: next section star char

* Subjects
* Alpha section subroutine
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
* SBJ1
         LA    R2,STUSBJ1
         LA    R3,20
         BAS   R15,ALPSEC  * SBJ validated and stored
* R1: next section star char
* SBJ2
         LA    R2,STUSBJ2
         BAS   R15,ALPSEC  * SBJ validated and stored
* R1: next section star char
* SBJ3
         LA    R2,STUSBJ3
         BAS   R15,ALPSEC  * SBJ validated and stored
* R1: next section star char
* SBJ4
         LA    R2,STUSBJ4
         BAS   R15,ALPSEC  * SBJ validated and stored
* R1: next section star char
* R2: STUSBJ4
         LA    R0,3

* CRS and SBJ combination check
* Check CME, SCI, or ART
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
         CLC   R2,=C'BUSINESS LAW'
         BE    CMEFND
         CLC   R2,=C'ECONOMICS'
         BE    CMEFND
         CLC   R2,=C'MATHS'
         BE    CMEFND
         CLC   R2,=C'TALLY'
         BE    CMEFND
         CLC   R2,=C'LANGUAGE'
         BE    CMEFND
         CLC   R2,=C'ACCOUNTANCY'
         BE    CMEFND
         CLC   R2,=C'BUSINESS STUDIES'
         BE    CMEFND
         WTOPC TEXT='INVALD SBJ AND CME COMBINATION'  * Error
         EXITC
CMEFND   EQU   *

         BAS   R15,SBJSEC     * Changes subject based on iteration
         BCT   R0,CRSCME

CRSSCI   EQU   *
         CLC   R2,=C'MATHS'
         BE    SCIFND
         CLC   R2,=C'PHYSICS'
         BE    SCIFND
         CLC   R2,=C'ECONOMICS'
         BE    SCIFND
         CLC   R2,=C'BIOLOGY'
         BE    SCIFND
         CLC   R2,=C'INFORMATION TECHNOLO'   * Information Technology
         BE    SCIFND                        * too long, over 20 bytes
         CLC   R2,=C'LANGUAGE'
         BE    SCIFND
         WTOPC TEXT='INVALD SBJ AND SCI COMBINATION'  * Error
         EXITC
SCIFND   EQU   *

         BAS   R15,SBJSEC     * Changes subject based on iteration
         BCT   R0,CRSSCI

CRSART   EQU   *
         CLC   R2,=C'HISTORY'
         BE    ARTFND
         CLC   R2,=C'SOCIOLOGY'
         BE    ARTFND
         CLC   R2,=C'GEOGRAPHY'
         BE    ARTFND
         CLC   R2,=C'FINE ARTS'
         BE    ARTFND
         CLC   R2,=C'MUSIC'
         BE    ARTFND
         CLC   R2,=C'POLITICAL SCIENCE'
         BE    ARTFND
         CLC   R2,=C'COMPUTER SCIENCE'
         BE    ARTFND
         CLC   R2,=C'REGIONAL LANGUAGE'
         BE    ARTFND
         CLC   R2,=C'PHYSICAL EDUCATION'
         BE    ARTFND
         WTOPC TEXT='INVALD SBJ AND ART COMBINATION'  * Error
         EXITC
ARTFND   EQU   *

         BAS   R15,SBJSEC     * Changes subject based on iteration
         BCT   R0,CRSART

         B     LASSEC         * To last section


* Delete and Display entry validation
DDPASS   EQU   *
* Check number of special chars of at least these registers
         LA    R12,2
         XR    R13,R13
         XR    R14,R14
         BAS   R15,SPCSEC  * Branch to special char section

         LA    R1,2        * next section start char

* Course
* Alpha section subroutine
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
         LA    R2,STUCRS
         LA    R3,3
         BAS   R15,ALPSEC  * CRS validated and stored
* R1: next section star char

* CME, SCI, or ART only
         CLC   STUCRS,=C'CME'
         BE    DDCRS
         CLC   STUCRS,=C'SCI'
         BE    DDCRS
         CLC   STUCRS,=C'ART'
         BE    DDCRS
         WTOPC TEXT='CRS NOT CME, SCI, OR ART'
         EXITC
DDCRS    EQU   *

* NUM or NAM
* alpha or num, go to NAM if char
         CLI   0(R1),X'F0'    * EBCDIC 0
         BL    NAMPAS
         B     NUMPAS

* Name
* Alpha section subroutine
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
NAMPAS   EQU   *
         LA    R2,STUNAM
         LA    R3,15
         BAS   R15,ALPSEC  * NAM validated and stored
* R1: next section star char
         B     LASSEC

* Roll number
* Number section
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
NUMPAS   EQU   *
         LA    R2,STUNUM
         LA    R3,2
         BAS   R15,NUMSEC  * NUM validated and stored
* R1: next section star char

* Last section of code
* goes to next program
LASSEC   EQU   *

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

* Reused code sections

* Special chars
* / , () count
* R2: used slashes
* R3: used commas
* R4: used parentheses
* R12: slash count
* R13: comma count
* R14: parentheses count
SPCSEC   EQU   *
         C     R2,R12
         BH    SPCSLA
         WTOPC TEXT='MISSING SLASHES'
         EXITC
SPCSLA   EQU   *
         
         C     R3,R13
         BH    SPCCOM
         WTOPC TEXT='MISSING COMMAS'
         EXITC
SPCCOM   EQU   *

         C     R4,R14
         BH    SPCPAR
         WTOPC TEXT='MISSING PARENTHESES PAIR'
         EXITC
SPCPAR   EQU   *


* Alpha with space
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
ALPSEC   EQU   *
         LR    R4,R1       * save starting char

ALPLOP   EQU   *           * loops through chars and validates

         CLI   0(R1),X'C1' * compare with EBCDIC A
         BNL   ALPLOW      * Not lower than A
         WTOPC TEXT='LOW CHAR'
         EXITC
ALPLOW   EQU   *

         CLI   0(R1),X'E9'       * compare with EBCDIC Z
         BNH   ALPHGH            * Not higher than Z
         CLI   0(R1),X'40'       * compare with EBCDIC blank
         BE    ALPHGH            * pass if blank char
         WTOPC TEXT='HIGH CHAR'
         EXITC
ALPHGH   EQU   *

         A     R1,1           * next char increment
         CLI   0(R1),X'61'    * EBCDIC /
         BE    ALPPAS
         CLI   0(R1),X'6B'    * EBCDIC ,
         BE    ALPPAS
         B     ALPLOP
ALPPAS   EQU   *

* R1: end /
* R4: start char
         LR    R5,R4       * last addr
         SR    R5,R1       * sub first and last addr
         S     R5,1        * exclude end slash
         
         C     R5,R3
         BNH   ALPLEN
         WTOPC TEXT='CHARS OVER MAX BYTES'
         EXITC
ALPLEN   EQU   *

* R5: used bytes         
         MVI   R5,X'40'    * blank fill char
         MVCL  R2,R4
         A     R1,1        * next section start char
         BR    R15         * go back to mainline


* Numbers
* R1: starting char
* R2: DSECT location
* R3: max bytes
* R15: branch back
NUMSEC   EQU   *

         LR    R4,R1             * save starting char addr

NUMLOP   EQU   *

         CLI   0(R1),X'F0'       * EBCDIC 0
         BNL   NUMLOW
         WTOPC TEXT='LOW CHAR'
         EXITC
NUMLOW   EQU   *

         CLI   0(R1),X'F9'       * EBCDIC 9
         BNH   NUMHGH
         WTOPC TEXT='HIGH CHAR'
         EXITC
NUMHGH   EQU   *

         A     R1,1              * next char
         CLI   0(R1),X'61'       * EBCDIC /
         BE    NUMPAS
         CLI   0(R1),X'60'       * EBCDIC -
         BE    NUMPAS
         B     NUMLOP
NUMPAS   EQU   *                 * ends loop

* R1: end slash char addr
* R4: starting char
         LR    R5,R4
         SR    R5,R1
         C     R5,R3
         BNH   NUMLEN
         WTOPC TEXT='NUMBERS OVER MAX BYTES'
         EXITC
NUMLEN   EQU   *

* R5: number of used bytes
         MVI   R5,X'40'    * blank fill char
         MVCL  R2,R4
         A     R1,1        * next section start char
         BR    R15


* Address
* R1: starting ( char
* R15: branch back
ADRSEC   EQU   *
         CLI   0(R1),X'4D'    * EBCDIC (
         BE    ADROPR
         WTOPC TEXT='ADR OPEN PARENTHESES MISSING'
         EXITC
ADROPR   EQU   *

         LR    R4,R1
         LA    R2,STUADR
         LA    R3,40

ADRLOP   EQU   *
         A     R1,1     * increment char addr

         CLI   0(R1),X'E9'       * EBCDIC Z
         BNL   ADRALP
         CLI   0(R1),X'C1'       * EBCDIC A
         BNL   ADRALP
         WTOPC TEXT='ADDRESS IS NOT IN ALPHABET'
         EXITC
ADRALP   EQU   *

         CLI   0(R1),X'F9'       * EBCDIC 9
         BNL   ADRNUM
         CLI   0(R1),X'F1'       * EBCDIC 1
         BNL   ADRNUM
         WTOPC TEXT='ADDRESS IS NOT NUMBER'
         EXITC
ADRNUM   EQU   *
         
         CLI   0(R1),X'40'      * EBCDIC blank
         BE    ADRSPL
         CLI   0(R1),X'60'      * EBCDIC /
         BE    ADRSPL
         CLI   0(R1),X'61'      * EBCDIC -
         BE    ADRSPL
         WTOPC TEXT='ADR INVALID CHAR'
         EXITC
ADRSPL   EQU   *
         
         CLI   0(R1),X'5D'    * EBCDIC )
         BNE   ADRLOP         * Loops if no ending ) close parentheses

* R1: end ) char
* R4: start ( char
         LR    R5,R1
         A     R4,1        * start char
         S     R5,R4
         S     R5,1        * deduct )

         C     R5,R3
         BNH   ADRLEN
         WTOPC TEXT='ADR OVER 40 BYTES'
         EXITC
ADRLEN   EQU   *

         MVI   R5,X'40'    * fill char
         MVCL  R2,R4
         A     R1,2        * next section start char
         BR    R15

* Subject count
* R0: iteration
* R2: STUSBJ#
* R15: branch back
SBJSEC   EQU   *
         C     R0,3
         BNE   ITER3
         LA    R2,STUSBJ3
ITER3    EQU   *

         C     R0,2
         BNE   ITER2
         LA    R2,STUSBJ2
ITER2    EQU   *

         C     R0,1
         BNE   ITER1
         LA    R2,STUSBJ1
ITER1    EQU   *
         BR    R15

         FINIS