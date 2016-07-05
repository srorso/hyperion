*
*Testcase ieee-cvtfrfix.tst: IEEE Convert From Fixed
*Message Testcase ieee-cvtfrfix.tst: IEEE Convert From Fixed
*Message ..Includes CONVERT FROM FIXED 32 (6).  Also tests traps and 
*Message ..exceptions and results from different rounding modes.
#
# CONVERT FROM FIXED tests - Binary Floating Point
#
# Tests the following three conversion instructions
#   CONVERT FROM FIXED (32 to short BFP, RRE)
#   CONVERT FROM FIXED (32 to long BFP, RRE) 
#   CONVERT FROM FIXED (32 to extended BFP, RRE)  
#   CONVERT TO FIXED (32 to short BFP, RRE)
#   CONVERT TO FIXED (32 to long BFP, RRE) 
#   CONVERT TO FIXED (32 to extended BFP, RRE)  
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
loadcore $(testpath)/ieee-cvtfrfix.core
runtest .1

*Program 7
*Compare
r 1000.10  # Inputs converted to BFP short 
*Want "CEFBR result pairs 1-2" 3F800000 3F800000 40000000 40000000
*Compare
r 1010.10  # Inputs converted to BFP short 
*Want "CEFBR result pairs 3-4" 40800000 40800000 C0000000 C0000000
*Compare
r 1020.8  # Inputs converted to BFP short 
*Want "CEFBR result pair 5" 4F000000 4F000000

*Compare
r 1080.10  # Inputs converted to BFP Short - FPC
*Want "CEFBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
*Compare
r 1090.10  # Inputs converted to BFP Short - FPC
*Want "CEFBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
*Compare
r 10A0.10  # Inputs converted to BFP Short - FPC
*Want "CEFBR FPC pairs 5-6" 00080000 F8000800 00080000 F8000800

*Compare
r 1100.10  # Rounding Mode Tests positive
*Want "CEFBRA + result FPC modes 1-3, 7" 4EFFFFFF 4F000000 4EFFFFFF 4EFFFFFF
r 1110.10  # Rounding Mode Tests positive
*Compare
*Want "CEFBRA + result M3 modes 1, 3-5" 4F000000 4EFFFFFF 4F000000 4EFFFFFF
*Compare
r 1120.08  # Rounding Mode Tests
*Want "CEFBRA + result M3 modes 6, 7" 4F000000 4EFFFFFF
*Compare
r 1130.10  # Rounding Mode Tests negative
*Want "CEFBRA - result FPC modes 1-3, 7" CEFFFFFF CEFFFFFF CF000000 CEFFFFFF
*Compare
r 1140.10  # Rounding Mode Tests negative
*Want "CEFBRA - result M3 modes 1, 3-5" CF000000 CEFFFFFF CF000000 CEFFFFFF 
*Compare
r 1150.08  # Rounding Mode Tests negative
*Want "CEFBRA - result M3 modes 6, 7" CEFFFFFF CF000000

*Compare
r 1180.10  # Rounding Mode Tests - FPC
*Want "CEFBRA + FPC modes 1-3, 74 FCPR" 00000001 00000002 00000003 00000007
r 1190.10  # Rounding Mode Tests - FPC
*Want "CEFBRA + M3 modes 1, 3-5 FPCR" 00080000 00080000 00080000 00080000
r 11A0.08  # Rounding Mode Tests - FPC
*Want "CEFBRA + M3 modes 5-7" 00080000 00080000
r 11B0.10  # Rounding Mode Tests - FPC
*Want "CEFBRA - FPC modes 1-3, 74 FCPR" 00000001 00000002 00000003 00000007
r 11C0.10  # Rounding Mode Tests - FPC
*Want "CEFBRA - M3 modes 1, 3-5 FPCR" 00080000 00080000 00080000 00080000
r 11D0.08  # Rounding Mode Tests - FPC
*Want "CEFBRA - M3 modes 5-7" 00080000 00080000

*Compare
r 1200.10  # Inputs converted to BFP long first pair
*Want "CDFBR result pair 1" 3FF00000 00000000 3FF00000 00000000
*Compare
r 1210.10  # Inputs converted to BFP long second pair
*Want "CDFBR result pair 2" 40000000 00000000 40000000 00000000 
*Compare
r 1220.10  # Inputs converted to BFP long third pair
*Want "CDFBR result pair 3" 40100000 00000000 40100000 00000000
*Compare
r 1230.10  # Inputs converted to BFP long fourth pair
*Want "CDFBR result pair 4" C0000000 00000000 C0000000 00000000
*Compare
r 1240.10  # Inputs converted to BFP long fifth pair
*Want "CDFBR result pair 5" 41DFFFFF FFC00000 41DFFFFF FFC00000
*Compare
r 1250.10  # Inputs converted to BFP long sixth pair
*Want "CDFBR result pair 6" C1DFFFFF FFC00000 C1DFFFFF FFC00000

*Compare
r 1300.10  # Inputs converted to BFP Long - FPC
*Want "CDFBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1310.10  # Inputs converted to BFP Long - FPC
*Want "CDFBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 1320.10  # Inputs converted to BFP Long - FPC
*Want "CDFBR FPC pairs 5-6" 00000000 F8000000 00000000 F8000000

*Compare
r 1400.10  # Inputs converted to BFP ext 1a expecting 1
*Want "CXFBR result 1a" 3FFF0000 00000000 00000000 00000000
*Compare
r 1410.10  # Inputs converted to BFP ext 1b expecting 1
*Want "CXFBR result 1b" 3FFF0000 00000000 00000000 00000000
*Compare
r 1420.10  # Inputs converted to BFP ext 2a expecting 2
*Want "CXFBR result 2a" 40000000 00000000 00000000 00000000
*Compare
r 1430.10  # Inputs converted to BFP ext 2b expecting 2
*Want "CXFBR result 2b" 40000000 00000000 00000000 00000000
*Compare
r 1440.10  # Inputs converted to BFP ext 3a expecting 4
*Want "CXFBR result 3a" 40010000 00000000 00000000 00000000
*Compare
r 1450.10  # Inputs converted to BFP ext 3b expecting 4
*Want "CXFBR result 3b" 40010000 00000000 00000000 00000000
*Compare
r 1460.10  # Inputs converted to BFP ext 4a expecting -2
*Want "CXFBR result 4a" C0000000 00000000 00000000 00000000
*Compare
r 1470.10  # Inputs converted to BFP ext 4b expecting -2
*Want "CXFBR result 4b" C0000000 00000000 00000000 00000000
*Compare
r 1480.10  # Inputs converted to BFP ext 5a
*Want "CXFBR result 5a" 401DFFFF FFFC0000 00000000 00000000
*Compare
r 1490.10  # Inputs converted to BFP ext 5b
*Want "CXFBR result 5b" 401DFFFF FFFC0000 00000000 00000000
*Compare
r 14A0.10  # Inputs converted to BFP ext 6a
*Want "CXFBR result 6a" C01DFFFF FFFC0000 00000000 00000000
*Compare
r 14B0.10  # Inputs converted to BFP ext 6b
*Want "CXFBR result 6b" C01DFFFF FFFC0000 00000000 00000000

*Compare
r 1600.10  # Inputs converted to BFP extended - FPC
*Want "CXFBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1610.10  # Inputs converted to BFP extended - FPC
*Want "CXFBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 1620.10  # Inputs converted to BFP extended - FPC
*Want "CXFBR FPC pairs 5-6" 00000000 F8000000 00000000 F8000000


*Done

