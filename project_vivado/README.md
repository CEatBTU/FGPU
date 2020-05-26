# FGPU quick start
Thank you for your interest in the FGPU, the support team in Brandenburg University of Technology Cottbus-Senftenberg has worked hard to make the FGPU accessible to new users, which is the motivation behind this initiative.

## Files
When getting the FGPU, you will get the following:

- LLVM compiler for OpenCL applications.
- FGPU RTL sources.
- Scripts for automating the simulation of the FGPU.
- A set of benchmarks ready to be simulated.
- Scripts for automating the implementation of the FGPU targeting the Xilinx ZC706 (no other boards are compatible at the moment).
- A set of pre-generated bitstreams to test right away.
- A set of kernels that can be used as templates to write your own openCL applications.
- A set of benchmarks to test the FGPU, that can be used as templates for new applications.


## What was tested

### Simulation
The simulation was tested under Modelsim and all the provided testbenches have been verified as successful except for _Floyd Warshall_, _sobel_, and _median_. 
A quick start would be:
1. Adapt the scripts to point to your paths regarding the Vivado installation. Also you might need to select your operating system from within the scripts as well.
2. Run successfully the provided scripts targeting the simulation. 
3. Select desired benchmark from the options given in 'FGPU_simulation_pkg.vhd'
4. Run the simulation.

NOTE: For some of the benchmarks to run successfully like 'max_half_atomic' one must also change the configuration of the FGPU in 'FGPU_definitions.vhd' to implement the atomic operations.   The most common configurations to change when the benchmark is not working are: 'atomic_implement', floating point implement', 'sub_integer implement', and 'number of CUs'.

For simulating a new application please refer to the corresponding tutorial.

### Implementation
The implementation was only tested and the scripts only work for the board _Xilinx ZC706_. The support team is working on porting the FGPU to another platform like the _Zedboard_ or _PYNQ Z2_ for example, but there are no fixed dates for this release.

1. Configure 'FGPU_definitions.vhd' according to your architecture needs. 
2. If not done before, modify the paths and Operating System indicated in the scripts.
3. Run the provided script targeting the implementation from inside a Vivado TCL command line.
4. Wait for the bitstream to be ready and export the Hardware to Vivado SDK. 
5. Launch Vivado SDK and create a new blank C++ application project.
6. Copy all the files from a benchmark 'src' folder to the application project's directory. 
7. Verify that the heap size is at least '0x8000000'
8. If you want to run another application, you must compile your OpenCL application using the provided LLVM compiler.
9. Follow any benchmark's directory structure and conventions for adapting your own application. Using a benchmark as a template is highly recommended.
10. Clean, build, and run.

NOTE: so far, the configurations that has proved to work with the given scripts are (from FGPU_definitions.vhd): atomic implementation set to '1' , sub_integer implementation either to '0' or to '1', Number of CUs equal to 1, and floating point implementation set to '0'.  The support team is working on making other configurations compatible with the scripts and flow.
