create_library_set -name nom\
    -timing\
    [list ../lib/typical.lib  ]
create_library_set -name fast\
   -timing\
    [list ../lib/fast.lib ]
#create_library_set -name slow\
#   -timing\
#    [list /home/rdpuser/digital_anuj/anuj_downloads/PDKs/sky130_scl_9T_0.1.1/sky130_scl_9T/lib/sky130_ss_1.62_125_nldm.lib ]

#create_timing_condition -name worst_timing\
#   -library_set slow
create_timing_condition -name nom_timing\
   -library_set nom
create_timing_condition -name best_timing\
   -library_set fast

#create_rc_corner -name rc_best\
#   -cap_table /home/rdpuser/digital_anuj/flow_2/Captbl/skywater.CapTbl\
#   -qrc_tech ../qrc/t018s6mm.tch\
#   -T 0
create_rc_corner -name rc_nom\
   -cap_table ../captable/t018s6mlv.capTbl\
   -qrc_tech ../qrc/t018s6mm.tch\
   -T 25
#create_rc_corner -name rc_worst\
#   -cap_table /home/rdpuser/digital_anuj/flow_2/Captbl/skywater.CapTbl\
#   -qrc_tech ../qrc/t018s6mm.tch\
#   -T 125

#create_delay_corner -name slow_max\
#   -timing_condition worst_timing\
#   -rc_corner rc_worst
create_delay_corner -name nom_nom\
   -timing_condition nom_timing\
   -rc_corner rc_nom
create_delay_corner -name fast_min\
   -timing_condition best_timing\
   -rc_corner rc_nom

create_constraint_mode -name func\
   -sdc_files\
    [list ./output_Feb06-12:16:56/cic_m.sdc]
#create_analysis_view -name func_slow_max -constraint_mode func -delay_corner slow_max
create_analysis_view -name func_nom_nom -constraint_mode func -delay_corner nom_nom
create_analysis_view -name func_fast_min -constraint_mode func -delay_corner fast_min
set_analysis_view -setup [list func_nom_nom] -hold [list func_nom_nom func_fast_min]
