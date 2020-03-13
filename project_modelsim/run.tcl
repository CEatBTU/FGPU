
project compileall

vsim work.fgpu_tb
add wave -position insertpoint sim:/fgpu_tb/*
run 1000ns
