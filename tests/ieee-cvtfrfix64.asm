   TITLE 'ieee-cvtfrfix64.asm: Test IEEE Convert From Fixed (int-64)'
***********************************************************************
*
*Testcase IEEE CONVERT FROM FIXED 64
*  Test case capability includes ieee exceptions trappable and 
*  otherwise.  Test result, FPCR flags, and DXC saved for all tests.
*  Convert From Fixed does not set the condition code.
*
***********************************************************************
          SPACE 2
***********************************************************************
*
* Tests the following six conversion instructions
*   CONVERT FROM FIXED (64 to short BFP, RRE)
*   CONVERT FROM FIXED (64 to long BFP, RRE)
*   CONVERT FROM FIXED (64 to extended BFP, RRE)
*   CONVERT FROM FIXED (64 to short BFP, RRF-e)
*   CONVERT FROM FIXED (64 to long BFP, RRF-e) 
*   CONVERT FROM FIXED (64 to extended BFP, RRF-e)  
*
* Test data is compiled into this program.  The test script that runs
* this program can provide alternative test data through Hercules R 
* commands.
* 
* Test Case Order
* 1) Int-32 to Short BFP
* 2) Int-32 to Short BFP with all rounding modes
* 3) Int-32 to Long BFP
* 4) Int-32 to Long BFP with all rounding modes
* 5) Int-32 to Extended BFP
*
* Provided test data:
*      1, 2, 4, -2,
*      9 223 372 036 854 775 807   (0x7FFFFFFFFFFF)
*      -9 223 372 036 854 775 807  (0x800000000000)
*   The last two values trigger inexact exceptions when converted
*   to long or short BFP and are used to exhaustively test 
*   operation of the various rounding modes.  Int-64 to extended
*   BFP is always exact.  
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
         LA    R10,SHORTS     Point to int-64 test inputs
         BAS   R13,CEGBR      Convert values from fixed to short BFP
         LA    R10,RMSHORTS   Point to int-64 inputs for rounding mode tests
         BAS   R13,CEGBRA     Convert to short BFP using rm options
*
         LA    R10,LONGS      Point to int-64 test inputs
         BAS   R13,CDGBR      Convert values from fixed to long BFP
         LA    R10,RMLONGS    Point to int-64 inputs for rounding mode tests
         BAS   R13,CDGBRA     Convert to long BFP using rm options
*
         LA    R10,EXTDS      Point to int-64 test inputs
         BAS   R13,CXGBR      Convert values from fixed to extended
*
         LPSWE WAITPSW        All done
*
         DS    0D             Ensure correct alignment for psw
WAITPSW  DC    X'0002000000000000',AD(0)  Normal end - disabled wait
HARDWAIT DC    X'0002000000000000',XL6'00',X'DEAD' Abnormal end
*
CTLR0    DS    F
FPCREGNT DC    X'00000000'    FPCR Reg IEEE exceptions Not Trappable
FPCREGTR DC    X'F8000000'    FPCR Reg IEEE exceptions TRappable
*
* Input values parameter list, four fullwords: 
*      1) Count, 
*      2) Address of inputs, 
*      3) Address to place results, and
*      4) Address to place DXC/Flags/cc values.  
*
         ORG   BFPCVTFF+X'280'
SHORTS   DS    0F           int-64 inputs for short BFP testing
         DC    A(INTCOUNT/8)
         DC    A(INTIN)
         DC    A(SBFPOUT)
         DC    A(SBFPFLGS)
*
LONGS    DS    0F           int-64 inputs for long BFP testing
         DC    A(INTCOUNT/8)
         DC    A(INTIN)
         DC    A(LBFPOUT)
         DC    A(LBFPFLGS)
*
EXTDS    DS    0F           int-64 inputs for Extended BFP testing
         DC    A(INTCOUNT/8)
         DC    A(INTIN)
         DC    A(XBFPOUT)
         DC    A(XBFPFLGS)
*
RMSHORTS DS    0F           int-64 inputs for long BFP rounding mode tests
         DC    A(INTRMCT/8)
         DC    A(INTRMIN)   Last two int-64 are only concerns
         DC    A(SBFPRMO)   Space for rounding mode results
         DC    A(SBFPRMOF)  Space for rounding mode FPCR contents
*
RMLONGS  DS    0F           int-64 inputs for extended BFP rounding mode tests
         DC    A(INTRMCT/8)
         DC    A(INTRMIN)   Last two int-64 are only concerns
         DC    A(LBFPRMO)   Space for rounding mode results
         DC    A(LBFPRMOF)  Space for rounding mode FPCR contents
         EJECT
***********************************************************************
*
* Convert int-64 to short BFP format.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR is stored for each result.
*
***********************************************************************
         SPACE 3

CEGBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get integer test value
         LFPC  FPCREGNT      Set exceptions non-trappable
         CEGBR R0,R1         Cvt Int in GPR1 to float in FPR0
         STE   R0,0(0,R7)    Store short BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGTR      Set exceptions trappable
         CEGBR R0,R1         Cvt Int in GPR1 to float in FPR0
         STE   R0,4(0,R7)    Store short BFP result
         STFPC 4(R8)         Store resulting FPCR flags and DXC
         LA    R3,8(0,R3)    point to next input values
         LA    R7,8(0,R7)    Point to next short BFP converted values
         LA    R8,8(0,R8)    Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert int-64 to short BFP format using each possible rounding mode.  
* Ten test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPCR with the 
* IEEE Inexact exception supressed.  SRNM (2-bit) is used  for the first
* two FPCR-controlled tests and SRNMB (3-bit) is used for the last two 
* to get full coverage of that instruction pair.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  RNTE is tested explicitly
* as a rounding mode in this section.  
*
CEGBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get int-64 test value
*
* Convert the Int-64 in GPR1 to float-64 in FPR0 using the rounding mode 
* specified in the FPCR.  Mask inexact exceptions.
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  1             SET FPCR to RZ, towards zero.  
         CEGBRA R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,0*4(0,R7)  Store short BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  2             SET FPCR to RP, to +infinity
         CEGBRA R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,1*4(0,R7)  Store short BFP result
         STFPC 1*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 3             SET FPCR to RM, to -infinity
         CEGBRA R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,2*4(0,R7)  Store short BFP result
         STFPC 2*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 7             RPS, Prepare for Shorter Precision
         CEGBRA R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,3*4(0,R7)  Store short BFP result
         STFPC 3*4(R8)       Store resulting FPCR flags and DXC
*
* Convert the Int-64 in GPR1 to float-64 in FPR0 using the rounding mode 
* specified in the M3 field of the instruction.  
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CEGBRA R0,1,R1,B'0000'  RNTA, to nearest, ties away from zero
         STE   R0,4*4(0,R7)  Store short BFP result
         STFPC 4*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CEGBRA R0,3,R1,B'0000'  RPS, to prepare for shorter precision
         STE   R0,5*4(0,R7)  Store short BFP result
         STFPC 5*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CEGBRA R0,4,R1,B'0000'  RNTE, to nearest, ties to even
         STE   R0,6*4(0,R7)  Store short BFP result
         STFPC 6*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CEGBRA R0,5,R1,B'0000'  RZ, toward zero
         STE   R0,7*4(0,R7)  Store short BFP result
         STFPC 7*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CEGBRA R0,6,R1,B'0000'  RP, to +inf
         STE   R0,8*4(0,R7)  Store short BFP result
         STFPC 8*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CEGBRA R0,7,R1,B'0000'  RM, to -inf
         STE   R0,9*4(0,R7)  Store short BFP result
         STFPC 9*4(R8)       Store resulting FPCR flags and DXC
*
         LA    R3,8(0,R3)    point to next input value
         LA    R7,12*4(0,R7)  Point to next short BFP rounded set
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* Convert int-64 to long BFP format.  A pair of results is generated
* for each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR is stored for each result.
* Conversion of a 32-bit integer to long is always exact; no exceptions
* are expected
*
***********************************************************************
         SPACE 3
CDGBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get integer test value
         LFPC  FPCREGNT      Set exceptions non-trappable
         CDGBR R0,R1         Cvt Int in GPR1 to float in FPR0
         STD   R0,0(0,R7)    Store long BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGTR      Set exceptions trappable
         CDGBR R0,R1         Cvt Int in GPR1 to float in FPR0
         STD   R0,8(0,R7)    Store long BFP result
         STFPC 4(R8)         Store resulting FPCR flags and DXC
         LA    R3,8(0,R3)    point to next input value
         LA    R7,16(0,R7)   Point to next long BFP converted value
         LA    R8,8(0,R8)    Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert int-64 to long BFP format using each possible rounding mode.  
* Ten test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPCR with the 
* IEEE Inexact exception supressed.  SRNM (2-bit) is used  for the first
* two FPCR-controlled tests and SRNMB (3-bit) is used for the last two 
* to get full coverage of that instruction pair.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  RNTE is tested explicitly
* as a rounding mode in this section.  
*
CDGBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get int-64 test value
*
* Convert the Int-64 in GPR1 to float-64 in FPR0 using the rounding mode 
* specified in the FPCR.  Mask inexact exceptions.  
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  1             SET FPCR to RZ, towards zero.  
         CDGBRA R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,0*8(0,R7)  Store long BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  2             SET FPCR to RP, to +infinity
         CDGBRA R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,1*8(0,R7)  Store long BFP result
         STFPC 1*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 3             SET FPCR to RM, to -infinity
         CDGBRA R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,2*8(0,R7)  Store long BFP result
         STFPC 2*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 7             RPS, Prepare for Shorter Precision
         CDGBRA R0,0,R1,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R0,3*8(0,R7)  Store long BFP result
         STFPC 3*4(R8)       Store resulting FPCR flags and DXC
