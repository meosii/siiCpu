# Compiling Code, Procedures, and Stacks

将高级语言如c语言转换为汇编语言，再转换至二进制文件，将该二进制指令存储在内存中，使cpu运行高级语言程序，在此选用riscv指令集。

## 一、 C语言至二进制文件的转换步骤
1. 将C语言编写的main.c文件编译成RV32I汇编语言并输出到main.s文件:
```
riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32i -S main.c -o main.s
```
2. 将基于RV32I指令集的汇编程序编译成机器语言，并存储到main.o文件当中：
```
riscv64-unknown-elf-as -mabi=ilp32 -march=rv32i main.s -o main.o
```
3. 将机器语言转为二进制文件：
```
riscv64-linux-gnu-objcopy -O binary main.o main.bi
```
4. 将二进制文件转为asc文件：
```
od -An -t x4 -w4 output.bi > output.asc
```
## 二、实例
如下展示了一段C语言代码：
```c
int gcd(int a, int b) {
    int x = a;
    int y = b;
    while (x != y){
        if (x > y) {
            x = x - y;
	    } else {
	        y = y - x;
	    }
    }
    return x;
}
```
其对应的汇编代码为：
```
gcd:
	addi	sp,sp,-48 // allocate 48 bytes on stack
	sw	    s0,44(sp) // save s0
	addi	s0,sp,48
	sw  	a0,-36(s0)
	sw  	a1,-40(s0)
	lw  	a5,-36(s0)
	sw  	a5,-20(s0)
	lw  	a5,-40(s0)
	sw  	a5,-24(s0)
	j	    .L2
.L4:
	lw	    a4,-20(s0)
	lw	    a5,-24(s0)
	ble 	a4,a5,.L3
	lw	    a4,-20(s0)
	lw	    a5,-24(s0)
	sub 	a5,a4,a5
	sw	    a5,-20(s0)
	j	    .L2
.L3:
	lw	    a4,-24(s0)
	lw	    a5,-20(s0)
	sub 	a5,a4,a5
	sw	    a5,-24(s0)
.L2:
	lw	    a4,-20(s0)
	lw	    a5,-24(s0)
	bne 	a4,a5,.L4
	lw	    a5,-20(s0)
	mv	    a0,a5
	lw	    s0,44(sp) // restore s0
	addi	sp,sp,48  // deallocate 48 bytes from stack(restore sp)
	jr	    ra
```
在C语言中，函数调用是一种常见的操作，它可以让程序员复用代码，实现模块化的设计。但是，函数调用也需要一些机制来保证程序的正确执行，其中一个重要的机制就是函数返回地址的保存和恢复。函数返回地址就是函数调用结束后，程序应该继续执行的位置，它通常是函数调用指令的下一条指令的地址，也就是pc+4。为了保存这个地址，CPU提供了一个专门的寄存器ra，每次函数调用时，都会把pc+4存入ra中。然而，ra只有一个，如果在一个函数中再调用其他函数，那么ra的值就会被覆盖，导致无法返回到正确的位置。为了解决这个问题，我们需要借助一个数据结构，叫做栈。栈是一种后进先出（LIFO）的结构，它可以让我们按照一定的顺序存储和取出数据。我们可以在内存中分配一段空间作为栈空间，然后用一个寄存器sp作为栈指针，指向栈顶元素的位置。每次函数调用时，我们先把ra的值压入栈中，也就是把ra的值存入sp所指向的位置，然后把sp减去4（因为每个地址占4个字节）。每次函数返回时，我们先把sp加上4，然后把sp所指向的位置的值弹出栈中，也就是把它赋给ra。这样，我们就可以保证每次函数返回都能回到正确的位置。另外，在函数返回前，我们还需要把函数的返回值（a0）存放到内存的某个位置，以便调用者使用。同时，我们还需要恢复寄存器中的其他内容，以免影响其他函数的执行。
