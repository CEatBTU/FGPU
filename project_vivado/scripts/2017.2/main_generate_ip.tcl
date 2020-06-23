# change the paths to project and RTL files !

# *** NOTE: For the "implement" to work, "generate_IP" must be run before to have a version of the FGPU IP in the system. ***

set action "generate_IP"
set path_thiscript [file normalize "[info script]/../"]
source "${path_thiscript}/setup_environment.tcl"
source "${path_tclscripts}/setup_project.tcl"
source "${path_tclscripts}/pack_fgpu_ip.tcl"

