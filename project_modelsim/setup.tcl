project new . FGPU

set VHD_FILES [list \
               \
               FGPU_definitions.vhd \
               FGPU_simulation_pkg.vhd \
               \
               DSP48E1.vhd \
               mult_add_sub.vhd \
               regFile.vhd \
               ALU.vhd \
               CV.vhd \
               \
               RTM.vhd \
               CU_instruction_dispatcher.vhd \
               CU_scheduler.vhd \
               \
               lmem.vhd \
               rd_cache_fifo.vhd \
               CU_mem_cntrl.vhd \
               CU.vhd \
               \
               loc_indcs_generator.vhd \
               init_alu_en_ram.vhd \
               WG_dispatcher.vhd \
               \
               axi_controllers.vhd \
               cache.vhd \
               gmem_atomics.vhd \
               gmem_cntrl_tag.vhd \
               gmem_cntrl.vhd \
               global_mem.vhd \
               \
               FGPU.vhd \
               FGPU_tb.vhd]

foreach f ${VHD_FILES} {
    project addfile ../RTL/${f}
}
project compileall
