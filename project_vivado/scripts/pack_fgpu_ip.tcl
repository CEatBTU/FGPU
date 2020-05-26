##############################################################################
#
# pack_FGPU_ip.tcl
#
# Description: Generates an IP block for the FGPU.
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

set_property top FGPU_v2_1 [current_fileset]
#set_property file_type {VHDL} [get_files *.vhd]
puts "Project files set to VHDL (no-2008) to make the IP packager happy."

#launch ip packager to pack the current project
ipx::package_project -root_dir ${path_fgpu_ip} -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false
ipx::unload_core ${path_fgpu_ip}/component.xml

#set a temporary project for the IP packing and pack automatically
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory ${path_fgpu_ip} ${path_fgpu_ip}/component.xml

#set the revision and be ready to pack
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]

#pack the IP
ipx::save_core [ipx::current_core]

#delete temporal project
close_project -delete

#add the new IP to the IP's pository
set_property  ip_repo_paths ${path_fgpu_ip} [current_project]
update_ip_catalog

#clean flag for being able to implement direclty
#set set_up_fgpu_environment false
unset set_up_fgpu_environment

#clean temporal project
close_project -delete
file delete -force "${path_repository}/project_vivado/fgpu_ip_temp/"

puts "DONE!"
puts "FGPU IP generated successfully!"
puts "You can run now the implementation script!"
