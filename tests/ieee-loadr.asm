  TITLE 'ieee-loadr.asm: Test IEEE Load Rounded'
***********************************************************************
*
*Testcase IEEE LOAD ROUNDED
*  Test case capability includes IEEE exceptions, trappable and 
*  otherwise.  Test result, FPCR flags, and DXC saved for all tests.  
*  Load Rounded does not set the condition code.
*
***********************************************************************
          SPACE 2
***********************************************************************
*
*
*Testcase IEEE LOAD ROUNDED
*  Test case capability includes ieee exceptions trappable and otherwise.
*  Test result, FPCR flags, and DXC saved for all tests.  Load Rounded 
*  does not set the condition code.  Overflow and underflow are not
*  tested by this program.  
*
* Tests the following three conversion instructions
*   LOAD ROUNDED (long to short BFP, RRE)
*   LOAD ROUNDED (extended to short BFP, RRE) 
*   LOAD ROUNDED (extended to long BFP, RRE)  
*   LOAD ROUNDED (long short BFP, RRF-e)
*   LOAD ROUNDED (extended to long BFP, RRF-e) 
*   LOAD ROUNDED (extended to short BFP, RRF-e)  
*
* This routine exhaustively tests rounding in 32- and 64-bit binary 
* floating point.  It is not possible to use Load Rounded to test
* rounding of 128-bit results; we will have to back in to those tests
* using Add.  

* Test data is compiled into this program.  The test script that runs
* this program can provide alternative test data through Hercules R 
* commands.
* 
* Test Case Order
* 1) Long to short BFP basic tests (exception traps and flags, NaNs)
* 2) Long to short BFP rounding mode tests
* 3) Extended to short BFP basic tests
* 4) Extended to short BFP rounding mode tests
* 5) Extended to long BFP basic tests.  
* 6) Extended to long BFP rounding mode tests
*
* Test data is 'white box,' meaning it is keyed to the internal 
* characteristics of Softfloat 3a, while expecting results to conform
* to the z/Architecture Principles of Opeartion, SA22-7832-10.  
*
* In the discussion below, "stored significand" does not include the 
* implicit units digit that is always assumed to be one for a non-
* tiny Binary Floating Point value.  
*
* Round long or extended to short: Softfloat uses the left-most 30 
*   bits of the long or extended BFP stored significand for 
*   rounding, which means 7 'extra' bits participate in the 
*   rounding.  If any of the right-hand 22 bits are non-zero, the 
*   30-bit pre-rounded value is or'd with 1 in the low-order bit 
*   position.  
* 
* Round extended to long: Softfloat uses the left-most 62 bits of
*   the extended BFP stored significand for rounding, which means 
*   10 'extra' bits participate in the rounding.  If any of the 
*   remaining right-hand 50 bits are non-zero, the 62-bit pre- 
*   rounded value is or'd with 1 in the low-order bit position.  
*   At least one of the test cases will have one bits in only the 
*   low-order 64 bits of the stored significand.  
*
* The or'd 1 bit representing the bits not participating in the 
*   rounding process prevents false exacts.  False exacts would 
*   otherwise occur when the extra 7 or 10 bits that participate
*   in rounding are zero and bits to the right of them are not.
*
* Basic test cases are needed as follows:
*   0, +1.5, -1.5, QNaN, SNaN, 
*
* If overflow/underflow occur and are trappable, the result should
*   be in the source format but scaled to the target precision.
*   This is not supported by either Softfloat or by ieee.c, so 
*   these test cases will be deferred until said support is 
*   implemented:  overflow, underflow.  And I may even code those
*   tests in a separate module.  
* 
* Overflow/underflow behavior also means that result registers
*   must be sanitized and allocated in pairs for extended inputs;
*   results must store source format registers, and *Compare
*   must examine both the target precision and the rest of the
*   register.  For the moment, the 'extra' result bits should 
*   be zero, but once underflow/overflow are handled, then
*   we will see results that need source format presentation.  
*
*   Tiny test cases should be considered too.  Later.  
*
* Rounding test cases are needed as follows:
*   Exact results are represented (no rounding needed)
*   Ties are represented, both even (round down) and odd (round up)
*   False exacts are represented
*   Nearest value is toward zero
*   Nearest value is away from zero.
*   Each of the above must be represented in positive and negative.  
*   
* Because rounding decisions are based on the binary significand,
*   there is limited value to considering test case inputs in 
*   decimal form.  The binary representations are all that is 
*   important.  
*
* Three input test data sets are provided, one for long to short, one
*   for extended to short, and one for extended to long.  We cannot use
*   the same extended inputs for long and short results because the 
*   rounding points differ for the two result precisions.  
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
BFPLDRND START 0
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
         ORG   BFPLDRND+X'8E'      Program check interrution code
