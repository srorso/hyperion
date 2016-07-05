*
*Testcase ieee-loadfpi.tst: IEEE Load FP Integer
*Message Testcase ieee-loadfpi.tst: IEEE Load FP Integer
*Message ..Includes LOAD FP INTEGER (6).  Also tests traps and 
*Message ..exceptions, results from different rounding modes, and 
*Message ..NaN propagation and exceptions.   
#
# CONVERT TO FIXED tests - Binary Floating Point
#
# Tests the following three conversion instructions
#   LOAD FP INTEGER (short BFP to int-32, RRE)
#   LOAD FP INTEGER (long BFP to int-32, RRE) 
#   LOAD FP INTEGER (extended BFP to int-32, RRE)  
#   LOAD FP INTEGER (short BFP to int-32, RRF-e)
#   LOAD FP INTEGER (long BFP to int-32, RRF-e) 
#   LOAD FP INTEGER (extended BFP to int-32, RRF-e)  
#
# Also tests the following floating point support instructions
#   LOAD  (Short)
#   LOAD  (Long)
#   LOAD FPC
#   SET BFP ROUNDING MODE 3-BIT
#   STORE (Short)
#   STORE (Long)
#   STORE FPC
#
#
sysclear
archmode esame
loadcore $(testpath)/ieee-loadfpi.core

runtest .1
*Program 7
r 1C00-1C7F  # Extended BFP basic rounding, NaNs, traps
r 1C80-1CFF  # Extended BFP basic rounding, NaNs, traps FPCR contents
r 1D00-23FF  # Extended BFP rounding modes
r 2400-25ff  # Extended BFP rounding modes FPCR contents

# Short BFP Inputs converted to integer short BFP
*Compare
r 1000.10  
*Want "CFEBR result pairs 1-2" 3F800000 3F800000 C0000000 C0000000
r 1010.10  
*Want "CFEBR result pairs 3-4" 7FC10000 00000000 7FC10000 7FC10000

*Compare
r 1080.10  # Inputs converted to BFP Short - FPC
*Want "CFEBR FPC pairs 1-2" 00000000 F8000000 00080000 F8000800
r 1090.10  # Inputs converted to BFP Short - FPC
*Want "CFEBR FPC pairs 3-4" 00800000 F8008000 00000000 F8000000

#  rounding mode tests - short BFP - results from rounding
*Compare
r 1100.10  # Rounding Mode Tests, FPCR,  RZ,    RP,       RM,      RFS
*Want "CFEBRA -9.5 FPC modes 1-3, 7"   C1100000 C1100000 C1200000 C1100000
r 1110.10  # Rounding Mode Tests, M3,    RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -9.5 M3 modes 1, 3-5"    C1200000 C1100000 C1200000 C1100000
r 1120.08  # Rounding Mode Tests, M3,    RP,      RM
*Want "CFEBRA -9.5 M3 modes 6, 7"      C1100000 C1200000

r 1130.10  # Rounding Mode Tests, FPCR, RZ,     RP,      RM,      RFS
*Want "CFEBRA -5.5 FPC modes 1-3, 7" C0A00000 C0A00000 C0C00000 C0A00000
r 1140.10  # Rounding Mode Tests, M3,  RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -5.5 M3 modes 1, 3-5"  C0C00000 C0A00000 C0C00000 C0A00000
r 1150.08  # Rounding Mode Tests, M3,  RP,      RM
*Want "CFEBRA -5.5 M3 modes 6, 7"    C0A00000 C0C00000

r 1160.10  # Rounding Mode Tests, FPCR, RZ,     RP,      RM,      RFS
*Want "CFEBRA -2.5 FPC modes 1-3, 7" C0000000 C0000000 C0400000 C0400000
r 1170.10  # Rounding Mode Tests, M3,  RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -2.5 M3 modes 1, 3-5"  C0400000 C0400000 C0000000 C0000000
r 1180.08  # Rounding Mode Tests, M3,  RP,      RM
*Want "CFEBRA -2.5 M3 modes 6, 7"    C0000000 C0400000

r 1190.10  # Rounding Mode Tests, FPCR, RZ,     RP,      RM,      RFS
*Want "CFEBRA -1.5 FPC modes 1-3, 7" BF800000 BF800000 C0000000 BF800000
r 11A0.10  # Rounding Mode Tests, M3,  RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -1.5 M3 modes 1, 3-5"  C0000000 BF800000 C0000000 BF800000
r 11B0.08  # Rounding Mode Tests, M3,  RP,      RM
*Want "CFEBRA -1.5 M3 modes 6, 7"    BF800000 C0000000

