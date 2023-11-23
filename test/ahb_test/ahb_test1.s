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
addi x10,x0,10
addi x11,x0,11
addi x12,x0,12
addi x13,x0,13
addi x14,x0,14
addi x15,x0,15
addi x16,x0,16
addi x17,x0,17
addi x18,x0,18
addi x19,x0,19
addi x20,x0,20
addi x21,x0,21
addi x22,x0,22
addi x23,x0,23
addi x24,x0,24
addi x25,x0,25
addi x26,x0,26
addi x27,x0,27
addi x28,x0,28
addi x29,x0,29
addi x30,x0,30
addi x31,x0,31
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
addi x10,x0,0x10a
addi x11,x0,0x11a
addi x12,x0,0x12a
addi x13,x0,0x13a
addi x14,x0,0x14a
addi x15,x0,0x15a
addi x16,x0,0x16a
addi x17,x0,0x17a
addi x18,x0,0x18a
addi x19,x0,0x19a
addi x20,x0,0x20a
addi x21,x0,0x21a
addi x22,x0,0x22a
addi x23,x0,0x23a
addi x24,x0,0x24a
addi x25,x0,0x25a
addi x26,x0,0x26a
addi x27,x0,0x27a
addi x28,x0,0x28a
addi x29,x0,0x29a
addi x30,x0,0x30a
addi x31,x0,0x31a
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0