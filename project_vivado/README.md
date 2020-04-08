# Vivado Project Folder

The files inside the `scripts/` directory to set everything up.

## Instructions

1. `cd` into *this* directory and run Vivado from here. Alternatively, launch Vivado and change the directory to this one by using the Tcl Console.
2. Call the scripts inside the `script/` folder from inside vivado by executing the following commands, in the following order:
  1. `source scripts/setup_environment.tcl`. This will set up some project variables.
  2. `source scripts/setup_project.tcl`. This will create the project.
  3. `source scripts/pack_fgpu_ip.tcl`. This will turn FGPU into an IP package.
  4. `source scripts/create_bd.tcl`. This will create a block diagram containing the FGPU, the Processing System, the AXI interconnects, the clock generator and so on.
  5. `source scripts/synthesize.tcl`. This will synthesize the FGPU.