PCINTCD  DS    H
PCOLDPSW EQU   BFPLDRND+X'150'     Program check old PSW
         ORG   BFPLDRND+X'1A0' 
         DC    X'0000000180000000',AD(START)     z/Arch restart PSW
         ORG   BFPLDRND+X'1D0' 
         DC    X'0000000000000000',AD(PROGCHK)   z/Arch pgm chk
         ORG   BFPLDRND+X'200'
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
         LA    R10,LTOSBAS    Long BFP test inputs
         BAS   R13,LEDBR      Load rounded to short BFP
         LA    R10,LTOSRM     Long BFP inputs for rounding tests
         BAS   R13,LEDBRA     Round to short BFP using rm options
*
         LA    R10,XTOSBAS    Point to extended BFP test inputs
         BAS   R13,LEXBR      Load rounded to short BFP
         LA    R10,XTOSRM     Extended BFP inputs for rounding tests
         BAS   R13,LEXBRA     Round to short BFP using rm options
*
         LA    R10,XTOLBAS    Point to extended BFP test inputs
         BAS   R13,LDXBR      Load rounded to long BFP
         LA    R10,XTOLRM     Extended BFP inputs for rounding tests
         BAS   R13,LDXBRA     Round to long BFP using rm options
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
         ORG   BFPLDRND+X'290'
LTOSBAS  DS    0F           Inputs for long to short BFP tests
         DC    A(LTOSCT/8)
         DC    A(LTOSIN)
         DC    A(LTOSOUT)
         DC    A(LTOSFLGS)
*
XTOSBAS  DS    0F           Inputs for extended to short BFP tests
         DC    A(XTOSCT/16)
         DC    A(XTOSIN)
         DC    A(XTOSOUT)
         DC    A(XTOSFLGS)
*
XTOLBAS  DS    0F           Inputs for extended to long BFP tests
         DC    A(XTOLCT/16)
         DC    A(XTOLIN)
         DC    A(XTOLOUT)
         DC    A(XTOLFLGS)
*
LTOSRM   DS    0F       Inputs for long to short BFP rounding tests
         DC    A(LTOSRMCT/8)
         DC    A(LTOSINRM)
         DC    A(LTOSRMO)
         DC    A(LTOSRMOF)
*
XTOSRM   DS    0F       Inputs for extended to short BFP rounding tests
         DC    A(XTOSRMCT/16)
         DC    A(XTOSINRM)
         DC    A(XTOSRMO)
         DC    A(XTOSRMOF)
*
XTOLRM   DS    0F       Inputs for extended to long BFP rounding tests
         DC    A(XTOLRMCT/16)
         DC    A(XTOLINRM)
         DC    A(XTOLRMO)
         DC    A(XTOLRMOF)
         EJECT
***********************************************************************
*
* Round extended BFP to short BFP.  A pair of results is generated for
* each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR contents are stored for 
* each result.
*
***********************************************************************
          SPACE 2
LEDBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LZDR  R1            Zero FRP1 to clear any residual
         LD    R0,0(0,R3)    Get long BFP test value
         LFPC  FPCREGNT      Set exceptions non-trappable
         LEDBR R1,R0         Cvt float in FPR0 to int float in FPR1
         STE   R1,0(0,R7)    Store short BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LZDR  R1            Zero FRP1 to clear any residual
         LFPC  FPCREGTR      Set exceptions trappable
         LEDBR R1,R0         Cvt float in FPR0 to int float in FPR1
         STE   R1,4(0,R7)    Store short BFP result
         STFPC 4(R8)         Store resulting FPCR flags and DXC
*
         LA    R3,8(0,R3)    point to next input value
         LA    R7,8(0,R7)    point to next result pair
         LA    R8,8(0,R8)    Point to next FPCR result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert long BFP to rounded short BFP using each possible rounding mode.
* Ten test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPCR with
* the IEEE Inexact exception supressed.  SRNM (2-bit) is used  for
* the first two FPCR-controlled tests and SRNMB (3-bit) is used for
* the last two To get full coverage of that instruction pair.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  RNTE is tested
* explicitly as a rounding mode in this section.   
*
LEDBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get long BFP test value
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  1             SET FPCR to RZ, Round towards zero.  
         LEDBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STE   R1,0*4(0,R7)  Store integer BFP result
         STFPC 0(R8)         Store resulting FPCRflags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  2             SET FPCR to RP, Round to +infinity
         LEDBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STE   R1,1*4(0,R7)  Store integer BFP result
         STFPC 1*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 3             SET FPCR to RM, Round to -infinity
         LEDBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STE   R1,2*4(0,R7)  Store integer BFP result
         STFPC 2*4(R8)       Store resulting FPCR flags and DXC
 *
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         LEDBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STE   R1,3*4(0,R7)  Store integer BFP result
         STFPC 3*4(R8)       Store resulting FPCR flags and DXC
*
* Test cases using rounding mode specified in the instruction M3 field
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEDBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         STE   R1,4*4(0,R7)  Store integer BFP result
         STFPC 4*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEDBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         STE   R1,5*4(0,R7)  Store integer BFP result
         STFPC 5*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEDBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         STE   R1,6*4(0,R7)  Store integer BFP result
         STFPC 6*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEDBRA R1,5,R0,B'0000'  RZ Round toward zero
         STE   R1,7*4(0,R7)  Store integer BFP result
         STFPC 7*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEDBRA R1,6,R0,B'0000'  Round to +inf
         STE   R1,8*4(0,R7)  Store integer BFP result
         STFPC 8*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEDBRA R1,7,R0,B'0000'  Round to -inf
         STE   R1,9*4(0,R7)  Store integer BFP result
         STFPC 9*4(R8)       Store resulting FPCR flags and DXC
*
         LA    R3,8(0,R3)    point to next input value
         LA    R7,12*4(0,R7)  Point to next short BFP result pair
         LA    R8,12*4(0,R8)  Point to next FPCR result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* Round extended BFP to short BFP.  A pair of results is genearted for
* each input: one with all exceptions non-trappable, and the second 
* with all exceptions trappable.   The FPCR contents are stored for 
* each result.  
*
***********************************************************************
          SPACE 2
LEXBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get extended BFP test value part 1
         LD    R2,8(0,R3)    Get extended BFP test value part 2
         LFPC  FPCREGNT      Set exceptions non-trappable
         LEXBR R1,R0         Cvt float in FPR0 to Int in GPR1
         STE   R1,0(0,R7)    Store short BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGTR      Set exceptions trappable
         LZDR  R1            Eliminate any residual results
         LEXBR R1,R0         Cvt float in FPR0 to Int in GPR1
         STE   R1,4(0,R7)    Store short BFP result
         STFPC 4(R8)         Store resulting FPCR flags and DXC
