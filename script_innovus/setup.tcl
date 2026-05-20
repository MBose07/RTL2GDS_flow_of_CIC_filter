read_mmmc ../script_innovus/mmmc.tcl
read_physical -lef {../lef/all.lef}
read_netlist -top cic "./output_Feb06-12:16:56/cic_m.v"
set_db init_power_nets VDD
set_db init_ground_nets VSS
init_design
set_db design_process_node 180



#######################################################################
##saving
##write_def /home/rdpuser/digital_anuj/filter/save_innovus/fir.def
##write_db /home/rdpuser/digital_anuj/filter/save_innovus/fir.db
##loading
##
#######################################################################
