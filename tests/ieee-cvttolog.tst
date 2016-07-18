*
*Testcase ieee-cvttofix.tst: IEEE Convert To Logical
*Message Testcase ieee-cvttolog.tst: IEEE Convert To Logical
*Message ..Includes CONVERT TO LOGICAL 32 (3).  Tests traps, exceptions,
*Message ..rounding modes, and NaN propagation.
#
# CONVERT TO LOGICAL tests - Binary Floating Point
#
# Tests the following three conversion instructions
#   CONVERT TO LOGICAL (short BFP to int-32, RRF-e)
#   CONVERT TO LOGICAL (long BFP to int-32, RRF-e) 
#   CONVERT TO LOGICAL (extended BFP to int-32, RRF-e)  
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
loadcore $(testpath)/ieee-cvttolog.core
runtest .1

*Program 7


# BFP short inputs converted to uint-32 test results
*Compare
r 1000.10                         1        1        2        2
*Want "CLFEBR result pairs 1-2" 00000001 00000001 00000002 00000002
r 1010.10                         4        4        9        9
*Want "CLFEBR result pairs 3-4" 00000004 00000004 00000009 00000009
r 1020.10                         
*Want "CLFEBR result pairs 5-6" 00000000 00000000 00000000 00000000
r 1030.08
*Want "CLFEBR result pair 7"    FFFFFF00 FFFFFF00

# BFP short inputs converted to uint-32 FPCR contents, cc
*Compare
r 1080.10
*Want "CLFEBR FPC pairs 1-2"    00000002 F8000002 00000002 F8000002
r 1090.10
*Want "CLFEBR FPC pairs 3-4"    00000002 F8000002 00000002 F8000002
r 10A0.10
*Want "CLFEBR FPC pairs 5-6"    00880003 F8008000 00880003 F8008000
r 10A0.08
*Want "CLFEBR FPC pair 7"       00880003 F8008000

#  rounding mode tests - short BFP - results from rounding
*Compare
r 1100.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFEBR -1.5 FPC modes 1-3, 7"  00000000 00000000 00000000 00000000
r 1110.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFEBR -1.5 M3 modes 1, 3-5"   00000000 00000000 00000000 00000000
r 1120.08  #                            RP,      RM
*Want "CLFEBR -1.5 M3 modes 6, 7"     00000000 00000000

r 1130.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFEBR -0.5 FPC modes 1-3, 7"  00000000 00000000 00000000 00000000
r 1140.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFEBR -0.5 M3 modes 1, 3-5"   00000000 00000000 00000000 00000000
r 1150.08  #                            RP,      RM
*Want "CLFEBR -0.5 M3 modes 6, 7"    00000000 00000000 

r 1160.10  #                           RZ,      RP,      RM,      RFS
*Want "CLFEBR 0.5 FPC modes 1-3, 7"  00000000 00000001 00000000 00000001
r 1170.10  #                           RNTA,    RFS,     RNTE,    RZ
*Want "CLFEBR 0.5 M3 modes 1, 3-5"   00000001 00000001 00000000 00000000
r 1180.08  #                           RP,      RM
*Want "CLFEBR 0.5 M3 modes 6, 7"     00000001 00000000

r 1190.10  #                           RZ,      RP,      RM,      RFS
*Want "CLFEBR 1.5 FPC modes 1-3, 7"  00000001 00000002 00000001 00000001
r 11A0.10  #                           RNTA,    RFS,     RNTE,    RZ
*Want "CLFEBR 1.5 M3 modes 1, 3-5"   00000002 00000001 00000002 00000001
r 11B0.08  #                           RP,      RM
*Want "CLFEBR 1.5 M3 modes 6, 7"     00000002 00000001

r 11C0.10  #                           RZ,      RP,      RM,      RFS
*Want "CLFEBR 2.5 FPC modes 1-3, 7"  00000002 00000003 00000002 00000003
r 11D0.10  #                           RNTA,    RFS,     RNTE,    RZ
*Want "CLFEBR 2.5 M3 modes 1, 3-5"   00000003 00000003 00000002 00000002
r 11E0.08  #                           RP,      RM
*Want "CLFEBR 2.5 M3 modes 6, 7"     00000003 00000002

