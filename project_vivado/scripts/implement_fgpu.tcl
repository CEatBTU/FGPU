##############################################################################
#
# implement_fgpu.tcl
#
# Description: Implements the FGPU until the bitstream generation phase.
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

# Guard clause to ensure everything is properly set up
if (![info exists set_up_fgpu_environment]) {
	puts "\[ERROR\] You must first source the setup_environment.tcl script."
	return
}

launch_runs impl_1 -to_step write_bitstream -jobs ${num_threads}