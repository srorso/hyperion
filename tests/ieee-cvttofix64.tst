*
*Testcase ieee-cvttofix64.tst: IEEE Convert To Fixed
*Message Testcase ieee-cvtfrfix64.tst: IEEE Convert To Fixed
*Message ..Includes CONVERT TO FIXED 64 (6).  Tests traps, exceptions
*Message ..results from different rounding modes, and NaN propagation.
#
# CONVERT TO FIXED tests - Binary Floating Point
#
# Tests the following six conversion instructions
#   CONVERT TO FIXED (short BFP to int-64, RRE)
#   CONVERT TO FIXED (long BFP to int-64, RRE) 
#   CONVERT TO FIXED (extended BFP to int-64, RRE)
#   CONVERT TO FIXED (short BFP to int-64, RRF-e)
#   CONVERT TO FIXED (long BFP to int-64, RRF-e) 
#   CONVERT TO FIXED (extended BFP to int-64, RRF-e)
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
loadcore $(testpath)/ieee-cvttofix64.core

runtest .1

*Program 7
r 1000.1000

# Short BFP inputs to int-64 - results
*Compare
r 1000.10
*Want "CGEBR result pair 1" 00000000 00000001 00000000 00000001
r 1010.10
*Want "CGEBR result pair 2" 00000000 00000002 00000000 00000002
r 1020.10
*Want "CGEBR result pair 3" 00000000 00000004 00000000 00000004
r 1030.10
*Want "CGEBR result pair 4" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 1040.10
*Want "CGEBR result pair 5" 80000000 00000000 00000000 00000000
r 1050.10
*Want "CGEBR result pair 6" 80000000 00000000 00000000 00000000
r 1060.10
*Want "CGEBR result pair 7" 7FFFFFFF FFFFFFFF 00000000 00000000
r 1070.10
*Want "CGEBR result pair 8" 80000000 00000000 00000000 00000000

# Short BFP inputs to int-64 - FPCR contents
*Compare
r 1080.10
*Want "CGEBR FPCR pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1090.10
*Want "CGEBR FPCR pairs 3-4" 00000002 F8000002 00000001 F8000001
r 10A0.10
*Want "CGEBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000
r 10B0.10
*Want "CGEBR FPCR pairs 7-8" 00880003 F8008000 00880003 F8008000

#  rounding mode tests - short BFP - results from rounding
*Compare
r 1100.10                             RZ,               RP
*Want "CGEBRA -9.5 FPCR modes 1, 2" FFFFFFFF FFFFFFF7 FFFFFFFF FFFFFFF7
r 1110.10                             RM,               RFS
*Want "CGEBRA -9.5 FPCR modes 3, 7" FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1120.10                             RNTA,             RFS
*Want "CGEBRA -9.5 M3 modes 1, 3"   FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1130.10                             RNTE,             RZ
*Want "CGEBRA -9.5 M3 modes 4, 5"   FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1140.10                             RP                RM
*Want "CGEBRA -9.5 M3 modes 6, 7"   FFFFFFFF FFFFFFF7 FFFFFFFF FFFFFFF6

r 1150.10                             RZ,               RP
*Want "CGEBRA -5.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFB FFFFFFFF FFFFFFFB
r 1160.10                             RM,               RFS
*Want "CGEBRA -5.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1170.10                             RNTA,             RFS
*Want "CGEBRA -5.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1180.10                             RNTE,             RZ
*Want "CGEBRA -5.5 M3 modes 4, 5"   FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1190.10                             RP,               RM
*Want "CGEBRA -5.5 M3 modes 6, 7"   FFFFFFFF FFFFFFFB FFFFFFFF FFFFFFFA

r 11A0.10                             RZ,            RP
*Want "CGEBRA -2.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 11B0.10                             RM,            RFS
*Want "CGEBRA -2.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFD FFFFFFFF FFFFFFFD
r 11C0.10                           RNTA,            RFS
*Want "CGEBRA -2.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFD FFFFFFFF FFFFFFFD
r 11D0.10                           RNTE,            RZ
*Want "CGEBRA -2.5 M3 modes 4, 5"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 11E0.10                           RP,              RM
*Want "CGEBRA -2.5 M3 modes 6, 7"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFD

