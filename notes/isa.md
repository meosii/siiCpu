## ECALL
ecall实际上只会改变三件事情：
1. ecall将代码从user mode改到supervisor mode。
2. ecall将程序计数器的值保存在了SEPC寄存器。
3. ecall会跳转到STVEC寄存器指向的指令。

接下来：我们需要保存32个用户寄存器的内容，这样当我们想要恢复用户代码执行时，我们才能恢复这些寄存器的内容。因为现在我们还在user page table，我们需要切换到kernel page table。我们需要创建或者找到一个kernel stack，并将Stack Pointer寄存器的内容指向那个kernel stack。这样才能给C代码提供栈。我们还需要跳转到内核中C代码的某些合理的位置。

ecall并不会为我们做这里的任何一件事。实际上，有的机器在执行系统调用时，会在硬件中完成所有这些工作。但是RISC-V并不会，RISC-V秉持了这样一个观点：ecall只完成尽量少必须要完成的工作，其他的工作都交给软件完成。这里的原因是，RISC-V设计者想要为软件和操作系统的程序员提供最大的灵活性，这样他们就能按照他们想要的方式开发操作系统。