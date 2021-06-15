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
	create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 zynq_ultra_ps_e_0
#add the FGPU block
	create_bd_cell -type ip -vlnv user.org:user:${FGPU_IP_NAME}:${FGPU_IP_VERSION} FGPU_0
#add a clock wizzard
	create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:${ip_clk_wiz_v} \
		clk_wiz_0
}

apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]

#set properties for the clock wizard (frequency)
set_property -dict [list CONFIG.USE_PHASE_ALIGNMENT {false} \
                         CONFIG.CLKOUT1_REQUESTED_OUT_FREQ  ${FREQ}.0 \
                         CONFIG.USE_LOCKED {false} \
                         CONFIG.USE_RESET {false} \
                         CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin}] \
					[get_bd_cells clk_wiz_0]


set_property -dict [list CONFIG.PSU__USE__M_AXI_GP1 {0} CONFIG.PSU__USE__S_AXI_GP2 {1} CONFIG.PSU__USE__S_AXI_GP3 {0}] [get_bd_cells zynq_ultra_ps_e_0]


set_property -dict [list CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {0} CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {0} CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 30 .. 31} CONFIG.PSU__UART1__PERIPHERAL__ENABLE {0} CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {0}] [get_bd_cells zynq_ultra_ps_e_0]




connect_bd_net [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins clk_wiz_0/clk_out1]
connect_bd_net [get_bd_pins FGPU_0/axi_clk] [get_bd_pins clk_wiz_0/clk_out1]


apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/FGPU_0/s} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins FGPU_0/s]


startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
endgroup
set_property -dict [list CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect_0]

delete_bd_objs [get_bd_nets rst_clk_wiz_0_100M_peripheral_aresetn]

connect_bd_intf_net [get_bd_intf_pins FGPU_0/m0] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
connect_bd_net [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins clk_wiz_0/clk_out1]
connect_bd_net [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins rst_clk_wiz_0_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins clk_wiz_0/clk_out1]
connect_bd_net [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins clk_wiz_0/clk_out1]
connect_bd_net [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins rst_clk_wiz_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins rst_clk_wiz_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins ps8_0_axi_periph/S00_ARESETN] [get_bd_pins rst_clk_wiz_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins ps8_0_axi_periph/M00_ARESETN] [get_bd_pins rst_clk_wiz_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins FGPU_0/axi_aresetn] [get_bd_pins rst_clk_wiz_0_100M/peripheral_aresetn]

apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_pins rst_clk_wiz_0_100M/ext_reset_in]


assign_bd_address -target_address_space /FGPU_0/m0 [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] -force
assign_bd_address -target_address_space /FGPU_0/m0 [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_LPS_OCM] -force
assign_bd_address -target_address_space /FGPU_0/m0 [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_QSPI] -force


connect_bd_net [get_bd_pins ps8_0_axi_periph/ARESETN] [get_bd_pins rst_clk_wiz_0_100M/interconnect_aresetn]

save_bd_design

update_compile_order -fileset sources_1

#create wrapper
make_wrapper -files [get_files ${path_project}/${name_project}.srcs/sources_1/bd/${name_bd}/${name_bd}.bd] -top
add_files -norecurse ${path_project}/${name_project}.srcs/sources_1/bd/${name_bd}/hdl/${name_bd}_wrapper.vhd
set_property top FGPU_bd_wrapper [current_fileset]

#generate bitstream (also runs synthesis and implementation)
#launch_runs impl_1 -to_step write_bitstream -jobs 48
