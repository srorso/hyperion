*
*Testcase ieee-cvttolog64.tst: IEEE Convert To Logical
*Message Testcase ieee-cvtfrLOG64.tst: IEEE Convert To Logical
*Message ..Includes CONVERT TO LOGICAL 64 (3).  Tests traps, exceptions, results
*Message ..from different rounding modes, and NaN propagation.
#
# CONVERT TO LOGICAL tests - Binary Floating Point
#
# Tests the following three conversion instructions
#   CONVERT TO LOGICAL (short BFP to int-64, RRF-e)
#   CONVERT TO LOGICAL (long BFP to int-64, RRF-e) 
#   CONVERT TO LOGICAL (extended BFP to int-64, RRF-e)
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
loadcore $(testpath)/ieee-cvttolog64.core

runtest .1

*Program 7
r 1000.1000

# BFP short inputs converted to uint-64 - results
*Compare
r 1000.10  
*Want "CLGEBR result pair 1" 00000000 00000001 00000000 00000001
r 1010.10
*Want "CLGEBR result pair 2" 00000000 00000002 00000000 00000002
r 1020.10
*Want "CLGEBR result pair 3" 00000000 00000004 00000000 00000004
r 1030.10
*Want "CLGEBR result pair 4" 00000000 00000000 00000000 00000000
r 1040.10
*Want "CLGEBR result pair 5" 00000000 00000000 00000000 00000000
r 1050.10
*Want "CLGEBR result pair 6" 00000000 00000000 00000000 00000000

# I am not satisfied with test case 6  further investigation needed. 
# It would appear that f32_to_uint64 is returning invalid and max uint-64.

# Short BFP inputs converted to uint-64 - FPCR contents
*Compare
r 1100.10 - FPC
*Want "CLGEBR FPC pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1110.10 - FPC
*Want "CLGEBR FPC pairs 3-4" 00000002 F8000002 00880003 F8008000
r 1120.10
*Want "CLGEBR FPC pairs 5-6" 00880003 F8008000 00880003 F8008000


#  short BFP inputs converted to uint-64 - results from rounding
*Compare
r 1200.10                            RZ,               RP
*Want "CLGEBR -1.5 FPC modes 1, 2" 00000000 00000000 00000000 00000000
r 1210.10                            RM,               RFS
*Want "CLGEBR -1.5 FPC modes 3, 7" 00000000 00000000 00000000 00000000
r 1220.10                            RNTA,             RFS
*Want "CLGEBR -1.5 M3 modes 1, 3"  00000000 00000000 00000000 00000000
r 1230.10                            RNTE,             RZ
*Want "CLGEBR -1.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 1240.10                            RP,               RM
*Want "CLGEBR -1.5 M3 modes 6, 7"  00000000 00000000 00000000 00000000

r 1250.10                            RZ,               RP
*Want "CLGEBR -0.5 FPC modes 1, 2" 00000000 00000000 00000000 00000000
r 1260.10                            RM,               RFS
*Want "CLGEBR -0.5 FPC modes 3, 7" 00000000 00000000 00000000 00000000
r 1270.10                            RNTA,             RFS
*Want "CLGEBR -0.5 M3 modes 1, 3"  00000000 00000000 00000000 00000000
r 1280.10                            RNTE,             RZ
*Want "CLGEBR -0.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 1290.10                            RP,               RM
*Want "CLGEBR -0.5 M3 modes 6, 7"  00000000 00000000 00000000 00000000

r 12A0.10                            RZ,               RP
*Want "CLGEBR +0.5 FPC modes 1, 2" 00000000 00000000 00000000 00000001
r 12B0.10                            RM,               RFS
*Want "CLGEBR +0.5 FPC modes 3, 7" 00000000 00000000 00000000 00000001
r 12C0.10                            RNTA,             RFS
*Want "CLGEBR +0.5 M3 modes 1, 3"  00000000 00000001 00000000 00000001
r 12D0.10                            RNTE,             RZ
*Want "CLGEBR +0.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 12E0.10                            RP,               RM
*Want "CLGEBR +0.5 M3 modes 6, 7"  00000000 00000001 00000000 00000000