r 11C0.10  # Rounding Mode Tests, FPCR, RZ,     RP,      RM,      RFS
*Want "CFEBRA -0.5 FPC modes 1-3, 7" 80000000 80000000 BF800000 BF800000
r 11D0.10  # Rounding Mode Tests, M3,  RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -0.5 M3 modes 1, 3-5"  BF800000 BF800000 80000000 80000000
r 11E0.08  # Rounding Mode Tests, M3,  RP,      RM
*Want "CFEBRA -0.5 M3 modes 6, 7"    80000000 BF800000

r 11F0.10  # Rounding Mode Tests, FPCR, RZ,    RP,      RM,      RFS
*Want "CFEBRA 0.5 FPC modes 1-3, 7" 00000000 3F800000 00000000 3F800000
r 1200.10  # Rounding Mode Tests, M3, RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA 0.5 M3 modes 1, 3-5"  3F800000 3F800000 00000000 00000000
r 1210.08  # Rounding Mode Tests, M3, RP,      RM
*Want "CFEBRA 0.5 M3 modes 6, 7"    3F800000 00000000

r 1220.10  # Rounding Mode Tests, FPCR, RZ,    RP,      RM,      RFS
*Want "CFEBRA 1.5 FPC modes 1-3, 7" 3F800000 40000000 3F800000 3F800000
r 1230.10  # Rounding Mode Tests, M3, RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA 1.5 M3 modes 1, 3-5"  40000000 3F800000 40000000 3F800000
r 1240.08  # Rounding Mode Tests, M3, RP,      RM
*Want "CFEBRA 1.5 M3 modes 6, 7"    40000000 3F800000

r 1250.10  # Rounding Mode Tests, FPCR, RZ,    RP,      RM,      RFS
*Want "CFEBRA 2.5 FPC modes 1-3, 7" 40000000 40400000 40000000 40400000
r 1260.10  # Rounding Mode Tests, M3, RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA 2.5 M3 modes 1, 3-5"  40400000 40400000 40000000 40000000
r 1270.08  # Rounding Mode Tests, M3, RP,      RM
*Want "CFEBRA 2.5 M3 modes 6, 7"    40400000 40000000

r 1280.10  # Rounding Mode Tests, FPCR, RZ,    RP,      RM,      RFS
*Want "CFEBRA 5.5 FPC modes 1-3, 7" 40A00000 40C00000 40A00000 40A00000
r 1290.10  # Rounding Mode Tests, M3, RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA 5.5 M3 modes 1, 3-5"  40C00000 40A00000 40C00000 40A00000
r 12A0.08  # Rounding Mode Tests, M3, RP,      RM
*Want "CFEBRA 5.5 M3 modes 6, 7"    40C00000 40A00000

r 12B0.10  # Rounding Mode Tests, FPCR, RZ,    RP,      RM,      RFS
*Want "CFEBRA 9.5 FPC modes 1-3, 7" 41100000 41200000 41100000 41100000
r 12C0.10  # Rounding Mode Tests, M3, RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA 9.5 M3 modes 1, 3-5"  41200000 41100000 41200000 41100000
r 12D0.08  # Rounding Mode Tests, M3, RP,      RM
*Want "CFEBRA 9.5 M3 modes 6, 7"    41200000 41100000

#  rounding mode tests - short BFP - FPCR contents 
*Compare
r 1300.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -9.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1310.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -9.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1320.08  # Rounding Mode Tests - FPC
*Want "CFEBRA -9.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1330.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -5.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1340.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -5.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1350.08  # Rounding Mode Tests - FPC
*Want "CFEBRA -5.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1360.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -2.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1370.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -2.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1380.08  # Rounding Mode Tests - FPC
*Want "CFEBRA -2.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1390.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -1.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 13A0.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -1.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 13B0.08  # Rounding Mode Tests - FPC
*Want "CFEBRA -1.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 13C0.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -0.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 13D0.10  # Rounding Mode Tests - FPC
*Want "CFEBRA -0.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 13E0.08  # Rounding Mode Tests - FPC
*Want "CFEBRA -0.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 13F0.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +0.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1400.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +0.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1410.08  # Rounding Mode Tests - FPC
*Want "CFEBRA +0.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1420.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +1.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1430.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +1.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1440.08  # Rounding Mode Tests - FPC
*Want "CFEBRA +1.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1450.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +2.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1460.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +2.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1470.08  # Rounding Mode Tests - FPC
*Want "CFEBRA +2.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1480.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +5.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1490.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +5.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 14A0.08  # Rounding Mode Tests - FPC
*Want "CFEBRA +5.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 14B0.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +9.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 14C0.10  # Rounding Mode Tests - FPC
*Want "CFEBRA +9.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 14D0.08  # Rounding Mode Tests - FPC
*Want "CFEBRA +9.5 M3 modes 5-7 - FCPR"    00080000 00080000


