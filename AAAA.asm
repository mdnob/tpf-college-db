         BEGIN

* Student DSECT
STUDENT  DSECT
STUNUM   DS    XL2      * roll number
STUNAME	 DS	   CL15     * full name
STUAGE   DS    XL2      * 2 digit age
STUTEL   DS	   XL10     * phone number
STUADDR	 DS    CL40     * mailing address
STUCRSE  DS    CL3      * major
STUSUBJ1 DS    CL20     * subjects
STUSUBJ2 DS    CL20
STUSUBJ3 DS    CL20
STUSUBJ4 DS    CL20
         END

         LA	   R1,MI0ACC      * input start address into R1
         LA	   R0,MI0CCT	  * Total number of bytes char 160
         XR	   R2,R2	   * Count for forward slashes, initialize to 0
         XR	   R3,R3		* Count for comma
         XR	   R4,R4		* Count for parentheses
         XR    R5,R5        * PAC


* Check PAC
* A, U, *, D corresponds with 1, 2, 3, 4
* Add
         CLI   0(R1),X'C1'    * EBCDIC for A
         BNE   ADD            * Skip
         A     R5,1
ADD      EQU   *
* Update
         CLI   0(R1),X'E4'
         BNE   UPD
         A     R5,2
UPD      EQU   *
* Display
         CLI   0(R1),X'5C'
         BNE   DISP
         A     R5,3
DISP     EQU   *
* Delete
         CLI   0(R1),X'C4'
         BNE   DEL
         A     R5,4
DEL      EQU   *

* Check PAC
         C     R1,0
         BNE   SUCPAC   * Valid PAC value not found
         WTO   TEXT='INVALID PAC' * Invalid PAC at beginning of MI0ACC
         EXITC
SUCPAC   EQU   *

         A     R1,1     * Next char

         
* Loops the number of input chars
LOOP     EQU   *
         
* Check for forward slash
         CLI   0(R1),X'61'  * EBCDIC forward slash
         BNE   SLASH    * skips increment
         A     R2,1		   * Increment forward slash count
SLASH    EQU   *
         
* Check for comma
         CLI   0(R1),X'6B' * EBCDIC forward slash
         BNE   COMMA    * skips increment count of comma
         A     R3,1		* Increment forward slash count
COMMA    EQU   *
         
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
         LR    R0,R2

         LA    R2,STUNAME
         LA    R3,15
         
         LR    R4,R1
         
         LR    R5,R2
         SR    R5,R1
         MVI   R5,X'40'

         MVCL  R2,R4
* Age

         MVC   TEMPNAME(30),EMPNAME * temp, copied from textbook
         
* SUCCESS
         WTO   TEXT='EXECUTED SUCCESSFULLY'
         EXITC 

         FINIS