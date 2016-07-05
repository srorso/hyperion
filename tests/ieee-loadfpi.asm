*
*Testcase IEEE LOAD FP INTEGER
*  Test case capability includes ieee exceptions trappable and otherwise.
*  Test result, FPC flags, and DXC saved for all tests.  Load FP Integer
*  does not set the condition code.
*
* Tests the following three conversion instructions
*   LOAD FP INTEGER (short BFP, RRE)
*   LOAD FP INTEGER (long BFP, RRE) 
*   LOAD FP INTEGER (extended BFP, RRE)  
*   LOAD FP INTEGER (short BFP, RRF-e)
*   LOAD FP INTEGER (long BFP, RRF-e) 
*   LOAD FP INTEGER (extended BFP, RRF-e)  
* 
* Limited test data is compiled into this program.  The test script that runs
* this program can provide alternative test data through Hercules R commands.
* 
* Test Case Order
* 1) Short BFP inexact masking/trapping & SNaN/QNaN tests
* 2) Short BFP rounding mode tests
* 3) Long BFP inexact masking/trapping & SNaN/QNaN tests
* 4) Long BFP rounding mode tests
* 5) Extended BFP inexact masking/trapping & SNaN/QNaN tests
* 6) Extended BFP rounding mode tests
*
* Provided test data is 1, 1.5, SNaN, and QNaN.
*   The second value will trigger an inexact exception when LOAD FP INTEGER
*   is executed.  The final value will trigger an invalid exception.  
* Provided test data for all rounding tests is taken from SA22-7832-10 table 9-11
*   on page 9-16:  -9.5, -5.5, -2.5, -1.5, -0.5, +0.5, +1.5, +2.5, +5.5, +9.5
*
*   Note that three input test data sets are provided, one each for short, long,
*   and extended precision BFP inputs.  
*
* Also tests the following floating point support instructions
*   LOAD  (Short)
*   LOAD  (Long)
*   LFPC  (Load Floating Point Control Register)
*   SRNMB (Set BFP Rounding Mode 3-bit)
*   STFPC (Store Floating Point Control Register)
*   STORE (Short)
*   STORE (Long)
*
BFPLDFPI START 0
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
         ORG   BFPLDFPI+X'8E'      Program check interrution code
PCINTCD  DS    H
PCOLDPSW EQU   BFPLDFPI+X'150'     Program check old PSW
         ORG   BFPLDFPI+X'1A0' 
         DC    X'0000000180000000',AD(START)       z/Arch restart PSW
         ORG   BFPLDFPI+X'1D0' 
HARDWAIT DC    X'0000000000000000',AD(PROGCHK)   z/Arch pgm chk
         ORG   BFPLDFPI+X'200'
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
         BAS   R13,FIEBR      Convert values to fixed from short BFP
         LA    R10,RMSHORTS   Point to short BFP inputs for rounding mode tests
         BAS   R13,FIEBRA     Convert values from fixed to short using rm options
*
         LA    R10,LONGS      Point to long BFP test inputs
         BAS   R13,FIDBR      Convert values to fixed from long BFP
         LA    R10,RMLONGS    Point to long BFP inputs for rounding mode tests
         BAS   R13,FIDBRA     Convert values to fixed from long using rm options
*
         LA    R10,EXTDS      Point to extended BFP test inputs
         BAS   R13,FIXBR      Convert values to fixed from extended
         LA    R10,RMEXTDS    Point to extended BFP inputs for rounding mode tests
         BAS   R13,FIXBRA     Convert values to fixed from extended using rm options
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
         ORG   BFPLDFPI+X'280'
SHORTS   DS    0F           Inputs for short BFP testing
         DC    A(SBFPCT/4)
         DC    A(SBFPIN)
         DC    A(SBFPOUT)
         DC    A(SBFPFLGS)
*
LONGS    DS    0F           Inputs for long BFP testing
         DC    A(LBFPCT/8)
         DC    A(LBFPIN)
         DC    A(LBFPOUT)
         DC    A(LBFPFLGS)
