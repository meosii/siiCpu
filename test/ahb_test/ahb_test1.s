.globl _start
_start:
li sp, 2415935488
addi sp, sp, -64
_int_en:
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw t0, 8(sp)
    addi a0,x0,8
    addi t0,x0,11
    lui a1,1092
    srl a1,a1,t0
    csrrw a0,mstatus,a0     /*mstatus = 'b1000*/
    csrrw a1,mie,a1         /*mie = 'b100010001000*/
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw t0, 8(sp)
    addi sp, sp, 12
_algebra:
    addi x10,x0,0xa
    sw x10, 0(sp)
    li x10, 0       /*x10=0xa*/
    addi x9,x0,0
    add sp,sp,x9
    lw x10,0(sp)
    addi x9, x10, 1
    addi x11,x9,0 /*x11=b*/
    sw x11, 4(sp)
    lw x12,4(sp)
    addi x12,x12,1 /*x12=c*/
    li x4, 1073741824 /*x4=0x4000_0000, (dtube_Hex0Num)*/
    sw x12, 0(x4)
    lw x13, 0(x4)
    addi x13,x13,1 /*x13=d*/
    lw x14, 0(x4)
    addi x14,x14,2 /*x14=e*/
    li x15, 0xf   /*x15=f*/
_dtube:
    li x4, 1073741824 /*x4=0x4000_0000, (dtube_Hex0Num)*/
    li x5, 1073741828 /*x5=0x4000_0004, (dtube_Hex1Num)*/
    li x6, 1073741832 /*x6=0x4000_0008, (dtube_Hex2Num)*/
    li x7, 1073741836 /*x7=0x4000_000c, (dtube_Hex3Num)*/
    li x8, 1073741840 /*x8=0x4000_0010, (dtube_Hex4Num)*/
    li x9, 1073741844 /*x9=0x4000_0014, (dtube_Hex5Num)*/
    sw x10, 0(x4)
    sw x11, 0(x5)
    sw x12, 0(x6)
    sw x13, 0(x7)
    sw x14, 0(x8)
    sw x15, 0(x9)
_uart_tx:
    li x8, 268513280 /*x8=0x1001_3000, (uart_TransData)*/
    li x10, 0x40302010
    li x11, 0xd0c0b0a0
    li x12, 0x05040302
    li x13, 0x0a0a0a0a
    li x14, 0xb0b0b0b0
    li x15, 0x11111111
    li x16, 0x22222222
    li x17, 0x33333333
    li x18, 0x40302010
    li x19, 0xd0c0b0a0
    li x20, 0xdecba990
    li x21, 0x99008800
    li x22, 0xddbbaabb
    li x23, 0x01010101
    li x24, 0x07070707
    li x25, 0x55555555
    li x26, 0xdddddddd
    li x27, 0xbabababa
    li x28, 0x99999999
    li x29, 0x66666666
    sw x10, 0(x8)
    sw x11, 0(x8)
    sw x12, 0(x8)
    sw x13, 0(x8)
    sw x14, 0(x8)
    sw x15, 0(x8)
    sw x16, 0(x8)
    sw x17, 0(x8)
    sw x18, 0(x8)
    sw x19, 0(x8)
    sw x20, 0(x8)
    sw x21, 0(x8)
    sw x22, 0(x8)
    sw x23, 0(x8)
    sw x24, 0(x8)
    sw x25, 0(x8)
    sw x26, 0(x8)
    sw x27, 0(x8)
    sw x28, 0(x8)
    sw x29, 0(x8)
    lw x5, 0(x8)
_empty:
    addi x0,x0,0
    j _empty