r 12F0.10                            RZ,               RP
*Want "CLGEBR +1.5 FPC modes 1, 2" 00000000 00000001 00000000 00000002
r 1300.10                            RM,               RFS
*Want "CLGEBR +1.5 FPC modes 3, 7" 00000000 00000001 00000000 00000001
r 1310.10                            RNTA,             RFS
*Want "CLGEBR +1.5 M3 modes 1, 3"  00000000 00000002 00000000 00000001
r 1320.10                            RNTE,             RZ
*Want "CLGEBR +1.5 M3 modes 4, 5"  00000000 00000002 00000000 00000001
r 1330.10                            RP,               RM
*Want "CLGEBR +1.5 M3 modes 6, 7"  00000000 00000002 00000000 00000001

r 1340.10                            RZ,               RP
*Want "CLGEBR +2.5 FPC modes 1, 2" 00000000 00000002 00000000 00000003
r 1350.10                            RM,               RFS
*Want "CLGEBR +2.5 FPC modes 3, 7" 00000000 00000002 00000000 00000003
r 1360.10                            RNTA,             RFS
*Want "CLGEBR +2.5 M3 modes 1, 3"  00000000 00000003 00000000 00000003
r 1370.10                            RNTE,             RZ
*Want "CLGEBR +2.5 M3 modes 4, 5"  00000000 00000002 00000000 00000002
r 1380.10                            RP,               RM
*Want "CLGEBR +2.5 M3 modes 6, 7"  00000000 00000003 00000000 00000002

r 1390.10                            RZ,               RP
*Want "CLGEBR +5.5 FPC modes 1, 2" 00000000 00000005 00000000 00000006
r 13A0.10                            RM,               RFS
*Want "CLGEBR +5.5 FPC modes 3, 7" 00000000 00000005 00000000 00000005
r 13B0.10                            RNTA,             RFS
*Want "CLGEBR +5.5 M3 modes 1, 3"  00000000 00000006 00000000 00000005
r 13C0.10                            RNTE,             RZ
*Want "CLGEBR +5.5 M3 modes 4, 5"  00000000 00000006 00000000 00000005
r 13D0.10                            RP,               RM
*Want "CLGEBR +5.5 M3 modes 6, 7"  00000000 00000006 00000000 00000005

r 13E0.10                            RZ,               RP
*Want "CLGEBR +9.5 FPC modes 1, 2" 00000000 00000009 00000000 0000000A
r 13F0.10                            RM,               RFS
*Want "CLGEBR +9.5 FPC modes 3, 7" 00000000 00000009 00000000 00000009
r 1400.10                            RNTA,             RFS
*Want "CLGEBR +9.5 M3 modes 1, 3"  00000000 0000000A 00000000 00000009
r 1410.10                            RNTE,             RZ
*Want "CLGEBR +9.5 M3 modes 4, 5"  00000000 0000000A 00000000 00000009
r 1420.10                            RP,               RM
*Want "CLGEBR +9.5 M3 modes 6, 7"  00000000 0000000A 00000000 00000009

r 1430.10                            RZ,               RP
*Want "CLGEBR max FPC modes 1, 2"  FFFFFF00 00000000 FFFFFF00 00000000
r 1440.10                            RM,               RFS
*Want "CLGEBR max FPC modes 3, 7"  FFFFFF00 00000000 FFFFFF00 00000000
r 1450.10                            RNTA,             RFS
*Want "CLGEBR max M3 modes 1, 3"   FFFFFF00 00000000 FFFFFF00 00000000
r 1460.10                            RNTE,             RZ
*Want "CLGEBR max M3 modes 4, 5"   FFFFFF00 00000000 FFFFFF00 00000000
r 1470.10                            RP,               RM
*Want "CLGEBR max M3 modes 6, 7"   FFFFFF00 00000000 FFFFFF00 00000000