r 11F0.10                             RZ,              RP
*Want "CGEBRA -1.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 1200.10                             RM,              RFS
*Want "CGEBRA -1.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 1210.10                              RNTA,             RFS
*Want "CGEBRA -1.5 M3 modes 1, 3"  FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 1220.10                              RNTE,             RZ
*Want "CGEBRA -1.5 M3 modes 4, 5"  FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 1230.10                              RP,               RM
*Want "CGEBRA -1.5 M3 modes 6, 7"  FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE

r 1240.10                             RZ,              RP
*Want "CGEBRA -0.5 FPCR modes 1, 2" 00000000 00000000 00000000 00000000
r 1250.10                             RM,              RFS
*Want "CGEBRA -0.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 1260.10                              RNTA,             RFS
*Want "CGEBRA -0.5 M3 modes 1, 3"  FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 1270.10                              RNTE,             RZ
*Want "CGEBRA -0.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 1280.10                              RP,               RM
*Want "CGEBRA -0.5 M3 modes 6, 7"  00000000 00000000 FFFFFFFF FFFFFFFF

r 1290.10                             RZ,             RP
*Want "CGEBRA 0.5 FPCR modes 1, 2" 00000000 00000000 00000000 00000001
r 12A0.10                             RM,             RFS
*Want "CGEBRA 0.5 FPCR modes 3, 7" 00000000 00000000 00000000 00000001
r 12B0.10                             RNTA,           RFS
*Want "CGEBRA 0.5 M3 modes 1, 3"  00000000 00000001 00000000 00000001
r 12C0.10                             RNTE,           RZ
*Want "CGEBRA 0.5 M3 modes 4, 5"  00000000 00000000 00000000 00000000
r 12D0.10                             RP,             RM
*Want "CGEBRA 0.5 M3 modes 6, 7"  00000000 00000001 00000000 00000000

r 12E0.10                             RZ,           RP
*Want "CGEBRA 1.5 FPCR modes 1, 2" 00000000 00000001 00000000 00000002
r 12F0.10                             RM,           RFS
*Want "CGEBRA 1.5 FPCR modes 3, 7" 00000000 00000001 00000000 00000001
r 1300.10                           RNTA,           RFS
*Want "CGEBRA 1.5 M3 modes 1, 3"  00000000 00000002 00000000 00000001
r 1310.10                           RNTE,           RZ
*Want "CGEBRA 1.5 M3 modes 4, 5"  00000000 00000002 00000000 00000001
r 1320.10                           RP,             RM
*Want "CGEBRA 1.5 M3 modes 6, 7"  00000000 00000002 00000000 00000001

r 1330.10                             RZ,           RP
*Want "CGEBRA 2.5 FPCR modes 1, 2" 00000000 00000002 00000000 00000003
r 1340.10                             RM,           RFS
*Want "CGEBRA 2.5 FPCR modes 3, 7" 00000000 00000002 00000000 00000003
r 1350.10                           RNTA,           RFS
*Want "CGEBRA 2.5 M3 modes 1, 3"  00000000 00000003 00000000 00000003
r 1360.10                           RNTE,           RZ
*Want "CGEBRA 2.5 M3 modes 4, 5"  00000000 00000002 00000000 00000002
r 1370.10                           RP,             RM
*Want "CGEBRA 2.5 M3 modes 6, 7"  00000000 00000003 00000000 00000002

r 1380.10                             RZ,           RP
*Want "CGEBRA 5.5 FPCR modes 1, 2" 00000000 00000005 00000000 00000006
r 1390.10                             RM,           RFS
*Want "CGEBRA 5.5 FPCR modes 3, 7" 00000000 00000005 00000000 00000005
r 13A0.10                           RNTA,           RFS
*Want "CGEBRA 5.5 M3 modes 1, 3"  00000000 00000006 00000000 00000005
r 13B0.10                           RNTE,           RZ
*Want "CGEBRA 5.5 M3 modes 4, 5"  00000000 00000006 00000000 00000005
r 13C0.10                           RP,             RM
*Want "CGEBRA 5.5 M3 modes 6, 7"  00000000 00000006 00000000 00000005

