$ErrorActionPreference = "Stop"

Write-Host "=== Assembling ==="

& riscv64-unknown-elf-gcc.exe `
    -march=rv32i `
    -mabi=ilp32 `
    -ffreestanding `
    -nostdlib `
    -nostartfiles `
    -T program_link.ld `
    program_start.s program.c `
    -o _program.elf

& riscv64-unknown-elf-objdump -d _program.elf
& riscv64-unknown-elf-objdump -h _program.elf

Write-Host "=== Generating Binaries ==="

& riscv64-unknown-elf-objcopy -O binary _program.elf _program.bin

Write-Host "=== Running Python conversions ==="

python convert.py bin _program.bin _program.bin