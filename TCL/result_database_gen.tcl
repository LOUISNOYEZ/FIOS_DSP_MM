variable res_mode
set res_mode "db"

if { $argc == 1 } {

	switch [ lindex $argv 0 ] {
		"db" {
			set res_mode "db"
		}
		"csv" {
			set res_mode "csv"
		}
	}

}

if { $res_mode eq "db" } {
	lappend auto_path "/usr/lib/sqlite3.40.0"

	package require sqlite3
}

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

if { $res_mode eq "db" } {
	sqlite3 db1 "${root_folder}/RESULTS/results.db"
	db1 eval {CREATE TABLE IF NOT EXISTS model(name TEXT PRIMARY KEY, CASCADE BOOLEAN, CONFIGURATION TEXT, LOOP_DELAY INTEGER, WIDTH INTEGER, ABREG BOOLEAN, MREG BOOLEAN, CREG BOOLEAN, DSP_REG_LEVEL INTEGER, s INTEGER, PE_DELAY INTEGER, PE_NB INTEGER)}
	db1 eval {CREATE TABLE IF NOT EXISTS simulation(name TEXT, success TEXT, CLOCK_CYCLES_1ST INTEGER, FOREIGN KEY(name) REFERENCES model(name))}
	db1 eval {CREATE TABLE IF NOT EXISTS implementation(name TEXT, FREQUENCY_MHZ REAL, CLOCK_CYCLES_1ST INTEGER, CLOCK_CYCLES_NEXT INTEGER, DSP INTEGER, LUT INTEGER, FF INTEGER, TIME_1ST_US REAL, TIME_NEXT_US REAL, THROUGHPUT REAL, FOREIGN KEY(name) REFERENCES simulation(name))}
} elseif { $res_mode eq "csv" } {
	if { !([file exist "${root_folder}/RESULTS/results.csv"]) } {
		set results_csv_file [ open "${root_folder}/RESULTS/results.csv" "w+"]
		puts $results_csv_file "\
PRAGMA foreign_keys=OFF;\n\
BEGIN TRANSACTION;\n\
CREATE TABLE model(name TEXT PRIMARY KEY, CASCADE BOOLEAN, CONFIGURATION TEXT, LOOP_DELAY INTEGER, WIDTH INTEGER, ABREG BOOLEAN, MREG BOOLEAN, CREG BOOLEAN, DSP_REG_LEVEL INTEGER, s INTEGER, PE_DELAY INTEGER, PE_NB INTEGER);\n\
CREATE TABLE simulation(name TEXT, success TEXT, CLOCK_CYCLES_1ST INTEGER, FOREIGN KEY(name) REFERENCES model(name));\n\
CREATE TABLE implementation(name TEXT, FREQUENCY_MHZ REAL, CLOCK_CYCLES_1ST INTEGER, CLOCK_CYCLES_NEXT INTEGER, DSP INTEGER, LUT INTEGER, FF INTEGER, TIME_1ST_US REAL, TIME_NEXT_US REAL, THROUGHPUT REAL, FOREIGN KEY(name) REFERENCES simulation(name));\n\
COMMIT;"
		flush $results_csv_file
	} else {
		set results_csv_file [ open "${root_folder}/RESULTS/results.csv" "r+" ]
	}
}

variable project_name
set project_name "FIOS_project"

open_project "${root_folder}/${project_name}/${project_name}.xpr"

set LOOP_DELAY 0

