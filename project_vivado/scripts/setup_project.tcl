##############################################################################
#
# setup_project.tcl
#
# Description: Sets up an initial project.
#
# Author: Hector Gerardo Munoz Hernandez <hector.munozhernandez@b-tu.de>
# Contributors:
#   - Marcelo Brandalero <marcelo.brandalero@b-tu.de>
#   - Mitko Veleski <mitko.veleski@b-tu.de>
# 
# Institution: Brandenburg University of Technology Cottbus-Senftenberg (B-TU)
# Date Created: 07.04.2020
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

# create a project if not already created
if {[file exists ${path_project}/${name_project}.xpr] == 0} {
	create_project -verbose ${name_project} ${path_project}
	puts "Creating project ..."
# if the project already exists, open it
} elseif {[catch {current_project} result]} {
	open_project -verbose ${path_project}/${name_project}
	puts "Opening project ..."
# if it exists and it is opened, do nothing
} else {
	puts "Project is already open."
}
puts "- Project Name: ${name_project}"
puts "- Project Path: ${path_project}"		

# set some project properties
set_property board_part ${board_part} [current_project]
set_property target_language VHDL [current_project]


set SIMULATION_MODE behavioral

if {${action} == "simulate"} {
    set_property default_lib work [current_project]
    set_property TARGET_SIMULATOR ModelSim [current_project]
	if {$SIMULATION_MODE != "behavioral"} {
		read_vhdl -verbose -library work -vhdl2008 ${postimp_sim_files}
		read_mem  -verbose ${mif_files}
	} else {
		read_vhdl -verbose -library work -vhdl2008 ${sim_files}
		read_vhdl -verbose -library work ${fpu_files}
		read_mem  -verbose ${mif_files}
	}
}

if {${action} == "generate_IP"} {
    read_vhdl -verbose  ${imp_files}
    read_mem  -verbose ${mif_files}
}

