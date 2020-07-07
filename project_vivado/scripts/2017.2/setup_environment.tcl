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
set path_repository [file normalize "${path_tclscripts}/../../../"]
cd "${path_repository}/project_vivado"

##############################################################################
############################ END DON'T TOUCH #################################
##############################################################################


##############################################################################
########### Modify the variables below according to your setup ###############
##############################################################################

# Choose one
set OS "linux"
#set OS "windows"

################################################################################
######                  Do not edit the fgpu_ip name                       #####
######You may only change the name of the project inside the else statement#####
################################################################################
if {${action} == "generate_IP"} {
    set name_project "fgpu_ip_temp"
} else {
    set name_project "fgpu_sys"
}


set path_project "${path_repository}/project_vivado/${name_project}"

# PATH to the ModelSim installation. Will look like this in Windows:
#set path_modelsim "C:/modeltech64_2020.1/win64"
# and like this in linux:
set path_modelsim "/opt/pkg/modelsim-2020.1/modeltech/linux_x86_64"

# The number of threads with which to run simulation, synthesis and impl.
set num_threads 4

# Set the target board
set target_board "ZedBoard"
# The target frequency for implementation
set FREQ        120

##############################################################################
### These variables below will likely be impacted by the version of Vivado ###
##############################################################################

# IP Versions
set ip_ps_ver "5.5"

# For Vivado 2017.3
set ip_clk_wiz_v "5.4"
# For Vivado 2018.3+
#set ip_clk_wiz_v "5.4"
# For Vivado 2019.2
# set ip_clk_wiz_v "6.0"

##############################################################################
###########                  FGPU IP Parameters               ################
##############################################################################

set FGPU_IP_NAME "FGPU"
set FGPU_IP_VERSION "2.1"
set FGPU_IP_DISPLAY_NAME "FGPU_v2_1"
set FGPU_IP_DESCRIPTION "FGPU version 2.1."

##############################################################################
########### Variables below "should" not require modification ################
##############################################################################

set name_bd     "FGPU_bd"

#set path_fgpu_ip       "${path_repository}/project_vivado/FGPU_2.1"
set path_fgpu_ip       "${path_repository}/project_vivado/fgpu_ip"

set path_modelsim_libs "${path_project}/${name_project}.cache/compile_simlib/modelsim"

set path_rtl "${path_repository}/RTL"
set path_fpu "${path_rtl}/floating_point"

set sim_files [list \
	${path_rtl}/FGPU_definitions.vhd \
	${path_rtl}/lmem.vhd \
	${path_rtl}/rd_cache_fifo.vhd \
	${path_rtl}/CU_mem_cntrl.vhd \
	${path_rtl}/DSP48E1.vhd \
	${path_rtl}/mult_add_sub.vhd \
	${path_rtl}/regFile.vhd \
	${path_rtl}/ALU.vhd \
	${path_rtl}/float_units.vhd \
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

set mif_files [list \
	${path_rtl}/cram.mif \
	${path_rtl}/krnl_ram.mif]

set fpu_files [list \
	${path_fpu}/fadd_fsub.vhd \
	${path_fpu}/fdiv.vhd \
	${path_fpu}/fmul.vhd \
	${path_fpu}/fsqrt.vhd \
	${path_fpu}/frsqrt.vhd \
	${path_fpu}/fslt.vhd \
	${path_fpu}/fsqrt.vhd \
	${path_fpu}/uitofp.vhd \
	\
	${path_fpu}/xbip_utils_v3_0_7/hdl/xbip_utils_v3_0_vh_rfs.vhd \
	${path_fpu}/axi_utils_v2_0_3/hdl/axi_utils_v2_0_vh_rfs.vhd \
	${path_fpu}/xbip_pipe_v3_0_3/hdl/xbip_pipe_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_pipe_v3_0_3/hdl/xbip_pipe_v3_0.vhd \
	${path_fpu}/mult_gen_v12_0_12/hdl/mult_gen_v12_0_vh_rfs.vhd \
	${path_fpu}/mult_gen_v12_0_12/hdl/mult_gen_v12_0.vhd \
	${path_fpu}/xbip_bram18k_v3_0_3/hdl/xbip_bram18k_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_bram18k_v3_0_3/hdl/xbip_bram18k_v3_0.vhd \
	${path_fpu}/xbip_dsp48_wrapper_v3_0_4/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_dsp48_addsub_v3_0_3/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_dsp48_addsub_v3_0_3/hdl/xbip_dsp48_addsub_v3_0.vhd \
	${path_fpu}/xbip_dsp48_multadd_v3_0_3/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd \
	${path_fpu}/xbip_dsp48_multadd_v3_0_3/hdl/xbip_dsp48_multadd_v3_0.vhd \
	${path_fpu}/floating_point_v7_1_4/hdl/floating_point_v7_1_vh_rfs.vhd]

set imp_files [list \
    ${path_rtl}/FGPU_definitions.vhd \
	${path_rtl}/lmem.vhd \
	${path_rtl}/rd_cache_fifo.vhd \
	${path_rtl}/CU_mem_cntrl.vhd \
	${path_rtl}/DSP48E1.vhd \
	${path_rtl}/mult_add_sub.vhd \
	${path_rtl}/regFile.vhd \
	${path_rtl}/ALU.vhd \
    ${path_fpu}/fadd_fsub.vhd \
	${path_fpu}/fdiv.vhd \
	${path_fpu}/fmul.vhd \
	${path_fpu}/fsqrt.vhd \
	${path_fpu}/frsqrt.vhd \
	${path_fpu}/fslt.vhd \
	${path_fpu}/fsqrt.vhd \
	${path_fpu}/uitofp.vhd \
	${path_rtl}/float_units.vhd \
	${path_rtl}/CV.vhd \
	${path_rtl}/CU_instruction_dispatcher.vhd \
	${path_rtl}/CU_scheduler.vhd \
	${path_rtl}/RTM.vhd \
	${path_rtl}/CU.vhd \
	${path_rtl}/gmem_atomics.vhd \
	${path_rtl}/gmem_cntrl_tag.vhd \
	${path_rtl}/axi_controllers.vhd \
	${path_rtl}/cache.vhd \
	${path_rtl}/gmem_cntrl.vhd \
	${path_rtl}/init_alu_en_ram.vhd \
	${path_rtl}/loc_indcs_generator.vhd \
	${path_rtl}/WG_dispatcher.vhd \
	${path_rtl}/FGPU.vhd \
    ${path_rtl}/FGPU_v2_1.vhd]
	
set postimp_sim_files [list \
	$path_rtl/FGPU_definitions.vhd \
	$path_rtl/FGPU_simulation_pkg.vhd \
    $path_rtl/global_mem.vhd \
    $path_rtl/FGPU_tb.vhd \
    $path_rtl/cram.mif \
    $path_rtl/krnl_ram.mif]
	
##############################################################################
############################ Commands ########################################
##############################################################################

source ${path_tclscripts}/targets/${target_board}/setup.tcl

# Changes to the project directory if it already exists
if {[file exists ${path_project}] != 0} {
	cd ${path_project}
}

set set_up_fgpu_environment true

