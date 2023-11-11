# Compiling Code, Procedures, and Stacks

将高级语言如c语言转换为汇编语言，再转换至二进制文件，将该二进制指令存储在内存中，使cpu运行高级语言程序，在此选用riscv指令集。

## 一、 C语言至二进制文件的转换步骤

### 1

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

### 2

1. 将C语言编写的main.c文件编译成RV32I汇编语言并输出到main.s文件:
```
riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32i -S main.c -o main.s
```
2. 将基于RV32I指令集的汇编程序编译成机器语言，并存储到main.o文件当中：
```
riscv64-unknown-elf-as -mabi=ilp32 -march=rv32i main.s -o main.o
```
3. 反汇编
```
riscv64-linux-gnu-objdump main.o -d > out
```

### 
1. 汇编文件生成二进制编码
```
riscv64-unknown-elf-c++ -nostdlib -nostdinc -static -g -Ttext 0x80000000 sum.s -o sum.elf -march=rv32i -mabi=ilp32
```
2. 将二进制文件反汇编查看内容
```
riscv64-linux-gnu-objdump main.o -d > out
```

### gun debug

1. riscv64-linux-gnu-gcc -nostdlib -nostdinc -static -g -Ttext 0x80000000 sum.s -o sum.elf -march=rv32i -mabi=ilp32
2. qemu-system-riscv32 -m 2G -nographic -machine virt -kernel sum.elf -s -S -bios none
3. gdb-multiarch ./sum.elf
4. target remote localhost:1234
5. b *80000000  // breakpoint
7. layout asm
8. si
9. info reg


在C语言中，函数调用是一种常见的操作，它可以让程序员复用代码，实现模块化的设计。但是，函数调用也需要一些机制来保证程序的正确执行，其中一个重要的机制就是函数返回地址的保存和恢复。函数返回地址就是函数调用结束后，程序应该继续执行的位置，它通常是函数调用指令的下一条指令的地址，也就是pc+4。为了保存这个地址，CPU提供了一个专门的寄存器ra，每次函数调用时，都会把pc+4存入ra中。然而，ra只有一个，如果在一个函数中再调用其他函数，那么ra的值就会被覆盖，导致无法返回到正确的位置。为了解决这个问题，我们需要借助一个数据结构，叫做栈。栈是一种后进先出（LIFO）的结构，它可以让我们按照一定的顺序存储和取出数据。我们可以在内存中分配一段空间作为栈空间，然后用一个寄存器sp作为栈指针，指向栈顶元素的位置。每次函数调用时，我们先把ra的值压入栈中，也就是把ra的值存入sp所指向的位置，然后把sp减去4（因为每个地址占4个字节）。每次函数返回时，我们先把sp加上4，然后把sp所指向的位置的值弹出栈中，也就是把它赋给ra。这样，我们就可以保证每次函数返回都能回到正确的位置。另外，在函数返回前，我们还需要把函数的返回值（a0）存放到内存的某个位置，以便调用者使用。同时，我们还需要恢复寄存器中的其他内容，以免影响其他函数的执行。
