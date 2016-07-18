*
*Testcase ieee-cvttofix.tst: IEEE Convert To Fixed
*Message Testcase ieee-cvtfrfix.tst: IEEE Convert To Fixed
*Message ..Includes CONVERT TO FIXED 32 (6).  Tests traps, exceptions,
*Message ..results from different rounding modes, and NaN propagation.

# CONVERT TO FIXED tests - Binary Floating Point
#
# Tests the following six conversion instructions
#   CONVERT TO FIXED (short BFP to int-32, RRE)
#   CONVERT TO FIXED (long BFP to int-32, RRE) 
#   CONVERT TO FIXED (extended BFP to int-32, RRE)  
#   CONVERT TO FIXED (short BFP to int-32, RRF-e)
#   CONVERT TO FIXED (long BFP to int-32, RRF-e) 
#   CONVERT TO FIXED (extended BFP to int-32, RRF-e)  
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
loadcore $(testpath)/ieee-cvttofix.core
runtest .1

*Program 7
r 1000.1000

# Convert short BFP to integer-32 results
*Compare
r 1000.10
*Want "CFEBR result pairs 1-2" 00000001 00000001 00000002 00000002
r 1010.10
*Want "CFEBR result pairs 3-4" 00000004 00000004 FFFFFFFE FFFFFFFE
r 1020.10
*Want "CFEBR result pairs 5-6" 80000000 00000000 80000000 00000000
r 1030.10
*Want "CFEBR result pairs 7-8" 7FFFFFFF 00000000 80000000 00000000

# Convert short BFP to integer-32 FPCR contents
*Compare
r 1080.10
*Want "CFEBR FPCR pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1090.10
*Want "CFEBR FPCR pairs 3-4" 00000002 F8000002 00000001 F8000001
r 10A0.10
*Want "CFEBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000
r 10A0.10
*Want "CFEBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000

#  Short BFP rounding mode tests - results from rounding
*Compare
r 1100.10                               RZ,     RP,       RM,      RFS
*Want "CFEBRA -9.5 FPCR modes 1-3, 7" FFFFFFF7 FFFFFFF7 FFFFFFF6 FFFFFFF7
r 1110.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -9.5 M3 modes 1, 3-5"   FFFFFFF6 FFFFFFF7 FFFFFFF6 FFFFFFF7
r 1120.08                               RP,      RM
*Want "CFEBRA -9.5 M3 modes 6, 7"     FFFFFFF7 FFFFFFF6

r 1130.10                               RZ,      RP,      RM,      RFS
*Want "CFEBRA -5.5 FPCR modes 1-3, 7" FFFFFFFB FFFFFFFB FFFFFFFA FFFFFFFB
r 1140.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -5.5 M3 modes 1, 3-5"   FFFFFFFA FFFFFFFB FFFFFFFA FFFFFFFB
r 1150.08                               RP,      RM
*Want "CFEBRA -5.5 M3 modes 6, 7"     FFFFFFFB FFFFFFFA

r 1160.10                               RZ,      RP,      RM,      RFS
*Want "CFEBRA -2.5 FPCR modes 1-3, 7" FFFFFFFE FFFFFFFE FFFFFFFD FFFFFFFD
r 1170.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -2.5 M3 modes 1, 3-5"   FFFFFFFD FFFFFFFD FFFFFFFE FFFFFFFE
r 1180.08                               RP,      RM
*Want "CFEBRA -2.5 M3 modes 6, 7"     FFFFFFFE FFFFFFFD

r 1190.10                               RZ,      RP,      RM,      RFS
*Want "CFEBRA -1.5 FPCR modes 1-3, 7" FFFFFFFF FFFFFFFF FFFFFFFE FFFFFFFF
r 11A0.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -1.5 M3 modes 1, 3-5"   FFFFFFFE FFFFFFFF FFFFFFFE FFFFFFFF
r 11B0.08                               RP,      RM
*Want "CFEBRA -1.5 M3 modes 6, 7"     FFFFFFFF FFFFFFFE

