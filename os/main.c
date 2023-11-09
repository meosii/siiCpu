void timer0_irq_handler()
{
    TIMER0_REG(TIMER0_CTRL) |= (1 << 2) | (1 << 0);  // clear int pending and start timer

    count++;
}