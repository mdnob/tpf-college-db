         BEGIN NAME=CCCC

* Load entry input into data level memory
         DROP                       * drops registers
         ADDAT REG=R5               * loads with STUDENT DSECT
         L     R5,CE1CR1            * assign data level

* Fixed file      
* Ordinal num based on CRS
         CLC   STUCRS,=C'CME'
         BNE   CMEPAS
         LA    R0,0                 * Load ordinal number
CMEPAS   EQU   *
         CLC   STUCRS,=C'SCI'
         BNE   SCIPAS
         LA    R0,1                 * Load ordinal number
SCIPAS   EQU   *
         CLC   STUCRS,=C'ART'
         BNE   ARTPAS
         LA    R0,2                 * Load ordinal number
ARTPAS   EQU   *
         LA    R6,=CL8'#ABCDEFG'    * Symbolic record type
         LA    R7,CE1FA2            * Load address of FARW D2
         ENTRC FACS                 * Call FACS
         LTR   R0,R0                * Test for Error return
         BZ    EXCEPT
         

* Save appropriate field to compare
         CLC   STUNUM,=X'0000'
         BNE   NUMPAS
         LA    R3,STUNAM
         B     NAMPAS
NUMPAS   EQU   *
         LA    R3,STUNUM
NAMPAS   EQU   *


* Find pool file in fixed file
         LA    R1,16(R7)            * skip header section
FNDPOL   EQU   *
         CLC   R1,=X'00000000'      * find empty spot
         BNE   POLFND               * not empty
         A     R1,4                 * next displacement
         B     FNDPOL
POLFND   EQU   *
         LA    R4,CE1FA3            * addr FARW D3
         LA    R4,0(R1)             * load pool file into FARW
         FINWC D3,EXCEPT            * FARW to CBRW, no hold
         L     R5,CE1CR3            * context D3 for STUDENT

* NAM or NUM
         CLI   0(R3),X'F0'          * EBCDIC 0
         BL    NAMCHK
         B     NUMCHK
NAMCHK   EQU   *
         CLC   0(15,R3),STUNAM
         BE    FOUNDP
         B     NXTPOL
NUMCHK   EQU   *
         CLC   0(2,R3),STUNUM
         BE    FOUNDP
         B     NXTPOL
NXTPOL   EQU   *
         A     R1,4                 * next pool file addr
         B     FNDPOL               * repeat
FOUNDP   EQU   *

         XPRNT STUOUT,L'STUOUT      * Print STUDENT output
         EXITC                      * End program

EXCEPT   EQU   *
         WTOPC TEXT='UNABLE TO OPEN FILE'
         EXITC

         FINIS CCCC