r 11F0.10  #                           RZ,      RP,      RM,      RFS
*Want "CLFEBR 5.5 FPC modes 1-3, 7"  00000005 00000006 00000005 00000005
r 1200.10  #                           RNTA,    RFS,     RNTE,    RZ
*Want "CLFEBR 5.5 M3 modes 1, 3-5"   00000006 00000005 00000006 00000005
r 1210.08  #                           RP,      RM
*Want "CLFEBR 5.5 M3 modes 6, 7"     00000006 00000005

r 1220.10  #                           RZ,     RP,      RM,      RFS
*Want "CLFEBR 9.5 FPC modes 1-3, 7"  00000009 0000000A 00000009 00000009
r 1230.10  #                           RNTA,    RFS,     RNTE,    RZ
*Want "CLFEBR 9.5 M3 modes 1, 3-5"   0000000A 00000009 0000000A 00000009
r 1240.08  #                           RP,      RM
*Want "CLFEBR 9.5 M3 modes 6, 7"     0000000A 00000009

r 1250.10  #                           RZ,      RP,      RM,      RFS
*Want "CLFEBR max FPC modes 1-3, 7"  FFFFFF00 FFFFFF00 FFFFFF00 FFFFFF00
r 1260.10  #                          RNTA,    RFS,     RNTE,    RZ
*Want "CLFEBR max M3 modes 1, 3-5"   FFFFFF00 FFFFFF00 FFFFFF00 FFFFFF00
r 1270.08  #                           RP,      RM
*Want "CLFEBR max M3 modes 6, 7"     FFFFFF00 FFFFFF00

#  rounding mode tests - short BFP - FPCR contents with cc in last byte
*Compare
r 1300.10
*Want "CLFEBR -1.5 FPC modes 1-3, 7 FPCR"  00800003 00800003 00800003 00800003
r 1310.10
*Want "CLFEBR -1.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00880003 00880003
r 1320.08
*Want "CLFEBR -1.5 M3 modes 6, 7 FPCR"     00880003 00880003

r 1330.10
*Want "CLFEBR -0.5 FPC modes 1-3, 7 FPCR"  00000001 00000001 00800003 00800003
r 1340.10
*Want "CLFEBR -0.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00080001 00080001
r 1350.08
*Want "CLFEBR -0.5 M3 modes 6, 7 FPCR"     00080001 00880003

r 1360.10
*Want "CLFEBR +0.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1370.10
*Want "CLFEBR +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1380.08
*Want "CLFEBR +0.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1390.10
*Want "CLFEBR +1.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 13A0.10
*Want "CLFEBR +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 13B0.08
*Want "CLFEBR +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 13C0.10
*Want "CLFEBR +2.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 13D0.10
*Want "CLFEBR +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 13E0.08
*Want "CLFEBR +2.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 13F0.10
*Want "CLFEBR +5.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1400.10
*Want "CLFEBR +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1410.08
*Want "CLFEBR +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1420.10
*Want "CLFEBR +9.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1430.10
*Want "CLFEBR +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1440.08
*Want "CLFEBR +9.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1450.10
*Want "CLFEBR max FPC modes 1-3, 7 FPCR"   00000002 00000002 00000002 00000002
r 1460.10
*Want "CLFEBR max M3 modes 1, 3-5 FPCR"    00000002 00000002 00000002 00000002
r 1470.08
*Want "CLFEBR max M3 modes 5-7"            00000002 00000002


# BFP short inputs converted to uint-32 test results
*Compare
r 1500.10
*Want "CLFDBR result pairs 1-2" 00000001 00000001 00000002 00000002
r 1510.10
*Want "CLFDBR result pairs 3-4" 00000004 00000004 00000009 00000009
r 1520.10
*Want "CLFDBR result pairs 5-6" 00000000 00000000 00000000 00000000
r 1530.08
*Want "CLFDBR result pair 7"    00000000 00000000

