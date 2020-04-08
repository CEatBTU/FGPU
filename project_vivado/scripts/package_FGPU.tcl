
set_property top FGPU_v2_1 [current_fileset]

#launch ip packager to pack the current project
ipx::package_project -root_dir IPs -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false
ipx::unload_core IPs/component.xml

#set a temporary project for the IP packing and pack automatically
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory IPs IPs/component.xml

#set the revision and be ready to pack
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]

#pack the IP
ipx::save_core [ipx::current_core]

#delete temporal project
close_project -delete

#add the new IP to the IP's pository
set_property  ip_repo_paths  IPs [current_project]
update_ip_catalog
