
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name TIC_TAC_TOE_XO_ASSIGNMENT -dir "D:/Lab Advanced Digital/TIC_TAC_TOE_XO_ASSIGNMENT/planAhead_run_4" -part xc6slx9tqg144-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "Tic_Tac_Toe_XO_Main.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {VHDL/SwitchDebounce.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VHDL/ClockDividerTo500ms.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VHDL/checkWin.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VHDL/CheckKeypad.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VHDL/Tic_Tac_Toe_XO_Main.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top Tic_Tac_Toe_XO_Main $srcset
add_files [list {Tic_Tac_Toe_XO_Main.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-3
