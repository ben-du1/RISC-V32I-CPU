$ErrorActionPreference = "Stop"

Write-Host "=== Assembling ==="

& riscv64-unknown-elf-gcc.exe `
    -march=rv32i `
    -mabi=ilp32 `
    -ffreestanding `
    -nostdlib `
    -nostartfiles `
    -T program_link.ld `
    start.s program.c `
    -o _program.elf

& riscv64-unknown-elf-objdump -d _program.elf
& riscv64-unknown-elf-objdump -h _program.elf

Write-Host "=== Generating Binaries ==="

& riscv64-unknown-elf-objcopy -O binary _program.elf _program.bin

Write-Host "=== Running Python conversions ==="

python convert.py bin _program.bin _program.bin

Write-Host "=== Copying to C:\Users\ben\Documents\Arduino\esp32_fpga_programmer\data\_program.bin ==="

Copy-Item -Path "C:\Users\ben\Desktop\coding\verilog-stuff\cpu2\_program.bin" -Destination "C:\Users\ben\Documents\Arduino\esp32_fpga_programmer\data"