*
*Testcase IEEE CONVERT TO FIXED 32
*  Test case capability includes ieee exceptions trappable and otherwise.
*  Test result, FPC flags, and DXC saved for all tests.  (Convert To 
*  Fixed does not set the condition code.)
*
* Tests the following three conversion instructions
*   CONVERT FROM FIXED (short BFP to int-32, RRE)
*   CONVERT FROM FIXED (long BFP to int-32, RRE) 
*   CONVERT FROM FIXED (extended BFP to int-32, RRE)  
*
* Limited test data is compiled into this program.  The test script that runs
* this program can provide alternative test data through Hercules R commands.
* 
* Test Case Order
* 1) Short BFP to Int-32 
* 2) Short BFP to Int-32 with all rounding modes
* 3) Long BFP Int-32
* 3) Long BFP Int-32 with all rounding modes
* 4) Extended BFP to Int-32 
* 4) Extended BFP to Int-32 with all rounding modes
*
* Provided test data is 1, 2, 4, -2, QNaN, SNaN, 2 147 483 648, -2 147 483 648.
*   The last two values will trigger inexact exceptions when converted to 
*   int-32.  ****** Need to addd underflow test cases   **********
* Provided test data for all rounding tests is taken from SA22-7832-10 table 9-11
*   on page 9-16.  While the table illustrates LOAD FP INTEGER, the same results
*   should be generated when creating an int-32 or int-64 integer.  
*   -9.5, -5.5, -2.5, -1.5, -0.5, +0.5, +1.5, +2.5, +5.5, +9.5
*
*   Note that three input test data sets are provided, one each for short, long,
*   and extended precision BFP.  All are converted to int-32. 
*
* Also tests the following floating point support instructions
*   LOAD  (Short)
*   LOAD  (Long)
*   SRNMB (Set BFP Rounding Mode 3-bit)
*   STORE (Short)
*   STORE (Long)
*
BFPCVTTF START 0
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         USING *,0
         ORG   BFPCVTTF+X'8E'      Program check interrution code
PCINTCD  DS    H
PCOLDPSW EQU   BFPCVTTF+X'150'     Program check old PSW
         ORG   BFPCVTTF+X'1A0' 
         DC    X'0000000180000000',AD(START)       z/Arch restart PSW
         ORG   BFPCVTTF+X'1D0' 
HARDWAIT DC    X'0000000000000000',AD(PROGCHK)   z/Arch pgm chk
         ORG   BFPCVTTF+X'200'
* 
* Program check routine.  If Data Exception, continue execution at
* the instruction following the program check.  Otherwise, hard wait.  
*
PROGCHK  DS    0H             Program check occured...
         CLI   PCINTCD+1,X'07'  Data Exception?
         BNE   PCNOTDTA       ..no, hardwait
         LPSWE PCOLDPSW       ..yes, resume program execution
PCNOTDTA LPSWE HARDWAIT       Not data exception, enter disabled wait.
*
*  Main program.  Enable Advanced Floating Point, process test cases.
*         
START    STCTL R0,R0,CTLR0    Store CR0 to enable AFP
         OI    CTLR0+1,X'04'  Turn on AFP bit
         LCTL  R0,R0,CTLR0    Reload updated CR0
*
         LA    R10,SHORTS     Point to short BFP test inputs
         BAS   R13,CFEBR      Convert values to fixed from short BFP
         LA    R10,RMSHORTS   Point to short BFP inputs for rounding mode tests
         BAS   R13,CFEBRA     Convert values from fixed to short using rm options
*
         LA    R10,LONGS      Point to long BFP test inputs
         BAS   R13,CFDBR      Convert values to fixed from long BFP
         LA    R10,RMLONGS    Point to long BFP inputs for rounding mode tests
         BAS   R13,CFDBRA     Convert values to fixed from long using rm options
*
         LA    R10,EXTDS      Point to extended BFP test inputs
         BAS   R13,CFXBR      Convert values to fixed from extended
         LA    R10,RMEXTDS    Point to extended BFP inputs for rounding mode tests
         BAS   R13,CFXBRA     Convert values to fixed from extended using rm options
*
         LPSWE WAITPSW        All done
*
         DS    0D             Ensure correct alignment for psw
