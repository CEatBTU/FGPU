##############################################################################
#
# create_bd.tcl
#
# Description: Creates the block diagram and sets up all component connections.
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
#   - Vivado 2018.3
#
##############################################################################

#Copy FGPU_definitions from RTL folder to the FGPU IP hdl
file copy -force ${path_repository}/RTL/db/fgpu_definitions_pkg.vhd ${path_fgpu_ip}/hdl/

# Guard clause to ensure everything is properly set up
if (![info exists set_up_fgpu_environment]) {
  puts "\[ERROR\] You must first source the setup_environment.tcl script."
  return
}
# if BD not already created
if {[file exists $path_project/${name_project}.srcs/sources_1/bd/$name_bd/${name_bd}.bd]} {
	open_bd_design $path_project/${name_project}.srcs/sources_1/bd/$name_bd/${name_bd}.bd
} else {
# create a new block design 
	create_bd_design $name_bd
}

#set IP repository to point to the FGPU's IP location
set_property ip_repo_paths ${path_fgpu_ip} [current_project]
update_ip_catalog

# if BD cells not already created
if {[get_bd_cells] == ""} {
#add a ZYNQ PS
	create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:${ip_ps_ver} \
		processing_system7_0
#add the FGPU block
	create_bd_cell -type ip -vlnv user.org:user:${FGPU_IP_NAME}:${FGPU_IP_VERSION} FGPU_0
#add a clock wizzard
	create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:${ip_clk_wiz_v} \
		clk_wiz_0
}


#set properties for the clock wizard (frequency)
set_property -dict [list CONFIG.USE_PHASE_ALIGNMENT {false} \
                         CONFIG.CLKOUT1_REQUESTED_OUT_FREQ  ${FREQ}.0 \
                         CONFIG.USE_LOCKED {false} \
                         CONFIG.USE_RESET {false} \
                         CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin}] \
					[get_bd_cells clk_wiz_0]

#apply automation for the current blocks (clk_wizzard, ZYNQ PS, and FGPU); connect their clk ports, etc.
apply_bd_automation \
    -rule xilinx.com:bd_rule:processing_system7 \
    -config { \
                  make_external "FIXED_IO, DDR" \
                  apply_board_preset "0" \
                  Master "Disable" \
                  Slave "Disable" \
              } \
    [get_bd_cells processing_system7_0]

#configure the ZYNQ PS to have the presets of the board
set_property -dict [list CONFIG.preset ${target_board}] \
    [get_bd_cells processing_system7_0]

#abilitate ZYNQs High Performance ports 0 through 3
set_property -dict [list \
                        CONFIG.PCW_USE_S_AXI_HP0 {1} \
                        CONFIG.PCW_USE_S_AXI_HP1 {1} \
                        CONFIG.PCW_USE_S_AXI_HP2 {1} \
                        CONFIG.PCW_USE_S_AXI_HP3 {1} \
                        CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0}] \
    [get_bd_cells processing_system7_0]

#apply block diagram automation (connect ports of the ZYNQ PS)
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {\
Master "/FGPU_0/m0" Clk "/clk_wiz_0/clk_out1 ($FREQ MHz)" \
} [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {\
Master "/FGPU_0/m1" Clk "/clk_wiz_0/clk_out1 ($FREQ MHz)" \
} [get_bd_intf_pins processing_system7_0/S_AXI_HP1]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
Master "/FGPU_0/m2" Clk "/clk_wiz_0/clk_out1 ($FREQ MHz)" \
}  [get_bd_intf_pins processing_system7_0/S_AXI_HP2]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
Master "/FGPU_0/m3" Clk "/clk_wiz_0/clk_out1 ($FREQ MHz)" \
} [get_bd_intf_pins processing_system7_0/S_AXI_HP3]
save_bd_design

connect_bd_net [get_bd_pins FGPU_0/axi_clk] [get_bd_pins clk_wiz_0/clk_out1]
connect_bd_net [get_bd_pins FGPU_0/axi_aresetn] [get_bd_pins rst_clk_wiz_0_${FREQ}M/peripheral_aresetn]
save_bd_design

#apply block diagram automation (connect ports of the slave interface of FGPU)
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
Master "/processing_system7_0/M_AXI_GP0" Clk "/clk_wiz_0/clk_out1 ($FREQ MHz)" \
} [get_bd_intf_pins FGPU_0/s]

# if not already connected
if {[string first "FCLK_RESET0_N" [get_bd_nets]] || [string first "FCLK_CLK0" [get_bd_nets]]} {
#connect remaining reset ports
	connect_bd_net \
		[get_bd_pins processing_system7_0/FCLK_RESET0_N] \
		[get_bd_pins rst_clk_wiz_0_$FREQ\M/ext_reset_in]
#connect remaining clock ports 
	connect_bd_net \
		[get_bd_pins processing_system7_0/FCLK_CLK0] \
		[get_bd_pins clk_wiz_0/clk_in1]
}

#set memory address of the FGPU interfaces to be of 1GB
if {${target_board} == "ZedBoard"} {
    set_property range 512M [get_bd_addr_segs {FGPU_0/m0/SEG_processing_system7_0_HP0_DDR_LOWOCM}]
    set_property range 512M [get_bd_addr_segs {FGPU_0/m1/SEG_processing_system7_0_HP1_DDR_LOWOCM}]
    set_property range 512M [get_bd_addr_segs {FGPU_0/m2/SEG_processing_system7_0_HP2_DDR_LOWOCM}]
    set_property range 512M [get_bd_addr_segs {FGPU_0/m3/SEG_processing_system7_0_HP3_DDR_LOWOCM}]
} else {
    set_property range 1G [get_bd_addr_segs {FGPU_0/m0/SEG_processing_system7_0_HP0_DDR_LOWOCM}]
    set_property range 1G [get_bd_addr_segs {FGPU_0/m1/SEG_processing_system7_0_HP1_DDR_LOWOCM}]
    set_property range 1G [get_bd_addr_segs {FGPU_0/m2/SEG_processing_system7_0_HP2_DDR_LOWOCM}]
    set_property range 1G [get_bd_addr_segs {FGPU_0/m3/SEG_processing_system7_0_HP3_DDR_LOWOCM}]
}
save_bd_design

update_compile_order -fileset sources_1
#Set manually the frequency of s and m0 of the FGPU to the chosen Frequency (Explanation: As one design decision was to disconnect m0 and s 's clock from the main FGPU clk signal, the values are no longer automatically propagated. 
set_property CONFIG.FREQ_HZ ${FREQ}000000 [get_bd_intf_pins /FGPU_0/m0]
set_property CONFIG.FREQ_HZ ${FREQ}000000 [get_bd_intf_pins /FGPU_0/m1]
set_property CONFIG.FREQ_HZ ${FREQ}000000 [get_bd_intf_pins /FGPU_0/m2]
set_property CONFIG.FREQ_HZ ${FREQ}000000 [get_bd_intf_pins /FGPU_0/m3]
set_property CONFIG.FREQ_HZ ${FREQ}000000 [get_bd_intf_pins /FGPU_0/s]

update_compile_order -fileset sources_1
#create wrapper
make_wrapper -files [get_files ${path_project}/${name_project}.srcs/sources_1/bd/${name_bd}/${name_bd}.bd] -top
add_files -norecurse ${path_project}/${name_project}.srcs/sources_1/bd/${name_bd}/hdl/${name_bd}_wrapper.vhd
set_property top FGPU_bd_wrapper [current_fileset]

#generate bitstream (also runs synthesis and implementation)
#launch_runs impl_1 -to_step write_bitstream -jobs 48
