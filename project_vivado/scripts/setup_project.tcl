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

# create a project if there isn't one already
if {[file exists ${path_project}/${name_project}.xpr] == 0} {
	create_project -verbose ${name_project} ${path_project}
}

set_property board_part ${board_part} [current_project]
set_property target_language VHDL [current_project]

#read the files in normal VHDL mode
read_vhdl -verbose $vhdl_files 

#read the memory files
read_mem  -verbose $mif_files