r 13D0.10                             RZ,           RP
*Want "CGEBRA 9.5 FPCR modes 1, 2" 00000000 00000009 00000000 0000000A
r 13E0.10                             RM,           RFS
*Want "CGEBRA 9.5 FPCR modes 3, 7" 00000000 00000009 00000000 00000009
r 13F0.10                           RNTA,           RFS
*Want "CGEBRA 9.5 M3 modes 1, 3"  00000000 0000000A 00000000 00000009
r 1400.10                           RNTE,           RZ
*Want "CGEBRA 9.5 M3 modes 4, 5"  00000000 0000000A 00000000 00000009
r 1400.10                           RP,             RM
*Want "CGEBRA 9.5 M3 modes 6, 7"  00000000 0000000A 00000000 00000009

#  rounding mode tests - short BFP - FPCR contents with cc in last byte
*Compare
r 1500.10  # Rounding Mode Tests - FPC
*Want "CGEBRA -9.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 1510.10  # Rounding Mode Tests - FPC
*Want "CGEBRA -9.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1520.08  # Rounding Mode Tests - FPC
*Want "CGEBRA -9.5 M3 modes 5-7"           00080001 00080001

r 1530.10
*Want "CGEBRA -5.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 1540.10
*Want "CGEBRA -5.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1550.08
*Want "CGEBRA -5.5 M3 modes 5-7"           00080001 00080001

r 1560.10
*Want "CGEBRA -2.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 1570.10
*Want "CGEBRA -2.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1580.08
*Want "CGEBRA -2.5 M3 modes 5-7"           00080001 00080001

r 1590.10
*Want "CGEBRA -1.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 15A0.10
*Want "CGEBRA -1.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 15B0.08
*Want "CGEBRA -1.5 M3 modes 5-7"           00080001 00080001

r 15C0.10
*Want "CGEBRA -0.5 FPCR modes 1-3, 7 FPCR"  00000000 00000000 00000001 00000001
r 15D0.10
*Want "CGEBRA -0.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080000 00080000
r 15E0.08
*Want "CGEBRA -0.5 M3 modes 5-7"           00080000 00080001

r 15F0.10
*Want "CGEBRA +0.5 FPCR modes 1-3, 7 FPCR"  00000000 00000002 00000000 00000002
r 1600.10
*Want "CGEBRA +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080000 00080000
r 1610.08
*Want "CGEBRA +0.5 M3 modes 5-7"           00080002 00080000

r 1620.10
*Want "CGEBRA +1.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1630.10
*Want "CGEBRA +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1640.08
*Want "CGEBRA +1.5 M3 modes 5-7"           00080002 00080002

r 1650.10
*Want "CGEBRA +2.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1660.10
*Want "CGEBRA +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1670.08
*Want "CGEBRA +2.5 M3 modes 5-7"           00080002 00080002

r 1680.10
*Want "CGEBRA +5.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1690.10
*Want "CGEBRA +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 16A0.08
*Want "CGEBRA +5.5 M3 modes 5-7"           00080002 00080002

r 16B0.10
*Want "CGEBRA +9.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 16C0.10
*Want "CGEBRA +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 16D0.08
*Want "CGEBRA +9.5 M3 modes 5-7"           00080002 00080002


# Long BFP inputs to int-64 - results
*Compare
r 1700.10
*Want "CGDBR result pair 1" 00000000 00000001 00000000 00000001
r 1710.10
*Want "CGDBR result pair 2" 00000000 00000002 00000000 00000002
r 1720.10
*Want "CGDBR result pair 3" 00000000 00000004 00000000 00000004
r 1730.10
*Want "CGDBR result pair 4" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 1740.10
*Want "CGDBR result pair 5" 80000000 00000000 00000000 00000000
r 1750.10
*Want "CGDBR result pair 6" 80000000 00000000 00000000 00000000
r 1760.10
*Want "CGDBR result pair 7" 7FFFFFFF FFFFFFFF 00000000 00000000
r 1770.10
*Want "CGDBR result pair 8" 80000000 00000000 00000000 00000000

