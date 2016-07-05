*
*Testcase ieee-cvtfrfix64.tst: IEEE Convert From Fixed (64-bit)
*Message Testcase ieee-cvtfrfix64.tst: IEEE Convert From Fixed (64-bit)
*Message ..Includes CONVERT FROM FIXED 64 (6).  Also tests traps and 
*Message ..exceptions and results from different rounding modes.
#
# CONVERT FROM FIXED tests - Binary Floating Point
#
# Tests the following three conversion instructions
#   CONVERT FROM FIXED (64 to short BFP, RRE)
#   CONVERT FROM FIXED (64 to long BFP, RRE) 
#   CONVERT FROM FIXED (64 to extended BFP, RRE)  
#
# Also tests the following floating point support instructions
#   LOAD  (Short)
#   LOAD  (Long)
#   STORE (Short)
#   STORE (Long)
#
#
sysclear
archmode esame
loadcore $(testpath)/ieee-cvtfrfix64.core

runtest .1

*Program 7
*Compare

r 1000.10  # Inputs converted to BFP short 
*Want "CEGBR result pairs 1-2" 3F800000 3F800000 40000000 40000000
r 1010.10  # Inputs converted to BFP short 
*Want "CEGBR result pairs 3-4" 40800000 40800000 C0000000 C0000000
r 1020.10  # Inputs converted to BFP short 
*Want "CEGBR result pairs 5-6" 5F000000 5F000000 DF000000 DF000000

r 1080.10  # Inputs converted to BFP Short - FPC
*Want "CEGBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
*Compare
r 1090.10  # Inputs converted to BFP Short - FPC
*Want "CEGBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
*Compare
r 10A0.10  # Inputs converted to BFP Short - FPC
*Want "CEGBR FPC pairs 5-6" 00080000 F8000800 00080000 F8000800

r 1100.10  # Rounding Mode Tests positive
*Want "CEGBRA + result FPC modes 1-3, 7" 5EFFFFFF 5F000000 5EFFFFFF 5EFFFFFF
r 1110.10  # Rounding Mode Tests positive
*Want "CEGBRA + result M3 modes 1, 3-5" 5F000000 5EFFFFFF 5F000000 5EFFFFFF
r 1120.08  # Rounding Mode Tests
*Want "CEGBRA + result M3 modes 6, 7" 5F000000 5EFFFFFF
r 1130.10  # Rounding Mode Tests negative
*Want "CEGBRA - result FPC modes 1-3, 7" DEFFFFFF DEFFFFFF DF000000 DEFFFFFF
r 1140.10  # Rounding Mode Tests negative
*Want "CEGBRA - result M3 modes 1, 3-5" DF000000 DEFFFFFF DF000000 DEFFFFFF
r 1150.08  # Rounding Mode Tests negative
*Want "CEGBRA - result M3 modes 6, 7" DEFFFFFF DF000000

*Compare
r 1180.10  # Rounding Mode Tests - FPC positive
*Want "CEGBRA + FPC modes 1-3, 74 FCPR" 00000001 00000002 00000003 00000007
r 1190.10  # Rounding Mode Tests - FPC positive
*Want "CEGBRA + M3 modes 1, 3-5 FPCR" 00080000 00080000 00080000 00080000
r 11A0.08  # Rounding Mode Tests - FPC positive
*Want "CEGBRA + M3 modes 6, 7 FPCR" 00080000 00080000
r 11B0.10  # Rounding Mode Tests - FPC negative
*Want "CEGBRA - FPC modes 1-3, 74 FCPR" 00000001 00000002 00000003 00000007
r 11C0.10  # Rounding Mode Tests - FPC negative
*Want "CEGBRA - M3 modes 1, 3-5 FPCR" 00080000 00080000 00080000 00080000
r 11D0.08  # Rounding Mode Tests - FPC negative
*Want "CEGBRA - M3 modes 6, 7 FPCR" 00080000 00080000

*Compare
r 1200.10  # Inputs converted to BFP long first pair
*Want "CDGBR result pair 1" 3FF00000 00000000 3FF00000 00000000
r 1210.10  # Inputs converted to BFP long second pair
*Want "CDGBR result pair 2" 40000000 00000000 40000000 00000000 
r 1220.10  # Inputs converted to BFP long third pair
*Want "CDGBR result pair 3" 40100000 00000000 40100000 00000000
r 1230.10  # Inputs converted to BFP long fourth pair
*Want "CDGBR result pair 4" C0000000 00000000 C0000000 00000000
r 1240.10  # Inputs converted to BFP long fifth pair
*Want "CDGBR result pair 5" 43E00000 00000000 43E00000 00000000
r 1250.10  # Inputs converted to BFP long sixth pair
*Want "CDGBR result pair 6" C3E00000 00000000 C3E00000 00000000

*Compare
r 1300.10  # Inputs converted to BFP Long - FPC
*Want "CDGBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1310.10  # Inputs converted to BFP Long - FPC
*Want "CDGBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 1320.10  # Inputs converted to BFP Long - FPC
*Want "CDGBR FPC pairs 5-6" 00080000 F8000800 00080000 F8000800

