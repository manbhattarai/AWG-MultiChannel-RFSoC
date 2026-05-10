# Original script location
set orig_script_dir [file dirname [file normalize [info script]]]

# Default: use original path
set script_dir $orig_script_dir

# On Windows, shorten the path using subst
if { $::tcl_platform(platform) eq "windows" } {
    set subst_drive X:
    catch {exec cmd /c subst $subst_drive /d}
    if {[catch {exec cmd /c subst $subst_drive $orig_script_dir} subst_err]} {
        puts "WARNING: subst failed, using original path: $subst_err"
    } else {
        set script_dir ${subst_drive}/
        puts "INFO: Using shortened path via subst: $script_dir"
    }
}
set proj_name awg_multichannel_rfsoc
set proj_dir [file join $script_dir $proj_name]
set part xczu48dr-ffvg1517-2-e
set design_name design_1

create_project $proj_name $proj_dir -part $part

add_files [list \
  [file join $script_dir src control_or_gate.v] \
  [file join $script_dir src pmod_test.v] \
  [file join $script_dir src awg_BRAM_dual.v] \
  [file join $script_dir src dataflower.v] \
]

add_files -fileset constrs_1 [file join $script_dir constrs constrs.xdc]

source [file join $script_dir bd block_design.tcl]


validate_bd_design
save_bd_design
generate_target all [get_files ${design_name}.bd]
export_ip_user_files -of_objects [get_files ${design_name}.bd] -no_script -sync -force


set wrapper_file [make_wrapper -files [get_files ${design_name}.bd] -top]
add_files -norecurse $wrapper_file

set_property top ${design_name}_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1

set synth_run [get_runs synth_1]
set_property strategy Flow_AlternateRoutability $synth_run

set obj [get_runs impl_1]
set_property strategy Performance_NetDelay_high $obj