#  short BFP inputs converted to uint-64 - FPCR with cc in last byte
*Compare 
r 1500.10
*Want "CLGEBR -1.5 FPC modes 1-3, 7 FPCR"  00800003 00800003 00800003 00800003
r 1510.10
*Want "CLGEBR -1.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00880003 00880003
r 1520.08
*Want "CLGEBR -1.5 M3 modes 6, 7 FPCR"     00880003 00880003

r 1530.10
*Want "CLGEBR -0.5 FPC modes 1-3, 7 FPCR"  00000001 00000001 00800003 00800003
r 1540.10
*Want "CLGEBR -0.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00080001 00080001
r 1550.08
*Want "CLGEBR -0.5 M3 modes 6, 7 FPCR"     00080001 00880003

r 1560.10
*Want "CLGEBR +0.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1570.10
*Want "CLGEBR +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1580.08
*Want "CLGEBR +0.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1590.10
*Want "CLGEBR +1.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 15A0.10
*Want "CLGEBR +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 15B0.08
*Want "CLGEBR +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 15C0.10
*Want "CLGEBR +2.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 15D0.10
*Want "CLGEBR +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 15E0.08
*Want "CLGEBR +2.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 15F0.10
*Want "CLGEBR +5.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1600.10
*Want "CLGEBR +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1610.08
*Want "CLGEBR +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1620.10
*Want "CLGEBR +9.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1630.10
*Want "CLGEBR +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1640.08
*Want "CLGEBR +9.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1650.10
*Want "CLGEBR max FPC modes 1-3, 7 FPCR"   00000002 00000002 00000002 00000002
r 1660.10
*Want "CLGEBR max M3 modes 1, 3-5 FPCR"    00000002 00000002 00000002 00000002
r 1670.08
*Want "CLGEBR max M3 modes 6, 7 FPCR"      00000002 00000002


# BFP long inputs converted to uint-64 - results
*Compare
r 1700.10
*Want "CLGDBR result pair 1" 00000000 00000001 00000000 00000001
r 1710.10
*Want "CLGDBR result pair 2" 00000000 00000002 00000000 00000002
r 1720.10
*Want "CLGDBR result pair 3" 00000000 00000004 00000000 00000004
r 1730.10
*Want "CLGDBR result pair 4" 00000000 00000000 00000000 00000000
r 1740.10
*Want "CLGDBR result pair 5" 00000000 00000000 00000000 00000000
r 1750.10
*Want "CLGDBR result pair 6" 00000000 00000000 00000000 00000000

*Compare
r 1800.10
*Want "CLGDBR FPC pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1810.10
*Want "CLGDBR FPC pairs 3-4" 00000002 F8000002 00880003 F8008000
r 1820.10
*Want "CLGDBR FPC pairs 5-6" 00880003 F8008000 00880003 F8008000


#  Long BFP inputs converted to uint-64 - results from rounding
*Compare
r 1900.10                            RZ,                RP
*Want "CLGDBR -1.5 FPC modes 1, 2" 00000000 00000000 00000000 00000000
r 1910.10                            RM,                RFS
*Want "CLGDBR -1.5 FPC modes 3, 7" 00000000 00000000 00000000 00000000
r 1920.10                            RNTA,             RFS
*Want "CLGDBR -1.5 M3 modes 1, 3"  00000000 00000000 00000000 00000000
r 1930.10                            RNTE,             RZ
*Want "CLGDBR -1.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 1940.10                            RP,               RM
*Want "CLGDBR -1.5 M3 modes 6, 7"  00000000 00000000 00000000 00000000

