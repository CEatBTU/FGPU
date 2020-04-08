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
########### Modify the variables below according to your setup ###############
##############################################################################

set project_name FGPU_Vivado

set target_board ZC706

set num_threads 8

set fgpu_ip_dir ./FGPU_IP

set FREQ        100
set bd_name     "FGPU_bd"


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

set rtl_path ../RTL

set vhdl_files [list \
	$rtl_path/FGPU_definitions.vhd \
	$rtl_path/lmem.vhd \
	$rtl_path/rd_cache_fifo.vhd \
	$rtl_path/CU_mem_cntrl.vhd \
	$rtl_path/DSP48E1.vhd \
	$rtl_path/mult_add_sub.vhd \
	$rtl_path/regFile.vhd \
	$rtl_path/ALU.vhd \
	$rtl_path/CV.vhd \
	$rtl_path/CU_instruction_dispatcher.vhd \
	$rtl_path/CU_scheduler.vhd \
	$rtl_path/RTM.vhd \
	$rtl_path/CU.vhd \
	$rtl_path/gmem_atomics.vhd \
	$rtl_path/gmem_cntrl_tag.vhd \
	$rtl_path/axi_controllers.vhd \
	$rtl_path/cache.vhd \
	$rtl_path/gmem_cntrl.vhd \
	$rtl_path/init_alu_en_ram.vhd \
	$rtl_path/loc_indcs_generator.vhd \
	$rtl_path/WG_dispatcher.vhd \
	$rtl_path/FGPU.vhd \
    $rtl_path/FGPU_v2_1.vhd]

set mif_files [list \
	$rtl_path/cram.mif \
	$rtl_path/krnl_ram.mif \
]

##############################################################################
############################ Commands ########################################
##############################################################################

source targets/${target_board}/setup.tcl
