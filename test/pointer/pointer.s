	.file	"pointer.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
addi sp,sp,100
addi sp,sp,-96
sw s0,92(sp)
addi s0,sp,96
addi a5,zero,8
sw a5,-76(s0)
addi a5,zero,16
sw a5,-80(s0)
addi a5,zero,17
sw a5,-84(s0)
addi a5,zero,1
sw a5,-20(s0)	
addi a5,s0,-76
sw a5,-24(s0)
addi a5,s0,-80
sw a5,-28(s0)
addi a5,s0,-84
sw a5,-32(s0)
addi a5,s0,-88
sw a5,-36(s0)
addi a5,s0,-92
sw a5,-40(s0)
lw a5,-36(s0)
addi a4,x0,18
sw a4,0(a5)
lw a5,-40(s0)
addi a4,x0,20
sw a4,0(a5)
lw a5,-40(s0)
lw a4,0(a5)
lw a5,-36(s0)
lw a5,0(a5)
sub a4,a4,a5
lw a5,-32(s0)
lw a3,0(a5)
lw a5,-28(s0)
lw a5,0(a5)
sub a5,a3,a5
bge a5,a4,.L2
lw a5,-40(s0)
lw a4,0(a5)
lw a5,-36(s0)
lw a5,0(a5)
sub a5,a4,a5
sw a5,-44(s0)
jal x0,.L4
.L2:
lw a5,-32(s0)
lw a4,0(a5)
lw a5,-28(s0)
lw a5,0(a5)
add a5,a4,a5
sw a5,-44(s0)
jal x0, .L4
.L9:
lw a4,-76(s0)
lw a5,-80(s0)
add a5,a4,a5
sw a5,-48(s0)
lw a5,-76(s0)
bne a5,x0,.L5
lw a5,-80(s0)
beqz a5,.L6
.L5:
addi a5,x0,1
jal x0, .L7
.L6:
addi a5,x0,0
.L7:
sw a5,-52(s0)
lw a4,-76(s0)	
lw a5,-80(s0)
xor a5,a4,a5
sw a5,-56(s0)
lw a5,-76(s0)
slli a5,a5,1
sw a5,-60(s0)
lw a5,-76(s0)
srai a5,a5,1
sw a5,-64(s0)
lw a4,-76(s0)
lw a5,-20(s0)
sll a5,a4,a5
sw a5,-68(s0)
lw  a4,-76(s0)
lw a5,-20(s0)
sra a5,a4,a5
sw a5,-72(s0)
jal x0, .L8
.L4:
lw a5,-24(s0)
lw a4,0(a5)
addi a5,x0,19
bge a5,a4,.L9
.L8:
addi a5,x0,0
addi a0,a5,0
lw s0,92(sp)
addi sp,sp,96
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 9.3.0"
