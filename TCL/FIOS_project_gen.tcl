
# This script is used to generate the implementation project for the FIOS Montgomery multiplication design.
# It loads sources, generates the top block design and sets implementation strategies.

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

variable project_name
set project_name "FIOS_project"

variable use_ip
set use_ip true

if { $argc == 1 } {

	if { [lindex $argv 0] eq "ip" } {
		
		set use_ip true
	
	} elseif { [lindex $argv 0] eq "no_ip" } {
	
		set use_ip false
	
	} else {
	
		set use_ip true
	
	}
}

# Create project and set the FPGA target.
create_project -force ${project_name} "${root_folder}/${project_name}" -part xczu9eg-ffvb1156-2-e
set_property BOARD_PART xilinx.com:zcu102:part0:3.4 [current_project]

# Import design sources.
if { $use_ip } {

	set_property  ip_repo_paths  "${root_folder}/IP" [current_project]
	update_ip_catalog

} else {

	add_files -fileset sources_1 "${root_folder}/SRC/RTL/"

	import_files -force

}

# Generates top block design including the FIOS design, the Zynq SoC, a Block memory compatible with a BRAM controller,
# a BRAM controller, a clock wizard and the AXI protocol features as well as reset systems.
# The Zynq SoC handles the AXI communication to the BRAM controller, starts the FIOS design, and is interrupted
# when the FIOS design is done computing.
source "${root_folder}/TCL/BD/impl_top_bd_gen.tcl"

# Make and add HDL wrapper for the block design.
make_wrapper -files [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/impl_top_bd/impl_top_bd.bd"] -top

add_files -fileset sources_1 "${root_folder}/${project_name}/${project_name}.gen/sources_1/bd/impl_top_bd/hdl/impl_top_bd_wrapper.v"

import_files -force

add_files -fileset sim_1 "${root_folder}/SRC/BENCH"
add_files -fileset sim_1 "${root_folder}/VERIFICATION/TEST_VECTORS/TXT"

import_files -force

# Set top design file.
set_property top impl_top_bd_wrapper [get_filesets sources_1]

update_compile_order -fileset sources_1

# Sets block design synthesis strategy to "Global".
set_property synth_checkpoint_mode None [get_files  "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/impl_top_bd/impl_top_bd.bd"]

# Sets implementation Strategy to Performance_ExploreWithRemap.
set_property strategy Performance_ExploreWithRemap [get_runs impl_1]

export_ip_user_files -of_objects [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/impl_top_bd/impl_top_bd.bd"] -no_script -sync -force -quiet


# Generate the simulation block design, including the design module, a clock wizard and a true dual port BRAM.
source "${root_folder}/TCL/BD/sim_top_bd_gen.tcl"

# Make and add HDL wrapper for the block design.
make_wrapper -files [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"] -top

add_files -fileset sources_1 "${root_folder}/${project_name}/${project_name}.gen/sources_1/bd/sim_top_bd/hdl/sim_top_bd_wrapper.v"

import_files -force

# set top files and updates compile order
set_property top top_bd_wrapper_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#launch_runs impl_1 -to_step write_bitstream -jobs 4
#wait_on_run impl_1
#write_hw_platform -fixed -include_bit -force -file "${root_folder}/FIOS_impl/impl_top_bd_wrapper.xsa"
