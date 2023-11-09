	.file	"array.c"
	.option pic
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-112
	sw	ra,108(sp)
	sw	s0,104(sp)
	addi	s0,sp,112
	la	a5,__stack_chk_guard
	lw	a4, 0(a5)
	sw	a4, -20(s0)
	li	a4, 0
	sw	zero,-100(s0)
	j	.L2
.L3:
	lw	a5,-100(s0)
	slli	a4,a5,2
	lw	a5,-100(s0)
	slli	a5,a5,2
	addi	a5,a5,-16
	add	a5,a5,s0
	sw	a4,-44(a5)
	lw	a5,-100(s0)
	slli	a5,a5,2
	addi	a5,a5,-16
	add	a5,a5,s0
	lw	a5,-44(a5)
	lw	a4,-96(s0)
	add	a5,a4,a5
	sw	a5,-96(s0)
	lw	a4,-92(s0)
	lw	a5,-96(s0)
	add	a4,a4,a5
	lw	a5,-100(s0)
	slli	a5,a5,2
	addi	a5,a5,-16
	add	a5,a5,s0
	lw	a5,-44(a5)
	add	a5,a4,a5
	sw	a5,-92(s0)
	lw	a5,-100(s0)
	addi	a5,a5,1
	sw	a5,-100(s0)
.L2:
	lw	a4,-100(s0)
	li	a5,9
	ble	a4,a5,.L3
	lw	a4,-60(s0)
	li	a5,9
	bgt	a4,a5,.L4
	lw	a5,-60(s0)
	addi	a5,a5,99
	sw	a5,-88(s0)
	j	.L5
.L4:
	li	a5,4
	sw	a5,-88(s0)
.L5:
	lw	a4,-56(s0)
	li	a5,10
	beq	a4,a5,.L6
	lw	a5,-56(s0)
	li	a4,111
	sra	a5,a4,a5
	sw	a5,-84(s0)
	j	.L7
.L6:
	li	a5,4
	sw	a5,-84(s0)
.L7:
	lw	a4,-52(s0)
	li	a5,10
	ble	a4,a5,.L8
	li	a5,4
	sw	a5,-80(s0)
	j	.L9
.L8:
	lw	a5,-52(s0)
	xori	a5,a5,222
	sw	a5,-80(s0)
.L9:
	lw	a4,-48(s0)
	li	a5,12
	bne	a4,a5,.L10
	lw	a5,-48(s0)
	andi	a5,a5,333
	sw	a5,-76(s0)
	j	.L11
.L10:
	li	a5,4
	sw	a5,-76(s0)
.L11:
	lw	a4,-44(s0)
	li	a5,16
	bne	a4,a5,.L12
	lw	a5,-44(s0)
	ori	a5,a5,444
	sw	a5,-76(s0)
	j	.L13
.L12:
	li	a5,4
	sw	a5,-76(s0)
.L13:
	lw	a4,-40(s0)
	li	a5,-11
	blt	a4,a5,.L14
	li	a5,555
	sw	a5,-72(s0)
	j	.L15
.L14:
	li	a5,4
	sw	a5,-72(s0)
.L15:
	lw	a4,-36(s0)
	li	a5,23
	ble	a4,a5,.L16
	li	a5,666
	sw	a5,-68(s0)
	j	.L17
.L16:
	li	a5,4
	sw	a5,-68(s0)
.L17:
	lw	a4,-96(s0)
	li	a5,180
	bne	a4,a5,.L18
	li	a5,999
	sw	a5,-64(s0)
	j	.L19
.L18:
	li	a5,4
	sw	a5,-64(s0)
.L19:
	li	a5,0
	mv	a4,a5
	la	a5,__stack_chk_guard
	lw	a3, -20(s0)
	lw	a5, 0(a5)
	xor	a5, a3, a5
	li	a3, 0
	beq	a5,zero,.L21
	call	__stack_chk_fail@plt
.L21:
	mv	a0,a4
	lw	ra,108(sp)
	lw	s0,104(sp)
	addi	sp,sp,112
	jr	ra
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
