*
*Testcase ieee-cvtfrlog.tst: IEEE Convert From Logical
*Message Testcase ieee-cvtfrlog.tst: IEEE Convert From Logical
*Message ..Includes CONVERT FROM LOGICAL 32 (3).  Also tests traps and exceptions
*Message ..and results from different rounding modes (CELFBR only).
#
# CONVERT FROM LOGICAL tests - Binary Floating Point
#
# Tests the following three conversion instructions
#   CONVERT TO LOGICAL (32 to short BFP, RRF-e)
#   CONVERT TO LOGICAL (32 to long BFP, RRF-e) 
#   CONVERT TO LOGICAL (32 to extended BFP, RRF-e)  
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
loadcore $(testpath)/ieee-cvtfrlog.core

runtest .1

*Program 7

# inputs converted to BFP short - result values
*Compare
r 1000.10
*Want "CELFBR result pairs 1-2" 3F800000 3F800000 40000000 40000000
r 1010.10
*Want "CELFBR result pairs 3-4" 40800000 40800000 41100000 41100000
r 1020.10
*Want "CELFBR result pairs 5-6" 4F800000 4F800000 4F7FFFFF 4F7FFFFF

# inputs converted to BFP short - FPCR contents
*Compare
r 1080.10
*Want "CELFBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1090.10
*Want "CELFBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 10A0.10
*Want "CELFBR FPC pairs 5-6" 00080000 F8000800 00000000 F8000000

# inputs converted to BFP short - rounding mode test results
*Compare
r 1100.10
*Want "CELFBR maxint-32 result FPC modes 1-3, 7" 4F7FFFFF 4F800000 4F7FFFFF 4F7FFFFF
r 1110.10
*Want "CELFBR maxint-32 result M3 modes 1, 3-5"  4F800000 4F7FFFFF 4F800000 4F7FFFFF
r 1120.08
*Want "CELFBR maxint-32 result M3 modes 6, 7"    4F800000 4F7FFFFF

r 1130.10
*Want "CELFBR 0xFFFFFF00 result FPC modes 1-3, 7" 4F7FFFFF 4F7FFFFF 4F7FFFFF 4F7FFFFF
r 1140.10
*Want "CELFBR 0xFFFFFF00 result M3 modes 1, 3-5"  4F7FFFFF 4F7FFFFF 4F7FFFFF 4F7FFFFF 
r 1150.08
*Want "CELFBR 0xFFFFFF00 result M3 modes 6, 7"    4F7FFFFF 4F7FFFFF

# inputs converted to BFP short - rounding mode test FPCR contents
*Compare
r 1180.10
*Want "CELFBR maxint-32 FPC modes 1-3, 7 FPCR"  00000001 00000002 00000003 00000007
r 1190.10
*Want "CELFBR maxint-32 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 11A0.08
*Want "CELFBR maxint-32 M3 modes 5-7"           00080000 00080000

r 11B0.10
*Want "CELFBR 0xFFFFFF00 FPC modes 1-3, 7 FPCR"  00000001 00000002 00000003 00000007
r 11C0.10
*Want "CELFBR 0xFFFFFF00 M3 modes 1, 3-5 FPCR"   00000000 00000000 00000000 00000000
r 11D0.08
*Want "CELFBR 0xFFFFFF00 M3 modes 6-7"           00000000 00000000

# inputs converted to BFP long - result values
*Compare
r 1200.10
*Want "CDLFBR result pair 1" 3FF00000 00000000 3FF00000 00000000
r 1210.10
*Want "CDLFBR result pair 2" 40000000 00000000 40000000 00000000 
r 1220.10
*Want "CDLFBR result pair 3" 40100000 00000000 40100000 00000000
r 1230.10
*Want "CDLFBR result pair 4" 40220000 00000000 40220000 00000000
r 1240.10
*Want "CDLFBR result pair 5" 41EFFFFF FFC00000 41EFFFFF FFC00000
r 1250.10
*Want "CDLFBR result pair 6" 41EFFFFF E0000000 41EFFFFF E0000000

# Inputs converted to BFP long - FPCR contents
*Compare
r 1300.10
*Want "CDLFBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1310.10
*Want "CDLFBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 1320.10
*Want "CDLFBR FPC pairs 5-6" 00000000 F8000000 00000000 F8000000

# Inputs converted to BFP extended - result values
*Compare
r 1400.10
*Want "CXLFBR result 1a" 3FFF0000 00000000 00000000 00000000
r 1410.10
*Want "CXLFBR result 1b" 3FFF0000 00000000 00000000 00000000
r 1420.10
*Want "CXLFBR result 2a" 40000000 00000000 00000000 00000000
r 1430.10
*Want "CXLFBR result 2b" 40000000 00000000 00000000 00000000
r 1440.10
*Want "CXLFBR result 3a" 40010000 00000000 00000000 00000000
r 1450.10
*Want "CXLFBR result 3b" 40010000 00000000 00000000 00000000
r 1460.10
*Want "CXLFBR result 4a" 40022000 00000000 00000000 00000000
r 1470.10
*Want "CXLFBR result 4b" 40022000 00000000 00000000 00000000
r 1480.10
*Want "CXLFBR result 5a" 401EFFFF FFFC0000 00000000 00000000
r 1490.10
*Want "CXLFBR result 5b" 401EFFFF FFFC0000 00000000 00000000
r 14A0.10
*Want "CXLFBR result 6a" 401EFFFF FE000000 00000000 00000000
r 14B0.10
*Want "CXLFBR result 6b" 401EFFFF FE000000 00000000 00000000

# Inputs converted to BFP extended - FPCR contents
*Compare
r 1600.10
*Want "CXLFBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1610.10
*Want "CXLFBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 1620.10
*Want "CXLFBR FPC pairs 5-6" 00000000 F8000000 00000000 F8000000


*Done

