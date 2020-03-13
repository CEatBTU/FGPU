
#
# Comment: this was an attempt to automatize the project
# creation steps in ModelSim, however it didn't work.
#
# For the future we should update this.
#
#

project new . FGPU

set VHD_FILES [ls ../RTL/ | grep vhd]
foreach f ${VHD_FILES} {
    project addfile ../RTL/${f} vhdl
}
project removefile ../RTL/float_units.vhd
project calculateorder

vdel -all
# Compile all files
foreach f [project compileorder] {
    vcom -work work -2008 -explicit -vopt -stats=none ${f}
}
