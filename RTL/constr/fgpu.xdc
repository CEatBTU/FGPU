# axi_controllers.vhd
#set_property max_fanout  60 [get_cells -hierarchical *wr_fifo_rdAddr_reg* -filter {name =~ */axi_cntrl/*}]
#set_property max_fanout  60 [get_cells -hierarchical *rd_fifo_wrAddr_reg* -filter {name =~ */axi_cntrl/*}]

# cache.vhd
#set_property max_fanout  60 [get_cells -hierarchical wr_fifo_ack_indx_d0_reg* -filter {name =~ */cache_inst/*}]

# cu_mem_cntrl.vhd
#set_property max_fanout  10 [get_cells -hierarchical atomic_rdData_d1_reg* -filter {name =~ */cu_mem_cntrl_inst/*}]
#set_property max_fanout 300 [get_cells -hierarchical mem_rqsts_rdData_ltchd_reg* -filter {name =~ */cu_mem_cntrl_inst/*}]
#set_property max_fanout  60 [get_cells -hierarchical station_slctd_indx_reg* -filter {name =~ */cu_mem_cntrl_inst/*}]
#set_property max_fanout   8 [get_cells -hierarchical rd_fifo_data_d0_reg* -filter {name =~ */cu_mem_cntrl_inst/*}]

# cu_scheduler.vhd
#set_property max_fanout  10 [get_cells -hierarchical wf_indx_in_CU_i_reg* -filter {name =~ */cu_sched_inst/*}]
#set_property max_fanout  10 [get_cells -hierarchical phase_i_reg* -filter {name =~ */cu_sched_inst/*}]

# cu_vector.vhd
#set_property max_fanout  40 [get_cells -hierarchical {family_vec_reg[23][*]} -filter {name =~ */cu_vector_inst/*}]
#set_property max_fanout  50 [get_cells -hierarchical regBlock_we_alu_reg* -filter {name =~ */cu_vector_inst/*}]
#set_property max_fanout  50 [get_cells -hierarchical regBlock_we_float_reg* -filter {name =~ */cu_vector_inst/*}]

# cu.vhd
#set_property max_fanout  10 [get_cells -hierarchical instr_slice_true.phase_reg* -filter {name =~ *.cu_inst/*}]
#set_property max_fanout  10 [get_cells -hierarchical instr_slice_true.wf_indx_reg* -filter {name =~ *.cu_inst/*}]

# float_units.vhd
#set_property max_fanout  32 [get_cells -hierarchical code_vec_reg* -filter {name =~ *.float_units_inst/*}]

# gmem_atomics.vhd
#set_property max_fanout  60 [get_cells -hierarchical *rcv_slctd_indx_reg* -filter {name =~ *.atomics_inst/*}]
#set_property max_fanout  40 [get_cells -hierarchical *rcv_slctd_indx_d0_reg* -filter {name =~ *.atomics_inst/*}]
#set_property max_fanout  60 [get_cells -hierarchical *rqst_type_reg* -filter {name =~ *.atomics_inst/*}]

# gmem_ctrl.vhd
#set_property max_fanout  50 [get_cells -hierarchical rcv_request_write_addr_reg* -filter {name =~ */gmem_controller_inst/*}]
#set_property max_fanout 100 [get_cells -hierarchical cache_read_v_reg* -filter {name =~ */gmem_controller_inst/*}]
#set_property max_fanout   8 [get_cells -hierarchical write_phase_reg* -filter {name =~ */gmem_controller_inst/*}]
#set_property max_fanout  60 [get_cells -hierarchical rcv_to_write_reg* -filter {name =~ */gmem_controller_inst/*}]

# mult_add_sub.vhd
set_property use_dsp no [get_nets -of_objects [get_cells -hierarchical res_middle_reg*]]
