## 函数调用

对于函数调用，编译器会生成伪指令 `call function`，`call` 可以写作 `auipc x1,offset[31:12]` 与 `jalr x1,x1,offset[11:0]` ，其中将 `call` 指令的 pc 地址与子函数 function 的 pc 地址之差写入 offset，执行到 `call` 指令时，将无条件跳转到子函数入口，在子函数结尾处会有 `jr ra` 指令，将 pc 重新指向 `call` 指令之后的指令。

``` ARM
main:
addi    sp,sp,-32
sw      ra,28(sp)
sw      s0,24(sp)
addi    s0,sp,32
li      a5,100
sw      a5,-20(s0)
li      a5,200
sw      a5,-24(s0)
lw      a1,-24(s0)
lw      a0,-20(s0)
call    max             // auipc x1,0; jalr x1,x1,36
sw      a0,-28(s0)
li      a5,0
mv      a0,a5
lw      ra,28(sp)
lw      s0,24(sp)
addi    sp,sp,32
jr      ra
.size	main, .-main
.align	2
.globl	max
.type	max, @function
max:
addi    sp,sp,-48
sw      s0,44(sp)
addi    s0,sp,48
sw      a0,-36(s0)
sw      a1,-40(s0)
lw      a4,-36(s0)
lw      a5,-40(s0)
ble     a4,a5,.L4
lw      a5,-36(s0)
sw      a5,-20(s0)
j	    .L5
.L4:
lw      a5,-40(s0)
sw      a5,-20(s0)
.L5:
lw      a5,-20(s0)
mv      a0,a5
lw      s0,44(sp)
addi    sp,sp,48
jr      ra
```

函数调用会实现无条件跳转，同时，将跳转时的地址 pc+4 保存下来，从而在子函数执行完成后，将跳转回 pc+4，执行之后的操作。

其中每个函数都会开辟自己的栈空间