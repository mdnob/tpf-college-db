         BEGIN NAME=BBBB
* R7: D1 CBRW contains STUDENT DSECT data       
         LR    R15,R7                * CBRW D1 moved

* Add
* Ordinal numbers based on department or CRS
* CME: 0, SCI: 1, ART: 2
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
         BZ    EXCEPT               * Branch to error return

         GETFC D3,ID=C'AB'
         LA    R6,CE1FA3
         FIWHC D3,EXCEPT
         LA    R2,CE1CR3+16

* R2: CBRW D3, pool file copy 16th displacement
* R6: FARW D3, pool file
* R7: FARW D2, fixed file
* R15: CBRW D1, STUDENT DSECT
         LA    R3,Y(L'STUOUT)       * bytes to move
         LR    R5,R3                * bytes to move
         LA    R4,STUOUT            * STUDENT data
         MVCL  R2,R4                * move data to held file copy CBRW
         FILUC D3                   * CBRW to FARW, file unheld, cb rel

EXCEPT   EQU   *
         WTOPC TEXT='UNABLE TO OPEN FILE'
         EXITC

         FINIS