

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "FGPU" "NUM_INSTANCES" "DEVICE_ID"  "C_S0_BASEADDR" "C_S0_HIGHADDR"
}
