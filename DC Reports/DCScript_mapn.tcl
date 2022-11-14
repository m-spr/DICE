remove_design -all
set designer "Mahboobeh"
set power_preserve_rtl_hier_names "true"
set search_path "/home/icic/Desktop/Power/New"
define_design_lib work -path "work"

set topname "MAP_n_m"

set target_library  /home/icic/Desktop/Power/New/Nandgate45.db
set link_library    /home/icic/Desktop/Power/New/Nandgate45.db


analyze -library WORK -format vhdl -lib work "mapn.vhd"
elaborate $topname -lib work -update

current_design $topname

set auto_wire_load_selection "true"
create_clock -period 4.2 {"clk"}

compile

report_timing -nworst 1  > "Out_Typical/MAP_n_m.timing.report"
report_area  > "Out_Typical/MAP_n_m.area.report"
report_power -cell -verbose > "Out_Typical/MAP_n_m.power.report"
report_qor > "Out_Typical/MAP_n_m.summary.report"
report_constraint > "Out_Typical/MAP_n_m.constraint.report"

exit
