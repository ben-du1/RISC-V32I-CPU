$ErrorActionPreference = "Stop"

Write-Host "=== Assembling ==="

& "C:\SysGCC\risc-v\bin\riscv64-unknown-elf-gcc.exe" `
    -march=rv32i `
    -mabi=ilp32 `
    -c program.s `
    -o _program.elf

& riscv64-unknown-elf-objdump -d _program.elf

Write-Host "=== Generating Binary ==="

& riscv64-unknown-elf-objcopy -O binary -j .text _program.elf _program.bin

Write-Host "=== Running Python conversion ==="

python convert.py hex _program.bin _program.hex

Write-Host "=== Compiling Verilog ==="

$verilogFiles = (Get-ChildItem -Filter "*.v").FullName
iverilog -g2012 -o cpu_sim $verilogFiles

Write-Host "=== Running simulation ==="

vvp cpu_sim

Write-Host "=== Done ==="