*
         LA    R3,16(0,R3)   point to next input value
         LA    R7,8(0,R7)   Point to next long rounded value pair
         LA    R8,8(0,R8)    Point to next FPCR result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert long BFP to integers using each possible rounding mode.  
* Ten test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPCR with
* the IEEE Inexact exception supressed.  SRNM (2-bit) is used  for
* the first two FPCR-controlled tests and SRNMB (3-bit) is used for
* the last two To get full coverage of that instruction pair.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  RNTE is tested
* explicitly as a rounding mode in this section.  
*
LEXBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get long BFP test value
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  1             SET FPCR to RZ, Round towards zero.  
         LEXBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R1,0*4(0,R7)  Store integer BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  2             SET FPCR to RP, Round to +infinity
         LEXBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R1,1*4(0,R7)  Store integer BFP result
         STFPC 1*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 3             SET FPCR to RM, Round to -infinity
         LEXBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R1,2*4(0,R7)  Store integer BFP result
         STFPC 2*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         LEXBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R1,3*4(0,R7)  Store integer BFP result
         STFPC 3*4(R8)       Store resulting FPCR flags and DXC
*
* Test cases using rounding mode specified in the instruction M3 field
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEXBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         STD   R1,4*4(0,R7)  Store integer BFP result
         STFPC 4*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEXBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         STD   R1,5*4(0,R7)  Store integer BFP result
         STFPC 5*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEXBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         STD   R1,6*4(0,R7)  Store integer BFP result
         STFPC 6*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEXBRA R1,5,R0,B'0000'  RZ Round toward zero
         STD   R1,7*4(0,R7)  Store integer BFP result
         STFPC 7*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEXBRA R1,6,R0,B'0000'  Round to +inf
         STD   R1,8*4(0,R7)  Store integer BFP result
         STFPC 8*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LEXBRA R1,7,R0,B'0000'  Round to -inf
         STD   R1,9*4(0,R7)  Store integer BFP result
         STFPC 9*4(R8)       Store resulting FPCR flags and DXC
*
         LA    R3,16(0,R3)   Point to next input value
         LA    R7,12*4(0,R7) Point to next long BFP converted values
         LA    R8,12*4(0,R8) Point to next FPCR/CC result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* Round extended BFP to long BFP.  A pair of results is generated for
* each input: one with all exceptions non-trappable, and the second
* with all exceptions trappable.   The FPCR contents are stored for
* each result.  
*
***********************************************************************
          SPACE 2
LDXBR    LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get extended BFP test value part 1
         LD    R2,8(0,R3)    Get extended BFP test value part 1
         LFPC  FPCREGNT      Set exceptions non-trappable
         LDXBR R1,R0         Round extended in FPR0-FPR2 to long in FPR1
         STD   R1,0(0,R7)    Store rounded long BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGTR      Set exceptions trappable
         LZXR  R1            Eliminate any residual results
         LDXBR R1,R0         Round extended in FPR0-FPR2 to long in FPR1
         STD   R1,8(0,R7)    Store rounded long BFP result
         STFPC 4(R8)         Store resulting FPCR flags and DXC
*
         LA    R3,16(0,R3)   Point to next extended BFP input value
         LA    R7,16(0,R7)   Point to next long BFP rounded value pair
         LA    R8,8(0,R8)    Point to next FPCR result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
*
* Convert extended BFP to integers using each possible rounding mode.
* Ten test results are generated for each input.  A 48-byte test result
* section is used to keep results sets aligned on a quad-double word.
*
* The first four tests use rounding modes specified in the FPCR with
* the IEEE Inexact exception supressed.  SRNM (2-bit) is used  for
* the first two FPCR-controlled tests and SRNMB (3-bit) is used for
* the last two To get full coverage of that instruction pair.  
*
* The next six results use instruction-specified rounding modes.  
*
* The default rounding mode (0 for RNTE) is not tested in this section; 
* prior tests used the default rounding mode.  RNTE is tested
* explicitly as a rounding mode in this section.  
*
LDXBRA   LM    R2,R3,0(R10)  Get count and address of test input values
         LM    R7,R8,8(R10)  Get address of result area and flag area.
         LTR   R2,R2         Any test cases?
         BZR   R13           ..No, return to caller
         BASR  R12,0         Set top of loop
