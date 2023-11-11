# siiCpu
Here is an introduction to siiCpu

- The CPU supports the complete rv32i instruction set, which can execute basic arithmetic, logic, shift, branch, jump, and other instructions.

- The CPU supports privileged instructions, which can implement system calls and exception handling, and only supports machine mode here.

- The CPU supports the processing of interrupts and exceptions, can respond to external interrupts and internal exceptions, and when an interrupt exception occurs, the hardware is responsible for recording the cause of the exception, the `pc` at the time of the exception, etc, and automatically jumps to the TRAP entry program pointed to by `mtvec`. Software is responsible for context protection, and hardware returns to continue executing the original program after receiving the mret instruction.

- The CPU includes 32 general-purpose registers for storing operands and results, with the x0 register fixed at 0.

- The CPU includes basic CSR registers for storing control and status information, such as interrupt enable (`mie`), interrupt suspend (`mip`), exception code (`mcause`), etc.

- The CPU is designed with a five-stage pipeline, including fetch, decode, execute, memory access, and write back, connected by pipeline registers.

- The CPU uses simple static branch prediction. For conditional branch instructions, the immediate number in the instruction is used to determine whether to jump. If the jump address is after the instruction, the jump occurs. For unconditional jump instructions, it is predicted that they always jump. Since the `jr ra` instruction is a function return instruction and occurs frequently, an interface is directly designed to read the `ra` register in the general-purpose register.

- The CPU adopts the Harvard architecture, and the instruction and data storage are separated and accessed by ITCM and DTCM, respectively. Single-cycle reading improves memory access efficiency.

- The data width of ITCM and DTCM is 32 bits, and one word of data can be read or written at a time. The capacity of ITCM and DTCM can be configured as needed.