# BFP long inputs converted to uint-32 FPCR contents, cc
*Compare
r 1580.10
*Want "CLFDBR FPC pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1590.10
*Want "CLFDBR FPC pairs 3-4" 00000002 F8000002 00000002 F8000002
r 15A0.10
*Want "CLFDBR FPC pairs 5-6" 00880003 F8008000 00880003 F8008000
r 15A0.08
*Want "CLFDBR FPC pair 7"    00880003 F8008000 


#  rounding mode tests - long BFP - results from rounding
*Compare
r 1600.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFDBR -1.5 FPC modes 1-3, 7"  00000000 00000000 00000000 00000000
r 1610.10  #                            RNTA,    FS,     RNTE,     RZ
*Want "CLFDBR -1.5 M3 modes 1, 3-5"   00000000 00000000 00000000 00000000
r 1620.08  #                            RP,      RM
*Want "CLFDBR -1.5 M3 modes 6, 7"     00000000 00000000

r 1630.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFDBR -0.5 FPC modes 1-3, 7"  00000000 00000000 00000000 00000000
r 1640.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFDBR -0.5 M3 modes 1, 3-5"   00000000 00000000 00000000 00000000
r 1650.08  #                            RP,      RM
*Want "CLFDBR -0.5 M3 modes 6, 7"     00000000 00000000

r 1660.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFDBR 0.5 FPC modes 1-3, 7"   00000000 00000001 00000000 00000001
r 1670.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFDBR 0.5 M3 modes 1, 3-5"    00000001 00000001 00000000 00000000
r 1680.08  #                            RP,      RM
*Want "CLFDBR 0.5 M3 modes 6, 7 FPCR"  00000001 00000000

r 1690.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFDBR 1.5 FPC modes 1-3, 7"   00000001 00000002 00000001 00000001
r 16A0.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFDBR 1.5 M3 modes 1, 3-5"    00000002 00000001 00000002 00000001
r 16B0.08  #                            RP,      RM
*Want "CLFDBR 1.5 M3 modes 6, 7 FPCR"  00000002 00000001

r 16C0.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFDBR 2.5 FPC modes 1-3, 7"   00000002 00000003 00000002 00000003
r 16D0.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFDBR 2.5 M3 modes 1, 3-5"    00000003 00000003 00000002 00000002
r 16E0.08  #                            RP,      RM
*Want "CLFDBR 2.5 M3 modes 6, 7 FPCR"  00000003 00000002

r 16F0.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFDBR 5.5 FPC modes 1-3, 7"   00000005 00000006 00000005 00000005
r 1700.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFDBR 5.5 M3 modes 1, 3-5"    00000006 00000005 00000006 00000005
r 1710.08  #                            RP,      RM
*Want "CLFDBR 5.5 M3 modes 6, 7"      00000006 00000005

r 1720.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFDBR 9.5 FPC modes 1-3, 7"   00000009 0000000A 00000009 00000009
r 1730.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFDBR 9.5 M3 modes 1, 3-5"    0000000A 00000009 0000000A 00000009
r 1740.08  #                            RP,      RM
*Want "CLFDBR 9.5 M3 modes 6, 7R"     0000000A 00000009

r 1750.10  #                            RZ,      RP,      RM,      RFS
*Want "CLFDBR max FPC modes 1-3, 7"   FFFFFFFF 00000000 FFFFFFFF FFFFFFFF
r 1760.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFDBR max M3 modes 1, 3-5"    00000000 FFFFFFFF 00000000 FFFFFFFF
r 1770.08  #                            RP,      RM
*Want "CLFDBR max M3 modes 6, 7"      00000000 FFFFFFFF

#  rounding mode tests - long BFP - FPCR contents with cc in last byte
*Compare
r 1800.10
*Want "CLFDBR -1.5 FPC modes 1-3, 7 FPCR"  00800003 00800003 00800003 00800003
r 1810.10
*Want "CLFDBR -1.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00880003 00880003
r 1820.08
*Want "CLFDBR -1.5 M3 modes 6, 7 FPCR"     00880003 00880003