# Long BFP inputs to int-64 - FPCR contents
*Compare
r 1780.10
*Want "CGDBR FPCR pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1790.10
*Want "CGDBR FPCR pairs 3-4" 00000002 F8000002 00000001 F8000001
r 17A0.10
*Want "CGDBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000
r 17B0.10
*Want "CGDBR FPCR pairs 7-8" 00880003 F8008000 00880003 F8008000


#  long BFP rounding mode tests - results 
*Compare
r 1800.10                             RZ,              RP
*Want "CGDBRA -9.5 FPCR modes 1, 2" FFFFFFFF FFFFFFF7 FFFFFFFF FFFFFFF7
r 1810.10                             RM,              RFS
*Want "CGDBRA -9.5 FPCR modes 3, 7" FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1820.10                            RNTA,             RFS
*Want "CGDBRA -9.5 M3 modes 1, 3"  FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1830.10                            RNTE,             RZ
*Want "CGDBRA -9.5 M3 modes 4, 5"  FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1840.10                            RP                RM
*Want "CGDBRA -9.5 M3 modes 6, 7"  FFFFFFFF FFFFFFF7 FFFFFFFF FFFFFFF6

r 1850.10                             RZ,              RP
*Want "CGDBRA -5.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFB FFFFFFFF FFFFFFFB
r 1860.10                             RM,              RFS
*Want "CGDBRA -5.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1870.10                            RNTA,             RFS
*Want "CGDBRA -5.5 M3 modes 1, 3"  FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1880.10                            RNTE,             RZ
*Want "CGDBRA -5.5 M3 modes 4, 5"  FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1890.10                            RP,               RM
*Want "CGDBRA -5.5 M3 modes 6, 7"  FFFFFFFF FFFFFFFB FFFFFFFF FFFFFFFA

r 18A0.10                             RZ,               RP
*Want "CGDBRA -2.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 18B0.10                             RM,               RFS
*Want "CGDBRA -2.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFD FFFFFFFF FFFFFFFD
r 18C0.10                             RNTA,             RFS
*Want "CGDBRA -2.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFD FFFFFFFF FFFFFFFD
r 18D0.10                             RNTE,             RZ
*Want "CGDBRA -2.5 M3 modes 4, 5"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 18E0.10                             RP,               RM
*Want "CGDBRA -2.5 M3 modes 6, 7"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFD

r 18F0.10                             RZ,               RP
*Want "CGDBRA -1.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 1900.10                             RM,               RFS
*Want "CGDBRA -1.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 1910.10                             RNTA,             RFS
*Want "CGDBRA -1.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 1920.10                             RNTE,             RZ
*Want "CGDBRA -1.5 M3 modes 4, 5"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 1930.10                             RP,               RM
*Want "CGDBRA -1.5 M3 modes 6, 7"   FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE

r 1940.10                             RZ,               RP
*Want "CGDBRA -0.5 FPCR modes 1, 2" 00000000 00000000 00000000 00000000
r 1950.10                             RM,               RFS
*Want "CGDBRA -0.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 1960.10                             RNTA,             RFS
*Want "CGDBRA -0.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 1970.10                             RNTE,             RZ
*Want "CGDBRA -0.5 M3 modes 4, 5"   00000000 00000000 00000000 00000000
r 1980.10                             RP,               RM
*Want "CGDBRA -0.5 M3 modes 6, 7"   00000000 00000000 FFFFFFFF FFFFFFFF

r 1990.10                             RZ,               RP
*Want "CGDBRA 0.5 FPCR modes 1, 2"  00000000 00000000 00000000 00000001
r 19A0.10                             RM,               RFS
*Want "CGDBRA 0.5 FPCR modes 3, 7"  00000000 00000000 00000000 00000001
r 19B0.10                             RNTA,             RFS
*Want "CGDBRA 0.5 M3 modes 1, 3"    00000000 00000001 00000000 00000001
r 19C0.10                             RNTE,             RZ
*Want "CGDBRA 0.5 M3 modes 4, 5"    00000000 00000000 00000000 00000000
r 19D0.10                             RP,               RM
*Want "CGDBRA 0.5 M3 modes 6, 7"    00000000 00000001 00000000 00000000

