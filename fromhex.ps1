$ErrorActionPreference = "Stop"
Write-Host "=== Compiling Verilog ==="

$verilogFiles = (Get-ChildItem -Filter "*.v").FullName
iverilog -g2012 -o cpu_sim $verilogFiles

Write-Host "=== Running simulation ==="

vvp cpu_sim

Write-Host "=== Done ==="