FGPU is a soft GPU-like architecture for FPGAs. It is described in VHDL, fully customizable, and can be programmed using OpenCL.

FGPU is currently being developed and maintained by the [Chair of Computer Engineering at the Brandenburg University of Technology Cottbus-Senftenberg], in Germany. It was originally developed by Muhammed Al Kadi from the [Ruhr University Bochum], in Germany.

[Chair of Computer Engineering at the Brandenburg University of Technology Cottbus-Senftenberg]: https://www.b-tu.de/en/computer-engineering-group
[Ruhr University Bochum]: https://www.ei.ruhr-uni-bochum.de/fakultaet/

# Contents and Structure of the FGPU Repository

This repository contains the following resources:
- The FGPU architecture, described in VHDL, which can be used for behavioral simulation and FPGA-targeted implementation. These are located in the `RTL` folder.
- The files for setting up and running an FGPU simulation project in Mentor ModelSim. These are located in the `project_modelsim` folder.
- The files for setting up simulation and or implementation projects in Xilinx Vivado. In the current version, only the Xilinx Zynq-7000 SoC ZC706 board is supported. These files are located in the `project_vivado` folder.
- The files for building the LLVM-based FGPU compiler. These are located in the `compiler` folder.
- Pre-generated bitstreams that can be quickly loaded to the ZC706 board for testing new FGPU applications without worrying about the hardware generation step. These are located in the `bitstreams` folder.
- Examples of OpenCL kernels for execution in FGPU the FGPU, located in the `kernels` folder.
- Examples of complete benchmarks for execution in an ARM+FGPU system that can be configured using Vivado SDK. These are located in the `benchmark` folder.

# FGPU Quick Start

## Setting up the FGPU LLVM-based compiler

The compiler will be used to generate, from an OpenCL kernel description, the binaries containing the FGPU instructions that implement the kernel. To ensure portability, the FGPU compiler is built inside a Docker container. See the instructions in `compiler/README.md.`

## Setting up the Vivado SW/HW Development Environment

First, you need to configure several parameters in the `scripts/setup_environment.tcl` folder. In particular, **it is critical** that one specifies in this script:
- the operating system (windows or linux - that will impact some filenames that are used by these scripts)
- the project name (your choice)
- the project path (your choice)
- the *ModelSim* installation path (use "/" as delimiter, both in Windows and in linux)

Additionally, this same script also allows selecting:
- the target board (choose one from the available targets in the `scripts/targets` folder)
- the desired clock frequency

## Running behavioral Simulation

TODO

## Implementing the design

TODO