r 19E0.10                             RZ,               RP
*Want "CGDBRA 1.5 FPCR modes 1, 2"  00000000 00000001 00000000 00000002
r 19F0.10                             RM,               RFS
*Want "CGDBRA 1.5 FPCR modes 3, 7"  00000000 00000001 00000000 00000001
r 1A00.10                             RNTA,             RFS
*Want "CGDBRA 1.5 M3 modes 1, 3"    00000000 00000002 00000000 00000001
r 1A10.10                             RNTE,             RZ
*Want "CGDBRA 1.5 M3 modes 4, 5"    00000000 00000002 00000000 00000001
r 1A20.10                             RP,               RM
*Want "CGDBRA 1.5 M3 modes 6, 7"    00000000 00000002 00000000 00000001

r 1A30.10                             RZ,               RP
*Want "CGDBRA 2.5 FPCR modes 1, 2"  00000000 00000002 00000000 00000003
r 1A40.10                             RM,               RFS
*Want "CGDBRA 2.5 FPCR modes 3, 7"  00000000 00000002 00000000 00000003
r 1A50.10                             RNTA,             RFS
*Want "CGDBRA 2.5 M3 modes 1, 3"    00000000 00000003 00000000 00000003
r 1A60.10                             RNTE,             RZ
*Want "CGDBRA 2.5 M3 modes 4, 5"    00000000 00000002 00000000 00000002
r 1A70.10                             RP,               RM
*Want "CGDBRA 2.5 M3 modes 6, 7"    00000000 00000003 00000000 00000002

r 1A80.10                             RZ,               RP
*Want "CGDBRA 5.5 FPCR modes 1, 2"  00000000 00000005 00000000 00000006
r 1A90.10                             RM,               RFS
*Want "CGDBRA 5.5 FPCR modes 3, 7"  00000000 00000005 00000000 00000005
r 1AA0.10                             RNTA,             RFS
*Want "CGDBRA 5.5 M3 modes 1, 3"    00000000 00000006 00000000 00000005
r 1AB0.10                             RNTE,             RZ
*Want "CGDBRA 5.5 M3 modes 4, 5"    00000000 00000006 00000000 00000005
r 1AC0.10                             RP,               RM
*Want "CGDBRA 5.5 M3 modes 6, 7"    00000000 00000006 00000000 00000005

r 1AD0.10                             RZ,               RP
*Want "CGDBRA 9.5 FPCR modes 1, 2"  00000000 00000009 00000000 0000000A
r 1AE0.10                             RM,               RFS
*Want "CGDBRA 9.5 FPCR modes 3, 7"  00000000 00000009 00000000 00000009
r 1AF0.10                             RNTA,             RFS
*Want "CGDBRA 9.5 M3 modes 1, 3"    00000000 0000000A 00000000 00000009
r 1B00.10                             RNTE,             RZ
*Want "CGDBRA 9.5 M3 modes 4, 5"    00000000 0000000A 00000000 00000009
r 1B10.10                             RP,               RM
*Want "CGDBRA 9.5 M3 modes 6, 7"    00000000 0000000A 00000000 00000009

#  rounding mode tests - long BFP - FPCR contents with cc in last byte
*Compare
r 1C00.10
*Want "CGDBRA -9.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 1C10.10
*Want "CGDBRA -9.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080001 00080001
r 1C20.08
*Want "CGDBRA -9.5 M3 modes 5-7"            00080001 00080001

r 1C30.10
*Want "CGDBRA -5.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 1C40.10
*Want "CGDBRA -5.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080001 00080001
r 1C50.08
*Want "CGDBRA -5.5 M3 modes 5-7"            00080001 00080001

r 1C60.10
*Want "CGDBRA -2.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 1C70.10
*Want "CGDBRA -2.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080001 00080001
r 1C80.08
*Want "CGDBRA -2.5 M3 modes 5-7"            00080001 00080001

r 1C90.10
*Want "CGDBRA -1.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 1CA0.10
*Want "CGDBRA -1.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080001 00080001
r 1CB0.08
*Want "CGDBRA -1.5 M3 modes 5-7"            00080001 00080001

r 1CC0.10
*Want "CGDBRA -0.5 FPCR modes 1-3, 7 FPCR"  00000000 00000000 00000001 00000001
r 1CD0.10
*Want "CGDBRA -0.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080000 00080000
r 1CE0.08
*Want "CGDBRA -0.5 M3 modes 5-7"            00080000 00080001

