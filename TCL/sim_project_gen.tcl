
# This script is used to generate the simulation project for the FIOS Montgomery multiplication design.
# It loads sources and test vectors and generates the simulation block design.


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
set project_name "FIOS_sim"

# Create project and set the FPGA target
create_project -force ${project_name} "${root_folder}/${project_name}" -part xczu9eg-ffvb1156-2-e
set_property BOARD_PART xilinx.com:zcu102:part0:3.4 [current_project]

# Import design sources, testbench sources and test vectors
set_property  ip_repo_paths  "${root_folder}/IP" [current_project]
update_ip_catalog

add_files -fileset sources_1 "${root_folder}/SRC/RTL"
add_files -fileset sim_1 "${root_folder}/SRC/BENCH"
add_files -fileset sim_1 "${root_folder}/VERIFICATION/TEST_VECTORS/TXT"

import_files -force

# Generate the simulation block design, including the design module, a clock wizard and a true dual port BRAM.
source "${root_folder}/TCL/BD/sim_top_bd_gen.tcl"

# Make and add HDL wrapper for the block design.
make_wrapper -files [get_files "${root_folder}/${project_name}/${project_name}.srcs/sources_1/bd/sim_top_bd/sim_top_bd.bd"] -top

add_files -fileset sources_1 "${root_folder}/${project_name}/${project_name}.gen/sources_1/bd/sim_top_bd/hdl/sim_top_bd_wrapper.v"

import_files -force

# set top files and updates compile order
set_property top top_bd_wrapper [get_filesets sources_1]
set_property top top_bd_wrapper_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
