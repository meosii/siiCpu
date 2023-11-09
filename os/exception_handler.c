void exception_handler(uint32_t mcause, uint32_t mepc)
{
    if ((mcause != TRAP_BREAKPOINT) && (mcause != TRAP_ECALL_M))
        while (1);
}