WAITPSW  DC    X'00020000000000000000000000000000'    Disabled wait state PSW - normal completion
CTLR0    DS    F
FPCREGNT DC    X'00000000'    FPC Reg no IEEE exceptions trappable, flags cleared
FPCREGTR DC    X'F8000000'    FPC Reg all IEEE exceptions trappable, flags cleared
*
* Input values parameter list, four fullwords: 
*      1) Count, 
*      2) Address of inputs, 
*      3) Address to place results, and
*      4) Address to place DXC/Flags/cc values.  
*
         ORG   BFPCVTTF+X'280'
SHORTS   DS    0F           Inputs for short BFP testing
         DC    A(SBFPCT/4)
         DC    A(SBFPIN)
         DC    A(SINTOUT)
         DC    A(SINTFLGS)
*
LONGS    DS    0F           Inputs for long BFP testing
         DC    A(LBFPCT/8)
         DC    A(LBFPIN)
         DC    A(LINTOUT)
         DC    A(LINTFLGS)
*
EXTDS    DS    0F           Inputs for Extended BFP testing
         DC    A(XBFPCT/16)
         DC    A(XBFPIN)
         DC    A(XINTOUT)
         DC    A(XINTFLGS)
*
RMSHORTS DC    A(SBFPRMCT/4)
         DC    A(SBFPINRM)  table for short BFP rounding mode tests
         DC    A(SINTRMO)   Space for rounding mode test results
         DC    A(SINTRMOF)  Space for rounding mode test flags
*
RMLONGS  DC    A(LBFPRMCT/8)
         DC    A(LBFPINRM)  table for long BFP rounding mode test inputs
         DC    A(LINTRMO)   Space for rounding mode tests results
         DC    A(LINTRMOF)  Space for rounding mode test flags
*
RMEXTDS  DC    A(XBFPRMCT/16)
         DC    A(XBFPINRM)  table for extended BFP rounding mode test inputs
         DC    A(XINTRMO)   Space for rounding mode results
         DC    A(XINTRMOF)  Space for rounding mode test flags