r 1950.10                            RZ,               RP
*Want "CLGDBR -0.5 FPC modes 1, 2" 00000000 00000000 00000000 00000000
r 1960.10                            RM,               RFS
*Want "CLGDBR -0.5 FPC modes 3, 7" 00000000 00000000 00000000 00000000
r 1970.10                            RNTA,             RFS
*Want "CLGDBR -0.5 M3 modes 1, 3"  00000000 00000000 00000000 00000000
r 1980.10                            RNTE,             RZ
*Want "CLGDBR -0.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 1990.10                            RP,               RM
*Want "CLGDBR -0.5 M3 modes 6, 7"  00000000 00000000 00000000 00000000

r 19A0.10                            RZ,              RP
*Want "CLGDBR +0.5 FPC modes 1, 2" 00000000 00000000 00000000 00000001
r 19B0.10                            RM,              RFS
*Want "CLGDBR +0.5 FPC modes 3, 7" 00000000 00000000 00000000 00000001
r 19C0.10                            RNTA,            RFS
*Want "CLGDBR +0.5 M3 modes 1, 3"  00000000 00000001 00000000 00000001
r 19D0.10                            RNTE,            RZ
*Want "CLGDBR +0.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 19E0.10                            RP,              RM
*Want "CLGDBR +0.5 M3 modes 6, 7"  00000000 00000001 00000000 00000000

r 19F0.10                            RZ,               RP
*Want "CLGDBR +1.5 FPC modes 1, 2" 00000000 00000001 00000000 00000002
r 1A00.10                            RM,               RFS
*Want "CLGDBR +1.5 FPC modes 3, 7" 00000000 00000001 00000000 00000001
r 1A10.10                            RNTA,             RFS
*Want "CLGDBR +1.5 M3 modes 1, 3"  00000000 00000002 00000000 00000001
r 1A20.10                            RNTE,             RZ
*Want "CLGDBR +1.5 M3 modes 4, 5"  00000000 00000002 00000000 00000001
r 1A30.10                            RP,               RM
*Want "CLGDBR +1.5 M3 modes 6, 7"  00000000 00000002 00000000 00000001

r 1A40.10                            RZ,               RP
*Want "CLGDBR +2.5 FPC modes 1, 2" 00000000 00000002 00000000 00000003
r 1A50.10                            RM,               RFS
*Want "CLGDBR +2.5 FPC modes 3, 7" 00000000 00000002 00000000 00000003
r 1A60.10                            RNTA,             RFS
*Want "CLGDBR +2.5 M3 modes 1, 3"  00000000 00000003 00000000 00000003
r 1A70.10                            RNTE,             RZ
*Want "CLGDBR +2.5 M3 modes 4, 5"  00000000 00000002 00000000 00000002
r 1A80.10                            RP,               RM
*Want "CLGDBR +2.5 M3 modes 6, 7"  00000000 00000003 00000000 00000002

r 1A90.10                            RZ,               RP
*Want "CLGDBR +5.5 FPC modes 1, 2" 00000000 00000005 00000000 00000006
r 1AA0.10                            RM,               RFS
*Want "CLGDBR +5.5 FPC modes 3, 7" 00000000 00000005 00000000 00000005
r 1AB0.10                            RNTA,             RFS
*Want "CLGDBR +5.5 M3 modes 1, 3"  00000000 00000006 00000000 00000005
r 1AC0.10                            RNTE,             RZ
*Want "CLGDBR +5.5 M3 modes 4, 5"  00000000 00000006 00000000 00000005
r 1AD0.10                            RP,               RM
*Want "CLGDBR +5.5 M3 modes 6, 7"  00000000 00000006 00000000 00000005

r 1AE0.10                            RZ,               RP
*Want "CLGDBR +9.5 FPC modes 1, 2" 00000000 00000009 00000000 0000000A
r 1AF0.10                            RM,               RFS
*Want "CLGDBR +9.5 FPC modes 3, 7" 00000000 00000009 00000000 00000009
r 1B00.10                            RNTA,             RFS
*Want "CLGDBR +9.5 M3 modes 1, 3"  00000000 0000000A 00000000 00000009
r 1B10.10                            RNTE,             RZ
*Want "CLGDBR +9.5 M3 modes 4, 5"  00000000 0000000A 00000000 00000009
r 1B20.10                            RP,               RM
*Want "CLGDBR +9.5 M3 modes 6, 7"  00000000 0000000A 00000000 00000009

