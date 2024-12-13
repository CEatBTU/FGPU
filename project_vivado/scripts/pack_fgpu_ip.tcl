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

update_compile_order -fileset sources_1
ipx::add_user_parameter num_master_intf [ipx::current_core]
set_property value_resolve_type user [ipx::get_user_parameters num_master_intf -of_objects [ipx::current_core]]
ipgui::add_param -name {num_master_intf} -component [ipx::current_core]
set_property display_name {Number of Master Interfaces} [ipgui::get_guiparamspec -name "num_master_intf" -component [ipx::current_core] ]
set_property widget {radioGroup} [ipgui::get_guiparamspec -name "num_master_intf" -component [ipx::current_core] ]
set_property layout {vertical} [ipgui::get_guiparamspec -name "num_master_intf" -component [ipx::current_core] ]
set_property value 4 [ipx::get_user_parameters num_master_intf -of_objects [ipx::current_core]]
set_property value_format long [ipx::get_user_parameters num_master_intf -of_objects [ipx::current_core]]
set_property value_validation_type list [ipx::get_user_parameters num_master_intf -of_objects [ipx::current_core]]
set_property value_validation_list {1 2 4 8 16} [ipx::get_user_parameters num_master_intf -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) >= 2} [ipx::get_bus_interfaces m01 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) >= 4} [ipx::get_bus_interfaces m02 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) >= 4} [ipx::get_bus_interfaces m03 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) >= 8} [ipx::get_bus_interfaces m04 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) >= 8} [ipx::get_bus_interfaces m05 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) >= 8} [ipx::get_bus_interfaces m06 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) >= 8} [ipx::get_bus_interfaces m07 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) = 16} [ipx::get_bus_interfaces m08 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) = 16} [ipx::get_bus_interfaces m09 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) = 16} [ipx::get_bus_interfaces m10 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) = 16} [ipx::get_bus_interfaces m11 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) = 16} [ipx::get_bus_interfaces m12 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) = 16} [ipx::get_bus_interfaces m13 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) = 16} [ipx::get_bus_interfaces m14 -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('PARAM_VALUE.num_master_intf')) = 16} [ipx::get_bus_interfaces m15 -of_objects [ipx::current_core]]

#set the revision and be ready to pack
set_property NAME ${FGPU_IP_NAME} [ipx::current_core]
set_property DISPLAY_NAME ${FGPU_IP_DISPLAY_NAME} [ipx::current_core]
set_property VERSION ${FGPU_IP_VERSION} [ipx::current_core]
set_property DESCRIPTION ${FGPU_IP_DESCRIPTION} [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]

set_property supported_families {virtexuplus Beta virtexuplusHBM Beta} [ipx::current_core]

#pack the IP
ipx::save_core [ipx::current_core]

#delete temporal project
close_project -delete

#add the new IP to the IP's pository
set_property  ip_repo_paths ${path_fgpu_ip} [current_project]
update_ip_catalog

#clean temporal project
close_project -delete
file delete -force "${path_repository}/project_vivado/fgpu_ip_temp/"

puts "DONE!"
puts "FGPU IP generated successfully!"
puts "You can run now the implementation script!"
