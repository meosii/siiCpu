    .section      .text.entry	
    .align 2
    .global _start
_start:

    addi sp, sp, -32*4

    sw x1, 1*4(sp)
    sw x2, 2*4(sp)
    sw x3, 3*4(sp)
    sw x4, 4*4(sp)
    sw x5, 5*4(sp)
    sw x6, 6*4(sp)
    sw x7, 7*4(sp)
    sw x8, 8*4(sp)
    sw x9, 9*4(sp)
    sw x10, 10*4(sp)
    sw x11, 11*4(sp)
    sw x12, 12*4(sp)
    sw x13, 13*4(sp)
    sw x14, 14*4(sp)
    sw x15, 15*4(sp)
    sw x16, 16*4(sp)
    sw x17, 17*4(sp)
    sw x18, 18*4(sp)
    sw x19, 19*4(sp)
    sw x20, 20*4(sp)
    sw x21, 21*4(sp)
    sw x22, 22*4(sp)
    sw x23, 23*4(sp)
    sw x24, 24*4(sp)
    sw x25, 25*4(sp)
#ifndef SIMULATION
    sw x26, 26*4(sp)
    sw x27, 27*4(sp)
#endif
    sw x28, 28*4(sp)
    sw x29, 29*4(sp)
    sw x30, 30*4(sp)
    sw x31, 31*4(sp)

    csrr a0, mcause
    csrr a1, mepc
test_if_asynchronous:
	srli a2, a0, 31		                /* MSB of mcause is 1 if handing an asynchronous interrupt - shift to LSB to clear other bits. */
	beq a2, x0, handle_synchronous		/* Branch past interrupt handing if not asynchronous. */

    call interrupt_handler
    j asynchronous_return

handle_synchronous:
    call exception_handler
    addi a1, a1, 4
    csrw mepc, a1

asynchronous_return:
    lw x1, 1*4(sp)
    lw x2, 2*4(sp)
    lw x3, 3*4(sp)
    lw x4, 4*4(sp)
    lw x5, 5*4(sp)
    lw x6, 6*4(sp)
    lw x7, 7*4(sp)
    lw x8, 8*4(sp)
    lw x9, 9*4(sp)
    lw x10, 10*4(sp)
    lw x11, 11*4(sp)
    lw x12, 12*4(sp)
    lw x13, 13*4(sp)
    lw x14, 14*4(sp)
    lw x15, 15*4(sp)
    lw x16, 16*4(sp)
    lw x17, 17*4(sp)
    lw x18, 18*4(sp)
    lw x19, 19*4(sp)
    lw x20, 20*4(sp)
    lw x21, 21*4(sp)
    lw x22, 22*4(sp)
    lw x23, 23*4(sp)
    lw x24, 24*4(sp)
    lw x25, 25*4(sp)
    lw x26, 26*4(sp)
    lw x27, 27*4(sp)
    lw x28, 28*4(sp)
    lw x29, 29*4(sp)
    lw x30, 30*4(sp)
    lw x31, 31*4(sp)

    addi sp, sp, 32*4

    mret


.weak interrupt_handler
interrupt_handler:
1:
    addi x18, x0, 0
    lui x19, 0x2000
    addi x19, x19, 0
    sw x18, 0(x19)      /*msip(0x0200_0000) = 0*/
    addi x13, x0, 0
    lui x11, 0x200b
    addi x11, x11, 0x7ff
    addi x11, x11, 0x7ff
    addi x11, x11, 0x1
    sw x13, 0(x11)      /*mtime_high(0x0200_bfff) = 0x0*/
    addi x14, x0, 0x0
    lui x11, 0x200b
    addi x11, x11, 0x7ff
    addi x11, x11, 0x7f9
    sw x14, 0(x11)      /*mtime_low(0x0200_bff8) = 0x0*/
    addi x10,x0,0x10f
    addi x11,x0,0x11f
    addi x12,x0,0x12f
    addi x13,x0,0x13f
    addi x14,x0,0x14f
    addi x15,x0,0x15f
    addi x16,x0,0x16f
    addi x17,x0,0x17f
    addi x18,x0,0x18f
    addi x19,x0,0x19f
    addi x20,x0,0x20f
    addi x21,x0,0x21f
    addi x22,x0,0x22f
    addi x23,x0,0x23f
    addi x24,x0,0x24f
    addi x25,x0,0x25f
    addi x26,x0,0x26f
    j asynchronous_return

.weak exception_handler
exception_handler:
2:
    addi x10,x0,0x10e
    addi x11,x0,0x11e
    addi x12,x0,0x12e
    addi x13,x0,0x13e
    addi x14,x0,0x14e
    addi x15,x0,0x15e
    addi x16,x0,0x16e
    addi x17,x0,0x17e
    addi a1, a1, 4
    csrw mepc, a1
    j asynchronous_return