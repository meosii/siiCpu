## ECALL
ecall实际上只会改变三件事情：
1. ecall将代码从user mode改到supervisor mode。
2. ecall将程序计数器的值保存在了SEPC寄存器。
3. ecall会跳转到STVEC寄存器指向的指令。

接下来：我们需要保存32个用户寄存器的内容，这样当我们想要恢复用户代码执行时，我们才能恢复这些寄存器的内容。因为现在我们还在user page table，我们需要切换到kernel page table。我们需要创建或者找到一个kernel stack，并将Stack Pointer寄存器的内容指向那个kernel stack。这样才能给C代码提供栈。我们还需要跳转到内核中C代码的某些合理的位置。

ecall并不会为我们做这里的任何一件事。实际上，有的机器在执行系统调用时，会在硬件中完成所有这些工作。但是RISC-V并不会，RISC-V秉持了这样一个观点：ecall只完成尽量少必须要完成的工作，其他的工作都交给软件完成。这里的原因是，RISC-V设计者想要为软件和操作系统的程序员提供最大的灵活性，这样他们就能按照他们想要的方式开发操作系统。

## 异常处理

当一个 hart 遇到异常的情况，硬件会执行以下的步骤：

1. 保存异常发生前的权限模式到 mstatus.MPP 中，并将权限模式切换到 M 模式。然后，保存异常发生前的 mstatus.MIE 到 mstatus.MPIE 中，并将 mstatus.MIE 清零以屏蔽中断。这说明 RISC-V 的硬件不支持中断的嵌套，如果要实现中断的嵌套，只能通过软件来完成。
2. 根据异常的来源设置 mcause 的值，并将异常的相关信息写入 mtval 中。

3. 将异常指令的 PC 保存到 mepc 中，并将 PC 设置为 mtvec 中指定的异常处理程序的入口地址。对于同步异常，mepc 指向导致异常的指令；对于中断，mepc 指向中断发生后应该继续执行的位置，通常是中断指令的下一条指令地址，即 mepc + 4。此外，mtvec 有两种模式：直接模式和向量模式。直接模式下，直接跳转到 mtvec 的基地址执行；向量模式下，根据 mcause 的中断类型跳转到相应的中断处理程序的首地址执行。
4. 执行异常处理程序，并在程序中保存和切换上下文环境。
5. 当异常处理程序执行完毕后，在程序末尾会调用 MRET 指令来退出异常处理程序，S 模式下调用的是 SRET 指令。
6. 执行 MRET 指令后，处理器硬件会做以下操作：更新 mstatus。将异常发生前的 mstatus 的状态恢复，将 mstatus.MPIE 复制到 mstatus.MIE 来恢复之前的中断使能设置，并将权限模式设置为 mstatus.MPP 域中的值。从 mepc 中保存的地址继续执行，即回到异常发生前的程序流继续执行。

1. If the trap is a device interrupt, and the sstatus SIE bit is clear, don’t do any of the
following.
2. Disable interrupts by clearing the SIE bit in sstatus.
3. Copy the pc to sepc.
4. Save the current mode (user or supervisor) in the SPP bit in sstatus.
5. Set scause to reflect the trap’s cause.
6. Set the mode to supervisor.
7. Copy stvec to the pc.
8. Start executing at the new pc

Note that the CPU doesn’t switch to the kernel page table, doesn’t switch to a stack in the
kernel, and doesn’t save any registers other than the pc. Kernel software must perform these tasks.

![](https://tinylab.org/wp-content/uploads/2022/03/riscv-linux/images/riscv-irq-pipeline-introduction/irq_pipeline.png)