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
    addi x10,x0,8
    sw x10, 0(sp)
    li x10, 0       /*x10=8*/
    addi x9,x0,0
    add sp,sp,x9
    lw x10,0(sp)
    addi x9, x10, 1
    addi x11,x9,-2 /*x11=7*/
    sw x11, 4(sp)
    lw x12,4(sp)
    addi x12,x12,-1 /*x12=6*/
    li x4, 1073741824 /*x4=0x4000_0000, (dtube_Hex0Num)*/
    sw x12, 0(x4)
    lw x13, 0(x4)
    addi x13,x13,-1 /*x13=5*/
    lw x14, 0(x4)
    addi x14,x14,-2 /*x14=4*/
    li x15, 3   /*x15=3*/
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
_empty:
    addi x0,x0,0
    j _empty