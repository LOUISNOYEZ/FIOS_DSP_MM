lappend auto_path "/usr/lib/sqlite3.40.0"

package require sqlite3

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

variable root_folder
set root_folder "${script_folder}/.."

sqlite3 db1 ./design_db
db1 eval {CREATE TABLE IF NOT EXISTS model(name TEXT PRIMARY KEY, CASCADE BOOLEAN, CONFIGURATION TEXT, LOOP_DELAY INTEGER, WIDTH INTEGER, ABREG BOOLEAN, MREG BOOLEAN, CREG BOOLEAN, DSP_REG_LEVEL INTEGER, s INTEGER, PE_DELAY INTEGER, PE_NB INTEGER)}
db1 eval {CREATE TABLE IF NOT EXISTS simulation(name TEXT, success TEXT, FOREIGN KEY(name) REFERENCES model(name))}
db1 eval {CREATE TABLE IF NOT EXISTS implementation(name TEXT, FREQUENCY_MHZ REAL, CLOCK_CYCLES_1ST INTEGER, CLOCK_CYCLES_NEXT INTEGER, DSP INTEGER, LUT INTEGER, FF INTEGER, TIME_1ST_US REAL, TIME_NEXT_US REAL, THROUGHPUT REAL, FOREIGN KEY(name) REFERENCES simulation(name))}


variable project_name
set project_name "FIOS_project"

open_project "${root_folder}/${project_name}/${project_name}.xpr"

set LOOP_DELAY 0

