# Vivado project with FGPU

It is possible to automatically:
* create / start FGPU project;
* compile Vivado libraries / compile RTL files / start behavioral simulation;
* perform synthesis / package FGPU IP / generate IPs for FPGA board;
* configure FGPU desing by including / excluding FPU
by using the provided scripts.

## Usage

First, you need to configure several parameters in the `scripts/setup_environment.tcl` folder. In particular, you **must** specify in this script:
- your operating system (windows or linux - that impacts some filenames that are used by these scripts)
- the project name (your choice)
- the project path (your choice)
- the target board (choose one from the available targets in the `scripts/targets` folder)
- the PATH of your *ModelSim* installation

Examples of typical *simulation* and *implementation* flows are provided in the `scripts/main.tcl` script. This script can be run by start Vivado in tcl mode by invoking `vivado -mode tcl` or simply using the *Tcl Console* inside Vivado.

After running the scripts, it is desirable to run the command `reset_project`.