r 1CF0.10
*Want "CGDBRA +0.5 FPCR modes 1-3, 7 FPCR"  00000000 00000002 00000000 00000002
r 1D00.10
*Want "CGDBRA +0.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080000 00080000
r 1D10.08
*Want "CGDBRA +0.5 M3 modes 5-7"            00080002 00080000

r 1D20.10
*Want "CGDBRA +1.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1D30.10
*Want "CGDBRA +1.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080002 00080002
r 1D40.08
*Want "CGDBRA +1.5 M3 modes 5-7"            00080002 00080002

r 1D50.10
*Want "CGDBRA +2.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1D60.10
*Want "CGDBRA +2.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080002 00080002
r 1D70.08
*Want "CGDBRA +2.5 M3 modes 5-7"            00080002 00080002

r 1D80.10
*Want "CGDBRA +5.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1D90.10
*Want "CGDBRA +5.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080002 00080002
r 1DA0.08
*Want "CGDBRA +5.5 M3 modes 5-7"            00080002 00080002

r 1DB0.10
*Want "CGDBRA +9.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1DC0.10
*Want "CGDBRA +9.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080002 00080002
r 1DD0.08
*Want "CGDBRA +9.5 M3 modes 5-7"            00080002 00080002


# Extended BFP inputs to int-64 - results
*Compare
r 1E00.10
*Want "CGXBR result pair 1" 00000000 00000001 00000000 00000001
r 1E10.10
*Want "CGXBR result pair 2" 00000000 00000002 00000000 00000002
r 1E20.10
*Want "CGXBR result pair 3" 00000000 00000004 00000000 00000004
r 1E30.10
*Want "CGXBR result pair 4" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 1E40.10
*Want "CGXBR result pair 5" 80000000 00000000 00000000 00000000
r 1E50.10
*Want "CGXBR result pair 6" 80000000 00000000 00000000 00000000
r 1E60.10
*Want "CGXBR result pair 7" 7FFFFFFF FFFFFFFF 00000000 00000000
r 1E70.10
*Want "CGXBR result pair 8" 80000000 00000000 00000000 00000000

# Extended BFP inputs to int-64 - FPCR contents
*Compare
r 1E80.10
*Want "CGXBR FPCR pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1E90.10
*Want "CGXBR FPCR pairs 3-4" 00000002 F8000002 00000001 F8000001
r 1EA0.10
*Want "CGXBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000
r 1EB0.10
*Want "CGXBR FPCR pairs 7-8" 00880003 F8008000 00880003 F8008000



#  rounding mode tests - extended BFP - results from rounding
*Compare
r 1F00.10                             RZ,               RP
*Want "CGXBRA -9.5 FPCR modes 1, 2" FFFFFFFF FFFFFFF7 FFFFFFFF FFFFFFF7
r 1F10.10                             RM,               RFS
*Want "CGXBRA -9.5 FPCR modes 3, 7" FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1F20.10                             RNTA,             RFS
*Want "CGXBRA -9.5 M3 modes 1, 3"   FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1F30.10                             RNTE,             RZ
*Want "CGXBRA -9.5 M3 modes 4, 5"   FFFFFFFF FFFFFFF6 FFFFFFFF FFFFFFF7
r 1F40.10                             RP                RM
*Want "CGXBRA -9.5 M3 modes 6, 7"   FFFFFFFF FFFFFFF7 FFFFFFFF FFFFFFF6

r 1F50.10                             RZ,               RP
*Want "CGXBRA -5.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFB FFFFFFFF FFFFFFFB
r 1F60.10                             RM,               RFS
*Want "CGXBRA -5.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1F70.10                             RNTA,             RFS
*Want "CGXBRA -5.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1F80.10                             RNTE,             RZ
*Want "CGXBRA -5.5 M3 modes 4, 5"   FFFFFFFF FFFFFFFA FFFFFFFF FFFFFFFB
r 1F90.10                             RP,               RM
*Want "CGXBRA -5.5 M3 modes 6, 7"   FFFFFFFF FFFFFFFB FFFFFFFF FFFFFFFA