r 11C0.10                               RZ,      RP,      RM,      RFS
*Want "CFEBRA -0.5 FPCR modes 1-3, 7" 00000000 00000000 FFFFFFFF FFFFFFFF
r 11D0.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA -0.5 M3 modes 1, 3-5"   FFFFFFFF FFFFFFFF 00000000 00000000
r 11E0.08                               RP,      RM
*Want "CFEBRA -0.5 M3 modes 6, 7"     00000000 FFFFFFFF

r 11F0.10                               RZ,      RP,      RM,      RFS
*Want "CFEBRA +0.5 FPCR modes 1-3, 7" 00000000 00000001 00000000 00000001
r 1200.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA +0.5 M3 modes 1, 3-5"   00000001 00000001 00000000 00000000
r 1210.08                               RP,      RM
*Want "CFEBRA +0.5 M3 modes 6, 7"     00000001 00000000

r 1220.10                               RZ,     RP,      RM,      RFS
*Want "CFEBRA +1.5 FPCR modes 1-3, 7" 00000001 00000002 00000001 00000001
r 1230.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA +1.5 M3 modes 1, 3-5"   00000002 00000001 00000002 00000001
r 1240.08                               RP,      RM
*Want "CFEBRA +1.5 M3 modes 6, 7"     00000002 00000001

r 1250.10                               RZ,      RP,      RM,      RFS
*Want "CFEBRA +2.5 FPCR modes 1-3, 7" 00000002 00000003 00000002 00000003
r 1260.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA +2.5 M3 modes 1, 3-5"   00000003 00000003 00000002 00000002
r 1270.08                               RP,      RM
*Want "CFEBRA +2.5 M3 modes 6, 7"     00000003 00000002

r 1280.10                               RZ,      RP,      RM,      RFS
*Want "CFEBRA +5.5 FPCR modes 1-3, 7" 00000005 00000006 00000005 00000005
r 1290.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA +5.5 M3 modes 1, 3-5"   00000006 00000005 00000006 00000005
r 12A0.08                               RP,      RM
*Want "CFEBRA +5.5 M3 modes 6, 7"     00000006 00000005

r 12B0.10                               RZ,      RP,      RM,      RFS
*Want "CFEBRA +9.5 FPCR modes 1-3, 7" 00000009 0000000A 00000009 00000009
r 12C0.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFEBRA +9.5 M3 modes 1, 3-5"   0000000A 00000009 0000000A 00000009
r 12D0.08                               RP,      RM
*Want "CFEBRA +9.5 M3 modes 6, 7"     0000000A 00000009

#  rounding mode tests - short BFP - FPCR contents with cc in last byte
*Compare
r 1300.10
*Want "CFEBRA -9.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1310.10
*Want "CFEBRA -9.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1320.08
*Want "CFEBRA -9.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1330.10
*Want "CFEBRA -5.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1340.10
*Want "CFEBRA -5.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1350.08
*Want "CFEBRA -5.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1360.10
*Want "CFEBRA -2.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 1370.10
*Want "CFEBRA -2.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1380.08
*Want "CFEBRA -2.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1390.10
*Want "CFEBRA -1.5 FPCR modes 1-3, 7 FPCR"  00000001 00000001 00000001 00000001
r 13A0.10
*Want "CFEBRA -1.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 13B0.08
*Want "CFEBRA -1.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 13C0.10
*Want "CFEBRA -0.5 FPCR modes 1-3, 7 FPCR"  00000000 00000000 00000001 00000001
r 13D0.10
*Want "CFEBRA -0.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080000 00080000
r 13E0.08
*Want "CFEBRA -0.5 M3 modes 6, 7 FPCR"     00080000 00080001

