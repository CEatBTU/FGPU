COMPILER=vcom
FLAGS=-32 -2008 -modelsimini ../../Questa_Vivado/modelsim.ini  -work /home/muhammed/ESITGPU/Questa_Vivado/work -check_synthesis -novopt +acc +cover
TOP=FGPU_tb

all: .$(TOP).tag 
clean: 
	rm .*.tag


.FGPU_tb.tag: .FGPU_definitions.tag .FGPU_simulation_pkg.tag .FGPU.tag .global_mem.tag
.global_mem.tag: .FGPU_definitions.tag .FGPU_simulation_pkg.tag
.FGPU.tag: .WG_dispatcher.tag .CU.tag .gmem_cntrl.tag .FGPU_definitions.tag
.WG_dispatcher.tag: .loc_indcs_generator.tag .FGPU_definitions.tag .init_alu_en_ram.tag
.loc_indcs_generator.tag: .FGPU_definitions.tag
.CU.tag: .RTM.tag .CU_scheduler.tag .CV.tag .CU_mem_cntrl.tag .FGPU_definitions.tag
.RTM.tag: .FGPU_definitions.tag
.CU_scheduler.tag: .CU_instruction_dispatcher.tag .FGPU_definitions.tag
.CU_instruction_dispatcher.tag: .FGPU_definitions.tag
.CV.tag: .ALU.tag .float_units.tag .FGPU_definitions.tag
.ALU.tag: .regFile.tag .FGPU_definitions.tag .mult_add_sub.tag
# .ALU.tag: .xbip_multadd_0_funcsim.tag .regFile.tag .FGPU_definitions.tag
.regFile.tag: .FGPU_definitions.tag
.CU_mem_cntrl.tag: .FGPU_definitions.tag .lmem.tag .rd_cache_fifo.tag
.init_alu_en_ram.tag: .FGPU_definitions.tag
.gmem_cntrl_tag.tag: .FGPU_definitions.tag
.dynamic_shift_registers.tag: .FGPU_definitions.tag
.mult_add.tag: .FGPU_definitions.tag
.FGPU_simulation_pkg.tag: .FGPU_definitions.tag
.DSP48E1.tag: .FGPU_definitions.tag
.mult_add_sub.tag: .FGPU_definitions.tag .DSP48E1.tag
.axi_controllers.tag: .FGPU_definitions.tag
# .cache_sim.tag: .FGPU_definitions.tag
.gmem_cntrl.tag: .FGPU_definitions.tag .cache.tag .gmem_cntrl_tag.tag .axi_controllers.tag .gmem_atomics.tag
.cache.tag: .FGPU_definitions.tag
.gmem_atomics.tag: .FGPU_definitions.tag
.lmem.tag : .FGPU_definitions.tag
.float_units.tag : .FGPU_definitions.tag
.rd_cache_fifo.tag: .FGPU_definitions.tag


.%.tag:%.vhd
	$(COMPILER) $(FLAGS) $<
	touch $@