*
         LD    R0,0(0,R3)    Get extended BFP test value part 1
         LD    R2,8(0,R3)    Get extended BFP test value part 2
*
* Test cases using rounding mode specified in the FPCR
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  1             SET FPCR to RZ, Round towards zero.  
         LDXBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R1,0*8(0,R7)  Store rounded long BFP result
         STFPC 0(R8)         Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNM  2             SET FPCR to RP, Round to +infinity
         LDXBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R1,1*8(0,R7)  Store rounded long BFP result 
         STFPC 1*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 3             SET FPCR to RM, Round to -infinity
         LDXBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R1,2*8(0,R7)  Store rounded long BFP result
         STFPC 2*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         SRNMB 7             RPS, Round Prepare for Shorter Precision
         LDXBRA R1,0,R0,B'0100'  FPCR ctl'd rounding, inexact masked
         STD   R1,3*8(0,R7)  Store rounded long BFP result
         STFPC 3*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LDXBRA R1,1,R0,B'0000'  RNTA Round to nearest, ties away from zero
         STD   R1,4*8(0,R7)  Store rounded long BFP result
         STFPC 4*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LDXBRA R1,3,R0,B'0000'  RPS Round to prepare for shorter precision
         STD   R1,5*8(0,R7)  Store rounded long BFP result
         STFPC 5*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LDXBRA R1,4,R0,B'0000'  RNTE Round to nearest, ties to even
         STD   R1,6*8(0,R7)  Store rounded long BFP result
         STFPC 6*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LDXBRA R1,5,R0,B'0000'  RZ Round toward zero
         STD   R1,7*8(0,R7)  Store rounded long BFP result
         STFPC 7*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LDXBRA R1,6,R0,B'0000'  Round to +inf
         STD   R1,8*8(0,R7)  Store rounded long BFP result
         STFPC 8*4(R8)       Store resulting FPCR flags and DXC
*
         LFPC  FPCREGNT      Set exceptions non-trappable, clear flags
         LDXBRA R1,7,R0,B'0000'  Round to -inf
         STD   R1,9*8(0,R7)  Store rounded long BFP result
         STFPC 9*4(R8)       Store resulting FPCR flags and DXC
*
         LA    R3,16(0,R3)    Point to next input value
         LA    R7,10*8(0,R7)  Point to next long BFP rounded result
         LA    R8,12*4(0,R8)  Point to next FPCR result area
         BCTR  R2,R12        Convert next input value.  
         BR    R13           All converted; return.
         EJECT
***********************************************************************
*
* BFP inputs.  One set of longs and two sets of extendeds are included.
* Each set includes input values for basic exception testing and input
* values for exhaustive rounding mode testing.  One set of extended
* inputs is used to generate short results, and the other is used to 
* generate long results.  The same set cannot be used for both long 
* and short because the rounding points are different.  
*
* We can cheat and use the same decimal values for long to short and 
* and extended to short because the result has the same number of
* bits and the rounding uses the same number of bits in the pre-
* rounded result.
*
***********************************************************************
          SPACE 2
*
LTOSIN   DS    0F        Inputs for long to short BFP basic tests
         DC    X'0000000000000000'         +0
         DC    X'3FF8000000000000'         +1.5
         DC    X'BFF8000000000000'         -1.5
         DC    X'7FF0100000000000'         SNaN
         DC    X'7FF8110000000000'         QNaN
         DS    0F           required by asma for following EQU to work.
