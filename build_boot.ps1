$ErrorActionPreference = "Stop"

Write-Host "=== Assembling ==="

& "C:\SysGCC\risc-v\bin\riscv64-unknown-elf-gcc.exe" `
    -march=rv32i `
    -mabi=ilp32 `
    -c boot.s `
    -T boot_link.ld `
    -o _boot.elf

& riscv64-unknown-elf-objdump -d _boot.elf
& riscv64-unknown-elf-objdump -h _boot.elf

Write-Host "=== Generating Binary ==="

& riscv64-unknown-elf-objcopy -O binary _boot.elf _boot.bin

Write-Host "=== Running Python conversion ==="

python convert.py hex _boot.bin _boot.hex