r 1FA0.10                             RZ,               RP
*Want "CGXBRA -2.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 1FB0.10                             RM,               RFS
*Want "CGXBRA -2.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFD FFFFFFFF FFFFFFFD
r 1FC0.10                             RNTA,             RFS
*Want "CGXBRA -2.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFD FFFFFFFF FFFFFFFD
r 1FD0.10                             RNTE,             RZ
*Want "CGXBRA -2.5 M3 modes 4, 5"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFE
r 1FE0.10                             RP,               RM
*Want "CGXBRA -2.5 M3 modes 6, 7"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFD

r 1FF0.10                             RZ,               RP
*Want "CGXBRA -1.5 FPCR modes 1, 2" FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 2000.10                             RM,               RFS
*Want "CGXBRA -1.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 2010.10                             RNTA,             RFS
*Want "CGXBRA -1.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 2020.10                             RNTE,             RZ
*Want "CGXBRA -1.5 M3 modes 4, 5"   FFFFFFFF FFFFFFFE FFFFFFFF FFFFFFFF
r 2030.10                             RP,               RM
*Want "CGXBRA -1.5 M3 modes 6, 7"   FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE

r 2040.10                             RZ,               RP
*Want "CGXBRA -0.5 FPCR modes 1, 2" 00000000 00000000 00000000 00000000
r 2050.10                             RM,               RFS
*Want "CGXBRA -0.5 FPCR modes 3, 7" FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 2060.10                             RNTA,             RFS
*Want "CGXBRA -0.5 M3 modes 1, 3"   FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
r 2070.10                             RNTE,             RZ
*Want "CGXBRA -0.5 M3 modes 4, 5"   00000000 00000000 00000000 00000000
r 2080.10                             RP,               RM
*Want "CGXBRA -0.5 M3 modes 6, 7"   00000000 00000000 FFFFFFFF FFFFFFFF

r 2090.10                             RZ,               RP
*Want "CGXBRA +0.5 FPCR modes 1, 2" 00000000 00000000 00000000 00000001
r 20A0.10                             RM,               RFS
*Want "CGXBRA +0.5 FPCR modes 3, 7" 00000000 00000000 00000000 00000001
r 20B0.10                             RNTA,             RFS
*Want "CGXBRA +0.5 M3 modes 1, 3"   00000000 00000001 00000000 00000001
r 20C0.10                             RNTE,             RZ
*Want "CGXBRA +0.5 M3 modes 4, 5"   00000000 00000000 00000000 00000000
r 20D0.10                             RP,               RM
*Want "CGXBRA +0.5 M3 modes 6, 7"   00000000 00000001 00000000 00000000

r 20E0.10                              RZ,              RP
*Want "CGXBRA +1.5 FPCR modes 1, 2" 00000000 00000001 00000000 00000002
r 20F0.10                              RM,              RFS
*Want "CGXBRA +1.5 FPCR modes 3, 7" 00000000 00000001 00000000 00000001
r 2100.10                             RNTA,             RFS
*Want "CGXBRA +1.5 M3 modes 1, 3"   00000000 00000002 00000000 00000001
r 2110.10                             RNTE,             RZ
*Want "CGXBRA +1.5 M3 modes 4, 5"   00000000 00000002 00000000 00000001
r 2120.10                             RP,               RM
*Want "CGXBRA +1.5 M3 modes 6, 7"   00000000 00000002 00000000 00000001

r 2130.10                             RZ,               RP
*Want "CGXBRA +2.5 FPCR modes 1, 2" 00000000 00000002 00000000 00000003
r 2140.10                             RM,               RFS
*Want "CGXBRA +2.5 FPCR modes 3, 7" 00000000 00000002 00000000 00000003
r 2150.10                             RNTA,             RFS
*Want "CGXBRA +2.5 M3 modes 1, 3"   00000000 00000003 00000000 00000003
r 2160.10                             RNTE,             RZ
*Want "CGXBRA +2.5 M3 modes 4, 5"   00000000 00000002 00000000 00000002
r 2170.10                             RP,               RM
*Want "CGXBRA +2.5 M3 modes 6, 7"   00000000 00000003 00000000 00000002

