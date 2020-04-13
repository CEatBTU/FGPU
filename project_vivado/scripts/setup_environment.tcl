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
########### These two lines must come on top and are used to determine #######
########### the absolute path where these scripts and the repository   #######
########### are located.                                               #######
##############################################################################

set path_tclscripts [file normalize "[info script]/../"]
set path_repository [file normalize "${path_tclscripts}/../../"]

##############################################################################
########### Modify the variables below according to your setup ###############
##############################################################################

set name_project "fgpu"
set path_project "${path_repository}/project_vivado/${name_project}"
set fgpu_ip_dir "${path_project}/${name_project}.ip_user_files/FGPU"

set target_board "ZC706"

set num_threads 8

set FREQ        100
set name_bd     "FGPU_bd"

set path_modelsim "C:/modeltech64_2020.1/win64"

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

set path_rtl "${path_repository}/RTL"

set vhdl_files [list \
	$path_rtl/FGPU_definitions.vhd \
	$path_rtl/lmem.vhd \
	$path_rtl/rd_cache_fifo.vhd \
	$path_rtl/CU_mem_cntrl.vhd \
	$path_rtl/DSP48E1.vhd \
	$path_rtl/mult_add_sub.vhd \
	$path_rtl/regFile.vhd \
	$path_rtl/ALU.vhd \
	$path_rtl/CV.vhd \
	$path_rtl/CU_instruction_dispatcher.vhd \
	$path_rtl/CU_scheduler.vhd \
	$path_rtl/RTM.vhd \
	$path_rtl/CU.vhd \
	$path_rtl/gmem_atomics.vhd \
	$path_rtl/gmem_cntrl_tag.vhd \
	$path_rtl/axi_controllers.vhd \
	$path_rtl/cache.vhd \
	$path_rtl/gmem_cntrl.vhd \
	$path_rtl/init_alu_en_ram.vhd \
	$path_rtl/loc_indcs_generator.vhd \
	$path_rtl/WG_dispatcher.vhd \
	$path_rtl/FGPU.vhd \
    $path_rtl/FGPU_v2_1.vhd]

set mif_files [list \
	$path_rtl/cram.mif \
	$path_rtl/krnl_ram.mif \
]

##############################################################################
############################ Commands ########################################
##############################################################################

source ${path_tclscripts}/targets/${target_board}/setup.tcl