for {set WIDTH 128} {$WIDTH <= 256} {set WIDTH [expr 2*$WIDTH]} {
for {set CONFIGURATION_int 0} {$CONFIGURATION_int <= 1} {incr CONFIGURATION_int} {

set CONFIGURATION [expr {($CONFIGURATION_int == 1) ? "FOLD" : "EXPAND"}]

for {set CASCADE 0} {$CASCADE <= 1} {incr CASCADE} {
for {if {$CASCADE == 1} {set CREG 1} else {set CREG 0}} {$CREG <= 1} {incr CREG} {
for {set ABREG 0} {$ABREG <= 1} {incr ABREG} {
for {set MREG 0} {$MREG <= 1} {incr MREG} {

open_bd_design "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"

set DSP_REG_LEVEL [expr 1 + $ABREG + $MREG]

if {$DSP_REG_LEVEL == 1} {
	if {$CASCADE || (!$CASCADE && !$CREG)} {
		set PE_DELAY 5
	} else {
		set PE_DELAY 6
	}
} elseif {$DSP_REG_LEVEL == 2} {
	if {$CASCADE || (!$CASCADE && !$CREG)} {
		set PE_DELAY 6
	} else {
		set PE_DELAY 7
	}
} elseif {$DSP_REG_LEVEL == 3} {
	if {$CASCADE || (!$CASCADE && !$CREG)} {
		set PE_DELAY 8
	} else {
		set PE_DELAY 9
	}
}

set s [expr {ceil(double($WIDTH+2)/17)}]

set PE_NB [expr {($CONFIGURATION eq "FOLD") ? ceil((2*$s+1+$DSP_REG_LEVEL)/$PE_DELAY) : $s}]

set model_name "${WIDTH}CASC${CASCADE}L${LOOP_DELAY}AB${ABREG}M${MREG}C${CREG}${CONFIGURATION}"

db1 eval {
       INSERT OR IGNORE INTO model (name, CASCADE, CONFIGURATION, LOOP_DELAY, WIDTH, ABREG, MREG, CREG, DSP_REG_LEVEL, PE_DELAY) \
       VALUES ($model_name, $CASCADE, $CONFIGURATION, $LOOP_DELAY, $WIDTH, $ABREG, $MREG, $CREG, $DSP_REG_LEVEL, $PE_DELAY) \
}

if {![db1 exists {SELECT 1 FROM simulation WHERE name=$model_name}]} {

	set_property -dict [list CONFIG.WIDTH ${WIDTH} CONFIG.CASCADE ${CASCADE} CONFIG.CONFIGURATION ${CONFIGURATION} CONFIG.LOOP_DELAY ${LOOP_DELAY} CONFIG.ABREG ${ABREG} CONFIG.MREG ${MREG} CONFIG.CREG ${CREG}] [get_bd_cells MM_demo_0]

	set_property generic WIDTH=${WIDTH} [get_filesets sim_1]

	generate_target Simulation [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"]
	export_ip_user_files -of_objects [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"] -no_script -sync -force -quiet
	export_simulation -of_objects [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"] -directory "${root_folder}/${project_name}/${project_name}.ip_user_files/sim_scripts" -ip_user_files_dir "${root_folder}/${project_name}/${project_name}.ip_user_files" -ipstatic_source_dir "${root_folder}/${project_name}/${project_name}.ip_user_files/ipstatic" -lib_map_path [list {modelsim="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/modelsim"} {questa="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/questa"} {xcelium="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/xcelium"} {vcs="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/vcs"} {riviera="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/riviera"}] -use_ip_compiled_libs -force -quiet
	launch_simulation

	source "${root_folder}/${project_name}/${project_name}.sim/sim_1/behav/xsim/top_bd_wrapper_tb.tcl"

	run -all

	set success_string [string trim [get_value success_string] "\""]

	close_sim
	reset_simulation -simset sim_1 -mode behavioral


	db1 eval {
	       INSERT OR IGNORE INTO simulation (name, success) \
	       VALUES ($model_name, $success_string) \
	}

}


if {![db1 exists {SELECT 1 FROM implementation WHERE name=$model_name}]} {

	open_bd_design "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/impl_top_bd/impl_top_bd.bd"

	set_property -dict [list CONFIG.WIDTH ${WIDTH} CONFIG.CASCADE ${CASCADE} CONFIG.CONFIGURATION ${CONFIGURATION} CONFIG.LOOP_DELAY ${LOOP_DELAY} CONFIG.ABREG ${ABREG} CONFIG.MREG ${MREG} CONFIG.CREG ${CREG}] [get_bd_cells MM_demo_0]

	if {$DSP_REG_LEVEL == 1} {
		set target_freq 425.0
	} elseif {$DSP_REG_LEVEL == 2} {
		set target_freq 625.0
	} elseif {$DSP_REG_LEVEL == 3} {
		set target_freq 738.0
	}

	set clk_wiz_freq 0
	set prev_clk_wiz_freq 0

	set end 0

	set attempt_nb 0

	set success 0
	set prev_success 0

	while {!$end && $attempt_nb < 10 } {

		reset_run synth_1
		reset_run impl_1
		
		set_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ ${target_freq} [get_bd_cells clk_wiz_0]
		set clk_wiz_freq [expr {double([get_property CONFIG.FREQ_HZ [get_bd_pins clk_wiz_0/clk_out1]])/1000000}]
		set target_freq $clk_wiz_freq
		
		save_bd_design
		
		puts [get_property CONFIG.FREQ_HZ [get_bd_pins MM_demo_0/clock_i]]
		
		launch_runs impl_1 -jobs 4
		wait_on_run impl_1
		open_run impl_1
		
		set slack [get_property SLACK [get_timing_paths]]
		
		set success [expr {$slack >= 0.000 && $clk_wiz_freq <= 738.0}]

		if {!$success && $prev_success} {
		
			db1 eval {
			       INSERT OR IGNORE INTO implementation (name, FREQUENCY_MHZ, CLOCK_CYCLES_1ST, CLOCK_CYCLES_NEXT, DSP, LUT, FF, TIME_1ST_US, TIME_NEXT_US, THROUGHPUT) \
			       VALUES ($model_name, $res_freq, $res_cc_1st, $res_cc_next, $res_dsp, $res_lut, $res_ff, $res_time_1st, $res_time_next, $res_throughput) \
			}
		
			reset_run synth_1
			reset_run impl_1
		
			set end 1
		
		} else {

			if {$success} {
			
				set res_freq $clk_wiz_freq
				set res_cc_1st [expr {($PE_DELAY+2)*$s-$PE_DELAY+1+$DSP_REG_LEVEL+((($CONFIGURATION == "FOLD") ? ($LOOP_DELAY+$CASCADE) : 0) + floor($PE_NB/double(168)))*ceil($s/double($PE_NB))}]
				set res_cc_next [expr {($CONFIGURATION eq "FOLD") ? $res_cc_1st : (2*$s+1+$DSP_REG_LEVEL+floor($PE_NB/double(168))*ceil($s/double($PE_NB)))}]
				
				if {$CASCADE} {
					set CASC_string "CASC"
				} elseif {!$CASCADE} {
					set CASC_string "NOCASC"
				}
				
				set use_res_list [split [report_utilization -cells impl_top_bd_i/MM_demo_0/inst/MM_top_inst/FIOS_${CASC_string}_inst/FIOS_MM_${CASC_string}_inst -return_string] "|"]
				
				foreach {name} $use_res_list {
					set trim_name [string trim $name] 
					if {$trim_name eq "CLB LUTs"} {
						set res_lut [string trim [lindex $use_res_list [expr {[lsearch $use_res_list $name] + 1}]]]
					} elseif {$trim_name eq "CLB Registers"} {
						set res_ff [string trim [lindex $use_res_list [expr {[lsearch $use_res_list $name] + 1}]]]
					} elseif {$trim_name eq "DSPs"} {
						set res_dsp [string trim [lindex $use_res_list [expr {[lsearch $use_res_list $name] + 1}]]]
					}
				}
				
				set res_time_1st [expr {double($res_cc_1st)/$res_freq}]
				set res_time_next [expr {double($res_cc_next)/$res_freq}]
				set res_throughput [expr {double($res_freq)/$res_cc_next}]
			
			}
			
			close_design
			
			set prev_success $success
			
			set target_freq [expr {1/(double(1)/$target_freq - $slack/double(1000))}]
			
			set_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ ${target_freq} [get_bd_cells clk_wiz_0]
			
			set prev_clk_wiz_freq $clk_wiz_freq
			
			while {[expr {double([get_property CONFIG.FREQ_HZ [get_bd_pins clk_wiz_0/clk_out1]])/1000000}] == $clk_wiz_freq} {
			
				set target_freq [expr {$target_freq + ($success ? 5 : -5)}]
				
				set_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ ${target_freq} [get_bd_cells clk_wiz_0]
			
			}

			set clk_wiz_freq [expr {double([get_property CONFIG.FREQ_HZ [get_bd_pins clk_wiz_0/clk_out1]])/1000000}]
			
			puts $clk_wiz_freq

		}
		
		set attempt_nb [expr {$attempt_nb+1}]

	}
	
}

}
}
}
}
}
}