r 13F0.10
*Want "CFEBRA +0.5 FPCR modes 1-3, 7 FPCR" 00000000 00000002 00000000 00000002
r 1400.10
*Want "CFEBRA +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080000 00080000
r 1410.08
*Want "CFEBRA +0.5 M3 modes 6, 7 FPCR"     00080002 00080000

r 1420.10
*Want "CFEBRA +1.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1430.10
*Want "CFEBRA +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1440.08
*Want "CFEBRA +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1450.10
*Want "CFEBRA +2.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1460.10
*Want "CFEBRA +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1470.08
*Want "CFEBRA +2.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1480.10
*Want "CFEBRA +5.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1490.10
*Want "CFEBRA +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 14A0.08
*Want "CFEBRA +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 14B0.10
*Want "CFEBRA +9.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 14C0.10
*Want "CFEBRA +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 14D0.08
*Want "CFEBRA +9.5 M3 modes 6, 7 FPCR"     00080002 00080002


# Long BFP converted to integer-32 - results
*Compare
r 1500.10
*Want "CFDBR result pairs 1-2" 00000001 00000001 00000002 00000002
r 1510.10
*Want "CFDBR result pairs 3-4" 00000004 00000004 FFFFFFFE FFFFFFFE
r 1520.10
*Want "CFDBR result pairs 5-6" 80000000 00000000 80000000 00000000
r 1530.10
*Want "CFDBR result pairs 7-8" 7FFFFFFF 00000000 80000000 00000000

# Long BFP converted to integer-32 - FPCR contents
*Compare
r 1580.10
*Want "CFDBR FPCR pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1590.10
*Want "CFDBR FPCR pairs 3-4" 00000002 F8000002 00000001 F8000001
r 15A0.10
*Want "CFDBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000
r 15A0.10
*Want "CFDBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000


#  rounding mode tests - long BFP - results from rounding
*Compare
r 1600.10                               RZ,      RP,       RM,      RFS
*Want "CFDBRA -9.5 FPCR modes 1-3, 7" FFFFFFF7 FFFFFFF7 FFFFFFF6 FFFFFFF7
r 1610.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA -9.5 M3 modes 1, 3-5"   FFFFFFF6 FFFFFFF7 FFFFFFF6 FFFFFFF7
r 1620.08                               RP,      RM
*Want "CFDBRA -9.5 M3 modes 6, 7"     FFFFFFF7 FFFFFFF6

r 1630.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA -5.5 FPCR modes 1-3, 7" FFFFFFFB FFFFFFFB FFFFFFFA FFFFFFFB
r 1640.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA -5.5 M3 modes 1, 3-5"   FFFFFFFA FFFFFFFB FFFFFFFA FFFFFFFB
r 1650.08                               RP,      RM
*Want "CFDBRA -5.5 M3 modes 6, 7"     FFFFFFFB FFFFFFFA

r 1660.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA -2.5 FPCR modes 1-3, 7" FFFFFFFE FFFFFFFE FFFFFFFD FFFFFFFD
r 1670.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA -2.5 M3 modes 1, 3-5"   FFFFFFFD FFFFFFFD FFFFFFFE FFFFFFFE
r 1680.08                               RP,      RM
*Want "CFDBRA -2.5 M3 modes 6, 7"     FFFFFFFE FFFFFFFD

r 1690.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA -1.5 FPCR modes 1-3, 7" FFFFFFFF FFFFFFFF FFFFFFFE FFFFFFFF
r 16A0.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA -1.5 M3 modes 1, 3-5"   FFFFFFFE FFFFFFFF FFFFFFFE FFFFFFFF
r 16B0.08                               RP,      RM
*Want "CFDBRA -1.5 M3 modes 6, 7"     FFFFFFFF FFFFFFFE

r 16C0.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA -0.5 FPCR modes 1-3, 7" 00000000 00000000 FFFFFFFF FFFFFFFF
r 16D0.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA -0.5 M3 modes 1, 3-5"   FFFFFFFF FFFFFFFF 00000000 00000000
r 16E0.08                               RP,      RM
*Want "CFDBRA -0.5 M3 modes 6, 7"     00000000 FFFFFFFF

