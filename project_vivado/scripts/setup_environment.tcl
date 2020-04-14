##############################################################################
#
# setup_environment.tcl
#
# Description: Root script that sets up environment variables and target.
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





##############################################################################
########################## BEGIN DON'T TOUCH #################################
##############################################################################

# Guard clause to prevent this script from running twice
if ([info exists set_up_fgpu_environment]) {
	puts "File [file tail [info script]] has already been sourced."
	puts "To enable re-sourcing, run \"unset set_up_fgpu_environment\"."
	return
}

# These two lines must come on top and are used to determine the absolute 
# path where these scripts and the repository are located.
set path_tclscripts [file normalize "[info script]/../"]
set path_repository [file normalize "${path_tclscripts}/../../"]

##############################################################################
############################ END DON'T TOUCH #################################
##############################################################################





##############################################################################
########### Modify the variables below according to your setup ###############
##############################################################################

# Choose one
#set OS "linux"
set OS "windows"

set name_project "fgpu"
set path_project "${path_repository}/project_vivado/${name_project}"

# PATH to the ModelSim installation. Will look like this in Windows:
set path_modelsim "C:/modeltech64_2020.1/win64"
# and like this in linux:
# set path_modelsim "/opt/pkg/modelsim-2020.1/modeltech/linux_x86_64"

# The number of threads with which to run simulation, synthesis and impl.
set num_threads 8




# Set the target board
set target_board "ZC706"
# The target frequency for implementation
set FREQ        100



##############################################################################
### These variables below will likely be impacted by the version of Vivado ###
##############################################################################

# IP Versions
set ip_ps_ver "5.5"

# For Vivado 2017.3
# set ip_clk_wiz_ver "5.4"
# For Vivado 2018.3
set ip_clk_wiz_v "5.4"




##############################################################################
########### Variables below "should" not require modification ################
##############################################################################

set name_bd     "FGPU_bd"

set path_fgpu_ip       "${path_project}/${name_project}.ip_user_files/FGPU"
set path_modelsim_libs "${path_project}/${name_project}.cache/compile_simlib/modelsim"

set path_rtl "${path_repository}/RTL"
set path_fpu "${path_rtl}/floating_point"

set files_vhdl [list \
	${path_rtl}/FGPU_definitions.vhd \
	${path_rtl}/lmem.vhd \
	${path_rtl}/rd_cache_fifo.vhd \
	${path_rtl}/CU_mem_cntrl.vhd \
	${path_rtl}/DSP48E1.vhd \
	${path_rtl}/mult_add_sub.vhd \
	${path_rtl}/regFile.vhd \
	${path_rtl}/ALU.vhd \
	${path_rtl}/CV.vhd \
	${path_rtl}/CU_instruction_dispatcher.vhd \
	${path_rtl}/CU_scheduler.vhd \
	${path_rtl}/RTM.vhd \
	${path_rtl}/CU.vhd \
    ${path_rtl}/FGPU_simulation_pkg.vhd \
	${path_rtl}/global_mem.vhd \
	${path_rtl}/gmem_atomics.vhd \
	${path_rtl}/gmem_cntrl_tag.vhd \
	${path_rtl}/axi_controllers.vhd \
	${path_rtl}/cache.vhd \
	${path_rtl}/gmem_cntrl.vhd \
	${path_rtl}/init_alu_en_ram.vhd \
	${path_rtl}/loc_indcs_generator.vhd \
	${path_rtl}/WG_dispatcher.vhd \
	${path_rtl}/FGPU.vhd \
    ${path_rtl}/FGPU_v2_1.vhd \
    ${path_rtl}/FGPU_tb.vhd]

set files_mif [list \
	${path_rtl}/cram.mif \
	${path_rtl}/krnl_ram.mif]

set files_fpu [list \
	${path_fpu}/xbip_utils_v3_0_6/hdl/xbip_utils_v3_0_vh_rfs.vhd \
	${path_fpu}/axi_utils_v2_0_2/hdl/axi_utils_v2_0_vh_rfs.vhd \
	${path_fpu}/xbip_pipe_v3_0_2/hdl/xbip_pipe_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_pipe_v3_0_2/hdl/xbip_pipe_v3_0.vhd \
	${path_fpu}/mult_gen_v12_0_11/hdl/mult_gen_v12_0_vh_rfs.vhd \
	${path_fpu}/mult_gen_v12_0_11/hdl/mult_gen_v12_0.vhd \
	${path_fpu}/xbip_bram18k_v3_0_2/hdl/xbip_bram18k_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_bram18k_v3_0_2/hdl/xbip_bram18k_v3_0.vhd \
	${path_fpu}/xbip_dsp48_wrapper_v3_0_4/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_dsp48_addsub_v3_0_2/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_dsp48_addsub_v3_0_2/hdl/xbip_dsp48_addsub_v3_0.vhd \
	${path_fpu}/xbip_dsp48_multadd_v3_0_2/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_dsp48_multadd_v3_0_2/hdl/xbip_dsp48_multadd_v3_0.vhd \
	${path_fpu}/floating_point_v7_1_2/hdl/floating_point_v7_1_vh_rfs.vhd]

##############################################################################
############################ Commands ########################################
##############################################################################

source ${path_tclscripts}/targets/${target_board}/setup.tcl

# Changes to the project directory if it already exists
if {[file exists ${path_project}] != 0} {
	cd ${path_project}
}

set set_up_fgpu_environment true