r 1B30.10                            RZ,               RP
*Want "CLGDBR max FPC modes 1, 2"  FFFFFFFF FFFFF800 FFFFFFFF FFFFF800
r 1B40.10                            RM,               RFS
*Want "CLGDBR max FPC modes 3, 7"  FFFFFFFF FFFFF800 FFFFFFFF FFFFF800
r 1B50.10                            RNTA,             RFS
*Want "CLGDBR max M3 modes 1, 3"   FFFFFFFF FFFFF800 FFFFFFFF FFFFF800
r 1B60.10                            RNTE,             RZ
*Want "CLGDBR max M3 modes 4, 5"   FFFFFFFF FFFFF800 FFFFFFFF FFFFF800
r 1B70.10                            RP,               RM
*Want "CLGDBR max M3 modes 6, 7"   FFFFFFFF FFFFF800 FFFFFFFF FFFFF800


#  Long BFP inputs converted to uint-64 - FPCR contents with cc in last byte
*Compare
r 1C00.10
*Want "CLGDBR -1.5 FPC modes 1-3, 7 FPCR"  00800003 00800003 00800003 00800003
r 1C10.10
*Want "CLGDBR -1.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00880003 00880003
r 1C20.08
*Want "CLGDBR -1.5 M3 modes 6, 7 FPCR"     00880003 00880003

r 1C30.10
*Want "CLGDBR -0.5 FPC modes 1-3, 7 FPCR"  00000001 00000001 00800003 00800003
r 1C40.10
*Want "CLGDBR -0.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00080001 00080001
r 1C50.08
*Want "CLGDBR -0.5 M3 modes 6, 7 FPCR"     00080001 00880003

r 1C60.10
*Want "CLGDBR +0.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1C70.10
*Want "CLGDBR +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1C80.08
*Want "CLGDBR +0.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1C90.10
*Want "CLGDBR +1.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1CA0.10
*Want "CLGDBR +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1CB0.08
*Want "CLGDBR +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1CC0.10
*Want "CLGDBR +2.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1CD0.10
*Want "CLGDBR +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1CE0.08
*Want "CLGDBR +2.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1CF0.10
*Want "CLGDBR +5.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1D00.10
*Want "CLGDBR +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1D10.08
*Want "CLGDBR +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1D20.10
*Want "CLGDBR +9.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1D30.10
*Want "CLGDBR +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1D40.08
*Want "CLGDBR +9.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1D50.10
*Want "CLGDBR max FPC modes 1-3, 7 FPCR"   00000002 00000002 00000002 00000002
r 1D60.10
*Want "CLGDBR max M3 modes 1, 3-5 FPCR"    00000002 00000002 00000002 00000002
r 1D70.08
*Want "CLGDBR max M3 modes 6, 7 FPCR"      00000002 00000002


# Extended BFP inputs converted to uint-64 - results
*Compare
r 1E00.10
*Want "CLGXBR result pair 1" 00000000 00000001 00000000 00000001
r 1E10.10
*Want "CLGXBR result pair 2" 00000000 00000002 00000000 00000002
r 1E20.10
*Want "CLGXBR result pair 3" 00000000 00000004 00000000 00000004
r 1E30.10
*Want "CLGXBR result pair 4" 00000000 00000000 00000000 00000000
r 1E40.10
*Want "CLGXBR result pair 5" 00000000 00000000 00000000 00000000
r 1E50.10
*Want "CLGXBR result pair 6" 00000000 00000000 00000000 00000000

*Compare
r 1F00.10
*Want "CLGXBR FPC pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1F10.10
*Want "CLGXBR FPC pairs 3-4" 00000002 F8000002 00880003 F8008000
r 1F20.10
*Want "CLGXBR FPC pairs 5-6" 00880003 F8008000 00880003 F8008000


