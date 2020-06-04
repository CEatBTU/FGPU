# Setting up the Vivado SW/HW Development Environment

First, you need to configure several parameters in the [project_vivado/scripts/setup_environment.tcl](project_vivado/scripts/setup_environment.tcl) file. In particular, **it is critical** to specify in this script:
- the operating system (windows or linux - that will impact some filenames used by these scripts)
- the *ModelSim* installation path, *if running the simulation flow*
- the project name (your choice)
- the project path (your choice)

For path delimiters, use "/" both in Windows and in linux.

Additionally, this same script also allows selecting:
- the target board (currently only the [Zynq-7000 ZC706] board is supported. future supported will be included in the [project_vivado/scripts/targets](project_vivado/scripts/targets) folder)
- the desired clock frequency

## Implementing the design

### Generating the HW Bitstream and Drivers

After setting up the environment, as described in the steps above, the first step consists of generating the bitstream and associated drivers that will configure the FPGA. We prove a set of scripts that already automate this flow. To run these, do the following:
- Launch `vivado` in either TCL console or GUI mode
- `source` the following script (if in TCL mode), or "Tools" -> "Run Tcl Script" (if in GUI mode) and select the following script: [main_implement.tcl](scripts/main_implement.tcl)

This script will generate a block diagram containing the FGPU along with the main processing system (ARM core) and accessory IPs. After that, synthesis and implementation will be run, and a bitstream will be generated.

Examples of pre-generated bitstreams (the output of this step) are provided in the [bitstreams folder](../bitstreams).

#### Known Issues

You may configure 'FGPU_definitions.vhd' according to your architecture needs. However, so far, the configurations that has proved to work with the given scripts are (from FGPU_definitions.vhd): atomic implementation set to '1' , sub_integer implementation either to '0' or to '1', Number of CUs equal to 1, and floating point implementation set to '0'.  The support team is working on making other configurations compatible with the scripts and flow.

### Writing your own FPGU application

The previous step generates the bistream. Now we need to write an application we want to run in FGPU, and set up the flow so that this application can be loaded to the FGPU at run time and executed.

To do so, follow these steps:
- Wait for the bitstream to be ready and export the Hardware to Vivado SDK. 
- Launch Vivado SDK and create a new blank C++ application project.
- Copy all the files from a benchmark's source folder to the application project's directory. 
- Verify that the heap size is at least '0x8000000'
- If you want to run another application, you must compile your OpenCL application using the provided LLVM compiler. *
- Follow any benchmark's directory structure and conventions for adapting your own application. Using a benchmark as a template is highly recommended.
- Clean, build, and run.

Examples of pre-generated applications (the output of this step) are provided in the [benchmarks folder](../benchmark).

* To compile openCL kernels, the user is encouraged to view the [FGPU_compiler](https://github.com/CEatBTU/FGPU_Compiler.git) repository which already has a docker instance to build / download an image which has already the LLVM compiler built and ready to use.

## Running behavioral Simulation

The simulation was tested under Modelsim and all the provided testbenches have been verified as successful except for _Floyd Warshall_, _sobel_, and _median_. 

A quick start would be:
1. Adapt the scripts to point to your paths regarding the Vivado installation. Also you might need to select your operating system from within the scripts as well.
2. Run successfully the provided scripts targeting the simulation. 
3. Select desired benchmark from the options given in 'FGPU_simulation_pkg.vhd'
4. Run the simulation.

### Known Issues

For some of the benchmarks to run successfully like 'max_half_atomic' one must also change the configuration of the FGPU in 'FGPU_definitions.vhd' to implement the atomic operations.   The most common configurations to change when the benchmark is not working are: 'atomic_implement', floating point implement', 'sub_integer implement', and 'number of CUs'.

For simulating a new application, we are currently developing a new tutorial.