*
EXTDS    DS    0F           Inputs for Extended BFP testing
         DC    A(XBFPCT/16)
         DC    A(XBFPIN)
         DC    A(XBFPOUT)
         DC    A(XBFPFLGS)
*
RMSHORTS DC    A(SBFPRMCT/4)
         DC    A(SBFPINRM)  table for short BFP rounding mode tests
         DC    A(SBFPRMO)   Space for rounding mode test results
         DC    A(SBFPRMOF)  Space for rounding mode test flags
*
RMLONGS  DC    A(LBFPRMCT/8)
         DC    A(LBFPINRM)  table for long BFP rounding mode test inputs
         DC    A(LBFPRMO)   Space for rounding mode tests results
         DC    A(LBFPRMOF)  Space for rounding mode test flags
*
RMEXTDS  DC    A(XBFPRMCT/16)
         DC    A(XBFPINRM)  table for extended BFP rounding mode test inputs
         DC    A(XBFPRMO)   Space for rounding mode results
         DC    A(XBFPRMOF)  Space for rounding mode test flags
*
* Convert short BFP to integer short BFP.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR and condition code is stored 
* for each result.
*
FIEBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LE    R0,0(0,R3)    Get short BFP test value
         LFPC  FPCREGNT      Set all exceptions non-trappable
         FIEBR R1,R0         Cvt float in FPR0 to int float in FPR1
         STE   R1,0(0,R7)    Store short BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGTR      Set all exceptions trappable
         LZER  R1            Eliminate any residual results
         FIEBR R1,R0         Cvt float in FPR0 to int float in FPR1
         STE   R1,4(0,R7)    Store short BFP result
         STFPC 4(R8)         Store resulting FPC flags and DXC
*
         LA    R3,4(0,R3)    point to next input values
         LA    R7,8(0,R7)    Point to next int-32 converted value pair
         LA    R8,8(0,R8)    Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert short BFP to integer BFP using each possible rounding mode.
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
FIEBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LE    R0,0(0,R3)    Get short BFP test value
*
*  Cvt float in FPR0 to integer BFP
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 1             SET FPC to RZ, Round towards zero.  
         FIEBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STE   R1,0*4(0,R7)  Store integer BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 2             SET FPC to RP, Round to +infinity
         FIEBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STE   R1,1*4(0,R7)  Store integer BFP result
         STFPC 1*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 3             SET FPC to RM, Round to -infinity
         FIEBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STE   R1,2*4(0,R7)  Store integer BFP result
         STFPC 2*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         FIEBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STE   R1,3*4(0,R7)  Store integer BFP result
         STFPC 3*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIEBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         STE   R1,4*4(0,R7)  Store integer BFP result
         STFPC 4*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIEBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         STE   R1,5*4(0,R7)  Store integer BFP result
         STFPC 5*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIEBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         STE   R1,6*4(0,R7)  Store integer BFP result
         STFPC 6*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIEBRA R1,5,R0,B'0000'  RZ Round toward zero
         STE   R1,7*4(0,R7)  Store integer BFP result
         STFPC 7*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIEBRA R1,6,R0,B'0000'  Round to +inf
         STE   R1,8*4(0,R7)  Store integer BFP result
         STFPC 8*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIEBRA R1,7,R0,B'0000'  Round to -inf
         STE   R1,9*4(0,R7)  Store integer BFP result
         STFPC 9*4(R8)       Store resulting FPC flags and DXC
*
         LA    R3,4(0,R3)    point to next input values
         LA    R7,12*4(0,R7)  Point to next short BFP converted values
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert long BFP inputs to integer BFP.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR and condition code is stored 
* for each result.  
*
FIDBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get long BFP test value
         LFPC  FPCREGNT      Set all exceptions non-trappable
         FIDBR R1,R0         Cvt float in FPR0 to Int in GPR1
         STD   R1,0(0,R7)    Store long BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGTR      Set all exceptions trappable
         LZDR  R1            Eliminate any residual results
         FIDBR R1,R0         Cvt float in FPR0 to Int in GPR1
         STD   R1,8(0,R7)    Store int-32 result
         STFPC 4(R8)         Store resulting FPC flags and DXC
