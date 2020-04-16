# change the paths to project and RTL files !

# Choose between "simulate", "generate IP of the FGPU", and "implement"
# NOTE: For the "implement" to work, "generate_IP" must be run at least once before to have 
# a version of the FGPU IP in the system. 

set action "implement"
#set action "generate_IP"
#set action "simulate"

set path_thiscript [file normalize "[info script]/../"]
source "${path_thiscript}/setup_environment.tcl"
source "${path_tclscripts}/setup_project.tcl"

if {${action} == "simulate"} {
	source "${path_tclscripts}/compile_simlibs.tcl"
	source "${path_tclscripts}/sim_fgpu.tcl"
}

if {${action} == "generate_IP"} {
	source "${path_tclscripts}/pack_fgpu_ip.tcl"
}

if {${action} == "implement"} {
	source "${path_tclscripts}/create_bd.tcl"
	source "${path_tclscripts}/implement_fgpu.tcl"
}