r 16F0.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA +0.5 FPCR modes 1-3, 7" 00000000 00000001 00000000 00000001
r 1700.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA +0.5 M3 modes 1, 3-5"   00000001 00000001 00000000 00000000
r 1710.08                               RP,      RM
*Want "CFDBRA +0.5 M3 modes 6, 7"     00000001 00000000

r 1720.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA +1.5 FPCR modes 1-3, 7" 00000001 00000002 00000001 00000001
r 1730.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA +1.5 M3 modes 1, 3-5"   00000002 00000001 00000002 00000001
r 1740.08                               RP,      RM
*Want "CFDBRA +1.5 M3 modes 6, 7"     00000002 00000001

r 1750.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA +2.5 FPCR modes 1-3, 7" 00000002 00000003 00000002 00000003
r 1760.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA +2.5 M3 modes 1, 3-5"   00000003 00000003 00000002 00000002
r 1770.08                               RP,      RM
*Want "CFDBRA +2.5 M3 modes 6, 7"     00000003 00000002

r 1780.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA +5.5 FPCR modes 1-3, 7" 00000005 00000006 00000005 00000005
r 1790.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA +5.5 M3 modes 1, 3-5"   00000006 00000005 00000006 00000005
r 17A0.08                               RP,      RM
*Want "CFDBRA +5.5 M3 modes 6, 7"     00000006 00000005

r 17B0.10                               RZ,      RP,      RM,      RFS
*Want "CFDBRA +9.5 FPCR modes 1-3, 7" 00000009 0000000A 00000009 00000009
r 17C0.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFDBRA +9.5 M3 modes 1, 3-5"   0000000A 00000009 0000000A 00000009
r 17D0.08                               RP,      RM
*Want "CFDBRA +9.5 M3 modes 6, 7"     0000000A 00000009

#  rounding mode tests - long BFP - FPCR contents with cc in last byte
*Compare
r 1800.10
*Want "CFDBRA -9.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1810.10
*Want "CFDBRA -9.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1820.08
*Want "CFDBRA -9.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1830.10
*Want "CFDBRA -5.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1840.10
*Want "CFDBRA -5.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1850.08
*Want "CFDBRA -5.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1860.10
*Want "CFDBRA -2.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1870.10
*Want "CFDBRA -2.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1880.08
*Want "CFDBRA -2.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1890.10
*Want "CFDBRA -1.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 18A0.10
*Want "CFDBRA -1.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 18B0.08
*Want "CFDBRA -1.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 18C0.10
*Want "CFDBRA -0.5 FPCR modes 1-3, 7 FPCR" 00000000 00000000 00000001 00000001
r 18D0.10
*Want "CFDBRA -0.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080000 00080000
r 18E0.08
*Want "CFDBRA -0.5 M3 modes 6, 7 FPCR"     00080000 00080001

r 18F0.10
*Want "CFDBRA +0.5 FPCR modes 1-3, 7 FPCR" 00000000 00000002 00000000 00000002
r 1900.10
*Want "CFDBRA +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080000 00080000
r 1910.08
*Want "CFDBRA +0.5 M3 modes 6, 7 FPCR"     00080002 00080000

r 1920.10
*Want "CFDBRA +1.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1930.10
*Want "CFDBRA +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1940.08
*Want "CFDBRA +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1950.10
*Want "CFDBRA +2.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1960.10
*Want "CFDBRA +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1970.08
*Want "CFDBRA +2.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1980.10
*Want "CFDBRA +5.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1990.10
*Want "CFDBRA +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 19A0.08
*Want "CFDBRA +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 19B0.10
*Want "CFDBRA +9.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 19C0.10
*Want "CFDBRA +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 19D0.08
*Want "CFDBRA +9.5 M3 modes 6, 7 FPCR"     00080002 00080002