r 2180.10                             RZ,               RP
*Want "CGXBRA +5.5 FPCR modes 1, 2" 00000000 00000005 00000000 00000006
r 2190.10                             RM,               RFS
*Want "CGXBRA +5.5 FPCR modes 3, 7" 00000000 00000005 00000000 00000005
r 21A0.10                             RNTA,             RFS
*Want "CGXBRA +5.5 M3 modes 1, 3"   00000000 00000006 00000000 00000005
r 21B0.10                             RNTE,             RZ
*Want "CGXBRA +5.5 M3 modes 4, 5"   00000000 00000006 00000000 00000005
r 21C0.10                             RP,               RM
*Want "CGXBRA +5.5 M3 modes 6, 7"   00000000 00000006 00000000 00000005

r 21D0.10                             RZ,               RP
*Want "CGXBRA +9.5 FPCR modes 1, 2" 00000000 00000009 00000000 0000000A
r 21E0.10                             RM,               RFS
*Want "CGXBRA +9.5 FPCR modes 3, 7" 00000000 00000009 00000000 00000009
r 21F0.10                             RNTA,             RFS
*Want "CGXBRA +9.5 M3 modes 1, 3"   00000000 0000000A 00000000 00000009
r 2200.10                             RNTE,             RZ
*Want "CGXBRA +9.5 M3 modes 4, 5"   00000000 0000000A 00000000 00000009
r 2210.10                             RP,               RM
*Want "CGXBRA +9.5 M3 modes 6, 7"   00000000 0000000A 00000000 00000009

#  rounding mode tests - extended BFP - FPCR contents with cc in last byte
*Compare
r 2300.10
*Want "CGXBRA -9.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 2310.10
*Want "CGXBRA -9.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 2320.08
*Want "CGXBRA -9.5 M3 modes 5-7"           00080001 00080001

r 2330.10
*Want "CGXBRA -5.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 2340.10
*Want "CGXBRA -5.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080001 00080001
r 2350.08
*Want "CGXBRA -5.5 M3 modes 5-7"            00080001 00080001
  
r 2360.10
*Want "CGXBRA -2.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 2370.10
*Want "CGXBRA -2.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080001 00080001
r 2380.08
*Want "CGXBRA -2.5 M3 modes 5-7"            00080001 00080001

r 2390.10
*Want "CGXBRA -1.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 23A0.10
*Want "CGXBRA -1.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080001 00080001
r 23B0.08
*Want "CGXBRA -1.5 M3 modes 5-7"            00080001 00080001

r 23C0.10
*Want "CGXBRA -0.5 FPCR modes 1-3, 7 FPCR"  00000000 00000000 00000001 00000001
r 23D0.10
*Want "CGXBRA -0.5 M3 modes 1, 3-5 FPCR"    00080001 00080001 00080000 00080000
r 23E0.08
*Want "CGXBRA -0.5 M3 modes 5-7"            00080000 00080001

r 23F0.10
*Want "CGXBRA +0.5 FPCR modes 1-3, 7 FPCR"  00000000 00000002 00000000 00000002
r 2400.10
*Want "CGXBRA +0.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080000 00080000
r 2410.08
*Want "CGXBRA +0.5 M3 modes 5-7"            00080002 00080000

r 2420.10
*Want "CGXBRA +1.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 2430.10
*Want "CGXBRA +1.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080002 00080002
r 2440.08
*Want "CGXBRA +1.5 M3 modes 5-7"            00080002 00080002

r 2450.10
*Want "CGXBRA +2.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 2460.10
*Want "CGXBRA +2.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080002 00080002
r 2470.08
*Want "CGXBRA +2.5 M3 modes 5-7"            00080002 00080002

r 2480.10
*Want "CGXBRA +5.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 2490.10
*Want "CGXBRA +5.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080002 00080002
r 24A0.08
*Want "CGXBRA +5.5 M3 modes 5-7"            00080002 00080002

r 24B0.10
*Want "CGXBRA +9.5 FPCR modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 24C0.10
*Want "CGXBRA +9.5 M3 modes 1, 3-5 FPCR"    00080002 00080002 00080002 00080002
r 24D0.08
*Want "CGXBRA +9.5 M3 modes 5-7"            00080002 00080002


*Done

