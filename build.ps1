$ErrorActionPreference = "Stop"

Write-Host "=== Assembling ==="

& "C:\SysGCC\risc-v\bin\riscv64-unknown-elf-gcc.exe" `
    -march=rv32i `
    -mabi=ilp32 `
    -c program.s `
    -o program.o

& riscv64-unknown-elf-objdump -d program.o

Write-Host "=== Generating Binary ==="

& riscv64-unknown-elf-objcopy -O binary -j .text program.o program.bin

Write-Host "=== Running Python conversion ==="

python convert.py

Write-Host "=== Compiling Verilog ==="

$verilogFiles = (Get-ChildItem -Filter "*.v").FullName
iverilog -g2012 -o cpu_sim $verilogFiles

Write-Host "=== Running simulation ==="

vvp cpu_sim

Write-Host "=== Done ==="