#  Long BFP inputs converted to uint-64 - results from rounding
*Compare
r 2000.10                            RZ,               RP
*Want "CLGXBR -1.5 FPC modes 1, 2" 00000000 00000000 00000000 00000000
r 2010.10                            RM,               RFS
*Want "CLGXBR -1.5 FPC modes 3, 7" 00000000 00000000 00000000 00000000
r 2020.10                            RNTA,             RFS
*Want "CLGXBR -1.5 M3 modes 1, 3"  00000000 00000000 00000000 00000000
r 2030.10                            RNTE,             RZ
*Want "CLGXBR -1.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 2040.10                            RP,               RM
*Want "CLGXBR -1.5 M3 modes 6, 7"  00000000 00000000 00000000 00000000

r 2050.10                            RZ,               RP
*Want "CLGXBR -0.5 FPC modes 1, 2" 00000000 00000000 00000000 00000000
r 2060.10                            RM,               RFS
*Want "CLGXBR -0.5 FPC modes 3, 7" 00000000 00000000 00000000 00000000
r 2070.10                            RNTA,             RFS
*Want "CLGXBR -0.5 M3 modes 1, 3"  00000000 00000000 00000000 00000000
r 2080.10                            RNTE,             RZ
*Want "CLGXBR -0.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 2090.10                            RP,               RM
*Want "CLGXBR -0.5 M3 modes 6, 7"  00000000 00000000 00000000 00000000

r 20A0.10                            RZ,               RP
*Want "CLGXBR +0.5 FPC modes 1, 2" 00000000 00000000 00000000 00000001
r 20B0.10                            RM,               RFS
*Want "CLGXBR +0.5 FPC modes 3, 7" 00000000 00000000 00000000 00000001
r 20C0.10                            RNTA,             RFS
*Want "CLGXBR +0.5 M3 modes 1, 3"  00000000 00000001 00000000 00000001
r 20D0.10                            RNTE,             RZ
*Want "CLGXBR +0.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 20E0.10                            RP,               RM
*Want "CLGXBR +0.5 M3 modes 6, 7"  00000000 00000001 00000000 00000000

r 20F0.10                            RZ,               RP
*Want "CLGXBR +1.5 FPC modes 1, 2" 00000000 00000001 00000000 00000002
r 2100.10                            RM,               RFS
*Want "CLGXBR +1.5 FPC modes 3, 7" 00000000 00000001 00000000 00000001
r 2110.10                            RNTA,             RFS
*Want "CLGXBR +1.5 M3 modes 1, 3"  00000000 00000002 00000000 00000001
r 2120.10                            RNTE,             RZ
*Want "CLGXBR +1.5 M3 modes 4, 5"  00000000 00000002 00000000 00000001
r 2130.10                            RP,               RM
*Want "CLGXBR +1.5 M3 modes 6, 7"  00000000 00000002 00000000 00000001

r 2140.10                            RZ,               RP
*Want "CLGXBR +2.5 FPC modes 1, 2" 00000000 00000002 00000000 00000003
r 2150.10                            RM,               RFS
*Want "CLGXBR +2.5 FPC modes 3, 7" 00000000 00000002 00000000 00000003
r 2160.10                            RNTA,             RFS
*Want "CLGXBR +2.5 M3 modes 1, 3"  00000000 00000003 00000000 00000003
r 2170.10                            RNTE,             RZ
*Want "CLGXBR +2.5 M3 modes 4, 5"  00000000 00000002 00000000 00000002
r 2180.10                            RP,               RM
*Want "CLGXBR +2.5 M3 modes 6, 7"  00000000 00000003 00000000 00000002