LTOSCT   EQU   *-LTOSIN     Count of long BFP in list * 8
*
LTOSINRM DS    0F        Inputs for long to short BFP rounding tests
*              x'8000000000000000'    sign bit
*              x'7FF0000000000000'    Biased Exponent
*              x'000FFFFFE0000000'    Significand used in short
*              x'000000001FC00000'    Significand used in rounding
*              x'00000000003FFFFF'    'extra' significand bits
*   Note: in the comments below, 'up' and 'down' mean 'toward 
*   higher magnitude' and 'toward lower magnitude' respectively and
*   without regard to the sign, and rounding is to short BFP.  
*
* Exact (fits in short BFP)   ..  1.99999988079071044921875
         DC    X'3FFFFFFFE0000000'    Positive exact
         DC    X'BFFFFFFFE0000000'    Negative exact
*
* Tie odd - rounds up    ..  1.999999940395355224609375
* rounds up to                ..  2.0
* rounds down to              ..  1.99999988079071044921875
         DC    X'3FFFFFFFF0000000'    Positive tie odd
         DC    X'BFFFFFFFF0000000'    Negative tie odd
*
* Tie even - rounds down ..  1.999999821186065673828125
* rounds up to                ..  1.99999988079071044921875
* rounds down to              ..  1.9999997615814208984375
         DC    X'3FFFFFFFD0000000'    Positive tie even
         DC    X'BFFFFFFFD0000000'    Negative tie even
*
* False exact 1.9999998817220328017896235905936919152736663818359375
* ..rounds up to       2.0
* ..rounds down to     1.99999988079071044921875
         DC    X'3FFFFFFFE03FFFFF'    Positive false exact   
         DC    X'BFFFFFFFE03FFFFF'    Negative false exact
*
* Nearest is towards zero: 1.9999998812563717365264892578125
* ..rounds up to           2.0
* ..rounds down to         1.99999988079071044921875
         DC    X'3FFFFFFFE0200000'    Positive zero closer
         DC    X'BFFFFFFFE0200000'    Negative zero closer
*
* Nearest is away from zero: 1.999999999068677425384521484375
* ..rounds up to             2.0
* ..rounds down to           1.99999988079071044921875
         DC    X'3FFFFFFFFFC00000'    Positive zero further
         DC    X'BFFFFFFFFFC00000'    Negative zero further
         DS    0F           required by asma for following EQU to work.
LTOSRMCT EQU   *-LTOSINRM   Count of long BFP rounding tests * 8
*
XTOSIN   DS    0D        Inputs for extended to short BFP basic tests
         DC    X'00000000000000000000000000000000'         +0
         DC    X'3FFF8000000000000000000000000000'         +1.5
         DC    X'BFFF8000000000000000000000000000'         -1.5
         DC    X'7FFF0100000000000000000000000000'         SNaN
         DC    X'7FFF8110000000000000000000000000'         QNaN
         DS    0D           required by asma for following EQU to work.
XTOSCT   EQU   *-XTOSIN     Count of extended BFP in list * 16
*
XTOSINRM DS    0D     Inputs for extended to short BFP rounding tests
*              x'80000000000000000000000000000000'  sign bit
*              x'7FFF0000000000000000000000000000'  Biased Exponent
*              x'0000FFFFFE0000000000000000000000'  Sig'd used in short
*              x'0000000001FC00000000000000000000'  Sig'd used in rndg
*              x'000000000003FFFFFFFFFFFFFFFFFFFF'  'extra' sig'd bits
*   Note: in the comments below, 'up' and 'down' mean 'toward 
*   higher magnitude' and 'toward lower magnitude' respectively and
*   without regard to the sign, and rounding is to short BFP.  
*
* Exact (fits in short BFP)   ..  1.99999988079071044921875
         DC    X'3FFFFFFFFE0000000000000000000000'    Pos. exact
         DC    X'BFFFFFFFFE0000000000000000000000'    Neg. exact
