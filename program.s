addi x1, x0, 0x3ec

addi x2, x0, 0xd0
sb   x2, 3(x1)

lb   x3, 3(x1)
lbu  x4, 3(x1)

hang:
    j hang