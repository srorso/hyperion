*
*Testcase ieee-cvtfrfix.tst: IEEE Convert From Fixed
*Message Testcase ieee-cvtfrfix.tst: IEEE Convert From Fixed
*Message ..Includes CONVERT FROM FIXED 32 (6).  Also tests traps and 
*Message ..exceptions and results from different rounding modes.
#
# CONVERT FROM FIXED tests - Binary Floating Point
#
# Tests the following six conversion instructions
#   CONVERT FROM FIXED (32 to short BFP, RRE)
#   CONVERT FROM FIXED (32 to long BFP, RRE) 
#   CONVERT FROM FIXED (32 to extended BFP, RRE)  
#   CONVERT FROM FIXED (32 to short BFP, RRF-e)
#   CONVERT FROM FIXED (32 to long BFP, RRF-e) 
#   CONVERT FROM FIXED (32 to extended BFP, RRF-e)  
#
# Also tests the following floating point support instructions
#   LOAD  (Short)
#   LOAD  (Long)
#   LOAD FPC
#   SET BFP ROUNDING MODE 2-BIT
#   SET BFP ROUNDING MODE 3-BIT
#   STORE (Short)
#   STORE (Long)
#   STORE FPC
#
#
sysclear
archmode esame
loadcore $(testpath)/ieee-cvtfrfix.core
runtest .1

*Program 7

# Inputs converted to short BFP
*Compare
r 1000.10
*Want "CEFBR result pairs 1-2"   3F800000 3F800000 40000000 40000000
r 1010.10
*Want "CEFBR result pairs 3-4"   40800000 40800000 C0000000 C0000000
r 1020.10
*Want "CEFBR result pairs 5-6"   4F000000 4F000000 CF000000 CF000000

# Inputs converted to short BFP - FPCR contents
*Compare
r 1080.10
*Want "CEFBR FPC pairs 1-2"      00000000 F8000000 00000000 F8000000
r 1090.10
*Want "CEFBR FPC pairs 3-4"      00000000 F8000000 00000000 F8000000
r 10A0.10
*Want "CEFBR FPC pairs 5-6"      00080000 F8000800 00080000 F8000800

# Short BFP rounding mode tests - FPCR & M3 modes, positive & negative inputs
*Compare
r 1100.10                            RZ       RP       RM       RFS
*Want "CEFBRA + FPC modes 1-3, 7"  4EFFFFFF 4F000000 4EFFFFFF 4EFFFFFF
r 1110.10                            RNTA     RFS      RNTE     RZ
*Want "CEFBRA + M3 modes 1, 3-5"   4F000000 4EFFFFFF 4F000000 4EFFFFFF
r 1120.08                            RP       RM
*Want "CEFBRA + M3 modes 6, 7"     4F000000 4EFFFFFF

r 1130.10                            RZ       RP       RM       RFS
*Want "CEFBRA - FPC modes 1-3, 7"  CEFFFFFF CEFFFFFF CF000000 CEFFFFFF
r 1140.10                            RNTA     RFS      RNTE     RZ
*Want "CEFBRA - M3 modes 1, 3-5"   CF000000 CEFFFFFF CF000000 CEFFFFFF 
r 1150.08                            RP       RM
*Want "CEFBRA - M3 modes 6, 7"     CEFFFFFF CF000000

*Compare
r 1180.10                                 RZ       RP       RM       RFS
*Want "CEFBRA + FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1190.10                                 RNTA     RFS      RNTE     RZ
*Want "CEFBRA + M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 11A0.08                                 RP       RM
*Want "CEFBRA + M3 modes 6, 7 FPCR"     00080000 00080000

r 11B0.10                                 RZ       RP       RM       RFS
*Want "CEFBRA - FPC modes 1-3, 7 FPCR"  00000001 00000002 00000003 00000007
r 11C0.10                                 RNTA     RFS      RNTE     RZ
*Want "CEFBRA - M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 11D0.08                                 RP       RM
*Want "CEFBRA - M3 modes 6, 7 FPCR"     00080000 00080000


# Inputs converted to long BFP
*Compare
r 1200.10
*Want "CDFBR result pair 1" 3FF00000 00000000 3FF00000 00000000
r 1210.10
*Want "CDFBR result pair 2" 40000000 00000000 40000000 00000000 
r 1220.10
*Want "CDFBR result pair 3" 40100000 00000000 40100000 00000000
r 1230.10
*Want "CDFBR result pair 4" C0000000 00000000 C0000000 00000000
r 1240.10
*Want "CDFBR result pair 5" 41DFFFFF FFC00000 41DFFFFF FFC00000
r 1250.10
*Want "CDFBR result pair 6" C1DFFFFF FFC00000 C1DFFFFF FFC00000

# Inputs converted to long BFP - FPCR contents
*Compare
r 1300.10
*Want "CDFBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1310.10
*Want "CDFBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 1320.10
*Want "CDFBR FPC pairs 5-6" 00000000 F8000000 00000000 F8000000


# Inputs converted to extended BFP
*Compare
r 1400.10
*Want "CXFBR result 1a" 3FFF0000 00000000 00000000 00000000
r 1410.10
*Want "CXFBR result 1b" 3FFF0000 00000000 00000000 00000000
r 1420.10
*Want "CXFBR result 2a" 40000000 00000000 00000000 00000000
r 1430.10
*Want "CXFBR result 2b" 40000000 00000000 00000000 00000000
r 1440.10
*Want "CXFBR result 3a" 40010000 00000000 00000000 00000000
r 1450.10
*Want "CXFBR result 3b" 40010000 00000000 00000000 00000000
r 1460.10
*Want "CXFBR result 4a" C0000000 00000000 00000000 00000000
r 1470.10
*Want "CXFBR result 4b" C0000000 00000000 00000000 00000000
r 1480.10
*Want "CXFBR result 5a" 401DFFFF FFFC0000 00000000 00000000
r 1490.10
*Want "CXFBR result 5b" 401DFFFF FFFC0000 00000000 00000000
r 14A0.10
*Want "CXFBR result 6a" C01DFFFF FFFC0000 00000000 00000000
r 14B0.10
*Want "CXFBR result 6b" C01DFFFF FFFC0000 00000000 00000000

# Inputs converted to extended BFP - FPCR contents
*Compare
r 1600.10
*Want "CXFBR FPC pairs 1-2" 00000000 F8000000 00000000 F8000000
r 1610.10
*Want "CXFBR FPC pairs 3-4" 00000000 F8000000 00000000 F8000000
r 1620.10
*Want "CXFBR FPC pairs 5-6" 00000000 F8000000 00000000 F8000000


*Done

