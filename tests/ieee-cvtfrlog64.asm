  TITLE 'ieee-cvtfrlog64.asm: Test IEEE Convert From Fixed (uint-64)'
***********************************************************************
*
*Testcase IEEE CONVERT FROM LOGICAL 64
*  Test case capability includes ieee exceptions trappable and otherwise.
*  Test result, FPC flags, and DXC saved for all tests.  (Convert From 
*  Logical does not set the condition code.)
*
***********************************************************************
         SPACE 2
***********************************************************************
*
* Tests the following three conversion instructions
*   CONVERT FROM LOGICAL (64 to short BFP, RRF-e)
*   CONVERT FROM LOGICAL (64 to long BFP, RRF-e) 
*   CONVERT FROM LOGICAL (64 to extended BFP, RRF-e)  
*
* Limited test data is compiled into this program.  The test script that runs
* this program can provide alternative test data through Hercules R commands.
* 
* Test Case Order
* 1) Uint-64 to Short BFP
* 2) Uint-64 to Short BFP with all rounding modes
* 3) Uint-64 to Long BFP
* 4) Uint-64 to Long BFP with all rounding modes
* 5) Uint-64 to Extended BFP
*
* Provided test data is: 
*        1, 2, 4,
*        9 007 199 254 740 991(0x001FFFFFFFFFFFFF)
*       18 014 398 509 481 983(0x003FFFFFFFFFFFFF)
*   18 446 744 073 709 551 615 (0xFFFFFFFFFFFFFFFF)
*
*   The fourth value oveflows a short BFP but fits in a long BFP.
*   The fifth  value oveflows both short BFP and long BFP.  The
*   last value also overflows both, but fits in an extended BFP.
*
* Also tests the following floating point support instructions
*   LOAD  (Short)
*   LOAD  (Long)
*   LOAD FPC
*   SET BFP ROUNDING MODE 2-BIT
*   SET BFP ROUNDING MODE 3-BIT
*   STORE (Short)
*   STORE (Long)
*   STORE FPC
*
***********************************************************************
         SPACE 3
BFPCVTFF START 0
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
         ORG   BFPCVTFF+X'8E'      Program check interrution code
PCINTCD  DS    H
PCOLDPSW EQU   BFPCVTFF+X'150'     Program check old PSW
         ORG   BFPCVTFF+X'1A0' 
         DC    X'0000000180000000',AD(START)     z/Arch restart PSW
         ORG   BFPCVTFF+X'1D0' 
         DC    X'0000000000000000',AD(PROGCHK)   z/Arch pgm chk
         ORG   BFPCVTFF+X'200'
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
*2345678901234567890123456789012345678901234567890123456789012345678901
         LA    R10,SHORTS     Point to uint-64 test inputs
         BAS   R13,CELGBR     Convert values from fixed to short BFP
         LA    R10,RMSHORTS   Point to uint-64 inputs for rounding mode tests
         BAS   R13,CELGBRA    Convert values from fixed to short using rm options
*
         LA    R10,LONGS      Point to uint-64 test inputs
         BAS   R13,CDLGBR     Convert values from fixed to long
         LA    R10,RMLONGS    Point to uint-64 inputs for rounding mode tests
         BAS   R13,CDLGBRA    Convert values from fixed to long using rm options
*
         LA    R10,EXTDS      Point to uint-64 test inputs
         BAS   R13,CXLGBR     Convert values from fixed to extended
*
         LPSWE WAITPSW        All done
*
         DS    0D             Ensure correct alignment for psw
WAITPSW  DC    X'0002000000000000',AD(0)  Normal end - disabled wait
HARDWAIT DC    X'0002000000000000',XL6'00',X'DEAD' Abnormal end
*
CTLR0    DS    F
FPCREGNT DC    X'00000000'  FPCR, trap all IEEE exceptions, zero flags
FPCREGTR DC    X'F8000000'  FPCR, trap no IEEE exceptions, zero flags
*
* Input values parameter list, four fullwords: 
*      1) Count, 
*      2) Address of inputs, 
*      3) Address to place results, and
*      4) Address to place DXC/Flags/cc values.  
*
         ORG   BFPCVTFF+X'280'
SHORTS   DS    0F
         DC    A(INTCOUNT/8)
         DC    A(INTIN)
         DC    A(SBFPOUT)
         DC    A(SBFPFLGS)
*
LONGS    DS    0F           uint-64 inputs for long BFP testing
         DC    A(INTCOUNT/8)
         DC    A(INTIN)
         DC    A(LBFPOUT)
         DC    A(LBFPFLGS)
*
EXTDS    DS    0F           uint-64 inputs for Extended BFP testing
         DC    A(INTCOUNT/8)
         DC    A(INTIN)
         DC    A(XBFPOUT)
         DC    A(XBFPFLGS)
*
RMSHORTS DC    A(INTRMCT/8)
         DC    A(INTRMIN)   Last two uint-64 are only concerns
         DC    A(SBFPRMO)   Space for rounding mode tests
         DC    A(SBFPRMOF)  Space for rounding mode test flags
