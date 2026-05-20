#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Fri Feb  6 12:26:46 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.15-s110_1 (64bit) 09/23/2022 13:08 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.15-s110_1 NR220912-2004/21_15-UB (database version 18.20.592) {superthreading v2.17}
#@(#)CDS: AAE 21.15-s039 (64bit) 09/23/2022 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.15-s038_1 () Sep 20 2022 11:42:13 ( )
#@(#)CDS: SYNTECH 21.15-s012_1 () Sep  5 2022 10:25:51 ( )
#@(#)CDS: CPE v21.15-s076
#@(#)CDS: IQuantus/TQuantus 21.1.1-s867 (64bit) Sun Jun 26 22:12:54 PDT 2022 (Linux 3.10.0-693.el7.x86_64)

read_mmmc ../script_innovus/mmmc.tcl
#@ Begin verbose source (pre): 
create_library_set -name nom\
    -timing\
    [list ../lib/typical.lib  ]
create_library_set -name fast\
   -timing\
    [list ../lib/fast.lib ]
create_timing_condition -name nom_timing\
   -library_set nom
create_timing_condition -name best_timing\
   -library_set fast
create_rc_corner -name rc_nom\
   -cap_table ../captable/t018s6mlv.capTbl\
   -qrc_tech ../qrc/t018s6mm.tch\
   -T 25
create_delay_corner -name nom_nom\
   -timing_condition nom_timing\
   -rc_corner rc_nom
create_delay_corner -name fast_min\
   -timing_condition best_timing\
   -rc_corner rc_nom
create_constraint_mode -name func\
   -sdc_files\
    [list ./output_Feb06-12:16:56/cic_m.sdc]
