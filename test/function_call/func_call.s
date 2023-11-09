	.file	"func_call.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
addi sp,sp,-32
sw ra,28(sp)
sw s0,24(sp)
addi s0,sp,32
li a5,100
sw a5,-20(s0)
li a5,200
sw a5,-24(s0)
lw a1,-24(s0)
lw a0,-20(s0)
call max
sw a0,-28(s0)
li a5,0
mv a0,a5
lw ra,28(sp)
lw s0,24(sp)
addi sp,sp,32
jr ra
.size	main, .-main
.align	2
.globl	max
.type	max, @function
max:
addi sp,sp,-48
sw s0,44(sp)
addi s0,sp,48
sw a0,-36(s0)
sw a1,-40(s0)
lw a4,-36(s0)
lw a5,-40(s0)
ble a4,a5,.L4
lw a5,-36(s0)
sw a5,-20(s0)
j	.L5
.L4:
lw a5,-40(s0)
sw a5,-20(s0)
.L5:
lw a5,-20(s0)
mv a0,a5
lw s0,44(sp)
addi sp,sp,48
jr ra
.size	max, .-max
.ident	"GCC: () 9.3.0"
