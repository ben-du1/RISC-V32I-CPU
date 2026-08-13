$ErrorActionPreference = "Stop"

Write-Host "=== Assembling ==="

& riscv64-unknown-elf-gcc.exe `
    -march=rv32i `
    -mabi=ilp32 `
    -ffreestanding `
    -nostdlib `
    -nostartfiles `
    -T link2.ld `
    start.s program.c `
    -o _program.elf

& riscv64-unknown-elf-objdump -d _program.elf
& riscv64-unknown-elf-objdump -h _program.elf

Write-Host "=== Generating Binaries ==="

& riscv64-unknown-elf-objcopy -O binary -j .text _program.elf _program.bin
& riscv64-unknown-elf-objcopy -O binary -j .data _program.elf _data.bin

Write-Host "=== Running Python conversions ==="

python convert.py hex _program.bin _program.hex
python convert.py bin _data.bin _data.bin

Write-Host "=== Compiling Verilog ==="

$verilogFiles = (Get-ChildItem -Filter "*.v").FullName
iverilog -g2012 -o cpu_sim $verilogFiles

Write-Host "=== Running simulation ==="

vvp cpu_sim

Write-Host "=== Done ==="