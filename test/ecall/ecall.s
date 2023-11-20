.globl _start
_start:
li sp, 2415935488
addi x10,x0,10
addi x11,x0,11
addi x12,x0,12
addi x13,x0,13
addi x14,x0,14
addi x15,x0,15
addi x16,x0,16
addi x17,x0,17
sw x10, -32(sp)
sw x11, -28(sp)
sw x12, -24(sp)
sw x13, -20(sp)
sw x14, -16(sp)
sw x15, -12(sp)
sw x16, -8(sp)
sw x17, -4(sp)
addi x10,x0,0
addi x11,x0,1
addi x12,x0,2
addi x13,x0,3
addi x14,x0,4
addi x15,x0,5
addi x16,x0,6
addi x17,x0,7
ecall
lw x10, -32(sp)
lw x11, -28(sp)
lw x12, -24(sp)
lw x13, -20(sp)
lw x14, -16(sp)
lw x15, -12(sp)
lw x16, -8(sp)
lw x17, -4(sp)