*
         LA    R3,8(0,R3)    point to next input value
         LA    R7,16(0,R7)   Point to next integer BFP converted value pair
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
FIDBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get long BFP test value
*
*  Cvt float in FPR0 to integer BFP
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 1             SET FPC to RZ, Round towards zero.  
         FIDBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STD   R1,0*8(0,R7)  Store integer BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 2             SET FPC to RP, Round to +infinity
         FIDBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STD   R1,1*8(0,R7)  Store integer BFP result
         STFPC 1*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 3             SET FPC to RM, Round to -infinity
         FIDBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STD   R1,2*8(0,R7)  Store integer BFP result
         STFPC 2*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         FIDBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STD   R1,3*8(0,R7)  Store integer BFP result
         STFPC 3*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIDBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         STD   R1,4*8(0,R7)  Store integer BFP result
         STFPC 4*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIDBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         STD   R1,5*8(0,R7)  Store integer BFP result
         STFPC 5*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIDBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         STD   R1,6*8(0,R7)  Store integer BFP result
         STFPC 6*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIDBRA R1,5,R0,B'0000'  RZ Round toward zero
         STD   R1,7*8(0,R7)  Store integer BFP result
         STFPC 7*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIDBRA R1,6,R0,B'0000'  Round to +inf
         STD   R1,8*8(0,R7)  Store integer BFP result
         STFPC 8*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIDBRA R1,7,R0,B'0000'  Round to -inf
         STD   R1,9*8(0,R7)  Store integer BFP result
         STFPC 9*4(R8)       Store resulting FPC flags and DXC
*
         LA    R3,8(0,R3)    point to next input values
         LA    R7,10*8(0,R7)  Point to next long BFP converted values
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert extended BFP to integer BFP.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the 
* second with all exceptions trappable.   The FPCR and condition code
* are stored for each result.  
*
FIXBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get extended BFP test value part 1
         LD    R2,8(0,R3)    Get extended BFP test value part 1
         LFPC  FPCREGNT      Set all exceptions non-trappable
         FIXBR R1,R0         Cvt float in FPR0-FPR2 to int float in FPR1-FPR3
         STD   R1,0(0,R7)    Store integer BFP result part 1
         STD   R3,8(0,R7)    Store integer BFP result part 2
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGTR      Set all exceptions trappable
         LZXR  R1            Eliminate any residual results
         FIXBR R1,R0         Cvt float in FPR0-FPR2 to int float in FPR1-FPR3
         STD   R1,16(0,R7)   Store integer BFP result part 1
         STD   R3,24(0,R7)   Store integer BFP result part 2
         STFPC 4(R8)         Store resulting FPC flags and DXC
*
         LA    R3,16(0,R3)   Point to next extended BFP input value
         LA    R7,32(0,R7)   Point to next integer BFP converted value pair
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
FIXBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get extended BFP test value part 1
         LD    R2,8(0,R3)    Get extended BFP test value part 2