r 2190.10                            RZ,               RP
*Want "CLGXBR +5.5 FPC modes 1, 2" 00000000 00000005 00000000 00000006
r 21A0.10                            RM,               RFS
*Want "CLGXBR +5.5 FPC modes 3, 7" 00000000 00000005 00000000 00000005
r 21B0.10                            RNTA,             RFS
*Want "CLGXBR +5.5 M3 modes 1, 3"  00000000 00000006 00000000 00000005
r 21C0.10                            RNTE,             RZ
*Want "CLGXBR +5.5 M3 modes 4, 5"  00000000 00000006 00000000 00000005
r 21D0.10                            RP,               RM
*Want "CLGXBR +5.5 M3 modes 6, 7"  00000000 00000006 00000000 00000005

r 21E0.10                            RZ,               RP
*Want "CLGXBR +9.5 FPC modes 1, 2" 00000000 00000009 00000000 0000000A
r 21F0.10                            RM,               RFS
*Want "CLGXBR +9.5 FPC modes 3, 7" 00000000 00000009 00000000 00000009
r 2200.10                            RNTA,             RFS
*Want "CLGXBR +9.5 M3 modes 1, 3"  00000000 0000000A 00000000 00000009
r 2210.10                            RNTE,             RZ
*Want "CLGXBR +9.5 M3 modes 4, 5"  00000000 0000000A 00000000 00000009
r 2220.10                            RP,               RM
*Want "CLGXBR +9.5 M3 modes 6, 7"  00000000 0000000A 00000000 00000009

r 2230.10                            RZ,               RP
*Want "CLGXBR max FPC modes 1, 2"  FFFFFFFF FFFFFFFF 00000000 00000000
r 2240.10                            RM,               RFS
*Want "CLGXBR max FPC modes 3, 7"  FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 2250.10                            RNTA,             RFS
*Want "CLGXBR max M3 modes 1, 3"   00000000 00000000 FFFFFFFF FFFFFFFF
r 2260.10                            RNTE,             RZ
*Want "CLGXBR max M3 modes 4, 5"   00000000 00000000 FFFFFFFF FFFFFFFF
r 2270.10                            RP,               RM
*Want "CLGXBR max M3 modes 6, 7"   00000000 00000000 FFFFFFFF FFFFFFFF


#  Extended BFP inputs converted to uint-64 - FPCR contents with cc in last byte
*Compare
r 2300.10
*Want "CLGXBR -1.5 FPC modes 1-3, 7 FPCR"  00800003 00800003 00800003 00800003
r 2310.10
*Want "CLGXBR -1.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00880003 00880003
r 2320.08
*Want "CLGXBR -1.5 M3 modes 6, 7 FPCR"     00880003 00880003

r 2330.10
*Want "CLGXBR -0.5 FPC modes 1-3, 7 FPCR"  00000001 00000001 00800003 00800003
r 2340.10
*Want "CLGXBR -0.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00080001 00080001
r 2350.08
*Want "CLGXBR -0.5 M3 modes 6, 7 FPCR"     00080001 00880003

r 2360.10
*Want "CLGXBR +0.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 2370.10
*Want "CLGXBR +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 2380.08
*Want "CLGXBR +0.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 2390.10
*Want "CLGXBR +1.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 23A0.10
*Want "CLGXBR +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 23B0.08
*Want "CLGXBR +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 23C0.10
*Want "CLGXBR +2.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 23D0.10
*Want "CLGXBR +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 23E0.08
*Want "CLGXBR +2.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 23F0.10
*Want "CLGXBR +5.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 2400.10
*Want "CLGXBR +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 2410.08
*Want "CLGXBR +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 2420.10
*Want "CLGXBR +9.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 2430.10
*Want "CLGXBR +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 2440.08
*Want "CLGXBR +9.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 2450.10
*Want "CLGXBR max FPC modes 1-3, 7 FPCR"   00000002 00800003 00000002 00000002
r 2460.10
*Want "CLGXBR max M3 modes 1, 3-5 FPCR"    00880003 00080002 00880003 00080002
r 2470.08
*Want "CLGXBR max M3 modes 6, 7 FPCR"      00880003 00080002


*Done