r 1830.10
*Want "CLFDBR -0.5 FPC modes 1-3, 7 FPCR"  00000001 00000001 00800003 00800003
r 1840.10
*Want "CLFDBR -0.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00080001 00080001
r 1850.08
*Want "CLFDBR -0.5 M3 modes 6, 7 FPCR"     00080001 00880003

r 1860.10
*Want "CLFDBR +0.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1870.10
*Want "CLFDBR +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1880.08
*Want "CLFDBR +0.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1890.10
*Want "CLFDBR +1.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 18A0.10
*Want "CLFDBR +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 18B0.08
*Want "CLFDBR +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 18C0.10
*Want "CLFDBR +2.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 18D0.10
*Want "CLFDBR +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 18E0.08
*Want "CLFDBR +2.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 18F0.10
*Want "CLFDBR +5.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1900.10
*Want "CLFDBR +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1910.08
*Want "CLFDBR +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1920.10
*Want "CLFDBR +9.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1930.10
*Want "CLFDBR +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1940.08
*Want "CLFDBR +9.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1950.10
*Want "CLFDBR max FPC modes 1-3, 7 FPCR"   00000002 00800003 00000002 00000002
r 1960.10
*Want "CLFDBR max M3 modes 1, 3-5 FPCR"    00880003 00080002 00880003 00080002
r 1970.08
*Want "CLFDBR max M3 modes 6, 7 FPCR"      00880003 00080002


# BFP extended inputs converted to uint-32 test results
*Compare
r 1A00.10
*Want "CLFXBR result pairs 1-2" 00000001 00000001 00000002 00000002
r 1A10.10
*Want "CLFXBR result pairs 3-4" 00000004 00000004 00000009 00000009
r 1A20.10
*Want "CLFXBR result pairs 5-6" 00000000 00000000 00000000 00000000
r 1A30.08
*Want "CLFXBR result pair 7"    00000000 00000000

# BFP extended inputs converted to uint-32 FPCR contents, cc
*Compare
r 1A80.10
*Want "CLFXBR FPC pairs 1-2" 00000002 F8000002 00000002 F8000002
r 1A90.10
*Want "CLFXBR FPC pairs 3-4" 00000002 F8000002 00000002 F8000002
r 1AA0.10
*Want "CLFXBR FPC pairs 5-6" 00880003 F8008000 00880003 F8008000
r 1AA0.08
*Want "CLFXBR FPC pair 7"    00880003 F8008000


#  rounding mode tests - extended BFP - results from rounding
*Compare
r 1B00.10  #                            RZ,     RP,      RM,      RFS
*Want "CLFXBR -1.5 FPC modes 1-3, 7"  00000000 00000000 00000000 00000000
r 1B10.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFXBR -1.5 M3 modes 1, 3-5"   00000000 00000000 00000000 00000000
r 1B20.08  #                            RP,      RM
*Want "CLFXBR -1.5 M3 modes 6, 7"     00000000 00000000

r 1B30.10  #                            RZ,     RP,      RM,      RFS
*Want "CLFXBR -0.5 FPC modes 1-3, 7"  00000000 00000000 00000000 00000000
r 1B40.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFXBR -0.5 M3 modes 1, 3-5"   00000000 00000000 00000000 00000000
r 1B50.08  #                            RP,      RM
*Want "CLFXBR -0.5 M3 modes 6, 7"     00000000 00000000

r 1B60.10  #                            RZ,    RP,      RM,      RFS
*Want "CLFXBR 0.5 FPC modes 1-3, 7"   00000000 00000001 00000000 00000001
r 1B70.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFXBR 0.5 M3 modes 1, 3-5"    00000001 00000001 00000000 00000000
r 1B80.08  #                            RP,      RM
*Want "CLFXBR 0.5 M3 modes 6, 7"      00000001 00000000

r 1B90.10  #                            RZ,    RP,      RM,      RFS
*Want "CLFXBR 1.5 FPC modes 1-3, 7"   00000001 00000002 00000001 00000001
r 1BA0.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFXBR 1.5 M3 modes 1, 3-5"    00000002 00000001 00000002 00000001
r 1BB0.08  #                            RP,      RM
*Want "CLFXBR 1.5 M3 modes 6, 7"      00000002 00000001

