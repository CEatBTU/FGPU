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

# Guard clause to ensure everything is properly set up
if (![info exists set_up_fgpu_environment]) {
	puts "\[ERROR\] You must first source the setup_environment.tcl script."
	return
}

# compile vivado libraries for simulation (manually override the command to avoid the -novopt option)
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

if { ${OS} == "linux" && [file exists ${path_modelsim_libs}/.cxl.modelsim.lin64.cmd]} {
	puts "ModelSim simulation libraries already available in \"${path_modelsim_libs}\"."
	return
} elseif { ${OS} == "windows" && [file exists ${path_modelsim_libs}/.cxl.modelsim.nt64.cmd]} {
	puts "ModelSim simulation libraries already available in \"${path_modelsim_libs}\"."
	return
}

if {[file exists ${path_modelsim_libs}/.cxl.modelsim.lin64.cmd] == 0} {
	puts "Compiling simulation libraries for ModelSim..."
	puts "This may take a while..."
	
	# compile all libraries except secureip (its compilation will result in error due to -novopt option) 
	# hence, we use the catch statement to prevent the error from blocking the further evaluation of this script
	catch { compile_simlib -directory ${path_modelsim_libs} -family zynq -library unisim -simulator modelsim -simulator_exec_path ${path_modelsim} }
	catch { compile_simlib -directory ${path_modelsim_libs} -family zynq -library simprim -simulator modelsim -simulator_exec_path ${path_modelsim}}
	puts "It is possible that compile_simlib failed to compile for modelsim with 1 errors."
	puts "If that is the case, don't worry: we will compile the secureip library manually now."

	# as said, "secureip" lib will fail and must be manually compiled:
    if { ${OS} == "linux" } {
		exec ${path_modelsim}/vlog -source +acc -64 -work secureip -f ${path_modelsim_libs}/secureip/.cxl.verilog.secureip.secureip.lin64.cmf
	} elseif { ${OS} == "windows" } {
		exec ${path_modelsim}/vlog -source +acc -64 -work secureip -f ${path_modelsim_libs}/secureip/.cxl.verilog.secureip.secureip.nt64.cmf
	}
	puts "Done!"
}