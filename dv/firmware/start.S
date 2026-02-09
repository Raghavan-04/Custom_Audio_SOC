.section .text
.globl _start

_start:
    li t0, 0x400       # Load Audio PWM Address into register t0
    li t1, 0xFF        # High Volume (Full Duty Cycle)
    li t2, 0x00        # Low Volume (Silence)

loop:
    sw t1, 0(t0)       # Write 0xFF to Audio PWM
    # Delay Loop (to make the sound audible in simulation)
    li t3, 100
delay1:
    addi t3, t3, -1
    bnez t3, delay1

    sw t2, 0(t0)       # Write 0x00 to Audio PWM
    li t3, 100
delay2:
    addi t3, t3, -1
    bnez t3, delay2

    j loop             # Repeat forever