for {set WIDTH 128} {$WIDTH <= 4096} {set WIDTH [expr $WIDTH+17]} {

add_files -fileset sim_1 "${root_folder}/VERIFICATION/TEST_VECTORS/TXT/sim_${WIDTH}.txt"

import_files -force

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

set PE_NB [expr {($CONFIGURATION eq "FOLD") ? floor((2*$s+1+$DSP_REG_LEVEL)/$PE_DELAY)+1 : $s}]

set model_name "${WIDTH}CASC${CASCADE}L${LOOP_DELAY}AB${ABREG}M${MREG}C${CREG}${CONFIGURATION}"

if { $res_mode eq "db" } {
	db1 eval {
	       INSERT OR IGNORE INTO model (name, CASCADE, CONFIGURATION, LOOP_DELAY, WIDTH, ABREG, MREG, CREG, DSP_REG_LEVEL, s, PE_DELAY, PE_NB) \
	       VALUES ($model_name, $CASCADE, $CONFIGURATION, $LOOP_DELAY, $WIDTH, $ABREG, $MREG, $CREG, $DSP_REG_LEVEL, $s, $PE_DELAY, $PE_NB) \
	}
} else {
	set model_insert_string "INSERT INTO model VALUES('$model_name',$CASCADE,'$CONFIGURATION',$LOOP_DELAY,$WIDTH,$ABREG,$MREG,$CREG,$DSP_REG_LEVEL,"
	append model_insert_string [expr int($s)] ",$PE_DELAY," [expr int($PE_NB)] ");"
	
	seek $results_csv_file 0 start
	if { [ llength [ lsearch -all [ split [ read $results_csv_file ] "\n()'" ] $model_name ] ] == 0 } {
		seek $results_csv_file -8 end
		puts $results_csv_file $model_insert_string
		puts $results_csv_file "COMMIT;"
		flush $results_csv_file
	}
	seek $results_csv_file 0 start
}

if { ($res_mode eq "db") ? [expr ![db1 exists {SELECT 1 FROM simulation WHERE name=$model_name}]] : [expr [ llength [ lsearch -all [ split [ read $results_csv_file ] "\n()'" ] $model_name ] ] < 2] } {
if { [file exist "${root_folder}/FIOS_project/FIOS_project.srcs/sim_1/imports/TXT/sim_${WIDTH}.txt"] } {

	set_property -dict [list CONFIG.WIDTH ${WIDTH} CONFIG.CASCADE ${CASCADE} CONFIG.CONFIGURATION ${CONFIGURATION} CONFIG.LOOP_DELAY ${LOOP_DELAY} CONFIG.ABREG ${ABREG} CONFIG.MREG ${MREG} CONFIG.CREG ${CREG}] [get_bd_cells MM_demo_0]

	set_property generic WIDTH=${WIDTH} [get_filesets sim_1]

	generate_target Simulation [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"]
	export_ip_user_files -of_objects [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"] -no_script -sync -force -quiet
	export_simulation -of_objects [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"] -directory "${root_folder}/${project_name}/${project_name}.ip_user_files/sim_scripts" -ip_user_files_dir "${root_folder}/${project_name}/${project_name}.ip_user_files" -ipstatic_source_dir "${root_folder}/${project_name}/${project_name}.ip_user_files/ipstatic" -lib_map_path [list {modelsim="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/modelsim"} {questa="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/questa"} {xcelium="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/xcelium"} {vcs="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/vcs"} {riviera="${root_folder}/${project_name}/${project_name}.cache/compile_simlib/riviera"}] -use_ip_compiled_libs -force -quiet
	launch_simulation

	source "${root_folder}/${project_name}/${project_name}.sim/sim_1/behav/xsim/top_bd_wrapper_tb.tcl"

	run -all

	set success_string [string trim [get_value success_string] "\""]
	
	set clock_cycles_1st [string trim [get_value FIOS_cycle_count] "\""]

	close_sim
	reset_simulation -simset sim_1 -mode behavioral

	if { $res_mode eq "db" } {
		db1 eval {
		       INSERT OR IGNORE INTO simulation (name, success, CLOCK_CYCLES_1ST) \
		       VALUES ($model_name, $success_string, $clock_cycles_1st) \
		}
	} else {
		set sim_insert_string "INSERT INTO simulation VALUES('$model_name','$success_string',$clock_cycles_1st);"
		
		seek $results_csv_file -8 end
		puts $results_csv_file $sim_insert_string
		puts $results_csv_file "COMMIT;"
		flush $results_csv_file
		seek $results_csv_file 0 start
	}

}
}


if { ($res_mode eq "csv") } {

	seek $results_csv_file 0 start

}

if { ($res_mode eq "db") ? [expr ![db1 exists {SELECT 1 FROM implementation WHERE name=$model_name}] ] : [expr [ llength [ lsearch -all [ split [ read $results_csv_file ] "\n()'," ] $model_name ] ] < 3 ]} {
	seek $results_csv_file 0 start

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
		
		launch_runs impl_1 -jobs 12
		wait_on_run impl_1 -timeout 60
		
		if {[get_property PROGRESS [get_runs impl_1]] == "100%"} {

			open_run impl_1
			
			set slack [get_property SLACK [get_timing_paths]]
			
			set success [expr {$slack >= 0.000 && $clk_wiz_freq <= 738.0}]

		} else {
			
			set success 0
		
		}

		if {!$success && $prev_success} {
		
			if { $res_mode eq "db" } {
				db1 eval {
				       INSERT OR IGNORE INTO implementation (name, FREQUENCY_MHZ, CLOCK_CYCLES_1ST, CLOCK_CYCLES_NEXT, DSP, LUT, FF, TIME_1ST_US, TIME_NEXT_US, THROUGHPUT) \
				       VALUES ($model_name, $res_freq, $res_cc_1st, $res_cc_next, $res_dsp, $res_lut, $res_ff, $res_time_1st, $res_time_next, $res_throughput) \
				}
			} else {
				set impl_insert_string "INSERT INTO implementation VALUES('$model_name',$res_freq,$res_cc_1st,$res_cc_next,$res_dsp,$res_lut,$res_ff,$res_time_1st,$res_time_next,$res_throughput);"
	
				seek $results_csv_file -8 end
				puts $results_csv_file $impl_insert_string
				puts $results_csv_file "COMMIT;"
				flush $results_csv_file
				seek $results_csv_file 0 start
			}
		
			reset_run synth_1
			reset_run impl_1
		
			set end 1
		
		} else {

			if {$success} {
			
				set res_freq $clk_wiz_freq
				set res_cc_1st [expr {($PE_DELAY+2)*$s-$PE_DELAY+1+$DSP_REG_LEVEL+((($CONFIGURATION == "FOLD") ? ($LOOP_DELAY+$CASCADE) : $LOOP_DELAY) + floor($PE_NB/double(168)))*(ceil($s/double($PE_NB)-1))}]
				set res_cc_next [expr {($CONFIGURATION eq "FOLD") ? $res_cc_1st : (2*$s+2+$DSP_REG_LEVEL))}]
				
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
			
			set target_freq [expr {double(round(1/(double(1)/$target_freq - $slack/double(1000))))}]
			
			set_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ ${target_freq} [get_bd_cells clk_wiz_0]
			
			set prev_clk_wiz_freq $clk_wiz_freq
			
			while {[expr {double([get_property CONFIG.FREQ_HZ [get_bd_pins clk_wiz_0/clk_out1]])/1000000}] == $clk_wiz_freq} {
			
				set target_freq [expr {$target_freq + ($success ? 1 : -1)}]
				
				set_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ ${target_freq} [get_bd_cells clk_wiz_0]
			
			}

			set clk_wiz_freq [expr {double([get_property CONFIG.FREQ_HZ [get_bd_pins clk_wiz_0/clk_out1]])/1000000}]
			
		}
		
		set attempt_nb [expr {$attempt_nb+1}]

	}
	
}

}
}
}
}
}

if {[file exist "${root_folder}/FIOS_project/FIOS_project.srcs/sim_1/imports/TXT/sim_${WIDTH}.txt"]} {
file delete "${root_folder}/FIOS_project/FIOS_project.srcs/sim_1/imports/TXT/sim_${WIDTH}.txt"
}

}

close $results_csv_file
