############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2016 Xilinx, Inc. All Rights Reserved.
############################################################
open_project nbody_HLS_project
set_top nbody
add_files nbody_HLS_project/nbody.cpp
open_solution "solution2"
set_part {xc7z045ffg900-2}
create_clock -period 3 -name default
#source "./nbody_HLS_project/solution2/directives.tcl"
#csim_design
csynth_design
#cosim_design
export_design -format ip_catalog
