_dtube:
    li x4, 1073741824 /*x4=0x4000_0000, (dtube_Hex0Num)*/
    li x5, 1073741828 /*x5=0x4000_0004, (dtube_Hex1Num)*/
    li x6, 1073741832 /*x6=0x4000_0008, (dtube_Hex2Num)*/
    li x7, 1073741836 /*x7=0x4000_000c, (dtube_Hex3Num)*/
    li x8, 1073741840 /*x8=0x4000_0010, (dtube_Hex4Num)*/
    li x9, 1073741844 /*x9=0x4000_0014, (dtube_Hex5Num)*/
    li x10, 1
    li x11, 2
    li x12, 3
    li x13, 4
    li x14, 5
    li x15, 6
    sw x10, 0(x4)
    sw x11, 0(x5)
    sw x12, 0(x6)
    sw x13, 0(x7)
    sw x14, 0(x8)
    sw x15, 0(x9)