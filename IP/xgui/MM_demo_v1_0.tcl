
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/MM_demo_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set Montgomery_Multiplier_parameters [ipgui::add_group $IPINST -name "Montgomery Multiplier parameters" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "WIDTH" -parent ${Montgomery_Multiplier_parameters}
  ipgui::add_param $IPINST -name "CONFIGURATION" -parent ${Montgomery_Multiplier_parameters} -widget comboBox
  ipgui::add_param $IPINST -name "CASCADE" -parent ${Montgomery_Multiplier_parameters}
  ipgui::add_param $IPINST -name "LOOP_DELAY" -parent ${Montgomery_Multiplier_parameters}
  ipgui::add_param $IPINST -name "DSP_PRIMITIVE" -parent ${Montgomery_Multiplier_parameters} -widget comboBox
  ipgui::add_param $IPINST -name "WORD_WIDTH" -parent ${Montgomery_Multiplier_parameters}
  ipgui::add_param $IPINST -name "COL_LENGTH" -parent ${Montgomery_Multiplier_parameters}

  #Adding Group
  set DSP_registers [ipgui::add_group $IPINST -name "DSP registers" -parent ${Page_0} -layout horizontal]
  set ABREG [ipgui::add_param $IPINST -name "ABREG" -parent ${DSP_registers}]
  set_property tooltip {ABREG} ${ABREG}
  set MREG [ipgui::add_param $IPINST -name "MREG" -parent ${DSP_registers}]
  set_property tooltip {MREG} ${MREG}
  set CREG [ipgui::add_param $IPINST -name "CREG" -parent ${DSP_registers}]
  set_property tooltip {CREG} ${CREG}



}

proc update_PARAM_VALUE.CREG { PARAM_VALUE.CREG PARAM_VALUE.CASCADE } {
	# Procedure called to update CREG when any of the dependent parameters in the arguments change
	
	set CREG ${PARAM_VALUE.CREG}
	set CASCADE ${PARAM_VALUE.CASCADE}
	set values(CASCADE) [get_property value $CASCADE]
	if { [gen_USERPARAMETER_CREG_ENABLEMENT $values(CASCADE)] } {
		set_property enabled true $CREG
	} else {
		set_property enabled false $CREG
		set_property value [gen_USERPARAMETER_CREG_VALUE $values(CASCADE)] $CREG
	}
}

proc validate_PARAM_VALUE.CREG { PARAM_VALUE.CREG } {
	# Procedure called to validate CREG
	return true
}

proc update_PARAM_VALUE.LOOP_DELAY { PARAM_VALUE.LOOP_DELAY PARAM_VALUE.CASCADE } {
	# Procedure called to update LOOP_DELAY when any of the dependent parameters in the arguments change
	
	set LOOP_DELAY ${PARAM_VALUE.LOOP_DELAY}
	set CASCADE ${PARAM_VALUE.CASCADE}
	set values(CASCADE) [get_property value $CASCADE]
	if { [gen_USERPARAMETER_LOOP_DELAY_ENABLEMENT $values(CASCADE)] } {
		set_property enabled true $LOOP_DELAY
	} else {
		set_property enabled false $LOOP_DELAY
		set_property value [gen_USERPARAMETER_LOOP_DELAY_VALUE $values(CASCADE)] $LOOP_DELAY
	}
}

proc validate_PARAM_VALUE.LOOP_DELAY { PARAM_VALUE.LOOP_DELAY } {
	# Procedure called to validate LOOP_DELAY
	return true
}

proc update_PARAM_VALUE.WORD_WIDTH { PARAM_VALUE.WORD_WIDTH PARAM_VALUE.DSP_PRIMITIVE } {
	# Procedure called to update WORD_WIDTH when any of the dependent parameters in the arguments change
	
	set WORD_WIDTH ${PARAM_VALUE.WORD_WIDTH}
	set DSP_PRIMITIVE ${PARAM_VALUE.DSP_PRIMITIVE}
	set values(DSP_PRIMITIVE) [get_property value $DSP_PRIMITIVE]
	if { [gen_USERPARAMETER_WORD_WIDTH_ENABLEMENT $values(DSP_PRIMITIVE)] } {
		set_property enabled true $WORD_WIDTH
	} else {
		set_property enabled false $WORD_WIDTH
		set_property value [gen_USERPARAMETER_WORD_WIDTH_VALUE $values(DSP_PRIMITIVE)] $WORD_WIDTH
	}
}