*Compare
r 1500.10  # Results converted from BFP long 
*Want "CFDBR result pair 1" 3FF00000 00000000 3FF00000 00000000
r 1510.10  # Results converted from BFP long 
*Want "CFDBR result pair 2" C0000000 00000000 C0000000 00000000
r 1520.10  # Results converted from BFP long 
*Want "CFDBR result pair 3" 7FF81000 00000000 00000000 00000000
r 1530.10  # Results converted from BFP long 
*Want "CFDBR result pair 4" 7FF81000 00000000 7FF81000 00000000

*Compare
r 1580.10  # Results converted from BFP long - FPC
*Want "CFDBR FPC pairs 1-2" 00000000 F8000000 00080000 F8000800
r 1590.10  # Results converted from BFP long - FPC
*Want "CFDBR FPC pairs 5-6" 00800000 F8008000 00000000 F8000000


#  rounding mode tests - long BFP - results from rounding
*Compare
r 1600.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA -9.5 FPC modes 1, 2"   C0220000 00000000 C0220000 00000000
r 1610.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA -9.5 FPC modes 3, 7"   C0240000 00000000 C0220000 00000000
r 1620.10  # Rounding Mode Tests, M3,  RNTA,              RFS
*Want "CFDBRA -9.5 M3 modes 1, 3"    C0240000 00000000 C0220000 00000000
r 1630.10  # Rounding Mode Tests, M3,  RNTE,              RZ
*Want "CFDBRA -9.5 M3 modes 4, 5"    C0240000 00000000 C0220000 00000000
r 1640.10  # Rounding Mode Tests, M3,  RP,                RM
*Want "CFDBRA -9.5 M3 modes 6, 7"    C0220000 00000000 C0240000 00000000

r 1650.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA -5.5 FPC modes 1, 2"   C0140000 00000000 C0140000 00000000
r 1660.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA -5.5 FPC modes 3, 7"   C0180000 00000000 C0140000 00000000
r 1670.10  # Rounding Mode Tests, M3,   RNTA,             RFS
*Want "CFDBRA -5.5 M3 modes 1, 3"    C0180000 00000000 C0140000 00000000
r 1680.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA -5.5 M3 modes 4, 5"    C0180000 00000000 C0140000 00000000
r 1690.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA -5.5 M3 modes 6, 7"    C0140000 00000000 C0180000 00000000

r 16A0.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA -2.5 FPC modes 1, 2"   C0000000 00000000 C0000000 00000000
r 16B0.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA -2.5 FPC modes 3, 7"   C0080000 00000000 C0080000 00000000
r 16C0.10  # Rounding Mode Tests, M3,   RNTA,             RFS
*Want "CFDBRA -2.5 M3 modes 1, 3"    C0080000 00000000 C0080000 00000000
r 16D0.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA -2.5 M3 modes 4, 5"    C0000000 00000000 C0000000 00000000
r 16E0.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA -2.5 M3 modes 6, 7"    C0000000 00000000 C0080000 00000000

r 16F0.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA -1.5 FPC modes 1, 2"   BFF00000 00000000 BFF00000 00000000
r 1700.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA -1.5 FPC modes 3, 7"   C0000000 00000000 BFF00000 00000000
r 1710.10  # Rounding Mode Tests, M3,   RNTA,             RFS
*Want "CFDBRA -1.5 M3 modes 1, 3"    C0000000 00000000 BFF00000 00000000
r 1720.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA -1.5 M3 modes 4, 5"    C0000000 00000000 BFF00000 00000000
r 1730.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA -1.5 M3 modes 6, 7"    BFF00000 00000000 C0000000 00000000

