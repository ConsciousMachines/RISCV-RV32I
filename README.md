# RISCV-RV32I
![demo bubble sort](https://github.com/ConsciousMachines/RISCV-RV32I/blob/main/img/demo.png)

This is an implementation of a RISC-V core supporting the RV32I instruction set, made in Virtual Circuit Board. This simulator allows you to build circuits from nothing except gates and wire, allowing you to witness the timing and area properties of your circuit, which usually get abstracted away in Verilog. This allows you to see the result as a living, breathing processor similar to ![Visual 6502](http://www.visual6502.org/JSSim/index.html), and you can see your code execute as binary numbers traveling between parts of the circuit. 

# Usage
On Debian (or WSL), we can install the tools to compile our code for the RISC-V RV32I instruction set.
```shell
sudo apt update
sudo apt install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```
Then we write the linker script and startup assembly, which are needed to compile C for this architecture.
## link.ld
The linker script tells us that instruction data starts at `0x4`. Set the top of the stack to `0x2000`.
```
ENTRY(_start)

SECTIONS
{
  . = 0x4;
  .text : { *(.text*) }
  .data : { *(.data*) }
  .bss  : { *(.bss*) }

  . = 0x2000;
  _stack_top = .;
}
```
## startup.s
Small startup script to initialize the stack pointer, and jump to the main function.
```asm 
.section .text
.global _start

_start:
    la   sp, _stack_top          # initialize stack pointer
    call main                    # jump to C code
hang:
    j    hang                    # spin forever
```
Then we can write some C code to watch it execute. Here is a basic Leetcode algorithm, bubble sort, which is easy to debug both in code and hardware. 
```C
#define ARR_BASE  0x1000
#define ARR_COUNT 8

int main(void) {
    volatile unsigned int *arr = (unsigned int *)ARR_BASE;

    // unsorted data
    arr[0] = 42;
    arr[1] = 7;
    arr[2] = 19;
    arr[3] = 3;
    arr[4] = 88;
    arr[5] = 1;
    arr[6] = 56;
    arr[7] = 23;

    for (int i = 0; i < ARR_COUNT - 1; i++)
    {
        for (int j = 0; j < ARR_COUNT - 1 - i; j++)
        {
            if (arr[j] > arr[j + 1])
            {
                unsigned int tmp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = tmp;
            }
        }
    }

    while (1) {}

    return 0;
}
```
We compile this and view the resulting disassembly:
```shell
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles \
  -T link.ld -O2 -o test.elf startup.s test.c
riscv64-unknown-elf-objcopy -O binary test.elf test.bin
riscv64-unknown-elf-objdump -d test.elf
```
Disassembly (code was optimized with -O2 so it is smaller). The processor has a memory-mapped output that goes into a hex display so we can see the contents at `0x1000`. This has to be marked as `volatile` so the compiler doesn't optimize away this I/O. 
```
test.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000004 <_start>:
   4:   00002117                auipc   sp,0x2
   8:   ffc10113                addi    sp,sp,-4 # 2000 <_stack_top>
   c:   008000ef                jal     14 <main>

00000010 <hang>:
  10:   0000006f                j       10 <hang>

00000014 <main>:
  14:   00001537                lui     a0,0x1
  18:   02a00793                li      a5,42
  1c:   00f52023                sw      a5,0(a0) # 1000 <main+0xfec>
  20:   00700693                li      a3,7
  24:   00d52223                sw      a3,4(a0)
  28:   01300693                li      a3,19
  2c:   00d52423                sw      a3,8(a0)
  30:   00300693                li      a3,3
  34:   00d52623                sw      a3,12(a0)
  38:   05800693                li      a3,88
  3c:   00d52823                sw      a3,16(a0)
  40:   00100693                li      a3,1
  44:   00d52a23                sw      a3,20(a0)
  48:   03800713                li      a4,56
  4c:   00e52c23                sw      a4,24(a0)
  50:   01c50593                addi    a1,a0,28
  54:   01700793                li      a5,23
  58:   00f5a023                sw      a5,0(a1)
  5c:   000017b7                lui     a5,0x1
  60:   0007a683                lw      a3,0(a5) # 1000 <main+0xfec>
  64:   00078613                mv      a2,a5
  68:   00478793                addi    a5,a5,4
  6c:   0007a703                lw      a4,0(a5)
  70:   00d77a63                bgeu    a4,a3,84 <main+0x70>
  74:   00062703                lw      a4,0(a2)
  78:   0007a683                lw      a3,0(a5)
  7c:   00d62023                sw      a3,0(a2)
  80:   00e7a023                sw      a4,0(a5)
  84:   fcb79ee3                bne     a5,a1,60 <main+0x4c>
  88:   ffc78593                addi    a1,a5,-4
  8c:   fca598e3                bne     a1,a0,5c <main+0x48>
  90:   0000006f                j       90 <main+0x7c>
```
I used a small Python function to copy the contents of this `.bin` file into the format that VCB understands:
```Python
file_name = r'\\wsl.localhost\Debian\home\chad\riscv_0001\test.bin'

with open(file_name, "rb") as f:
    data = f.read()

# pad to a multiple of 4 in case the binary isn't word-aligned in length
while len(data) % 4 != 0:
    data += b'\x00'

str_lines = []
for i in range(0, len(data), 4):
    word = data[i:i+4]
    hex_word = f"{word[3]:02x}{word[2]:02x}{word[1]:02x}{word[0]:02x}"
    str_lines.append(f"0x{hex_word}")

filename = r'C:\Users\cudac\Desktop\new\code\art\VCB\riscv.vcbmem'

str_lines.insert(0, '0xFAFAFAFA') # first word is never used in VCB

with open(filename, "wb") as file:
    for line in str_lines:
        file.write(bytes.fromhex(line[2:]))
```

# Timing
Because we are working with individual gates, each sub-circuit has a propagation delay equal to the longest path in gates. To get the data flowing correctly, we need to wait for each sub-circuit to finish (many times they finish early, so we wait for the worst case). This analysis was done by drawing a timing diagram in Excel for each instruction type.
![Timing Diagram BEQ](https://github.com/ConsciousMachines/RISCV-RV32I/blob/main/img/timing.png)

# Future Work
The goal of this project was to connect the bottom-up approach of starting with nothing but logic gates and wire, with the top-down activity of programming in C that many people are familiar with. This shows how we can go from "nothing" to C, and all we had to do was implement the specification that is RISC-V. The next step of course is to run Linux on this processor.  

