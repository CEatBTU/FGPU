
set action "simulate"

set path_thiscript [file normalize "[info script]/../"]
source "${path_thiscript}/setup_environment.tcl"
source "${path_tclscripts}/setup_project.tcl"
source "${path_tclscripts}/compile_simlibs.tcl"
source "${path_tclscripts}/sim_fgpu.tcl"