r 1740.10  # Rounding Mode Tests, FPCR, RZ,              RP
*Want "CFDBRA -0.5 FPC modes 1, 2"   80000000 00000000 80000000 00000000
r 1750.10  # Rounding Mode Tests, FPCR, RM,              RFS
*Want "CFDBRA -0.5 FPC modes 3, 7"   BFF00000 00000000 BFF00000 00000000
r 1760.10  # Rounding Mode Tests, M3,   RNTA,            RFS
*Want "CFDBRA -0.5 M3 modes 1, 3"    BFF00000 00000000 BFF00000 00000000
r 1770.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA -0.5 M3 modes 4, 5"    80000000 00000000 80000000 00000000
r 1780.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA -0.5 M3 modes 6, 7"    80000000 00000000 BFF00000 00000000

r 1790.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA 0.5 FPC modes 1, 2"    00000000 00000000 3FF00000 00000000
r 17A0.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA 0.5 FPC modes 3, 7"    00000000 00000000 3FF00000 00000000
r 17B0.10  # Rounding Mode Tests, M3,   RNTA,             RFS
*Want "CFDBRA 0.5 M3 modes 1, 3"     3FF00000 00000000 3FF00000 00000000
r 17C0.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA 0.5 M3 modes 4, 5"     00000000 00000000 00000000 00000000
r 17D0.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA 0.5 M3 modes 6, 7"     3FF00000 00000000 00000000 00000000

r 17E0.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA 1.5 FPC modes 1, 2"    3FF00000 00000000 40000000 00000000
r 17F0.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA 1.5 FPC modes 3, 7"    3FF00000 00000000 3FF00000 00000000
r 1800.10  # Rounding Mode Tests, M3,   RNTA,             RFS
*Want "CFDBRA 1.5 M3 modes 1, 3"     40000000 00000000 3FF00000 00000000
r 1810.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA 1.5 M3 modes 4, 5"     40000000 00000000 3FF00000 00000000
r 1820.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA 1.5 M3 modes 6, 7"     40000000 00000000 3FF00000 00000000

r 1830.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA 2.5 FPC modes 1, 2"    40000000 00000000 40080000 00000000
r 1840.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA 2.5 FPC modes 3, 7"    40000000 00000000 40080000 00000000
r 1850.10  # Rounding Mode Tests, M3,   RNTA,             RFS
*Want "CFDBRA 2.5 M3 modes 1, 3"     40080000 00000000 40080000 00000000
r 1860.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA 2.5 M3 modes 4, 5"     40000000 00000000 40000000 00000000
r 1870.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA 2.5 M3 modes 6, 7"     40080000 00000000 40000000 00000000

r 1880.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA 5.5 FPC modes 1, 2"    40140000 00000000 40180000 00000000
r 1890.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA 5.5 FPC modes 3, 7"    40140000 00000000 40140000 00000000
r 18A0.10  # Rounding Mode Tests, M3,   RNTA,             RFS
*Want "CFDBRA 5.5 M3 modes 1, 3"     40180000 00000000 40140000 00000000
r 18B0.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA 5.5 M3 modes 4, 5"     40180000 00000000 40140000 00000000
r 18C0.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA 5.5 M3 modes 6, 7"     40180000 00000000 40140000 00000000

r 18D0.10  # Rounding Mode Tests, FPCR, RZ,               RP
*Want "CFDBRA 9.5 FPC modes 1, 2"    40220000 00000000 40240000 00000000
r 18E0.10  # Rounding Mode Tests, FPCR, RM,               RFS
*Want "CFDBRA 9.5 FPC modes 3, 7"    40220000 00000000 40220000 00000000
r 18F0.10  # Rounding Mode Tests, M3,   RNTA,             RFS
*Want "CFDBRA 9.5 M3 modes 1, 3"     40240000 00000000 40220000 00000000
r 1900.10  # Rounding Mode Tests, M3,   RNTE,             RZ
*Want "CFDBRA 9.5 M3 modes 4, 5"     40240000 00000000 40220000 00000000
r 1910.10  # Rounding Mode Tests, M3,   RP,               RM
*Want "CFDBRA 9.5 M3 modes 6, 7"     40240000 00000000 40220000 00000000

