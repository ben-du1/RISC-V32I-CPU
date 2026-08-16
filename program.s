addi x1, x0, 0x3ec

# Initial word = 0x12345678
lui  x2, 0x12345
addi x2, x2, 0x678

sw   x2, 0(x1)

# Read back initial word
lw   x3, 0(x1)
lb   x4, 0(x1)
lbu  x5, 0(x1)
lh   x6, 0(x1)
lhu  x7, 0(x1)

# SH at offset 0
addi x2, x0, 0x5a6
sh   x2, 0(x1)

lw   x8, 0(x1)
lb   x9, 0(x1)
lbu  x10, 0(x1)
lh   x11, 0(x1)

hang:
    j hang