*Compare
r 1380.10  # Rounding Mode Test FPC modes 1, 2
*Want "CDGBRA + FPC modes 1, 2" 43DFFFFF FFFFFFFF 43E00000 00000000
r 1390.10  # Rounding Mode Test FPC modes 3, 7
*Want "CDGBRA + FPC modes 3, 7" 43DFFFFF FFFFFFFF 43DFFFFF FFFFFFFF
r 13A0.10  # Rounding Mode Test M3 modes 1, 3
*Want "CDGBRA + M3 modes 1, 3"  43E00000 00000000 43DFFFFF FFFFFFFF
r 13B0.10  # Rounding Mode Test M3 modes 4, 5
*Want "CDGBRA + M3 modes 4, 5"  43E00000 00000000 43DFFFFF FFFFFFFF
r 13C0.10  # Rounding Mode Test M3 modes 6, 7
*Want "CDGBRA + M3 modes 6, 7"  43E00000 00000000 43DFFFFF FFFFFFFF
r 13D0.10  # Rounding Mode Test FPC modes 1, 2
*Want "CDGBRA - FPC modes 1, 2" C3DFFFFF FFFFFFFF C3DFFFFF FFFFFFFF
r 13E0.10  # Rounding Mode Test FPC modes 3, 7
*Want "CDGBRA - FPC modes 3, 7" C3E00000 00000000 C3DFFFFF FFFFFFFF
r 13F0.10  # Rounding Mode Test M3 modes 1, 3
*Want "CDGBRA - M3 modes 1, 3"  C3E00000 00000000 C3DFFFFF FFFFFFFF
r 1400.10  # Rounding Mode Test M3 modes 4, 5
*Want "CDGBRA - M3 modes 4, 5"  C3E00000 00000000 C3DFFFFF FFFFFFFF
r 1410.10  # Rounding Mode Test M3 modes 6, 7
*Want "CDGBRA - M3 modes 6, 7"  C3DFFFFF FFFFFFFF C3E00000 00000000

*Compare
r 1480.10  # Rounding Mode Tests - FPC positive
*Want "CDGBRA + FPC modes 1-3, 74 FCPR" 00000001 00000002 00000003 00000007
r 1490.10  # Rounding Mode Tests - FPC positive
*Want "CDGBRA + M3 modes 1, 3-5 FPCR" 00080000 00080000 00080000 00080000
r 14A0.08  # Rounding Mode Tests - FPC positive
*Want "CDGBRA + M3 modes 6, 7 FPCR" 00080000 00080000
r 14B0.10  # Rounding Mode Tests - FPC negative
*Want "CDGBRA - FPC modes 1-3, 74 FCPR" 00000001 00000002 00000003 00000007
r 14C0.10  # Rounding Mode Tests - FPC negative
*Want "CDGBRA - M3 modes 1, 3-5 FPCR" 00080000 00080000 00080000 00080000
r 14D0.08  # Rounding Mode Tests - FPC negative
*Want "CDGBRA - M3 modes 6, 7 FPCR" 00080000 00080000


*Compare
r 1500.10  # Inputs converted to BFP ext 1a expecting 1
*Want "CXGBR result 1a" 3FFF0000 00000000 00000000 00000000
*Compare
r 1510.10  # Inputs converted to BFP ext 1b expecting 1
*Want "CXGBR result 1b" 3FFF0000 00000000 00000000 00000000
*Compare
r 1520.10  # Inputs converted to BFP ext 2a expecting 2
*Want "CXGBR result 2a" 40000000 00000000 00000000 00000000
*Compare
r 1530.10  # Inputs converted to BFP ext 2b expecting 2
*Want "CXGBR result 2b" 40000000 00000000 00000000 00000000
*Compare
r 1540.10  # Inputs converted to BFP ext 3a expecting 4
*Want "CXGBR result 3a" 40010000 00000000 00000000 00000000
*Compare
r 1550.10  # Inputs converted to BFP ext 3b expecting 4
*Want "CXGBR result 3b" 40010000 00000000 00000000 00000000
*Compare
r 1560.10  # Inputs converted to BFP ext 4a expecting -2
*Want "CXGBR result 4a" C0000000 00000000 00000000 00000000
*Compare
r 1570.10  # Inputs converted to BFP ext 4b expecting -2
*Want "CXGBR result 4b" C0000000 00000000 00000000 00000000
*Compare
r 1580.10  # Inputs converted to BFP ext 5a
*Want "CXGBR result 5a" 403DFFFF FFFFFFFF FFFC0000 00000000
*Compare
r 1590.10  # Inputs converted to BFP ext 5b
*Want "CXGBR result 5b" 403DFFFF FFFFFFFF FFFC0000 00000000
*Compare
r 15A0.10  # Inputs converted to BFP ext 6a
*Want "CXGBR result 6a" C03DFFFF FFFFFFFF FFFC0000 00000000
*Compare
r 15B0.10  # Inputs converted to BFP ext 6b
*Want "CXGBR result 6b" C03DFFFF FFFFFFFF FFFC0000 00000000

*Compare
r 1700.10  # Inputs converted to BFP extended - FPC
*Want "CXGBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1710.10  # Inputs converted to BFP extended - FPC
*Want "CXGBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 1720.10  # Inputs converted to BFP extended - FPC
*Want "CXGBR FPC pairs 5-6" 00000000 F8000000 00000000 F8000000


*Done