*
RMLONGS  DC    A(INTRMCT/8)
         DC    A(INTRMIN)   Last two uint-64 are only concerns
         DC    A(LBFPRMO)   Space for rounding mode tests
         DC    A(LBFPRMOF)  Space for rounding mode test flags
         EJECT
***********************************************************************
*
* Convert integers to short BFP format.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR is stored for each result.
*
***********************************************************************
         SPACE 2
CELGBR   LM    R2,R3,0(R10)  Get count and address of test input values
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get integer test value
         LFPC  FPCREGNT      Set exceptions non-trappable
         CELGBR R0,0,R1,0    Cvt uint in GPR1 to float in FPR0
         STE   R0,0(0,R7)    Store short BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGTR      Set exceptions trappable
         CELGBR R0,0,R1,0    Cvt uint in GPR1 to float in FPR0
         STE   R0,4(0,R7)    Store short BFP result
         STFPC 4(R8)         Store resulting FPC flags and DXC
         LA    R3,8(0,R3)    point to next input values
         LA    R7,8(0,R7)    Point to next short BFP converted values
         LA    R8,8(0,R8)    Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert uint-64 to short BFP format using every rounding mode.
* Ten test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPCR with 
* the IEEE Inexact exception supressed.  SRNM (2-bit) is used  for the 
* first two FPCR-controlled tests and SRNMB (3-bit) is used for the 
* last two To get full coverage of that instruction pair.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  RNTE is tested
* explicitly as a rounding mode in this section.  
*
CELGBRA  LM    R2,R3,0(R10)  Get count and address of test input values
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get uint-64 test value
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 1             SET FPC to RZ, towards zero.  
         CELGBR R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,0*4(0,R7)  Store short BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 2             SET FPC to RP, to +infinity
         CELGBR R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,1*4(0,R7)  Store short BFP result
         STFPC 1*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 3             SET FPC to RM, to -infinity
         CELGBR R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,2*4(0,R7)  Store short BFP result
         STFPC 2*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 7             RFS, Prepare for Shorter Precision
         CELGBR R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,3*4(0,R7)  Store short BFP result
         STFPC 3*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CELGBR R0,1,R1,B'0000'  RNTA, to nearest, ties away from zero
         STE   R0,4*4(0,R7)  Store short BFP result
         STFPC 4*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CELGBR R0,3,R1,B'0000'  RFS, to prepare for shorter precision
         STE   R0,5*4(0,R7)  Store short BFP result
         STFPC 5*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CELGBR R0,4,R1,B'0000'  RNTE, to nearest, ties to even
         STE   R0,6*4(0,R7)  Store short BFP result
         STFPC 6*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CELGBR R0,5,R1,B'0000'  RZ, toward zero
         STE   R0,7*4(0,R7)  Store short BFP result
         STFPC 7*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CELGBR R0,6,R1,B'0000'  RP, to +inf
         STE   R0,8*4(0,R7)  Store short BFP result
         STFPC 8*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CELGBR R0,7,R1,B'0000'  RM, to -inf
         STE   R0,9*4(0,R7)  Store short BFP result
         STFPC 9*4(R8)       Store resulting FPC flags and DXC
*
         LA    R3,8(0,R3)    point to next input values
         LA    R7,12*4(0,R7)  Point to next short BFP converted values
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* Convert integers to long BFP format.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR is stored for each result.
* Conversion of a 64-bit integer to long is always exact; no exceptions
* are expected
*
***********************************************************************
         SPACE 2