*
* Tie odd - rounds up    ..  1.999999940395355224609375
* rounds up to                ..  2.0
* rounds down to              ..  1.99999988079071044921875
         DC    X'3FFFFFFFFF0000000000000000000000'    Pos. tie odd
         DC    X'BFFFFFFFFF0000000000000000000000'    Neg. tie odd
*
* Tie even - rounds down ..  1.999999821186065673828125
* rounds up to                ..  1.99999988079071044921875
* rounds down to              ..  1.9999997615814208984375
         DC    X'3FFFFFFFFD0000000000000000000000'    Pos. tie even
         DC    X'BFFFFFFFFD0000000000000000000000'    Neg. tie even
*
* False exact 1.9999998817220330238342285156249998... (continues)
*               ..07407005561276414694402205741507... (continues)
*               ..2681461898351784611804760061204433441162109375
* ..rounds up to       2.0
* ..rounds down to     1.99999988079071044921875
         DC    X'3FFFFFFFFE03FFFFFFFFFFFFFFFFFFFF'    Pos. false exact   
         DC    X'BFFFFFFFFE03FFFFFFFFFFFFFFFFFFFF'    Neg. false exact
*
* Nearest is towards zero: 1.9999998812563717365264892578125
* ..rounds up to           2.0
* ..rounds down to         1.99999988079071044921875
         DC    X'3FFFFFFFFE0200000000000000000000'    Pos. zero closer
         DC    X'BFFFFFFFFE0200000000000000000000'    Neg. zero closer
*
* Nearest is away from zero: 1.999999999068677425384521484375
* ..rounds up to             2.0
* ..rounds down to           1.99999988079071044921875
         DC    X'3FFFFFFFFFFC00000000000000000000'    Pos. zero further
         DC    X'BFFFFFFFFFFC00000000000000000000'    Neg. zero further
         DS    0D           required by asma for following EQU to work.
XTOSRMCT EQU   *-XTOSINRM   Count of extended BFP rounding tests * 16
*
XTOLIN   DS    0D        Inputs for extended to short BFP basic tests
         DC    X'00000000000000000000000000000000'         +0
         DC    X'3FFF8000000000000000000000000000'         +1.5
         DC    X'BFFF8000000000000000000000000000'         -1.5
         DC    X'7FFF0100000000000000000000000000'         SNaN
         DC    X'7FFF8110000000000000000000000000'         QNaN
         DS    0D           required by asma for following EQU to work.
XTOLCT   EQU   *-XTOLIN     Count of extended BFP in list * 16
*
XTOLINRM DS    0D     Inputs for extended to short BFP rounding tests
*              x'80000000000000000000000000000000'  sign bit
*              x'7FFF0000000000000000000000000000'  Biased Exponent
*              x'0000FFFFFFFFFFFFF000000000000000'  Sig'd used in short
*              x'00000000000000000FFC000000000000'  Sig'd used in rndg
*              x'00000000000000000003FFFFFFFFFFFF'  'extra' sig'd bits
*2345678901234567890123456789012345678901234567890123456789012345678901
*   Note: in the comments below, 'up' and 'down' mean 'toward 
*   higher magnitude' and 'toward lower magnitude' respectively and
*   without regard to the sign, and rounding is to short BFP.  
*
*
* Exact (fits in short BFP)   
* ..  1.9999999999999997779553950749686919152736663818359375
*
         DC    X'3FFFFFFFFFFFFFFFF000000000000000'    Pos. exact
         DC    X'BFFFFFFFFFFFFFFFF000000000000000'    Neg. exact
*
*
* Tie odd - rounds up    
* ..  1.99999999999999988897769753748434595763683319091796875
* rounds up to                ..  2.0
* rounds down to
* ..  1.9999999999999997779553950749686919152736663818359375
*
         DC    X'3FFFFFFFFFFFFFFFF800000000000000'    Pos. tie odd
         DC    X'BFFFFFFFFFFFFFFFF800000000000000'    Neg. tie odd
