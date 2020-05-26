##############################################################################
#
# sim_fgpu.tcl
#
# Description: Simulates the FGPU design.
#
# Author: Mitko Veleski <mitko.veleski@b-tu.de>
# Contributors:
#   - Marcelo Brandalero <marcelo.brandalero@b-tu.de>
#   - Hector Gerardo Munoz Hernandez <hector.munozhernandez@b-tu.de>
# 
# Institution: Brandenburg University of Technology Cottbus-Senftenberg (B-TU)
# Date Created: 14.04.2020
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
# Setting simulation properties
if {$SIMULATION_MODE != "behavioral"} {
	if {[get_filesets "fgpu_sim"] ne "fgpu_sim"} {
		create_fileset -simset fgpu_sim
	} else {
		add_files -fileset fgpu_sim  $postimp_sim_files
		current_fileset -simset fgpu_sim
		set_property top FGPU_tb [get_filesets fgpu_sim]
		set_property top_file "${path_rtl}/FGPU_tb.vhd" [get_filesets fgpu_sim]
		set_property file_type {VHDL 2008} [get_filesets fgpu_sim]
	}}	else { 
	current_fileset -simset sim_1
	set_property top FGPU_tb [get_filesets sim_1]
	set_property top_file "${path_rtl}/FGPU_tb.vhd" [get_filesets sim_1]
	set_property file_type {VHDL 2008} [get_filesets sim_1]
	}

# Launching simulation
puts "Starting simulation..."
if {$SIMULATION_MODE != "behavioral"} {
	launch_simulation -mode $SIMULATION_MODE -type timing -simset fgpu_sim -install_path ${path_modelsim}
} else {
	launch_simulation -mode $SIMULATION_MODE -simset sim_1 -install_path ${path_modelsim}
}