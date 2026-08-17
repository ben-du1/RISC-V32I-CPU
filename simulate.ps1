Write-Host "=== Compiling Verilog ==="

$verilogFiles = (Get-ChildItem -Filter "*.v").FullName
iverilog -g2012 -o _cpu_sim $verilogFiles

Write-Host "=== Running simulation ==="

vvp _cpu_sim

Write-Host "=== Done ==="