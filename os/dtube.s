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

_four_bit_dtube:
	slli x10, x31,28
	srli x10, x10,28 /* x31[3:0] */
	slli x11, x31,24
	srli x11, x11,28 /* x31[7:4] */
	slli x12, x31,20
	srli x12, x12,28 /* x31[11:8] */
	slli x13, x31,16
	srli x13, x13,28 /* x31[15:12] */
	slli x14, x31,12
	srli x14, x14,28 /* x31[19:16] */
	slli x15, x31,8
	srli x15, x15,28 /* x31[24:20] */