#  rounding mode tests - long BFP - FPCR contents with cc in last byte
*Compare
r 1A00.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -9.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1A10.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -9.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1A20.08  # Rounding Mode Tests - FPC
*Want "CFDBRA -9.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1A30.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -5.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1A40.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -5.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1A50.08  # Rounding Mode Tests - FPC
*Want "CFDBRA -5.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1A60.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -2.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1A70.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -2.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1A80.08  # Rounding Mode Tests - FPC
*Want "CFDBRA -2.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1A90.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -1.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1AA0.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -1.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1AB0.08  # Rounding Mode Tests - FPC
*Want "CFDBRA -1.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1AC0.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -0.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1AD0.10  # Rounding Mode Tests - FPC
*Want "CFDBRA -0.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1AE0.08  # Rounding Mode Tests - FPC
*Want "CFDBRA -0.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1AF0.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +0.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1B00.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +0.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1B10.08  # Rounding Mode Tests - FPC
*Want "CFDBRA +0.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1B20.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +1.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1B30.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +1.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1B40.08  # Rounding Mode Tests - FPC
*Want "CFDBRA +1.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1B50.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +2.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1B60.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +2.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1B70.08  # Rounding Mode Tests - FPC
*Want "CFDBRA +2.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1B80.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +5.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1B90.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +5.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1BA0.08  # Rounding Mode Tests - FPC
*Want "CFDBRA +5.5 M3 modes 5-7 - FCPR"    00080000 00080000

r 1BB0.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +9.5 FPC modes 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 1BC0.10  # Rounding Mode Tests - FPC
*Want "CFDBRA +9.5 M3 modes 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 1BD0.08  # Rounding Mode Tests - FPC
*Want "CFDBRA +9.5 M3 modes 5-7 - FCPR"    00080000 00080000


*Compare
r 1C00.10  # Results converted from BFP extended 
*Want "CFXBR result pair 1a" 3FFF0000 00000000 00000000 00000000
r 1C10.10  # Results converted from BFP extended 
*Want "CFXBR result pair 1b" 3FFF0000 00000000 00000000 00000000
r 1C20.10  # Results converted from BFP extended 
*Want "CFXBR result pair 2a" C0000000 00000000 00000000 00000000
r 1C30.10  # Results converted from BFP extended 
*Want "CFXBR result pair 2b" C0000000 00000000 00000000 00000000
r 1C40.10  # Results converted from BFP extended 
*Want "CFXBR result pair 3a" 7FFF8100 00000000 00000000 00000000
r 1C50.10  # Results converted from BFP extended 
*Want "CFXBR result pair 3b" 00000000 00000000 00000000 00000000
r 1C60.10  # Results converted from BFP extended 
*Want "CFXBR result pair 4a" 7FFF8100 00000000 00000000 00000000
r 1C70.10  # Results converted from BFP extended 
*Want "CFXBR result pair 4b" 7FFF8100 00000000 00000000 00000000


*Compare
r 1C80.10  # Results converted from BFP extended - FPC
*Want "CFXBR FPC pair  1-2" 00000000 F8000000 00080000 F8000800
r 1C90.10  # Results converted from BFP extended - FPC
*Want "CFXBR FPC pair  3-4" 00800000 F8008000 00000000 F8000000


#  rounding mode tests - extended BFP - results from rounding
*Compare
r 1D00.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA -9.5 FPC mode 1"         C0022000 00000000 00000000 00000000
r 1D10.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA -9.5 FPC mode 2"         C0022000 00000000 00000000 00000000
r 1D20.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA -9.5 FPC mode 3"         C0024000 00000000 00000000 00000000
r 1D30.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA -9.5 FPC mode 7"         C0022000 00000000 00000000 00000000
r 1D40.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA -9.5 M3 mode 1"          C0024000 00000000 00000000 00000000
r 1D50.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA -9.5 M3 mode 3"          C0022000 00000000 00000000 00000000
r 1D60.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA -9.5 M3 mode 4"          C0024000 00000000 00000000 00000000
r 1D70.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA -9.5 M3 mode 5"          C0022000 00000000 00000000 00000000
r 1D80.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA -9.5 M3 mode 6"          C0022000 00000000 00000000 00000000
r 1D90.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA -9.5 M3 mode 7"          C0024000 00000000 00000000 00000000