r 1BC0.10  #                            RZ,    RP,      RM,      RFS
*Want "CLFXBR 2.5 FPC modes 1-3, 7"   00000002 00000003 00000002 00000003
r 1BD0.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFXBR 2.5 M3 modes 1, 3-5"    00000003 00000003 00000002 00000002
r 1BE0.08  #                            RP,      RM
*Want "CLFXBR 2.5 M3 modes 6, 7"      00000003 00000002

r 1BF0.10  #                            RZ,    RP,      RM,      RFS
*Want "CLFXBR 5.5 FPC modes 1-3, 7"   00000005 00000006 00000005 00000005
r 1C00.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFXBR 5.5 M3 modes 1, 3-5"    00000006 00000005 00000006 00000005
r 1C10.08  #                            RP,      RM
*Want "CLFXBR 5.5 M3 modes 6, 7"      00000006 00000005

r 1C20.10  #                            RZ,    RP,      RM,      RFS
*Want "CLFXBR 9.5 FPC modes 1-3, 7"   00000009 0000000A 00000009 00000009
r 1C30.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFXBR 9.5 M3 modes 1, 3-5"    0000000A 00000009 0000000A 00000009
r 1C40.08  #                            RP,      RM
*Want "CLFXBR 9.5 M3 modes 6, 7"      0000000A 00000009

r 1C50.10  #                            RZ,    RP,      RM,      RFS
*Want "CLFXBR max FPC modes 1-3, 7"   FFFFFFFF 00000000 FFFFFFFF FFFFFFFF
r 1C60.10  #                            RNTA,    RFS,     RNTE,    RZ
*Want "CLFXBR max M3 modes 1, 3-5"    00000000 FFFFFFFF 00000000 FFFFFFFF
r 1C70.08  #                            RP,      RM
*Want "CLFXBR max M3 modes 6, 7"      00000000 FFFFFFFF

r 1D00.10
*Want "CLFXBR -1.5 FPC modes 1-3, 7 FPCR"  00800003 00800003 00800003 00800003
r 1D10.10
*Want "CLFXBR -1.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00880003 00880003
r 1D20.08
*Want "CLFXBR -1.5 M3 modes 6, 7 FPCR"     00880003 00880003

r 1D30.10
*Want "CLFXBR -0.5 FPC modes 1-3, 7 FPCR"  00000001 00000001 00800003 00800003
r 1D40.10
*Want "CLFXBR -0.5 M3 modes 1, 3-5 FPCR"   00880003 00880003 00080001 00080001
r 1D50.08
*Want "CLFXBR -0.5 M3 modes 6, 7 FPCR"     00080001 00880003

r 1D60.10
*Want "CLFXBR +0.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1D70.10
*Want "CLFXBR +0.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1D80.08
*Want "CLFXBR +0.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1D90.10
*Want "CLFXBR +1.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1DA0.10
*Want "CLFXBR +1.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1DB0.08
*Want "CLFXBR +1.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1DC0.10
*Want "CLFXBR +2.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1DD0.10
*Want "CLFXBR +2.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1DE0.08
*Want "CLFXBR +2.5 M3 modes 5-7"           00080002 00080002

r 1DF0.10
*Want "CLFXBR +5.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1E00.10
*Want "CLFXBR +5.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1E10.08
*Want "CLFXBR +5.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1E20.10
*Want "CLFXBR +9.5 FPC modes 1-3, 7 FPCR"  00000002 00000002 00000002 00000002
r 1E30.10
*Want "CLFXBR +9.5 M3 modes 1, 3-5 FPCR"   00080002 00080002 00080002 00080002
r 1E40.08
*Want "CLFXBR +9.5 M3 modes 6, 7 FPCR"     00080002 00080002

r 1E50.10
*Want "CLFXBR max FPC modes 1-3, 7 FPCR"   00000002 00800003 00000002 00000002
r 1E60.10
*Want "CLFXBR max M3 modes 1, 3-5 FPCR"    00880003 00080002 00880003 00080002
r 1E70.08
*Want "CLFXBR max M3 modes 6, 7 FPCR"      00880003 00080002


*Done