# Extended BFP to integer-32 - results
*Compare
r 1A00.10
*Want "CFXBR result pairs 1-2" 00000001 00000001 00000002 00000002
r 1A10.10
*Want "CFXBR result pairs 3-4" 00000004 00000004 FFFFFFFE FFFFFFFE
r 1A20.10
*Want "CFXBR result pairs 5-6" 80000000 00000000 80000000 00000000
r 1A30.10
*Want "CFXBR result pairs 7-8" 7FFFFFFF 00000000 80000000 00000000

# Extended BFP to integer-32 - FPCR contents
*Compare
r 1A80.10
*Want "CFXBR FPCR pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1A90.10
*Want "CFXBR FPCR pairs 3-4" 00000002 F8000002 00000001 F8000001
r 1AA0.10
*Want "CFXBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000
r 1AA0.10
*Want "CFXBR FPCR pairs 5-6" 00880003 F8008000 00880003 F8008000


#  rounding mode tests - extended BFP - results from rounding
*Compare
r 1B00.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA -9.5 FPCR modes 1-3, 7" FFFFFFF7 FFFFFFF7 FFFFFFF6 FFFFFFF7
r 1B10.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA -9.5 M3 modes 1, 3-5"   FFFFFFF6 FFFFFFF7 FFFFFFF6 FFFFFFF7
r 1B20.08                               RP,      RM
*Want "CFXBRA -9.5 M3 modes 6, 7"     FFFFFFF7 FFFFFFF6

r 1B30.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA -5.5 FPCR modes 1-3, 7" FFFFFFFB FFFFFFFB FFFFFFFA FFFFFFFB
r 1B40.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA -5.5 M3 modes 1, 3-5"   FFFFFFFA FFFFFFFB FFFFFFFA FFFFFFFB
r 1B50.08                               RP,      RM
*Want "CFXBRA -5.5 M3 modes 6, 7"     FFFFFFFB FFFFFFFA

r 1B60.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA -2.5 FPCR modes 1-3, 7" FFFFFFFE FFFFFFFE FFFFFFFD FFFFFFFD
r 1B70.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA -2.5 M3 modes 1, 3-5"   FFFFFFFD FFFFFFFD FFFFFFFE FFFFFFFE
r 1B80.08                               RP,      RM
*Want "CFXBRA -2.5 M3 modes 6, 7"     FFFFFFFE FFFFFFFD

r 1B90.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA -1.5 FPCR modes 1-3, 7" FFFFFFFF FFFFFFFF FFFFFFFE FFFFFFFF
r 1BA0.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA -1.5 M3 modes 1, 3-5"   FFFFFFFE FFFFFFFF FFFFFFFE FFFFFFFF
r 1BB0.08                               RP,      RM
*Want "CFXBRA -1.5 M3 modes 6, 7"     FFFFFFFF FFFFFFFE

r 1BC0.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA -0.5 FPCR modes 1-3, 7" 00000000 00000000 FFFFFFFF FFFFFFFF
r 1BD0.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA -0.5 M3 modes 1, 3-5"   FFFFFFFF FFFFFFFF 00000000 00000000
r 1BE0.08                               RP,      RM
*Want "CFXBRA -0.5 M3 modes 6, 7"     00000000 FFFFFFFF

r 1BF0.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA +0.5 FPCR modes 1-3, 7" 00000000 00000001 00000000 00000001
r 1C00.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA +0.5 M3 modes 1, 3-5"   00000001 00000001 00000000 00000000
r 1C10.08                               RP,      RM
*Want "CFXBRA +0.5 M3 modes 6, 7"     00000001 00000000

r 1C20.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA +1.5 FPCR modes 1-3, 7" 00000001 00000002 00000001 00000001
r 1C30.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA +1.5 M3 modes 1, 3-5"   00000002 00000001 00000002 00000001
r 1C40.08                               RP,      RM
*Want "CFXBRA +1.5 M3 modes 6, 7"     00000002 00000001

