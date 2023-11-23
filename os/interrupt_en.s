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
_timer_irq:
    addi sp, sp, -20
    sw x10, 0(sp)
    sw x11, 4(sp)
    sw x12, 8(sp)
    sw x13, 12(sp)
    sw x14, 16(sp)
    addi x10, x0, 1
    lui x11, 0x2004
    addi x11, x11, 0x004
    sw x10, 0(x11)      /* mtimecmp_high(0x0200_4004) = 1*/
    addi x12, x0, 0xa
    lui x11, 0x2004
    addi x11, x11, 0x000
    sw x12, 0(x11)      /* mtimecmp_low(0x0200_4000) = 0xa*/
    addi x13, x0, 0x1
    lui x11, 0x200b
    addi x11, x11, 0x7ff
    addi x11, x11, 0x7ff
    addi x11, x11, 0x1
    sw x13, 0(x11)      /*mtime_high(0x0200_bfff) = 0x1*/
    addi x14, x0, 0x9
    lui x11, 0x200b
    addi x11, x11, 0x7ff
    addi x11, x11, 0x7f9
    sw x14, 0(x11)      /*mtime_low(0x0200_bff8) = 0x9*/
    lw x10, 0(sp)
    lw x11, 4(sp)
    lw x12, 8(sp)
    lw x13, 12(sp)
    lw x14, 16(sp)
    addi sp, sp, 20
_software_irq:
    addi sp, sp, -12
    sw x15, 0(sp)
    sw x11, 4(sp)
    addi x15, x0, 1
    lui x11, 0x2000
    addi x11, x11, 0
    sw x15, 0(x11)      /*msip(0x0200_0000) = 1*/
    addi x15, x0, 0
    lui x11, 0x2000
    addi x11, x11, 0
    sw x15, 0(x11)      /*msip(0x0200_0000) = 0*/
    lw x15, 0(sp)
    lw x11, 4(sp)
    addi sp, sp, 12