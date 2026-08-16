.section .text
.global _start

.equ UART_BASE,     0x10000000
.equ UART_RX,       0x10
.equ UART_STATUS,   0x14
.equ PROGRAM_BASE,  0x1000

_start:
    # x1 = UART base
    lui     x1, 0x10000

    # x2 = destination address
    lui     x2, 0x1              # 0x1000

    # x3 = program length
    addi    x3, x0, 0

    # Receive 4-byte little-endian length
    jal     x5, receive_byte
    or      x3, x3, x4

    jal     x5, receive_byte
    slli    x4, x4, 8
    or      x3, x3, x4

    jal     x5, receive_byte
    slli    x4, x4, 16
    or      x3, x3, x4

    jal     x5, receive_byte
    slli    x4, x4, 24
    or      x3, x3, x4


receive_program:
    # Finished?
    beq     x3, x0, program_loaded

    # Receive one byte
    jal     x5, receive_byte

    # Store byte into unified memory
    sb      x4, 0(x2)

    # Advance destination
    addi    x2, x2, 1

    # Decrement remaining byte count
    addi    x3, x3, -1

    jal     x0, receive_program


program_loaded:
    # Jump to application at 0x1000
    lui     x6, 0x1
    jalr    x0, 0(x6)


# ------------------------------------------------
# receive_byte
#
# Waits until UART RX has data.
#
# Returns:
#   x4 = received byte
#
# Clobbers:
#   x7
# ------------------------------------------------

receive_byte:
wait_rx:
    lw      x7, UART_STATUS(x1)

    beq     x7, x0, wait_rx

    lw      x4, UART_RX(x1)

    jalr    x0, 0(x5)