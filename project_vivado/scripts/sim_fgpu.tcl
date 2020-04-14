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

# rename the default sim fileset
if {[get_filesets fgpu_sim] != "fgpu_sim"} {
	create_fileset -simset -clone_properties sim_1 fgpu_sim
}

current_fileset -simset fgpu_sim
if {[get_filesets sim_1] == "sim_1"} {
	delete_fileset sim_1
}

# set simulation properties
set_property top FGPU_tb [get_fileset fgpu_sim]
set_property top_file "${path_rtl}/FGPU_tb.vhd" [current_fileset]
set_property file_type {VHDL 2008} [get_files *.vhd]

# Launching simulation
puts "Starting simulation..."
launch_simulation -mode behavioral -install_path ${path_modelsim}