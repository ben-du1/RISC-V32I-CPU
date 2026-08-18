# RISC-V RV32I Soft-Core CPU & FPGA SoC
![](https://github.com/user-attachments/assets/fb0fa088-e58a-46dc-a757-89b07d0899e2)
*Tang Nano 20K with ESP32 Programmer running* `/program/program.c`

## Overview
This is a Verilog-based soft-core CPU that I developed which executes the RISCV32I instruction set. If you plan on testing this chip on an FPGA, make sure to read the "FPGA Implementation" section.

## Architecture
![Architecture diagram](https://github.com/user-attachments/assets/9500de31-34a0-47e9-af45-61bdc0997473)

The CPU features a Von Neumann architecture with programs and data being stored in a unified memory. The CPU is multicycle to accommodate synchronous read and write to memory, which is crucial for proper BSRAM inference during synthesis.

## Instruction Set
| Type              | Instructions                   |
| ----------------- | ------------------------------ |
| R-type arithmetic | `ADD`, `SUB`                   |
| R-type logical    | `AND`, `OR`, `XOR`             |
| R-type shifts     | `SLL`, `SRL`, `SRA`            |
| R-type comparison | `SLT`, `SLTU`                  |
| I-type arithmetic | `ADDI`                         |
| I-type logical    | `ANDI`, `ORI`, `XORI`          |
| I-type shifts     | `SLLI`, `SRLI`, `SRAI`         |
| I-type comparison | `SLTI`, `SLTIU`                |
| Loads             | `LB`, `LBU`, `LH`, `LHU`, `LW` |
| Stores            | `SB`, `SH`, `SW`               |
| Branches          | `BEQ`, `BNE`, `BLT`, `BGE`     |
| Jumps             | `JAL`, `JALR`                  |
| Upper immediate   | `LUI`, `AUIPC`                 |

Note that `FENCE`, `ECALL`, and `EBREAK` are not implemented.

## Memory
The CPU has 8 KB of memory with the first 4 KB reserved for the bootloader by default. Natively, our memory array is implemented as a 2048 x 32 bit word array to allow for proper BSRAM inference but it is regarded as byte-addressable during reads and writes through splicing and reassembly.

| Address Range             |   Size | Purpose                                       |
| ------------------------- | -----: | --------------------------------------------- |
| `0x00000000 – 0x00000FFF` |   4 KB | Bootloader               |
| `0x00001000 – 0x00001FFF` |   4 KB | Program Memory & Stack  |
| `0x10000000`              | 1 word | UART TX         |
| `0x10000010`              | 1 word | UART RX           |
| `0x10000014`              | 1 word | UART RX Status         |
| `0x1000001C`              | 1 word | GPIO Input              |
| `0x10000020`              | 1 word | GPIO Output |
| `0x10000024`              | 1 word | Timer                |

## UART Bootloader
I wrote a simple assembly bootloader which is initialized onto the CPU during synthesis. Combined with the CPU's UART capabilities, the bootloader allows programs to be dynamically loaded into memory and executed with a UART programmer. The bootloader first receives 4 bytes over UART to indicate program length, then it receives and stores the program byte-by-byte. The bootloader monitors RX status which is exposed to indicate when a new byte is ready to be read. To load a program, another microcontroller or a USB-to-UART adapter is needed. Simply connect the appropriate TX, RX, RESET, and GND pins together before transmitting. The system is able to be reliably programmed at 100,000 baud and other baudrates can be achieved by changing the configuration of the CPU UART module. 

## Verification
To test and debug the system, I used Icarus Verilog and GTKWave. Troubleshooting problems required creating testbenches and assembly scripts as well as performing waveform analysis. I've provided sample functions in `/program/program.c` and a testbench in `/src/cpu_tb.v`.

## FPGA Implementation
I used a relatively-affordable Tang Nano 20K FPGA board for testing. The `/synthesis` folder contains the appropriate files for synthesis and place-and-route processes in Gowin EDA. I have enabled and assigned 6 GPIO inputs, 6 GPIO outputs, TX, RX, and RESET by default in `/synthesis/top.cst`. I defaulted to the Tang Nano's 27MHz clock for processor timing, so it will be necessary to change the values of `BIT_CLK_CYCLES` and `SAMPLE_DELAY` in `/src/uart.v` to `9'd270` and `9'd135` for reliable UART. Here is the resource usage/utilization summary:

| Resource     | Usage |
| ------------ | ----: |
| **I/O Port** |    16 |
| ↳ IBUF       |     9 |
| ↳ OBUF       |     7 |
| **Register** |   452 |
| ↳ DFF        |    78 |
| ↳ DFFE       |    44 |
| ↳ DFFSE      |     1 |
| ↳ DFFR       |    43 |
| ↳ DFFRE      |   286 |
| **LUT**      | 1,718 |
| ↳ LUT2       |   204 |
| ↳ LUT3       |   585 |
| ↳ LUT4       |   929 |
| **ALU**      |   133 |
| **SSRAM**    |    12 |
| ↳ RAM16SDP1  |     8 |
| ↳ RAM16SDP4  |     4 |
| **INV**      |     6 |
| **BSRAM**    |     6 |
| ↳ SDPB       |     6 |

| Resource            |          Usage | Utilization |
| ------------------- | -------------: | ----------: |
| **Logic**           | 1,929 / 20,736 |     **10%** |
| ↳ LUT               | 1,724 / 20,736 |           — |
| ↳ ALU               |   133 / 20,736 |           — |
| ↳ RAM16             |    12 / 20,736 |           — |
| **Register**        |   452 / 15,750 |      **3%** |
| ↳ Register as Latch |     0 / 15,750 |      **0%** |
| ↳ Register as FF    |   452 / 15,750 |      **3%** |
| **BSRAM**           |         6 / 46 |     **14%** |
