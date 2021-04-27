These are all the VHDL files that may be needed to synthesize or simulate FGPU.
Please notice:
+ This version of FGPU operates on a single clock.
+ No constraint files are needed!
+ The top level file is FGPU.vhd
+ A model for the global memory is included (global_mem.vhd)
+ The folder floating_point contains different instantiations with different settings of the Xilinx floating-point IP-core to be used within FGPU. However, it is not needed if no floating-point hardware is desired.
+ The files FGPU_tb.vhd and FGPU_simulation_pkg.vhd are needed only for simulation.

