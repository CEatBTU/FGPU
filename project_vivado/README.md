# Vivado project with FGPU

It is possible to automatically:
* create / start FGPU project;
* compile Vivado libraries / compile RTL files / start behavioral simulation;
* perform synthesis / package FGPU IP / generate IPs for FPGA board;
* configure FGPU desing by including / excluding FPU
by using the provided scripts.

## Usage

### Step 1. Environment Setup

First, you need to configure several parameters in the `scripts/setup_environment.tcl` folder. In particular, **it is critical** that one specifies in this script:
- the operating system (windows or linux - that will impact some filenames that are used by these scripts)
- the project name (your choice)
- the project path (your choice)
- the *ModelSim* installation path (use "/" as delimiter, both in windows and in linux)

Additionally, this same script also allows selecting:
- the target board (choose one from the available targets in the `scripts/targets` folder)
- the desired clock frequency

### Step 2. Running the simulation and/or implementation flow

Examples of typical *simulation* and *implementation* flows are provided in the `scripts/main.tcl` script. This script can be run by start Vivado in tcl mode by invoking `vivado -mode tcl` or simply using the *Tcl Console* inside Vivado.
## Regenerating the floating point IPs for a different vivado version or board part

If a different verison of vivado is used and/or a different board from the ZC706 is used, one must manually regenerate the ip modules: fadd_fsub.vhd, fdiv.vhd, fmul.vhd, frsqrt.vhd, fslt.vhd, fsqrt.vhd, and uitofp.vhd. To do this follow the next instructions:
(Flow using the Vivado GUI) 

First we need to Create a new Vivado project, it is temporary and it can be deleted after generating the files. 

Instructions for fadd_fsub.vhd

1. Open IP catalog, search for floating point and double click on it.
2. Change the name to "fadd_fsub"
3. Select the options "Add/Substract" and "Both"
4. Go to interface options and inside flow control select: "Nonblocking"
5. Select Ok and when prompted, select "Generate" to start the OOC synthesis.

Instructions for fdiv.vhd

1. Open IP catalog, search for floating point and double click on it.
2. Change the name to "fdiv"
3. Select the options "Divide"
4. Go to interface options and inside flow control select: "Nonblocking"
5. Select Ok and when prompted, select "Generate" to start the OOC synthesis.

Instructions for fmul.vhd

1. Open IP catalog, search for floating point and double click on it.
2. Change the name to "fmul"
3. Select the options "Multiply"
4. Go to interface options and inside flow control select: "Nonblocking"
5. Select Ok and when prompted, select "Generate" to start the OOC synthesis.

Instructions for frsqrt.vhd

1. Open IP catalog, search for floating point and double click on it.
2. Change the name to "frsqrt"
3. Select the options "Reciprical Square Root"
4. Go to interface options and inside flow control select: "Nonblocking"
5. Select Ok and when prompted, select "Generate" to start the OOC synthesis.

Instructions for fsqrt.vhd

1. Open IP catalog, search for floating point and double click on it.
2. Change the name to "fsqrt"
3. Select the options "Square-root"
4. Go to interface options and inside flow control select: "Nonblocking"
5. Select Ok and when prompted, select "Generate" to start the OOC synthesis.

Instructions for fslt.vhd

1. Open IP catalog, search for floating point and double click on it.
2. Change the name to "fslt"
3. Select the options "Compare" and "Less than"
4. Go to interface options and inside flow control select: "Nonblocking"
5. Select Ok and when prompted, select "Generate" to start the OOC synthesis.

Instructions for uitofp.vhd

1. Open IP catalog, search for floating point and double click on it.
2. Change the name to "uitofp"
3. Select the options "Fixed-to-float"
4. Go to Precision of inputs and select "Uint32"
5. Go to interface options and inside flow control select: "Nonblocking"
6. Select Ok and when prompted, select "Generate" to start the OOC synthesis.


