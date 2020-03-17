project new . FGPU

set VHD_FILES [ls ../RTL | grep .vhd]

foreach f ${VHD_FILES} {
    project addfile ../RTL/${f}
}
project removefile ../RTL/float_units.vhd
project calculateorder