*
*
* Tie even - rounds down 
* ..  1.99999999999999966693309261245303787291049957275390625
* rounds up to                
* ..  1.9999999999999997779553950749686919152736663818359375
* rounds down to
* ..  1.999999999999999555910790149937383830547332763671875
*
         DC    X'3FFFFFFFFFFFFFFFE800000000000000'    Pos. tie even
         DC    X'BFFFFFFFFFFFFFFFE800000000000000'    Neg. tie even
*
*
* False exact 1.9999998817220330238342285156249998... (continues)
*               ..07407005561276414694402205741507... (continues)
*               ..2681461898351784611804760061204433441162109375
* ..rounds up to       2.0
* ..rounds down to
* ..  1.9999999999999997779553950749686919152736663818359375
*
         DC    X'3FFFFFFFFFFFFFFFF003FFFFFFFFFFFF'    Pos. false exact   
         DC    X'BFFFFFFFFFFFFFFFF003FFFFFFFFFFFF'    Neg. false exact
*
*
* Nearest is towards zero: 
* ..  1.99999999999999977817223550946579280207515694200992584228515625
* ..rounds up to           2.0
* ..rounds down to
* ..  1.9999999999999997779553950749686919152736663818359375
*
         DC    X'3FFFFFFFFFFFFFFFF004000000000000'    Pos. zero closer
         DC    X'BFFFFFFFFFFFFFFFF004000000000000'    Neg. zero closer
*
*
* Nearest is away from zero: 
* ..  1.9999999999999999722444243843710864894092082977294921875
* ..rounds up to             2.0
* ..rounds down to
* ..  1.999999999999999555910790149937383830547332763671875
*
         DC    X'3FFFFFFFFFFFFFFFFE00000000000000'    Pos. zero further
         DC    X'BFFFFFFFFFFFFFFFFE00000000000000'    Neg. zero further
         DS    0D           required by asma for following EQU to work.
XTOLRMCT EQU   *-XTOLINRM   Count of extended BFP rounding tests * 16
*
*  Locations for results
*
LTOSOUT  EQU   BFPLDRND+X'1000'    Short BFP rounded from long
*                                  ..5 pairs planned, room for 16
LTOSFLGS EQU   BFPLDRND+X'1080'    FPCR flags and DXC from above
*                                  ..5 pairs planned, room for 16
LTOSRMO  EQU   BFPLDRND+X'1100'    Short BFP result rounding tests
*                                  ..12 sets planned, room for 21
LTOSRMOF EQU   BFPLDRND+X'1500'    FPCR flags and DXC from above
*                                  ..12 sets planned, room for 21
*
XTOSOUT  EQU   BFPLDRND+X'1900'    Short BFP rounded from extended
*                                  ..5 pairs planned, room for 16
XTOSFLGS EQU   BFPLDRND+X'1980'    FPCR flags and DXC from above
*                                  ..5 pairs planned, room for 16
XTOSRMO  EQU   BFPLDRND+X'1A00'    Short BFP rounding tests
*                                  ..12 sets planned, room for 21
XTOSRMOF EQU   BFPLDRND+X'1E00'    FPCR flags and DXC from above
*                                  ..12 sets planned, room for 21

*
XTOLOUT  EQU   BFPLDRND+X'2200'    Long BFP rounded from extended
*                                  ..5 pairs planned, room for 16
XTOLFLGS EQU   BFPLDRND+X'2300'    FPCR flags and DXC from above
*                                  ..5 pairs planned, room for 32
XTOLRMO  EQU   BFPLDRND+X'2400'    Long BFP rounding tests
*                                  ..12 results planned, room for 22
XTOLRMOF EQU   BFPLDRND+X'2B00'    FPCR flags and DXC from above
*                                  ..12 results planned, room for 21
*
*
         END