*
* Convert the Int-64 in GPR1 to float-64 in FPR0 using the rounding mode 
* specified in the M3 field of the instruction.  
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDGBRA R0,1,R1,B'0000'  RNTA, to nearest, ties away from zero
         STD   R0,4*8(0,R7)  Store long BFP result
         STFPC 4*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDGBRA R0,3,R1,B'0000'  RPS, to prepare for shorter precision
         STD   R0,5*8(0,R7)  Store long BFP result
         STFPC 5*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDGBRA R0,4,R1,B'0000'  RNTE, to nearest, ties to even
         STD   R0,6*8(0,R7)  Store long BFP result
         STFPC 6*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDGBRA R0,5,R1,B'0000'  RZ, toward zero
         STD   R0,7*8(0,R7)  Store long BFP result
         STFPC 7*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDGBRA R0,6,R1,B'0000'  RP, to +inf
         STD   R0,8*8(0,R7)  Store long BFP result
         STFPC 8*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         CDGBRA R0,7,R1,B'0000'  RM, to -inf
         STD   R0,9*8(0,R7)  Store long BFP result
         STFPC 9*4(R8)       Store resulting FPCR flags and DXC
*
         LA    R3,8(0,R3)    point to next input value
         LA    R7,10*8(0,R7)  Point to next long BFP rounded value set
         LA    R8,12*4(0,R8)  Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* Convert int-64 to extended BFP format.  A pair of results is 
* generated * for each input: one with all exceptions non-trappable, 
* and the second with all exceptions trappable.   The FPCR is stored 
* for each result.  Conversion of an int-64to extended is always exact; 
* no exceptions are expected.
*
***********************************************************************
         SPACE 3
CXGBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LG    R1,0(0,R3)    Get integer test value
         LFPC  FPCREGNT      Set exceptions non-trappable
         CXGBR R0,R1         Cvt Int in GPR1 to float in FPR0-FPR2
         STD   R0,0(0,R7)    Store extended BFP result part 1
         STD   R2,8(0,R7)    Store extended BFP result part 2
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGTR      Set exceptions trappable
         CXGBR R0,R1         Cvt Int in GPR1 to float in FPR0-FPR2
         STD   R0,16(0,R7)   Store extended BFP result part 1
         STD   R2,24(0,R7)   Store extended BFP result part 2
         STFPC 4(R8)         Store resulting FPCR flags and DXC
         LA    R3,8(0,R3)    point to next input value
         LA    R7,32(0,R7)   Point to next extended BFP converted value
         LA    R8,8(0,R8)    Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* Int-64 inputs for Convert From Fixed testing.  The same set of 
* inputs are used for short, long, and extended formats.  The last two 
* values are used for rounding mode tests for short and long only; 
* conversion of int-64 to extended is always exact.  
*
***********************************************************************
         SPACE 3
INTIN    DS    0D
         DC    FD'1'
         DC    FD'2'
         DC    FD'4'
         DC    FD'-2'                    X'FFFFFFFF FFFFFFFE'
INTRMIN  DC    FD'9223372036854775807'   X'7FFFFFFF FFFFFFFF'
         DC    FD'-9223372036854775807'  X'80000000 00000001'
         DS    0F         required by asma for following EQU to work.  
INTCOUNT EQU   *-INTIN    Count of int-64 input values * 8
INTRMCT  EQU   *-INTRMIN  Count of int-64 for rounding tests * 8
*
SBFPOUT  EQU   BFPCVTFF+X'1000'    Int-32 results from short BFP inputs
*                                  ..6 pairs used, room for 16 pairs
SBFPFLGS EQU   BFPCVTFF+X'1080'    FPCR flags and DXC from short BFP
*                                  ..6 pairs used, room for 16 pairs
SBFPRMO  EQU   BFPCVTFF+X'1100'    Short BFP rounding mode results
*                                  ..2 sets used, no room for more sets
SBFPRMOF EQU   BFPCVTFF+X'1180'    Short BFP rndg mode FPCR contents
*                                  ..2 sets used, no room for more sets
*
LBFPOUT  EQU   BFPCVTFF+X'1200'    Int-32 results from long BFP inputs
*                                  ..6 pairs used, room for 16 pairs
LBFPFLGS EQU   BFPCVTFF+X'1300'    Long BFP FPCR contents
*                                  ..6 pairs used, room for 32 pairs
LBFPRMO  EQU   BFPCVTFF+X'1380'    Long BFP rounding mode results
*                                  ..2 sets used, no room for more sets
LBFPRMOF EQU   BFPCVTFF+X'1480'    Long BFP rndg mode FPCR contents
*                                  ..2 sets used, no room for more sets
*
XBFPOUT  EQU   BFPCVTFF+X'1500'    Int-32 results from extended BFP 
*                                  ..6 pairs used, room for 16 pairs
XBFPFLGS EQU   BFPCVTFF+X'1700'    Extended BFP FPCR contents
*                                  ..6 pairs used, room for 16 pairs
*
*
         END