*
* Convert short BFP to integer-32 format.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR and condition code is stored 
* for each result.
*
CFEBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LE    R0,0(0,R3)    Get short BFP test value
         LFPC  FPCREGNT      Set all exceptions non-trappable
         CFEBR R1,R0         Cvt float in FPR0 to Int in GPR1
         ST    R1,0(0,R7)    Store int-32 result
         STFPC 0(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGTR      Set all exceptions trappable
         XR    R1,R1         Clear any residual result in R1
         SPM   R1            Clear out any residual nz condition code
         CFEBR R1,R0         Cvt float in FPR0 to Int in GPR1
         ST    R1,4(0,R7)    Store short BFP result
         STFPC 4(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,7(0,R8)    Save condition code as low byte of FPCR
*
         LA    R3,4(0,R3)    point to next input values
         LA    R7,8(0,R7)    Point to next int-32 converted value pair
         LA    R8,8(0,R8)    Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert short BFP to integers using each possible rounding mode.  Ten
* test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPC with the 
* IEEE Inexact exception supressed.  (Nonce error: the current build of 
* Hyperion does not support Set BFP Rounding Mode 3-Bit.  The FPCR test
* of rounding mode 7 is skipped.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  
*
CFEBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LE    R0,0(0,R3)    Get short BFP test value
*
*  Cvt float in FPR0 to integer-32
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 1             SET FPC to RZ, Round towards zero.  
         CFEBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,0*4(0,R7)  Store integer-32 result
         STFPC 0(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 2             SET FPC to RP, Round to +infinity
         CFEBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,1*4(0,R7)  Store integer-32 result
         STFPC 1*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(1*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 3             SET FPC to RM, Round to -infinity
         CFEBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,2*4(0,R7)  Store integer-32 result
         STFPC 2*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(2*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         CFEBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,3*4(0,R7)  Store integer-32 result
         STFPC 3*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(3*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFEBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         ST    R1,4*4(0,R7)  Store integer-32 result
         STFPC 4*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(4*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFEBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         ST    R1,5*4(0,R7)  Store integer-32 result
         STFPC 5*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(5*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFEBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         ST    R1,6*4(0,R7)  Store integer-32 result
         STFPC 6*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(6*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFEBRA R1,5,R0,B'0000'  RZ Round toward zero
         ST    R1,7*4(0,R7)  Store integer-32 result
         STFPC 7*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(7*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFEBRA R1,6,R0,B'0000'  Round to +inf
         ST    R1,8*4(0,R7)  Store integer-32 result
         STFPC 8*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(8*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFEBRA R1,7,R0,B'0000'  Round to -inf
         ST    R1,9*4(0,R7)  Store integer-32 result
         STFPC 9*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(9*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LA    R3,4(0,R3)    point to next input values
         LA    R7,12*4(0,R7)  Point to next short BFP converted values
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert long BFP inputs to integer-32.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR and condition code is stored 
* for each result.  
*
CFDBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get long BFP test value
         LFPC  FPCREGNT      Set all exceptions non-trappable
         CFDBR R1,R0         Cvt float in FPR0 to Int in GPR1
         ST    R1,0(0,R7)    Store long BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGTR      Set all exceptions trappable
         XR    R1,R1         Clear any residual result in R1
         SPM   R1            Clear out any residual nz condition code
         CFDBR R1,R0         Cvt float in FPR0 to Int in GPR1
         ST    R1,4(0,R7)    Store int-32 result
         STFPC 4(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,7(0,R8)    Save condition code as low byte of FPCR
*
         LA    R3,8(0,R3)    point to next input values
         LA    R7,8(0,R7)    Point to next integer-32 converted value pair
         LA    R8,8(0,R8)    Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert long BFP to integers using each possible rounding mode.  Ten
* test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPC with the 
* IEEE Inexact exception supressed.  (Nonce error: the current build of 
* Hyperion does not support Set BFP Rounding Mode 3-Bit.  The FPCR test
* of rounding mode 7 is skipped.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  
*
CFDBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get long BFP test value
*
*  Cvt float in FPR0 to integer-32
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 1             SET FPC to RZ, Round towards zero.  
         CFDBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,0*4(0,R7)  Store integer-32 result
         STFPC 0(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 2             SET FPC to RP, Round to +infinity
         CFDBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,1*4(0,R7)  Store integer-32 result
         STFPC 1*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(1*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 3             SET FPC to RM, Round to -infinity
         CFDBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,2*4(0,R7)  Store integer-32 result
         STFPC 2*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(2*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         CFDBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,3*4(0,R7)  Store integer-32 result
         STFPC 3*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(3*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFDBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         ST    R1,4*4(0,R7)  Store integer-32 result
         STFPC 4*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(4*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFDBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         ST    R1,5*4(0,R7)  Store integer-32 result
         STFPC 5*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(5*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFDBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         ST    R1,6*4(0,R7)  Store integer-32 result
         STFPC 6*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(6*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFDBRA R1,5,R0,B'0000'  RZ Round toward zero
         ST    R1,7*4(0,R7)  Store integer-32 result
         STFPC 7*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(7*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFDBRA R1,6,R0,B'0000'  Round to +inf
         ST    R1,8*4(0,R7)  Store integer-32 result
         STFPC 8*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(8*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFDBRA R1,7,R0,B'0000'  Round to -inf
         ST    R1,9*4(0,R7)  Store integer-32 result
         STFPC 9*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(9*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LA    R3,8(0,R3)    point to next input values
         LA    R7,12*4(0,R7)  Point to next long BFP converted values
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert extended BFP to integer-32.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the 
* second with all exceptions trappable.   The FPCR and condition code
* are stored for each result.  
*
CFXBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get extended BFP test value part 1
         LD    R2,8(0,R3)    Get extended BFP test value part 1
         LFPC  FPCREGNT      Set all exceptions non-trappable
         CFXBR R1,R0         Cvt float in FPR0-FPR2 to Int-32 in GPR1
         ST    R1,0(0,R7)    Store integer-32 result
         STFPC 0(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGTR      Set all exceptions trappable
         XR    R1,R1         Clear any residual result in R1
         SPM   R1            Clear out any residual nz condition code
         CFXBR R1,R0         Cvt float in FPR0-FPR2 to Int-32 in GPR1
         ST    R1,4(0,R7)    Store integer-32 result
         STFPC 4(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,7(0,R8)    Save condition code as low byte of FPCR
*
         LA    R3,16(0,R3)   Point to next extended BFP input value
         LA    R7,8(0,R7)    Point to next integer-32 converted value pair
         LA    R8,8(0,R8)    Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert extended BFP to integers using each possible rounding mode.
* Tentest results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPC with the 
* IEEE Inexact exception supressed.  (Nonce error: the current build of 
* Hyperion does not support Set BFP Rounding Mode 3-Bit.  The FPCR test
* of rounding mode 7 is skipped.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  
*
CFXBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get extended BFP test value part 1
         LD    R2,8(0,R3)    Get extended BFP test value part 2
*
*  Cvt float in FPR0 to integer-32
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 1             SET FPC to RZ, Round towards zero.  
         CFXBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,0*4(0,R7)  Store integer-32 result
         STFPC 0(R8)         Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 2             SET FPC to RP, Round to +infinity
         CFXBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,1*4(0,R7)  Store integer-32 result
         STFPC 1*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(1*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 3             SET FPC to RM, Round to -infinity
         CFXBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,2*4(0,R7)  Store integer-32 result
         STFPC 2*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(2*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         CFXBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         ST    R1,3*4(0,R7)  Store integer-32 result
         STFPC 3*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(3*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFXBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         ST    R1,4*4(0,R7)  Store integer-32 result
         STFPC 4*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(4*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFXBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         ST    R1,5*4(0,R7)  Store integer-32 result
         STFPC 5*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(5*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFXBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         ST    R1,6*4(0,R7)  Store integer-32 result
         STFPC 6*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(6*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFXBRA R1,5,R0,B'0000'  RZ Round toward zero
         ST    R1,7*4(0,R7)  Store integer-32 result
         STFPC 7*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(7*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFXBRA R1,6,R0,B'0000'  Round to +inf
         ST    R1,8*4(0,R7)  Store integer-32 result
         STFPC 8*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(8*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         CFXBRA R1,7,R0,B'0000'  Round to -inf
         ST    R1,9*4(0,R7)  Store integer-32 result
         STFPC 9*4(R8)       Store resulting FPC flags and DXC
         IPM   R1            Get condition code and program mask
         SRL   R1,28         Isolate CC in low order byte
         STC   R1,(9*4)+3(0,R8)    Save condition code as low byte of FPCR
*
         LA    R3,16(0,R3)    point to next input value
         LA    R7,12*4(0,R7)  Point to next long BFP converted values
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Short integer inputs for Convert From Fixed testing.  The same set of 
* inputs are used for short, long, and extended formats.  The last two 
* values are used for rounding mode tests for short only; conversion of 
* int-32 to long or extended are always exact.  
*
SBFPIN   DS    0F                Inputs for short BFP testing
         DC    X'3F800000'         +1.0
         DC    X'40000000'         +2.0
         DC    X'40800000'         +4.0
         DC    X'C0000000'         -2.0
         DC    X'7F810000'         SNaN
         DC    X'7FC10000'         QNaN
         DC    X'4F000001'         positive max int-32 value plus 1.  (2147483647 + 1)
         DC    X'CF000002'         negative max int-32 value minus 2.  (-2147483647 - 2)
         DS    0F                  required by asma for following EQU to work.
SBFPCT   EQU   *-SBFPIN            Count of short BFP in list * 4
*
SBFPINRM DS    0F
         DC    X'C1180000'         -9.5
         DC    X'C0B00000'         -5.5
         DC    X'C0200000'         -2.5
         DC    X'BFC00000'         -1.5
         DC    X'BF000000'         -0.5
         DC    X'3F000000'         +0.5
         DC    X'3FC00000'         +1.5
         DC    X'40200000'         +2.5
         DC    X'40B00000'         +5.5
         DC    X'41180000'         +9.5
         DS    0F                  required by asma for following EQU to work.
SBFPRMCT EQU   *-SBFPINRM          Count of short BFP * 4 to be used for rounding mode tests
*
LBFPIN   DS    0F                Inputs for long BFP testing
         DC    X'3FF0000000000000'    +1.0
         DC    X'4000000000000000'    +2.0
         DC    X'4010000000000000'    +4.0
         DC    X'C000000000000000'    -2.0
         DC    X'7FF0100000000000'    SNaN
         DC    X'7FF8100000000000'    QNaN
         DC    X'41E0000000000000'   positive max int-32 value plus 1.  (2147483647 + 1)
         DC    X'C1E0000000200000'   negative max int-32 value minus 2.  (-2147483647 - 2)
         DS    0F                  required by asma for following EQU to work.
LBFPCT   EQU   *-LBFPIN            Count of long BFP in list * 8
*
LBFPINRM DS    0F
         DC    X'C023000000000000'         -9.5
         DC    X'C016000000000000'         -5.5
         DC    X'C004000000000000'         -2.5
         DC    X'BFF8000000000000'         -1.5
         DC    X'BFE0000000000000'         -0.5
         DC    X'3FE0000000000000'         +0.5
         DC    X'3FF8000000000000'         +1.5
         DC    X'4004000000000000'         +2.5
         DC    X'4016000000000000'         +5.5
         DC    X'4023000000000000'         +9.5
         DS    0F                  required by asma for following EQU to work.
LBFPRMCT EQU   *-LBFPINRM          Count of long BFP * 8 to be used for rounding mode tests
*
XBFPIN   DS    0D                Inputs for long BFP testing
         DC    X'3FFF0000000000000000000000000000'    +1.0
         DC    X'40000000000000000000000000000000'    +2.0
         DC    X'40010000000000000000000000000000'    +4.0
         DC    X'C0000000000000000000000000000000'    -2.0
         DC    X'7FFF0100000000000000000000000000'    SNaN
         DC    X'7FFF8100000000000000000000000000'    QNaN
         DC    X'401E0000000000000000000000000000'   positive max int-32 value plus 1.  (2147483647 + 1)
         DC    X'C01E0000000200000000000000000000'   negative max int-32 value minus 2.  (-2147483647 - 2)
         DS    0D                  required by asma for following EQU to work.
XBFPCT   EQU   *-XBFPIN            Count of extended BFP in list * 16
*
XBFPINRM DS    0D
         DC    X'C0023000000000000000000000000000'         -9.5
         DC    X'C0016000000000000000000000000000'         -5.5
         DC    X'C0004000000000000000000000000000'         -2.5
         DC    X'BFFF8000000000000000000000000000'         -1.5
         DC    X'BFFE0000000000000000000000000000'         -0.5
         DC    X'3FFE0000000000000000000000000000'         +0.5
         DC    X'3FFF8000000000000000000000000000'         +1.5
         DC    X'40004000000000000000000000000000'         +2.5
         DC    X'40016000000000000000000000000000'         +5.5
         DC    X'40023000000000000000000000000000'         +9.5
         DS    0D                  required by asma for following EQU to work.
XBFPRMCT EQU   *-XBFPINRM          Count of extended BFP * 16 to be used for rounding mode tests
*
*  Locations for results
*
SINTOUT  EQU   BFPCVTTF+X'1000'    Integer-32 values from short BFP, 16 planned, room for 32
SINTFLGS EQU   BFPCVTTF+X'1080'    FPC flags and DXC from short BFP, 16 planned, room for 32
SINTRMO  EQU   BFPCVTTF+X'1100'    Space for short rounding mode tests, room for 10 sets
SINTRMOF EQU   BFPCVTTF+X'1300'    Space for short rounding mode test flags, room for 10 sets
*
LINTOUT  EQU   BFPCVTTF+X'1500'    Integer-32 values from long BFP, 16 planned, room for 32
LINTFLGS EQU   BFPCVTTF+X'1580'    FPC flags and DXC from long BFP, 16 planned, room for 32
LINTRMO  EQU   BFPCVTTF+X'1600'    Space for long rounding mode tests, room for 10 sets
LINTRMOF EQU   BFPCVTTF+X'1800'    Space for long  rounding mode test flags, room for 10 sets
*
XINTOUT  EQU   BFPCVTTF+X'1A00'    Integer-32 values from extended BFP, 16 planned, room for 32
XINTFLGS EQU   BFPCVTTF+X'1A80'    FPC flags and DXC from extended BFP, 16 planned, room for 32
XINTRMO  EQU   BFPCVTTF+X'1B00'    Space for extended rounding mode tests, room for 10 sets
XINTRMOF EQU   BFPCVTTF+X'1D00'    Space for extended rounding mode test flags, room for 10 sets
*

         END
