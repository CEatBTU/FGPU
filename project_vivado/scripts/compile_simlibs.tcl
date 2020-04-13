##############################################################################
#
# compile_simlibs.tcl
#
# Description: Compiles the simulation libraries from Xilinx for ModelSim.
#
# Author: Mitko Veleski <mitko.veleski@b-tu.de>
# Contributors:
#   - Marcelo Brandalero <marcelo.brandalero@b-tu.de>
#   - Hector Gerardo Munoz Hernandez <hector.munozhernandez@b-tu.de>
# 
# Institution: Brandenburg University of Technology Cottbus-Senftenberg (B-TU)
# Date Created: 13.04.2020
#
# Tested Under:
#   - Vivado 2017.2
#
##############################################################################

set_property default_lib work [current_project]

# rename the default sim fileset
if {[get_filesets fgpu_sim] != "fgpu_sim"} {
	create_fileset -simset -clone_properties sim_1 fgpu_sim
}
current_fileset -simset fgpu_sim
if {[get_filesets sim_1] == "sim_1"} {
	delete_fileset sim_1
}

# set simulation properties
set_property TARGET_SIMULATOR ModelSim [current_project]
set_property top FGPU_tb [get_fileset fgpu_sim]
set_property top_file {$rtl_path/FGPU_tb.vhd} [current_fileset]

# compile vivado libraries for simulation (manually override the command to avoid the -novopt option)
puts "Compiling simulation libraries..."
config_compile_simlib -cfgopt {modelsim.vhdl.unisim: +acc -source} -simulator modelsim \
	-cfgopt {modelsim.vhdl.axi_bfm: +acc -source} \
	-cfgopt {modelsim.vhdl.ieee: +acc -source} \
	-cfgopt {modelsim.vhdl.std: +acc -source} \
	-cfgopt {modelsim.vhdl.simprim: +acc -source} \
	-cfgopt {modelsim.vhdl.vl: +acc -source} \
	-cfgopt {modelsim.verilog.unisim: +acc -source} \
	-cfgopt {modelsim.verilog.axi_bfm: +acc -source} \
	-cfgopt {modelsim.verilog.ieee: +acc -source} \
	-cfgopt {modelsim.verilog.std: +acc -source} \
	-cfgopt {modelsim.verilog.simprim: +acc -source} \
	-cfgopt {modelsim.verilog.vl: +acc -source}

# compile all libraries except secureip (its compilation will result in error due to -novopt option)
if {[file exists ${path_project}/${name_project}.cache/.cxl.modelsim.lin64.cmd] == 0} {
	compile_simlib -directory ${path_project}/${name_project}.cache/ -family zynq -library unisim -simulator modelsim -quiet
    # compile secureip library manually as -novopt option cannot be disabled for this library by using previous command

    if { ${OS} == "linux" } {
		exec ${path_modelsim}/vlog -source +acc -64 -work secureip -f ${path_project}/${name_project}.cache/secureip/.cxl.verilog.secureip.secureip.lin64.cmf
	} elseif { ${OS} == "windows" } {
		exec ${path_modelsim}/vlog -source +acc -64 -work secureip -f ${path_project}/${name_project}.cache/secureip/.cxl.verilog.secureip.secureip.nt64.cmf
	}
	puts "Done!"
}