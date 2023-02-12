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

setws "${root_folder}/vitis_workspace"

platform create -name {impl_top_bd_wrapper}\
-hw "${root_folder}/FIOS_impl/impl_top_bd_wrapper.xsa"\
-arch {64-bit} -fsbl-target {psu_cortexa53_0}

platform write
domain create -name {standalone_psu_cortexa53_0} -display-name {standalone_psu_cortexa53_0} -os {standalone} -proc {psu_cortexa53_0} -runtime {cpp} -arch {64-bit} -support-app {hello_world}
platform generate -domains 
platform active {impl_top_bd_wrapper}
domain active {zynqmp_fsbl}
domain active {zynqmp_pmufw}
domain active {standalone_psu_cortexa53_0}
platform generate

app create -name FIOS_256 -platform {impl_top_bd_wrapper} -domain {standalone_psu_cortexa53_0} -template {Hello World}

file delete "${root_folder}/vitis_workspace/FIOS_256/src/helloworld.c"
importsource -name FIOS_256 -path "${root_folder}/SRC/VITIS/FIOS_256.c"

app build -name FIOS_256
