	.file	"array.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	main
	.type	main, @function
	main:
	addi sp,sp,100 // add by myself
	addi sp,sp,-64
	sw s0,60(sp)
	addi s0,sp,64
	sw zero,-20(s0)
	jal x0, .L2
	.L3:
	lw a5,-20(s0)
	addi a4,a5,100
	lw a5,-20(s0)
	slli a5,a5,2
	addi a3,s0,-16
	add a5,a3,a5
	sw a4,-44(a5)
	lw a5,-20(s0)
	addi a5,a5,1
	sw a5,-20(s0)
	.L2:
	lw a4,-20(s0)
	addi a5,x0,9
	bge a5,a4,.L3
	addi a5,x0,0
	addi a0,a5,0
	lw s0,60(sp)
	addi sp,sp,64
	jalr x0,ra,0
	.size	main, .-main
	.ident	"GCC: () 9.3.0"