*
*  Cvt float in FPR0 to integer BFP
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 1             SET FPC to RZ, Round towards zero.  
         FIXBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STD   R1,0*16(0,R7)     Store integer BFP result part 1
         STD   R3,(0*16)+8(0,R7) Store integer BFP result part 2
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 2             SET FPC to RP, Round to +infinity
         FIXBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STD   R1,1*16(0,R7)     Store integer BFP result part 1
         STD   R3,(1*16)+8(0,R7) Store integer BFP result part 2
         STFPC 1*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 3             SET FPC to RM, Round to -infinity
         FIXBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STD   R1,2*16(0,R7)     Store integer BFP result part 1
         STD   R3,(2*16)+8(0,R7) Store integer BFP result part 2
         STFPC 2*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         FIXBRA R1,0,R0,B'0100'  FPC controlled rounding, inexact masked
         STD   R1,3*16(0,R7)     Store integer BFP result part 1
         STD   R3,(3*16)+8(0,R7) Store integer BFP result part 2
         STFPC 3*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIXBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         STD   R1,4*16(0,R7)     Store integer BFP result part 1
         STD   R3,(4*16)+8(0,R7) Store integer BFP result part 2
         STFPC 4*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIXBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         STD   R1,5*16(0,R7)     Store integer BFP result part 1
         STD   R3,(5*16)+8(0,R7) Store integer BFP result part 2
         STFPC 5*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIXBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         STD   R1,6*16(0,R7)     Store integer BFP result part 1
         STD   R3,(6*16)+8(0,R7) Store integer BFP result part 2
         STFPC 6*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIXBRA R1,5,R0,B'0000'  RZ Round toward zero
         STD   R1,7*16(0,R7)     Store integer BFP result part 1
         STD   R3,(7*16)+8(0,R7) Store integer BFP result part 2
         STFPC 7*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIXBRA R1,6,R0,B'0000'  Round to +inf
         STD   R1,8*16(0,R7)     Store integer BFP result part 1
         STD   R3,(8*16)+8(0,R7) Store integer BFP result part 2
         STFPC 8*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set all exceptions non-trappable, clear flags
         FIXBRA R1,7,R0,B'0000'  Round to -inf
         STD   R1,9*16(0,R7)     Store integer BFP result part 1
         STD   R3,(9*16)+8(0,R7) Store integer BFP result part 2
         STFPC 9*4(R8)       Store resulting FPC flags and DXC
*
         LA    R3,16(0,R3)    Point to next input value
         LA    R7,10*16(0,R7) Point to next long BFP converted values
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Short integer inputs for Load FP Integer testing.  The same 
* values are used for short, long, and extended formats.  
*
SBFPIN   DS    0F                Inputs for short BFP testing
         DC    X'3F800000'         +1.0
         DC    X'BFC00000'         -1.5
         DC    X'7F810000'         SNaN
         DC    X'7FC10000'         QNaN
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
         DC    X'3FF0000000000000'         +1.0
         DC    X'BFF8000000000000'         -1.5
         DC    X'7FF0100000000000'         SNaN
         DC    X'7FF8100000000000'         QNaN
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
         DC    X'3FFF0000000000000000000000000000'         +1.0
         DC    X'BFFF8000000000000000000000000000'         -1.5
         DC    X'7FFF0100000000000000000000000000'         SNaN
         DC    X'7FFF8100000000000000000000000000'         QNaN
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
SBFPOUT  EQU   BFPLDFPI+X'1000'    Integer short BFP values from short BFP
SBFPFLGS EQU   BFPLDFPI+X'1080'    FPC flags and DXC from short BFP
SBFPRMO  EQU   BFPLDFPI+X'1100'    Space for short rounding mode tests
SBFPRMOF EQU   BFPLDFPI+X'1300'    Space for short rounding mode test flags
*
LBFPOUT  EQU   BFPLDFPI+X'1500'    Integer long BFP values from long BFP
LBFPFLGS EQU   BFPLDFPI+X'1580'    FPC flags and DXC from long BFP
LBFPRMO  EQU   BFPLDFPI+X'1600'    Space for long rounding mode tests
LBFPRMOF EQU   BFPLDFPI+X'1A00'    Space for long  rounding mode test flags
*
XBFPOUT  EQU   BFPLDFPI+X'1C00'    Integer extended BFP values from extended BFP
XBFPFLGS EQU   BFPLDFPI+X'1C80'    FPC flags and DXC from extended BFP
XBFPRMO  EQU   BFPLDFPI+X'1D00'    Space for extended rounding mode tests
XBFPRMOF EQU   BFPLDFPI+X'2400'    Space for extended rounding mode test flags
*

         END
