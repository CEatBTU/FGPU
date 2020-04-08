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

set_property top FGPU_v2_1 [current_fileset]

#launch ip packager to pack the current project
ipx::package_project -root_dir ${fgpu_ip_dir} -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false
ipx::unload_core IPs/component.xml

#set a temporary project for the IP packing and pack automatically
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory ${fgpu_ip_dir} ${fgpu_ip_dir}/component.xml

#set the revision and be ready to pack
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]

#pack the IP
ipx::save_core [ipx::current_core]

#delete temporal project
close_project -delete

#add the new IP to the IP's pository
set_property  ip_repo_paths ${fgpu_ip_dir} [current_project]
update_ip_catalog