r 1DA0.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA -5.5 FPC mode 1"         C0014000 00000000 00000000 00000000
r 1DB0.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA -5.5 FPC mode 2"         C0014000 00000000 00000000 00000000
r 1DC0.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA -5.5 FPC mode 3"         C0018000 00000000 00000000 00000000
r 1DD0.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA -5.5 FPC mode 7"         C0014000 00000000 00000000 00000000
r 1DE0.10  # Rounding Mode Tests, M3,    RNTA
*Want "CFXBRA -5.5 M3 mode 1"          C0018000 00000000 00000000 00000000
r 1DF0.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA -5.5 M3 mode 3"          C0014000 00000000 00000000 00000000
r 1E00.10  # Rounding Mode Tests, M3,    RNTE
*Want "CFXBRA -5.5 M3 mode 4"          C0018000 00000000 00000000 00000000
r 1E10.10  # Rounding Mode Tests, M3,    RZ
*Want "CFXBRA -5.5 M3 mode 5"          C0014000 00000000 00000000 00000000
r 1E20.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA -5.5 M3 mode 6"          C0014000 00000000 00000000 00000000
r 1E30.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA -5.5 M3 mode 7"          C0018000 00000000 00000000 00000000

r 1E40.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA -2.5 FPC mode 1"         C0000000 00000000 00000000 00000000
r 1E50.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA -2.5 FPC mode 2"         C0000000 00000000 00000000 00000000
r 1E60.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA -2.5 FPC mode 3"         C0008000 00000000 00000000 00000000
r 1E70.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA -2.5 FPC mode 7"         C0008000 00000000 00000000 00000000
r 1E80.10  # Rounding Mode Tests, M3,    RNTA
*Want "CFXBRA -2.5 M3 mode 1"          C0008000 00000000 00000000 00000000
r 1E90.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA -2.5 M3 mode 3"          C0008000 00000000 00000000 00000000
r 1EA0.10  # Rounding Mode Tests, M3,    RNTE
*Want "CFXBRA -2.5 M3 mode 4"          C0000000 00000000 00000000 00000000
r 1EB0.10  # Rounding Mode Tests, M3,    RZ
*Want "CFXBRA -2.5 M3 mode 5"          C0000000 00000000 00000000 00000000
r 1EC0.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA -2.5 M3 mode 6"          C0000000 00000000 00000000 00000000
r 1ED0.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA -2.5 M3 mode 7"          C0008000 00000000 00000000 00000000

r 1EE0.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA -1.5 FPC mode 1"         BFFF0000 00000000 00000000 00000000
r 1EF0.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA -1.5 FPC mode 2"         BFFF0000 00000000 00000000 00000000
r 1F00.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA -1.5 FPC mode 3"         C0000000 00000000 00000000 00000000
r 1F10.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA -1.5 FPC mode 7"         BFFF0000 00000000 00000000 00000000
r 1F20.10  # Rounding Mode Tests, M3,    RNTA
*Want "CFXBRA -1.5 M3 mode 1"          C0000000 00000000 00000000 00000000
r 1F30.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA -1.5 M3 mode 3"          BFFF0000 00000000 00000000 00000000
r 1F40.10  # Rounding Mode Tests, M3,    RNTE
*Want "CFXBRA -1.5 M3 mode 4"          C0000000 00000000 00000000 00000000
r 1F50.10  # Rounding Mode Tests, M3,    RZ
*Want "CFXBRA -1.5 M3 mode 5"          BFFF0000 00000000 00000000 00000000
r 1F60.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA -1.5 M3 mode 6"          BFFF0000 00000000 00000000 00000000
r 1F70.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA -1.5 M3 mode 7"          C0000000 00000000 00000000 00000000

r 1F80.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA -0.5 FPC mode 1"         80000000 00000000 00000000 00000000
r 1F90.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA -0.5 FPC mode 2"         80000000 00000000 00000000 00000000
r 1FA0.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA -0.5 FPC mode 3"         BFFF0000 00000000 00000000 00000000
r 1FB0.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA -0.5 FPC mode 7"         BFFF0000 00000000 00000000 00000000
r 1FC0.10  # Rounding Mode Tests, M3,    RNTA
*Want "CFXBRA -0.5 M3 mode 1"          BFFF0000 00000000 00000000 00000000
r 1FD0.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA -0.5 M3 mode 3"          BFFF0000 00000000 00000000 00000000
r 1FE0.10  # Rounding Mode Tests, M3,    RNTE
*Want "CFXBRA -0.5 M3 mode 4"          80000000 00000000 00000000 00000000
r 1FF0.10  # Rounding Mode Tests, M3,    RZ
*Want "CFXBRA -0.5 M3 mode 5"          80000000 00000000 00000000 00000000
r 2000.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA -0.5 M3 mode 6"          80000000 00000000 00000000 00000000
r 2010.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA -0.5 M3 mode 7"          BFFF0000 00000000 00000000 00000000