r 1C50.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA +2.5 FPCR modes 1-3, 7" 00000002 00000003 00000002 00000003
r 1C60.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA +2.5 M3 modes 1, 3-5"   00000003 00000003 00000002 00000002
r 1C70.08                               RP,      RM
*Want "CFXBRA +2.5 M3 modes 6, 7"     00000003 00000002

r 1C80.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA +5.5 FPCR modes 1-3, 7" 00000005 00000006 00000005 00000005
r 1C90.10                               RNTA,    RFS,     RNTE,    RZ
*Want "CFXBRA +5.5 M3 modes 1, 3-5"   00000006 00000005 00000006 00000005
r 1CA0.08                               RP,      RM
*Want "CFXBRA +5.5 M3 modes 6, 7"     00000006 00000005

r 1CB0.10                               RZ,      RP,      RM,      RFS
*Want "CFXBRA +9.5 FPCR modes 1-3, 7" 00000009 0000000A 00000009 00000009
r 1CC0.10                               RNTA,    RFS,    RNTE,    RZ
*Want "CFXBRA +9.5 M3 modes 1, 3-5"   0000000A 00000009 0000000A 00000009
r 1CD0.08                               RP,      RM
*Want "CFXBRA +9.5 M3 modes 6, 7"     0000000A 00000009

#  rounding mode tests - extended BFP - FPCR contents with cc in last byte
*Compare
r 1D00.10
*Want "CFXBRA -9.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1D10.10
*Want "CFXBRA -9.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1D20.08
*Want "CFXBRA -9.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1D30.10
*Want "CFXBRA -5.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1D40.10
*Want "CFXBRA -5.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1D50.08
*Want "CFXBRA -5.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1D60.10
*Want "CFXBRA -2.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1D70.10
*Want "CFXBRA -2.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1D80.08
*Want "CFXBRA -2.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1D90.10
*Want "CFXBRA -1.5 FPCR modes 1-3, 7 FPCR" 00000001 00000001 00000001 00000001
r 1DA0.10
*Want "CFXBRA -1.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080001 00080001
r 1DB0.08
*Want "CFXBRA -1.5 M3 modes 6, 7 FPCR"     00080001 00080001

r 1DC0.10
*Want "CFXBRA -0.5 FPCR modes 1-3, 7 FPCR" 00000000 00000000 00000001 00000001
r 1DD0.10
*Want "CFXBRA -0.5 M3 modes 1, 3-5 FPCR"   00080001 00080001 00080000 00080000
r 1DE0.08
*Want "CFXBRA -0.5 M3 modes 6, 7 FPCR"     00080000 00080001

r 1DF0.10
*Want "CFXBRA +0.5 FPCR modes 1-3, 7 FPCR" 00000000 00000002 00000000 00000002
r 1E00.10
*Want "CFXBRA +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080000 00080000
r 1E10.08
*Want "CFXBRA +0.5 M3 modes 6, 7 FPCR"     00080002 00080000

r 1E20.10
*Want "CFXBRA +1.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1E30.10
*Want "CFXBRA +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1E40.08
*Want "CFXBRA +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1E50.10
*Want "CFXBRA +2.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1E60.10
*Want "CFXBRA +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1E70.08
*Want "CFXBRA +2.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1E80.10
*Want "CFXBRA +5.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1E90.10
*Want "CFXBRA +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1EA0.08
*Want "CFXBRA +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1EB0.10
*Want "CFXBRA +9.5 FPCR modes 1-3, 7 FPCR" 00000002 00000002 00000002 00000002
r 1EC0.10
*Want "CFXBRA +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1ED0.08
*Want "CFXBRA +9.5 M3 modes 6, 7 FPCR"     00080002 00080002


*Done