create_analysis_view -name func_nom_nom -constraint_mode func -delay_corner nom_nom
create_analysis_view -name func_fast_min -constraint_mode func -delay_corner fast_min
set_analysis_view -setup [list func_nom_nom] -hold [list func_nom_nom func_fast_min]
#@ End verbose source: ../script_innovus/mmmc.tcl
read_physical -lef {../lef/all.lef}
read_netlist -top cic "./output_Feb06-12:16:56/cic_m.v"
set_db init_power_nets VDD
set_db init_ground_nets VSS
init_design
set_db design_process_node 180
set_io_flow_flag 0
create_floorplan -site tsm3site -core_density_size 0.973654343049 0.699988 20 20 20 20
set_io_flow_flag 0
create_floorplan -site tsm3site -core_density_size 0.924901185771 0.699474 20.46 20.16 20.46 20.16
delete_global_net_connections
connect_global_net VDD -type pg_pin -pin_base_name VDD -inst_base_name * -hinst {}
connect_global_net VDD -type tie_hi -pin_base_name VDD -inst_base_name * -hinst {}
connect_global_net VSS -type tie_lo -pin_base_name VSS -inst_base_name * -hinst {}
connect_global_net VSS -type pg_pin -pin_base_name VSS -inst_base_name * -hinst {}
set_db add_rings_target default
set_db add_rings_extend_over_row 0
set_db add_rings_ignore_rows 0
set_db add_rings_avoid_short 0
set_db add_rings_skip_shared_inner_ring none
set_db add_rings_stacked_via_top_layer Metal6
set_db add_rings_stacked_via_bottom_layer Metal1
set_db add_rings_via_using_exact_crossover_size 1
set_db add_rings_orthogonal_only true
set_db add_rings_skip_via_on_pin {  standardcell }
set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top Metal5 bottom Metal5 left Metal6 right Metal6} -width {top 1 bottom 1 left 1 right 1} -spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
set_db add_rings_target default
set_db add_rings_extend_over_row 0
set_db add_rings_ignore_rows 0
set_db add_rings_avoid_short 0
set_db add_rings_skip_shared_inner_ring none
set_db add_rings_stacked_via_top_layer Metal6
set_db add_rings_stacked_via_bottom_layer Metal1
set_db add_rings_via_using_exact_crossover_size 1
set_db add_rings_orthogonal_only true
set_db add_rings_skip_via_on_pin {  standardcell }
set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top Metal5 bottom Metal5 left Metal6 right Metal6} -width {top 1 bottom 1 left 1 right 1} -spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at {  block_ring  }
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target none
set_db add_stripes_stop_at_last_wire_for_area false
set_db add_stripes_partial_set_through_domain false
set_db add_stripes_ignore_non_default_domains false
set_db add_stripes_trim_antenna_back_to_shape none
set_db add_stripes_spacing_type edge_to_edge
set_db add_stripes_spacing_from_block 0
set_db add_stripes_stripe_min_length stripe_width
set_db add_stripes_stacked_via_top_layer Metal6
set_db add_stripes_stacked_via_bottom_layer Metal1
set_db add_stripes_via_using_exact_crossover_size false
set_db add_stripes_split_vias false
set_db add_stripes_orthogonal_only true
set_db add_stripes_allow_jog { padcore_ring }
set_db add_stripes_skip_via_on_pin {  standardcell }
set_db add_stripes_skip_via_on_wire_shape {  noshape   }
add_stripes -nets {VDD VSS} -layer Metal6 -direction vertical -width 0.88 -spacing 1.8 -number_of_sets 5 -start_from left -start_offset 30 -stop_offset 30 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit Metal6 -pad_core_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal6 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid none
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at {  block_ring  }
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target none
set_db add_stripes_stop_at_last_wire_for_area false
set_db add_stripes_partial_set_through_domain false
set_db add_stripes_ignore_non_default_domains false
set_db add_stripes_trim_antenna_back_to_shape none
set_db add_stripes_spacing_type edge_to_edge
set_db add_stripes_spacing_from_block 0
set_db add_stripes_stripe_min_length stripe_width
set_db add_stripes_stacked_via_top_layer Metal6
set_db add_stripes_stacked_via_bottom_layer Metal1
set_db add_stripes_via_using_exact_crossover_size false
set_db add_stripes_split_vias false
set_db add_stripes_orthogonal_only true
set_db add_stripes_allow_jog { padcore_ring }
set_db add_stripes_skip_via_on_pin {  standardcell }
set_db add_stripes_skip_via_on_wire_shape {  noshape   }
add_stripes -nets {VDD VSS} -layer Metal6 -direction vertical -width 0.88 -spacing 1.8 -number_of_sets 5 -start_from left -start_offset 30 -stop_offset 30 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit Metal6 -pad_core_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal6 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid none
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at {  block_ring  }
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target none
set_db add_stripes_stop_at_last_wire_for_area false
set_db add_stripes_partial_set_through_domain false
set_db add_stripes_ignore_non_default_domains false
set_db add_stripes_trim_antenna_back_to_shape none
set_db add_stripes_spacing_type edge_to_edge
set_db add_stripes_spacing_from_block 0
set_db add_stripes_stripe_min_length stripe_width
set_db add_stripes_stacked_via_top_layer Metal6
set_db add_stripes_stacked_via_bottom_layer Metal1
set_db add_stripes_via_using_exact_crossover_size false
set_db add_stripes_split_vias false
set_db add_stripes_orthogonal_only true
set_db add_stripes_allow_jog { padcore_ring }
set_db add_stripes_skip_via_on_pin {  standardcell }
set_db add_stripes_skip_via_on_wire_shape {  noshape   }
add_stripes -nets {VDD VSS} -layer Metal5 -direction horizontal -width 0.56 -spacing 1.8 -number_of_sets 5 -start_from bottom -start_offset 30 -stop_offset 30 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit Metal6 -pad_core_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal6 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid none
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at {  block_ring  }
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target none
set_db add_stripes_stop_at_last_wire_for_area false
set_db add_stripes_partial_set_through_domain false
set_db add_stripes_ignore_non_default_domains false
set_db add_stripes_trim_antenna_back_to_shape none
set_db add_stripes_spacing_type edge_to_edge
set_db add_stripes_spacing_from_block 0
set_db add_stripes_stripe_min_length stripe_width
set_db add_stripes_stacked_via_top_layer Metal6
set_db add_stripes_stacked_via_bottom_layer Metal1
set_db add_stripes_via_using_exact_crossover_size false
set_db add_stripes_split_vias false
set_db add_stripes_orthogonal_only true
set_db add_stripes_allow_jog { padcore_ring }
set_db add_stripes_skip_via_on_pin {  standardcell }
set_db add_stripes_skip_via_on_wire_shape {  noshape   }
add_stripes -nets {VDD VSS} -layer Metal5 -direction horizontal -width 0.56 -spacing 1.8 -number_of_sets 5 -start_from bottom -start_offset 30 -stop_offset 30 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit Metal6 -pad_core_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal6 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid none
route_special -connect core_pin -nets {VDD VSS}
check_connectivity 
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both
set_db place_global_place_io_pins true
set_dont_use *XL true
set_dont_use *X1 true
place_opt_design
set_db add_tieoffs_cells "TIEHI TIELO"
add_tieoffs
place_detail
write_db ./DBS/prects.db
set_db route_early_global_bottom_routing_layer 2
set_db route_early_global_top_routing_layer 6
set_db route_early_global_honor_power_domain false
set_db route_early_global_honor_partition_pin_guide true
route_early_global
report_congestion -hotspot 
write_db ./DBS/preRC.db
gui_deselect -all
gui_select -point {30.92200 207.19450}
gui_select -point {37.19200 207.84000}
extract_rc
write_parasitics -spef_file rc.spef -rc_corner rc_nom
time_design -pre_cts -path_report -drv_report -slack_report -num_paths 50 -report_prefix fir_preCTS -report_dir timingReports
create_route_rule -width {Metal1 0.240 Metal2 0.280 Metal3 0.280 Metal4 0.280 Metal5 0.280 Metal6 0.440} -spacing {Metal1 0.280 Metal2 0.350 Metal3 0.320 Metal4 0.320 Metal5 0.320 Metal6 0.480} -name 2w2s
create_route_type -name clkroute -route_rule 2w2s -bottom_preferred_layer Metal2 -top_preferred_layer Metal5
set_db cts_route_type_trunk clkroute
set_db cts_route_type_leaf clkroute
set_db cts_inverter_cells {CLKINVXL CLKINVX1 CLKINVX2 CLKINVX3 CLKINVX4 CLKINVX8 CLKINVX12 CLKINVX16 CLKINVX20 }
set_db cts_buffer_cells {CLKBUFXL CLKBUFX1 CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20 }
create_clock_tree_spec -out_file ccopt.spec
#@ source ccopt.spec
#@ Begin verbose source (pre): source ccopt.spec
if { [get_db clock_trees] != {} } {...}
namespace eval ::ccopt {}
namespace eval ::ccopt::ilm {}
set ::ccopt::ilm::ccoptSpecRestoreData {}
if { [catch {ccopt_check_and_flatten_ilms_no_restore}] } {...}
set ::ccopt::ilm::ccoptSpecRestoreData $::ccopt::ilm::ccoptRestoreILMState
set_db port:clk .cts_is_sdc_clock_root true
create_clock_tree -name clk -source clk -no_skew_group
set_db port:clk .cts_clock_period 100
set_db cts_timing_connectivity_info {}
create_skew_group -name clk/func -sources clk -auto_sinks
set_db skew_group:clk/func .cts_skew_group_include_source_latency true
set_db skew_group:clk/func .cts_skew_group_created_from_clock clk
set_db skew_group:clk/func .cts_skew_group_created_from_constraint_mode func
set_db skew_group:clk/func .cts_skew_group_created_from_delay_corners {nom_nom fast_min}
check_clock_tree_convergence
if { [get_db ccopt_auto_design_state_for_ilms] == 0 } {...}
#@ End verbose source: ccopt.spec
ccopt_design
write_db ./DBS/cts.db
time_design -post_cts
time_design -post_cts -hold
write_db ./DBS/postcts.db
set_db route_design_antenna_diode_insertion 1
set_db route_design_antenna_cell_name ANTENNA
set_db route_design_with_timing_driven 1
set_db route_design_with_si_driven 1
set_db route_design_top_routing_layer 5
set_db route_design_bottom_routing_layer 1
set_db route_design_detail_end_iteration 0
set_db route_design_with_timing_driven true
set_db route_design_with_si_driven true
route_design -global_detail
set_layer_preference violation -is_visible 1
route_eco -fix_drc
delete_routes -regular_wire_with_drc
route_design
check_connectivity 
check_drc
check_antenna
write_db ./DBS/route.db
set_db extract_rc_engine post_route
set_db extract_rc_effort_level medium
time_design -post_route
time_design -post_route -hold
opt_design -post_route -setup -hold
write_db ./DBS/final.db
check_drc 
check_antenna 
check_connectivity 
gui_pan 5.21200 11.57850
gui_pan 2.56050 15.84300
gui_pan 6.72100 4.64100
check_floorplan
check_place 
check_tieoffs 
check_pin_assignment 
check_metal_density 
set_layer_preference node_inst -is_visible 0
set_layer_preference node_module -is_visible 0
set_layer_preference node_cell -is_visible 1
set_layer_preference node_cell -is_visible 0
set_layer_preference node_partition -is_visible 0
set_layer_preference node_net -is_visible 0
set_layer_preference node_route -is_visible 0
set_layer_preference node_inst -is_visible 1
set_layer_preference instanceCell -is_visible 0
set_layer_preference node_module -is_visible 1
set_layer_preference node_module -is_visible 0
set_layer_preference node_cell -is_visible 1
set_layer_preference node_cell -is_visible 0
set_layer_preference node_blockage -is_visible 1
set_layer_preference node_blockage -is_visible 0
set_layer_preference node_row -is_visible 1
gui_pan -6.75350 22.10700
set_layer_preference node_partition -is_visible 1
set_layer_preference node_partition -is_visible 0
set_layer_preference node_power -is_visible 1
set_layer_preference node_power -is_visible 0
set_layer_preference node_overlay -is_visible 1
set_layer_preference node_overlay -is_visible 0
set_layer_preference node_track -is_visible 1
set_layer_preference node_track -is_visible 0
set_layer_preference node_net -is_visible 1
set_layer_preference node_net -is_visible 0
set_layer_preference node_route -is_visible 1
set_layer_preference node_route -is_visible 0
set_layer_preference node_layer -is_visible 0
set_layer_preference node_layer -is_visible 1
opt_design -h
check_tracks 
check_noise 
route_design -wire_opt 
set_layer_preference instanceCell -is_visible 1
set_layer_preference node_module -is_visible 1
set_layer_preference node_cell -is_visible 1
set_layer_preference node_blockage -is_visible 1
set_layer_preference node_floorplan -is_visible 1
set_layer_preference node_partition -is_visible 1
set_layer_preference node_power -is_visible 1
set_layer_preference node_track -is_visible 1
set_layer_preference node_net -is_visible 1
set_layer_preference node_route -is_visible 1
gui_pan -47.44900 -20.43200
set_layer_preference node_overlay -is_visible 1
set_layer_preference node_overlay -is_visible 0
set_layer_preference node_gird -is_visible 1
set_layer_preference node_gird -is_visible 0
set_layer_preference node_misc -is_visible 1
set_layer_preference node_misc -is_visible 0
set_layer_preference node_row -is_selectable 1
set_layer_preference node_misc -is_visible 1
set_layer_preference node_overlay -is_visible 1
set_layer_preference node_overlay -is_visible 0
set_layer_preference node_power -is_selectable 1
set_layer_preference node_gird -is_visible 1
set_layer_preference node_gird -is_visible 0
route_design -via_opt
add_fillers
route_eco -fix_drc
check_connectivity
gui_pan -0.94550 32.01150
gui_pan 7.93600 -69.68050
set_layer_preference node_misc -is_visible 0
gui_pan 20.35200 7.87800
set_layer_preference violation -is_visible 1
gui_select -point {264.88400 263.18050}
exit