proc validate_PARAM_VALUE.WORD_WIDTH { PARAM_VALUE.WORD_WIDTH } {
	# Procedure called to validate WORD_WIDTH
	return true
}

proc update_PARAM_VALUE.ABREG { PARAM_VALUE.ABREG } {
	# Procedure called to update ABREG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ABREG { PARAM_VALUE.ABREG } {
	# Procedure called to validate ABREG
	return true
}

proc update_PARAM_VALUE.CASCADE { PARAM_VALUE.CASCADE } {
	# Procedure called to update CASCADE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CASCADE { PARAM_VALUE.CASCADE } {
	# Procedure called to validate CASCADE
	return true
}

proc update_PARAM_VALUE.COL_LENGTH { PARAM_VALUE.COL_LENGTH } {
	# Procedure called to update COL_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COL_LENGTH { PARAM_VALUE.COL_LENGTH } {
	# Procedure called to validate COL_LENGTH
	return true
}

proc update_PARAM_VALUE.CONFIGURATION { PARAM_VALUE.CONFIGURATION } {
	# Procedure called to update CONFIGURATION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CONFIGURATION { PARAM_VALUE.CONFIGURATION } {
	# Procedure called to validate CONFIGURATION
	return true
}

proc update_PARAM_VALUE.DSP_PRIMITIVE { PARAM_VALUE.DSP_PRIMITIVE } {
	# Procedure called to update DSP_PRIMITIVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DSP_PRIMITIVE { PARAM_VALUE.DSP_PRIMITIVE } {
	# Procedure called to validate DSP_PRIMITIVE
	return true
}

proc update_PARAM_VALUE.MREG { PARAM_VALUE.MREG } {
	# Procedure called to update MREG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MREG { PARAM_VALUE.MREG } {
	# Procedure called to validate MREG
	return true
}

proc update_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH } {
	# Procedure called to update WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH } {
	# Procedure called to validate WIDTH
	return true
}


proc update_MODELPARAM_VALUE.CONFIGURATION { MODELPARAM_VALUE.CONFIGURATION PARAM_VALUE.CONFIGURATION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CONFIGURATION}] ${MODELPARAM_VALUE.CONFIGURATION}
}

proc update_MODELPARAM_VALUE.ABREG { MODELPARAM_VALUE.ABREG PARAM_VALUE.ABREG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ABREG}] ${MODELPARAM_VALUE.ABREG}
}

proc update_MODELPARAM_VALUE.MREG { MODELPARAM_VALUE.MREG PARAM_VALUE.MREG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MREG}] ${MODELPARAM_VALUE.MREG}
}

proc update_MODELPARAM_VALUE.CREG { MODELPARAM_VALUE.CREG PARAM_VALUE.CREG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CREG}] ${MODELPARAM_VALUE.CREG}
}

proc update_MODELPARAM_VALUE.CASCADE { MODELPARAM_VALUE.CASCADE PARAM_VALUE.CASCADE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CASCADE}] ${MODELPARAM_VALUE.CASCADE}
}

proc update_MODELPARAM_VALUE.LOOP_DELAY { MODELPARAM_VALUE.LOOP_DELAY PARAM_VALUE.LOOP_DELAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LOOP_DELAY}] ${MODELPARAM_VALUE.LOOP_DELAY}
}

proc update_MODELPARAM_VALUE.WIDTH { MODELPARAM_VALUE.WIDTH PARAM_VALUE.WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH}] ${MODELPARAM_VALUE.WIDTH}
}

proc update_MODELPARAM_VALUE.DSP_PRIMITIVE { MODELPARAM_VALUE.DSP_PRIMITIVE PARAM_VALUE.DSP_PRIMITIVE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DSP_PRIMITIVE}] ${MODELPARAM_VALUE.DSP_PRIMITIVE}
}

proc update_MODELPARAM_VALUE.COL_LENGTH { MODELPARAM_VALUE.COL_LENGTH PARAM_VALUE.COL_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COL_LENGTH}] ${MODELPARAM_VALUE.COL_LENGTH}
}

proc update_MODELPARAM_VALUE.WORD_WIDTH { MODELPARAM_VALUE.WORD_WIDTH PARAM_VALUE.WORD_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WORD_WIDTH}] ${MODELPARAM_VALUE.WORD_WIDTH}
}

