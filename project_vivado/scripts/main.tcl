# change the paths to project and RTL files !

# Choose between "implement" and "simulate"
set action "implement"
#set action "simulate"

set path_thiscript [file normalize "[info script]/../"]
source "${path_thiscript}/setup_environment.tcl"
source "${path_tclscripts}/setup_project.tcl"

if {${action} == "simulate"} {
	source "${path_tclscripts}/compile_simlibs.tcl"
	source "${path_tclscripts}/sim_fgpu.tcl"
}

if {${action} == "implement"} {
	source "${path_tclscripts}/pack_fgpu_ip.tcl"
	source "${path_tclscripts}/create_bd.tcl"
	source "${path_tclscripts}/implement_fgpu.tcl"
}