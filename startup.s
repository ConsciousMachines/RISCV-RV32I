.section .text
.global _start

_start:
    la   sp, _stack_top          # initialize stack pointer
    call main                    # jump to C code
hang:
    j    hang                    # spin forever