######################################
####Synthesize Modules (Bottom-Up)####
######################################
proc synthesize { module FGPU_ver FREQ} {
  global tclParams 
  global part 
  global board 
  global synthDir
  global srcDir
  global verbose
  global hdfName
  global bd_name
  global bdDir
  global build_bd
  
  set moduleName  [get_attribute module $module moduleName]
  set topLevel    [get_attribute module $module top_level]
  set prj         [get_attribute module $module prj]
  set includes    [get_attribute module $module includes]
  set generics    [get_attribute module $module generics]
  set vlogHeaders [get_attribute module $module vlog_headers]
  set vlogDefines [get_attribute module $module vlog_defines]
  set sysvlog     [get_attribute module $module sysvlog]
  set vlog        [get_attribute module $module vlog]
  set vhdl        [get_attribute module $module vhdl]
  set ip          [get_attribute module $module ip]
  set ipRepo      [get_attribute module $module ipRepo]
  set bd          [get_attribute module $module bd]
  set cores       [get_attribute module $module cores]
  set xdc         [get_attribute module $module xdc]
  set synthXDC    [get_attribute module $module synthXDC]
  set options     [get_attribute module $module synth_options]
  set writeHdf    [get_attribute module $module writeHdf]

  set resultDir "$synthDir/$module"

  # Make the synthesis directory if needed
  if {![file exists $synthDir]} {
     file mkdir $synthDir
  }
  # Clean-out and re-make the synthesis directory for this module
  file delete -force $resultDir
  file mkdir $resultDir

  #Open local log files
  set rfh [open "$resultDir/run.log" w]
  set cfh [open "$resultDir/command.log" w]
  set wfh [open "$resultDir/critical.log" w]

  command "puts \"#HD: Running synthesis for block $module\""
  puts "\tWriting results to: $resultDir"
  set synth_start [clock seconds]

  #### Set Tcl Params
  if {[info exists tclParams] && [llength $tclParams] > 0} {
     set_parameters $tclParams
  }

  #Create in-memory project
  command "create_project -in_memory -part $part" "$resultDir/create_project.log"

  if {[info exists board] && [llength $board]} {
     command "set_property board_part $board \[current_project\]"
  }

  #### Setup any IP Repositories 
  if {$ipRepo != ""} {
     puts "\tLoading IP Repositories:\n\t+ [join $ipRepo "\n\t+ "]"
     command "set_property IP_REPO_PATHS \{$ipRepo\} \[current_fileset\]" "$resultDir/temp.log"
     command "update_ip_catalog" "$resultDir/temp.log"
  }

  if {$topLevel} {
    if {![file exists $bdDir/$bd_name.bd] || $build_bd } {
      puts "FGPU block design will be created"
      file delete -force ".srcs"
      set start_time [clock seconds]
      command "create_FGPU_block_design  $bd_name $FGPU_ver $FREQ"
      set end_time [clock seconds]
      log_time create_FGPU_bd $start_time $end_time 0 "create FGPU block design"
      if {$writeHdf} {
        set start_time [clock seconds]
        write_hwdef -force $hdfName
        set end_time [clock seconds]
        log_time write_hwdef $start_time $end_time 0 "Generate HDF file to export to SDK"
      }
    } else {
      puts "block design alread exists"
    }
  }

  set start_time [clock seconds]
  if {[llength $prj] > 0} {
     add_prj $prj
     set end_time [clock seconds]
     log_time add_prj $start_time $end_time 1 "Process PRJ file"
  } else {
     #### Read in System Verilog
     if {[llength $sysvlog] > 0} {
        add_sysvlog $sysvlog
     }

     #### Read in Verilog
     if {[llength $vlog] > 0} {
        add_vlog $vlog
     }

     #### Read in VHDL
     if {[llength $vhdl] > 0} {
        add_vhdl $vhdl
     }
     set end_time [clock seconds]
     log_time add_files $start_time $end_time 1 "Add source files"
  }

  #### Read IP from Catalog
  if {[llength $ip] > 0} {
     set start_time [clock seconds]
     add_ip $ip
     set end_time [clock seconds]
     log_time add_ip $start_time $end_time 0 "Add XCI files and generate/synthesize IP"
  }

  #### Read IPI systems
  if {[llength $bd] > 0} {
      set start_time [clock seconds]
      add_bd $bd
      set end_time [clock seconds]
      log_time add_bd $start_time $end_time 0 "Add/generate IPI block design"
      if {$writeHdf} {
        set start_time [clock seconds]
        write_hwdef -force $hdfName
        set end_time [clock seconds]
        log_time write_hwdef $start_time $end_time 0 "Generate HDF file to export to SDK"
     }
  }

  #### Read in IP Netlists 
  if {[llength $cores] > 0} {
     set start_time [clock seconds]
     add_cores $cores
     set end_time [clock seconds]
     log_time add_cores $start_time $end_time 0 "Add synthesized IP (DCP, NGC, EDIF)"
  }

  #### Read in synthXDC files
  if {[llength $synthXDC] > 0} {
     set start_time [clock seconds]
     add_xdc $synthXDC 2
     set end_time [clock seconds]
     log_time add_xdc $start_time $end_time 0 "Add synthesis only XDC files"
  }

  #### Read in XDC file
  if {[llength $xdc] > 0} {
     set start_time [clock seconds]
     add_xdc $xdc 1 
     set end_time [clock seconds]
     log_time add_xdc $start_time $end_time 0 "Add XDC files"
  }

  if {[llength $xdc] == 0 && [llength $synthXDC] == 0} {
     puts "\tInfo: No XDC file specified for $module"
  }

  #### Set Verilog Headers 
  if {[llength $vlogHeaders] > 0} {
     foreach file $vlogHeaders {
        command "set_property file_type {Verilog Header} \[get_files $file\]"
     }
  }

  #### Set Verilog Defines
  if {$vlogDefines != ""} {
     command "set_property verilog_define $vlogDefines \[current_fileset\]"
  }

  #### Set Include Directories
  if {$includes != ""} {
     command "set_property include_dirs \"$includes\" \[current_fileset\]"
  }

  #### Set Generics
  if {$generics != ""} {
     command "set_property generic $generics \[current_fileset\]"
  }

  #### synthesis
  puts "\tRunning synth_design"
  set start_time [clock seconds]
  if {$topLevel} {
     command "synth_design -mode default $options -top $moduleName -part $part" "$resultDir/${moduleName}_synth_design.rds"
  } else {
     command "synth_design -mode out_of_context $options -top $moduleName -part $part" "$resultDir/${moduleName}_synth_design.rds"
  }
  set end_time [clock seconds]
  log_time synth_design $start_time $end_time 0 "$moduleName $options"

  set start_time [clock seconds]
  command "write_checkpoint -force $resultDir/${moduleName}_synth.dcp" "$resultDir/temp.log"
  set end_time [clock seconds]
  log_time write_checkpiont $start_time $end_time 0 "Write out synthesis DCP"

  if {$verbose >= 1} {
     set start_time [clock seconds]
     command "report_utilization -file $resultDir/${moduleName}_utilization_synth.rpt" "$resultDir/temp.log"
     set end_time [clock seconds]
     log_time report_utilization $start_time $end_time 0 "Report Synthesis Utilization of $module"
  }
  set synth_end [clock seconds]
  log_time final $synth_start $synth_end
  command "close_project"
  command "puts \"#HD: Synthesis of module $module complete\\n\""
  close $rfh
  close $cfh
  close $wfh
}
