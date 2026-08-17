.section .text
.global _start

.equ UART_BASE, 0x10000
.equ UART_READY, 0x14
.equ UART_RX, 0x10
.equ PROGRAM_START, 0x1

_start:
lui x1, UART_BASE
lui x2, PROGRAM_START

addi x6, x0, 0

jal x3, receive_byte
or x6, x6, x5

jal x3, receive_byte
slli x5, x5, 8
or x6, x6, x5

jal x3, receive_byte
slli x5, x5, 16
or x6, x6, x5

jal x3, receive_byte
slli x5, x5, 24
or x6, x6, x5

jal x0, receive_program


receive_byte:
wait_rx:
lw x4, UART_READY(x1)
beq x4, x0, wait_rx
lw x5, UART_RX(x1)
jalr x0, 0(x3)

receive_program:
beq x6, x0, start_program
jal x3, receive_byte
sb x5, 0(x2)
addi x2, x2, 1
addi x6, x6, -1
jal x0, receive_program

start_program:
lui x7, 0x1
jalr x0, 0(x7)