r 2020.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA 0.5 FPC mode 1"          00000000 00000000 00000000 00000000
r 2030.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA 0.5 FPC mode 2"          3FFF0000 00000000 00000000 00000000
r 2040.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA 0.5 FPC mode 3"          00000000 00000000 00000000 00000000
r 2050.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA 0.5 FPC mode 7"          3FFF0000 00000000 00000000 00000000
r 2060.10  # Rounding Mode Tests, M3,    RNTA
*Want "CFXBRA 0.5 M3 mode 1"           3FFF0000 00000000 00000000 00000000
r 2070.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA 0.5 M3 mode 3"           3FFF0000 00000000 00000000 00000000
r 2080.10  # Rounding Mode Tests, M3,    RNTE
*Want "CFXBRA 0.5 M3 mode 4"           00000000 00000000 00000000 00000000
r 2090.10  # Rounding Mode Tests, M3,    RZ
*Want "CFXBRA 0.5 M3 mode 5"           00000000 00000000 00000000 00000000
r 20A0.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA 0.5 M3 mode 6"           3FFF0000 00000000 00000000 00000000
r 20B0.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA 0.5 M3 mode 7"           00000000 00000000 00000000 00000000

r 20C0.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA 1.5 FPC mode 1"          3FFF0000 00000000 00000000 00000000
r 20D0.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA 1.5 FPC mode 2"          40000000 00000000 00000000 00000000
r 20E0.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA 1.5 FPC mode 3"          3FFF0000 00000000 00000000 00000000
r 20F0.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA 1.5 FPC mode 7"          3FFF0000 00000000 00000000 00000000
r 2100.10  # Rounding Mode Tests, M3,    RNTA
*Want "CFXBRA 1.5 M3 mode 1"           40000000 00000000 00000000 00000000
r 2110.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA 1.5 M3 mode 3"           3FFF0000 00000000 00000000 00000000
r 2120.10  # Rounding Mode Tests, M3,    RNTE
*Want "CFXBRA 1.5 M3 mode 4"           40000000 00000000 00000000 00000000
r 2130.10  # Rounding Mode Tests, M3,    RZ
*Want "CFXBRA 1.5 M3 mode 5"           3FFF0000 00000000 00000000 00000000
r 2140.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA 1.5 M3 mode 6"           40000000 00000000 00000000 00000000
r 2150.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA 1.5 M3 mode 7"           3FFF0000 00000000 00000000 00000000

r 2160.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA 2.5 FPC mode 1"          40000000 00000000 00000000 00000000
r 2170.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA 2.5 FPC mode 2"          40008000 00000000 00000000 00000000
r 2180.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA 2.5 FPC mode 3"          40000000 00000000 00000000 00000000
r 2190.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA 2.5 FPC mode 7"          40008000 00000000 00000000 00000000
r 21A0.10  # Rounding Mode Tests, M3,    RNTA
*Want "CFXBRA 2.5 M3 mode 1"           40008000 00000000 00000000 00000000
r 21B0.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA 2.5 M3 mode  3"          40008000 00000000 00000000 00000000
r 21C0.10  # Rounding Mode Tests, M3,    RNTE
*Want "CFXBRA 2.5 M3 mode 4"           40000000 00000000 00000000 00000000
r 21D0.10  # Rounding Mode Tests, M3,    RZ
*Want "CFXBRA 2.5 M3 mode 5"           40000000 00000000 00000000 00000000
r 21E0.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA 2.5 M3 mode 6"           40008000 00000000 00000000 00000000
r 21F0.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA 2.5 M3 mode 7"           40000000 00000000 00000000 00000000

r 2200.10  # Rounding Mode Tests, FPCR,  RZ
*Want "CFXBRA 5.5 FPC mode 1"          40014000 00000000 00000000 00000000
r 2210.10  # Rounding Mode Tests, FPCR,  RP
*Want "CFXBRA 5.5 FPC mode 2"          40018000 00000000 00000000 00000000
r 2220.10  # Rounding Mode Tests, FPCR,  RM
*Want "CFXBRA 5.5 FPC mode 3"          40014000 00000000 00000000 00000000
r 2230.10  # Rounding Mode Tests, FPCR,  RFS
*Want "CFXBRA 5.5 FPC mode 7"          40014000 00000000 00000000 00000000
r 2240.10  # Rounding Mode Tests, M3,    RNTA
*Want "CFXBRA 5.5 M3 mode 1"           40018000 00000000 00000000 00000000
r 2250.10  # Rounding Mode Tests, M3,    RFS
*Want "CFXBRA 5.5 M3 mode 3"           40014000 00000000 00000000 00000000
r 2260.10  # Rounding Mode Tests, M3,    RNTE
*Want "CFXBRA 5.5 M3 mode 4"           40018000 00000000 00000000 00000000
r 2270.10  # Rounding Mode Tests, M3,    RZ
*Want "CFXBRA 5.5 M3 mode 5"           40014000 00000000 00000000 00000000
r 2280.10  # Rounding Mode Tests, M3,    RP
*Want "CFXBRA 5.5 M3 mode 6"           40018000 00000000 00000000 00000000
r 2290.10  # Rounding Mode Tests, M3,    RM
*Want "CFXBRA 5.5 M3 mode 7"           40014000 00000000 00000000 00000000

