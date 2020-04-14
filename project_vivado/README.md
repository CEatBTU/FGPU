# Vivado project with FGPU

It is possible to automatically:
* create / start FGPU project;
* compile Vivado libraries / compile RTL files / start behavioral simulation;
* perform synthesis / package FGPU IP / generate IPs for FPGA board;
* configure FGPU desing by including / excluding FPU
by using the provided scripts.

## Usage

First, you need to configure several parameters in the `scripts/setup_environment.tcl` folder. In particular, **it is critical** that one specifies in this script:
- the operating system (windows or linux - that will impact some filenames that are used by these scripts)
- the project name (your choice)
- the project path (your choice)
- the *ModelSim* installation path (use "/" as delimiter, both in windows and in linux)

Additionally, this same script also allows selecting:
- the target board (choose one from the available targets in the `scripts/targets` folder)
- the desired clock frequency

Examples of typical *simulation* and *implementation* flows are provided in the `scripts/main.tcl` script. This script can be run by start Vivado in tcl mode by invoking `vivado -mode tcl` or simply using the *Tcl Console* inside Vivado.