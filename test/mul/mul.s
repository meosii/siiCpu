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
main:
	li a5, 10
	li a4, 20
	mul	a6,a4,a5
	li a5, 30
	li a4, 40
	mul	a6,a4,a5
	li a5, 50
	li a4, 60
	mul	a6,a4,a5
	li a5, -10
	li a4, -20
	mul	a6,a4,a5
	li a5, -10
	li a4, 20
	mul	a6,a4,a5
	li a5, 10
	li a4, -20
	mul	a6,a4,a5
	li a5, 10000
	li a4, 20000
	mul	a6,a4,a5
	li a5, 1000000000
	li a4, 200000000
	mulhu a6,a4,a5
	li a5, 1000000000
	li a4, 200000000
	mulh x31,a4,a5
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
_L4:
	li	a5,0
	mv	a0,a5
	lw	s0,28(sp)
	addi	sp,sp,32
_empty:
    addi x0,x0,0
    j _empty
	jr	ra