CDLGBR   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get integer test value
         LFPC  FPCREGNT      Set exceptions non-trappable
         CDLGBR R0,0,R1,0    Cvt uint in GPR1 to float in FPR0
         STD   R0,0(0,R7)    Store long BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGTR      Set exceptions trappable
         CDLGBR R0,0,R1,0    Cvt uint in GPR1 to float in FPR0
         STD   R0,8(0,R7)    Store long BFP result
         STFPC 4(R8)         Store resulting FPC flags and DXC
         LA    R3,8(0,R3)    Point to next input value
         LA    R7,16(0,R7)   Point to next long BFP result pair
         LA    R8,8(0,R8)    Point to next FPCR/CC contents pair
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert uint-64 to short BFP format using every rounding mode.
* Ten test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPCR with 
* the IEEE Inexact exception supressed.  SRNM (2-bit) is used  for the 
* first two FPCR-controlled tests and SRNMB (3-bit) is used for the 
* last two To get full coverage of that instruction pair.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  RNTE is tested
* explicitly as a rounding mode in this section.  
*
CDLGBRA  LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get uint-64 test value
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 1             SET FPC to RZ, towards zero.  
         CDLGBR R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,0*8(0,R7)  Store short BFP result
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 2             SET FPC to RP, to +infinity
         CDLGBR R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,1*8(0,R7)  Store short BFP result
         STFPC 1*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 3             SET FPC to RM, to -infinity
         CDLGBR R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,2*8(0,R7)  Store short BFP result
         STFPC 2*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 7             RFS, Prepare for Shorter Precision
         CDLGBR R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,3*8(0,R7)  Store short BFP result
         STFPC 3*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDLGBR R0,1,R1,B'0000'  RNTA, to nearest, ties away from zero
         STD   R0,4*8(0,R7)  Store short BFP result
         STFPC 4*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDLGBR R0,3,R1,B'0000'  RFS, to prepare for shorter precision
         STD   R0,5*8(0,R7)  Store short BFP result
         STFPC 5*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDLGBR R0,4,R1,B'0000'  RNTE, to nearest, ties to even
         STD   R0,6*8(0,R7)  Store short BFP result
         STFPC 6*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDLGBR R0,5,R1,B'0000'  RZ, toward zero
         STD   R0,7*8(0,R7)  Store short BFP result
         STFPC 7*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDLGBR R0,6,R1,B'0000'  RP, to +inf
         STD   R0,8*8(0,R7)  Store short BFP result
         STFPC 8*4(R8)       Store resulting FPC flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDLGBR R0,7,R1,B'0000'  RM, to -inf
         STD   R0,9*8(0,R7)  Store short BFP result
         STFPC 9*4(R8)       Store resulting FPC flags and DXC
*
         LA    R3,8(0,R3)    point to next input values
         LA    R7,10*8(0,R7)  Point to next long BFP converted values
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* Convert integers to extended BFP format.  A pair of results is 
* generated for each input: one with all exceptions non-trappable, 
* and the second with all exceptions trappable.   The FPCR is 
* stored for each result.  Conversion of a 64-bit integer to 
* extended is always exact; no exceptions are expected
*
***********************************************************************
         SPACE 2
CXLGBR   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get integer test value
         LFPC  FPCREGNT      Set exceptions non-trappable
         CXLGBR R0,0,R1,0    Cvt uint in GPR1 to float in FPR0-FPR2
         STD   R0,0(0,R7)    Store extended BFP result part 1
         STD   R2,8(0,R7)    Store extended BFP result part 1
         STFPC 0(R8)         Store resulting FPC flags and DXC
*
         LFPC  FPCREGTR      Set exceptions trappable
         CXLGBR R0,0,R1,0    Cvt uint in GPR1 to float in FPR0-FPR2
         STD   R0,16(0,R7)   Store extended BFP result
         STD   R2,24(0,R7)   Store extended BFP result
         STFPC 4(R8)         Store resulting FPC flags and DXC
         LA    R3,8(0,R3)    point to next input value
         LA    R7,32(0,R7)   Point to next extended BFP result pair
         LA    R8,8(0,R8)    Point to next FPCR/CC result pair
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* long integer inputs for Convert From Fixed testing.  The same set of 
* inputs are used for short, long, and extended formats.  The last two 
* values are used for rounding mode tests for short and long only; 
* conversion of uint-64 to extended is always exact.  
*
***********************************************************************
         SPACE 2
INTIN    DS    0D
         DC    FD'U1'
         DC    FD'U2'
         DC    FD'U4'
         DC    XL8'001FFFFFFFFFFFFF'  fits long BFP, o'flows short bfp
INTRMIN  DC    XL8'003FFFFFFFFFFFFF'  overflows short & long bfp
         DC    XL8'FFFFFFFFFFFFFFFF'  overflows short & long bfp
         DS    0F           required by asma for following EQU to work.  
INTCOUNT EQU   *-INTIN      Count of integers in list
INTRMCT  EQU   *-INTRMIN    Count of integers for rounding mode tests
*
SBFPOUT  EQU   BFPCVTFF+X'1000'    Short BFP values from uint-64
*                                  ..6 pairs used, room for 16 pairs
SBFPFLGS EQU   BFPCVTFF+X'1080'    FPCR flags and DXC from short BFP
*                                  ..6 pairs used, room for 16 pairs
SBFPRMO  EQU   BFPCVTFF+X'1100'    Short BFP rounding mode results
SBFPRMOF EQU   BFPCVTFF+X'1180'    Short BFP rounding mode FPCR 
*
LBFPOUT  EQU   BFPCVTFF+X'1200'    Long BFP values from uint-64
*                                  ..6 pairs used, room for 16 pairs
LBFPFLGS EQU   BFPCVTFF+X'1300'    FPCR flags and DXC from long BFP
*                                  ..6 pairs used, room for 16 pairs
LBFPRMO  EQU   BFPCVTFF+X'1380'    Long BFP rounding mode results
LBFPRMOF EQU   BFPCVTFF+X'1480'    Long BFP rounding mode FPCR
*
XBFPOUT  EQU   BFPCVTFF+X'1500'    Extended BFP values from uint-64
XBFPFLGS EQU   BFPCVTFF+X'1700'    Extended BFP rounding mode FPCR
*
*
         END
