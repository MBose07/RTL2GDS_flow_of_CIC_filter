if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name fast\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast.lib]
create_library_set -name nom\
   -timing\
    [list ${::IMEX::libVar}/mmmc/typical.lib]
create_timing_condition -name nom_timing\
   -library_sets [list nom]
create_timing_condition -name best_timing\
   -library_sets [list fast]
create_rc_corner -name rc_nom\
   -cap_table ${::IMEX::libVar}/mmmc/t018s6mlv.capTbl\
   -pre_route_res 1\
   -post_route_res 1\
   -pre_route_cap 1\
   -post_route_cap 1\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0\
   -temperature 25\
   -qrc_tech ${::IMEX::libVar}/mmmc/rc_nom/t018s6mm.tch
create_delay_corner -name nom_nom\
   -timing_condition {nom_timing}\
   -rc_corner rc_nom
create_delay_corner -name fast_min\
   -timing_condition {best_timing}\
   -rc_corner rc_nom
create_constraint_mode -name func\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/func/func.sdc]
create_analysis_view -name func_fast_min -constraint_mode func -delay_corner fast_min -latency_file ${::IMEX::dataVar}/mmmc/views/func_fast_min/latency.sdc
create_analysis_view -name func_nom_nom -constraint_mode func -delay_corner nom_nom -latency_file ${::IMEX::dataVar}/mmmc/views/func_nom_nom/latency.sdc
set_analysis_view -setup [list func_nom_nom] -hold [list func_nom_nom func_fast_min]
