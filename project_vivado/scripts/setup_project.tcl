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

if {[file exists ${path_project}/${name_project}.xpr] == 0} {
	create_project -verbose ${name_project} ${path_project}
	puts "Creating project ..."
} elseif {[catch {current_project} result]} {
	open_project -verbose ${path_project}/${name_project}
	puts "Opening project ..."
# if it exists and it is opened, do nothing
} else {
	puts "Project is already open."
	#close_project
	#open_project -verbose ${path_project}/${name_project}
}
puts "- Project Name: ${name_project}"
puts "- Project Path: ${path_project}"		

set_property board_part ${board_part} [current_project]
set_property target_language VHDL [current_project]

if {${action} == "simulate"} {
    set_property default_lib work [current_project]
    set_property TARGET_SIMULATOR ModelSim [current_project]

    #read the files in normal VHDL mode
    read_vhdl -verbose -library work -vhdl2008 ${files_vhdl}
    read_vhdl -verbose -library work -vhdl2008 ${files_fpu}

    #read the memory files
    read_mem  -verbose ${files_mif}
}

if {${action} == "generate_IP"} {
    #read the files in normal VHDL mode
    read_vhdl -verbose  ${vhdl_files}

    #read the memory files
    read_mem  -verbose ${files_mif}
}