r 22A0.10  # Rounding Mode Tests, FPCR, RZ
*Want "CFXBRA 9.5 FPC mode 1"        40022000 00000000 00000000 00000000
r 22B0.10  # Rounding Mode Tests, FPCR, RP
*Want "CFXBRA 9.5 FPC mode 2"        40024000 00000000 00000000 00000000
r 22C0.10  # Rounding Mode Tests, FPCR, RM
*Want "CFXBRA 9.5 FPC mode 3"        40022000 00000000 00000000 00000000
r 22D0.10  # Rounding Mode Tests, FPCR, RFS
*Want "CFXBRA 9.5 FPC mode 7"        40022000 00000000 00000000 00000000
r 22E0.10  # Rounding Mode Tests, M3, RNTA
*Want "CFXBRA 9.5 M3 mode 1"         40024000 00000000 00000000 00000000
r 22F0.10  # Rounding Mode Tests, M3,  RFS
*Want "CFXBRA 9.5 M3 mode 3"         40022000 00000000 00000000 00000000
r 2300.10  # Rounding Mode Tests, M3,  RNTE
*Want "CFXBRA 9.5 M3 mode 4"         40024000 00000000 00000000 00000000
r 2310.10  # Rounding Mode Tests, M3,  RZ
*Want "CFXBRA 9.5 M3 mode 5"         40022000 00000000 00000000 00000000
r 2320.10  # Rounding Mode Tests, M3,  RP
*Want "CFXBRA 9.5 M3 mode 6"         40024000 00000000 00000000 00000000
r 2330.10  # Rounding Mode Tests, M3,  RM
*Want "CFXBRA 9.5 M3 mode 7"         40022000 00000000 00000000 00000000

#  rounding mode tests - extended BFP - FPCR contents with cc in last byte
*Compare
r 2400.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -9.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 2410.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -9.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 2420.08  # Rounding Mode Tests - FPC
*Want "CFXBRA -9.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 2430.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -5.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 2440.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -5.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 2450.08  # Rounding Mode Tests - FPC
*Want "CFXBRA -5.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 2460.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -2.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 2470.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -2.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 2480.08  # Rounding Mode Tests - FPC
*Want "CFXBRA -2.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 2490.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -1.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 24A0.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -1.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 24B0.08  # Rounding Mode Tests - FPC
*Want "CFXBRA -1.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 24C0.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -0.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 24D0.10  # Rounding Mode Tests - FPC
*Want "CFXBRA -0.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 24E0.08  # Rounding Mode Tests - FPC
*Want "CFXBRA -0.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 24F0.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +0.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 2500.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +0.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 2510.08  # Rounding Mode Tests - FPC
*Want "CFXBRA +0.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 2520.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +1.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 2530.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +1.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 2540.08  # Rounding Mode Tests - FPC
*Want "CFXBRA +1.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 2550.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +2.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 2560.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +2.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 2570.08  # Rounding Mode Tests - FPC
*Want "CFXBRA +2.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 2580.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +5.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 2590.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +5.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 25A0.08  # Rounding Mode Tests - FPC
*Want "CFXBRA +5.5 M3 mode 5-7 - FCPR"    00080000 00080000

r 25B0.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +9.5 FPC mode 1-3, 7 FCPR"  00000001 00000002 00000003 00000007
r 25C0.10  # Rounding Mode Tests - FPC
*Want "CFXBRA +9.5 M3 mode 1, 3-5 FPCR"   00080000 00080000 00080000 00080000
r 25D0.08  # Rounding Mode Tests - FPC
*Want "CFXBRA +9.5 M3 mode 5-7 - FCPR"    00080000 00080000


*Done

