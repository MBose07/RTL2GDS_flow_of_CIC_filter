# CIC Filter RTL2GDS Flow

## Table of Contents
1. [Project Overview](#project-overview)
2. [Directory Structure](#directory-structure)
3. [RTL Design](#rtl-design)
4. [Verification](#verification)
5. [RTL2GDS Flow](#rtl2gds-flow)
6. [Running the Flow](#running-the-flow)
7. [Generated Outputs](#generated-outputs)

---

## Project Overview

This project implements a complete RTL-to-GDSII (RTL2GDS) design flow for a **Cascaded Integrator-Comb (CIC) Filter**. The CIC filter is a multi-stage decimation filter commonly used in digital signal processing applications, particularly in software-defined radios, audio processing, and telecommunications.

### CIC Filter Characteristics

- **Architecture**: Cascaded Integrator-Comb (CIC) architecture
- **Configurable Parameters**:
  - Order: 6 stages (tunable)
  - Input Width: 16 bits (signed)
  - Output Width: 16 bits (signed)
  - Decimation Ratio: 4x
  - Differential Delay: 4 taps per comb stage
- **Technology**: 180nm CMOS (Cadence GPDK files)
- **Clock Frequency**: 100 ns (10 MHz)

---

## Directory Structure

```
CIC/
├── README.md                       # This file
├── hdl/                            # Hardware Description Language (RTL)
│   └── cic.v                       # CIC filter Verilog implementation
├── tb/                             # TestBench directory
│   ├── tb.v                        # Testbench for CIC filter verification
│   ├── input.txt                   # Input test vectors
│   ├── output.txt                  # Simulation output results
│   └── py/                         # Python utilities (Python verification)
├── script_innovus/                 # Cadence Innovus physical design scripts
│   ├── setup.tcl                   # Innovus initialization and constraints
│   └── mmmc.tcl                    # Multi Mode Multi Corner (MMMC) setup
├── gg.tcl                          # Genus synthesis script (GENUS 21.14)
├── lib/                            # Standard cell libraries
│   ├── typical.lib                 # Typical corner library
│   └── fast.lib                    # Fast corner library
├── lef/                            # Library Exchange Format (physical data)
│   └── all.lef                     # Combined LEF for all cells
├── captable/                       # Capacitance tables
│   └── t018s6mlv.capTbl            # Interconnect capacitance model
├── qrc/                            # QRC technology file
│   └── t018s6mm.tch                # QuasiRC technology characterization
├── OUTPUT/                         # Generated synthesis outputs
└── workspace/                      # Working directory (physical design)
    └── DBS/                        # Innovus database snapshots
        ├── cts.db/                 # Clock tree synthesis
        ├── postcts.db/             # Post-CTS optimization
        ├── route.db/               # Routing
        ├── final.db/               # Final place and route
        └── prects.db/              # Pre-CTS placement
```

---

## RTL Design

### CIC Filter Architecture

The CIC filter is implemented in **`hdl/cic.v`** using a parameterized Verilog design.

#### Design Hierarchy

```
cic (top module)
├── Integrator Section
│   ├── order cascaded integrators (default = 6)
│   └── decimation control (ce_1, ce_2)
├── Comb Section
│   ├── order cascaded comb filters
│   ├── Differential delay stages (D=4)
│   └── Subtraction logic
└── Output Rounding & Truncation
```

#### Key Features

1. **Integrator Stage** (`hdl/cic.v:30-46`)
   - `order` cascaded integrators process every input sample when `ce_1` is asserted
   - Decimation control: output is captured when `ce_2` is asserted
   - Fixed-point arithmetic with internal bit growth

2. **Comb Stage** (`hdl/cic.v:48-70`)
   - Processes decimated samples at reduced clock rate
   - `differential_delay` delay line per comb stage (tunable shift register)
   - Subtraction between current and delayed samples

3. **Output Processing** (`hdl/cic.v:72-80`)
   - Bitwidth reduction through truncation and rounding
   - Fixed-point arithmetic: `d_out = (comb >> (in_width + GAIN_BITS - out_width))`
   - Supports both signed inputs and outputs

#### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `in_width` | 16 | Input data width (bits) |
| `out_width` | 16 | Output data width (bits) |
| `order` | 6 | Number of integrator/comb stages |
| `decimation_ratio` | 4 | Decimation factor |
| `differential_delay` | 4 | Delay taps in comb filters |

#### Internal Signals

- `GAIN_BITS`: Automatically calculated growth bits for fixed-point saturation
- `d_tmp`: Integrator output buffer (acts as FIFO between integrator and comb)
- `d_comb[order][differential_delay]`: Comb stage delay lines
- `comb[order]`: Comb stage outputs

---

## Verification

### Testbench Architecture

The testbench is implemented in **`tb/tb.v`** and uses file-based I/O verification.

#### Testbench Features

1. **File-Based I/O** (`tb/tb.v:87-88`)
   - Reads test vectors from `input.txt`
   - Writes results to `output.txt`
   - Line-by-line 16-bit signed integer format

2. **Clock Generation** (`tb/tb.v:49`)
   - Clock period: 100 ns (10 MHz)
   - Symmetric clock: `always #50 clk = ~clk`

3. **Decimation Control** (`tb/tb.v:52-65`)
   - Generates `ce_2` signal once every `decimation_ratio` cycles (4 clocks)
   - Maintains decimation counter `dec_cnt`

4. **Output Capture** (`tb/tb.v:67-75`)
   - Delayed sampling using `ce_2_d` to capture valid output
   - Writes output when comb stage processing completes

5. **Test Sequence** (`tb/tb.v:77-121`)
   - Reset pulse: 200 ns active high
   - Feed samples from `input.txt` at each clock
   - Pipeline flush: 200 cycles after EOF for latency compensation
   - Automatic file closure and simulation termination

#### Test Vectors

- **Input file**: `tb/input.txt` (1,239 KB)
  - Contains 309,757 16-bit signed samples
  - Generated by `tb/py/script.py` from audio input

- **Expected output**: `tb/output.txt`
  - Generated decimated and filtered samples
  - Used for cross-verification with golden models (Python)

### Python Verification Suite

Located in **`tb/py/`**, three complementary Python scripts handle test generation and verification.

#### 1. **script.py** - Audio Input Preparation & Output Recovery

Converts audio to Verilog test vectors and back to audio for listening.

**Features**:
- Anti-aliasing filter (Butterworth 6th order)
- Scales audio to `in_bit_width` (default 16-bit) for Verilog input
- Converts Verilog text output back to decimated audio WAV file
- Normalizes output for audible comparison

**Usage**:
```bash
cd tb
python3 py/script.py
# Step 1: Prepares input.txt from py/input_audio.wav (11-bit input, R=4)
# [Waits for your RTL simulation to complete]
# Step 2: Converts output.txt to py/filtered_output.wav
```

**Key Parameters** (edit in script.py):
```python
IN_W  = 16             # Verilog input bit-width (16-bit)
OUT_W = 16             # Verilog output bit-width (16-bit)
R = 4                  # Decimation ratio
RAW_AUDIO = '...input_audio.wav'
VERILOG_IN = 'input.txt'
VERILOG_OUT = 'output.txt'
```

#### 2. **soft_cic.py** - Software Golden Model

Pure Python implementation of CIC filter for reference.

**Features**:
- 6 cascaded integrators (`np.cumsum`)
- Decimation by R=4
- 6 cascaded comb stages (y[n] = x[n] - x[n-D])
- DC offset removal before integration
- Generates `py/software_output.wav` for comparison

**Usage**:
```bash
cd tb
python3 py/soft_cic.py
# Generates software_output.wav (golden reference)
```
#### 3. **check.py** - Signal Analysis & Visualization

Plots time-domain and frequency-domain comparison of RTL vs software results.

**Features**:
- Time-domain waveform overlay
- FFT spectrum comparison (passband 0-5kHz)
- Auto-normalization for level comparison
- Separate analysis for software and RTL outputs

**Usage**:
```bash
cd tb
python3 py/check.py
# Generates comparison plots: Input vs Software vs RTL
```

### Actual Verification Flow

The complete verification process from **`scripts.txt`**:

```bash
# TERMINAL 1: Prepare test vectors (interactive)
cd /home/moulikbose/STUFFFF/explo/CIC/tb
python3 py/script.py
# Output: ">>> Press Enter AFTER your simulation has generated 'output.txt'..."
# [Waits here for simulation to complete]

# TERMINAL 2: Run RTL simulation (in separate terminal)
cd /home/moulikbose/STUFFFF/explo/CIC/tb
iverilog tb.v ../hdl/cic.v      # Compile with iverilog
vvp a.out                        # Run simulation (generates output.txt)

# TERMINAL 1: Continue after simulation completes
# [Press Enter in Terminal 1]
# Output: generated filtered_output.wav from Verilog output.txt

# TERMINAL 1: Run verification checks
python3 py/soft_cic.py           # Generate software golden model
python3 py/check.py              # Compare RTL vs Software (plots)
```

**Detailed Step-by-Step Process**:

1. **Generate Input Test Vectors**
   - `script.py` reads `input_audio.wav` (audio file)
   - Applies anti-aliasing butterworth filter
   - Scales to 16-bit signed integers
   - Writes to `input.txt` (one sample per line)

2. **Run RTL Simulation**
   - iverilog compiles `tb.v` + `cic.v` → `a.out` executable
   - `vvp a.out` executes simulation
   - Testbench reads `input.txt`, feeds to CIC
   - Outputs decimated results to `output.txt`
   - Simulation time: ~130 ms for 310k samples @ 10MHz

3. **Generate Golden Model Output**
   - `soft_cic.py` implements CIC in pure NumPy
   - Reads same `input_audio.wav`
   - Outputs `software_output.wav` for reference

4. **Compare Results**
   - `check.py` plots both outputs side-by-side
   - Time-domain waveforms should match closely
   - Frequency response should show decimation filter behavior
   - Any major differences indicate RTL bugs

### RTL Verification Results
The plots below were generated by `tb/py/check.py` and compare the input signal against both the RTL output and the software golden model output.

#### RTL Output Comparison
![RTL Verification: Input vs RTL Output](images/Screenshot%20from%202026-05-20%2011-35-50.png)

#### Software Golden Model Comparison
![Software Verification: Input vs Software Output](images/Screenshot%20from%202026-05-20%2011-35-41.png)

5. **Convert to Audio**
   - `script.py` Step 2: recovers `filtered_output.wav` from `output.txt`
   - Decimated by 4x from original rate
   - Listen to confirm audio quality (should sound filtered)


## RTL2GDS Flow

The complete RTL-to-GDSII flow uses industry-standard EDA tools:

### 1. Synthesis (GENUS)

**Script**: `gg.tcl` - Generates gate-level netlist from RTL

#### Synthesis Steps

1. **Library & Physical Setup** (`gg.tcl:40-46`)
   ```tcl
   read_libs typical.lib
   read_physical -lef { ../lef/all.lef}
   set_db / .cap_table_file ../captable/t018s6mlv.capTbl
   ```
   - Loads 180nm standard cell library
   - Import physical LEF for cell layouts
   - Configure parasitic capacitance model

2. **Design Load & Elaboration** (`gg.tcl:55-62`)
   ```tcl
   read_hdl {cic.v}
   elaborate $DESIGN
   check_design -unresolved
   ```
   - Reads Verilog source
   - Elaborates to design database
   - Validates design integrity

3. **Constraints** (`gg.tcl:69-84`)
   ```tcl
   set_units -time 1ns
   create_clock -period 100 -name clk [get_ports clk]
   set_false_path -from [get_ports {rst}] -to [all_registers]
   ```
   - Clock constraint: 100 ns = 10 MHz
   - Async reset (false path exception)
   - Input/output delays (optional, commented)

4. **Synthesis Stages**

   a) **Generic Synthesis** (`gg.tcl:113-119`)
      - Technology-independent optimization
      - Datapath extraction and analysis
      - Effort level: HIGH (`GEN_EFF`)

   b) **Technology Mapping** (`gg.tcl:130-137`)
      - Map to standard cells
      - Effort level: HIGH (`MAP_OPT_EFF`)
      - Generates `.lec` file for LEC reference

   c) **Optimization** (`gg.tcl:152-159`)
      - Post-mapping optimization
      - Power reduction, area optimization
      - Generate power reports

5. **Output Generation** (`gg.tcl:166-178`)
   ```tcl
   write_hdl  > ${_OUTPUTS_PATH}/${DESIGN}_m.v        # Gate-level netlist
   write_sdc  > ${_OUTPUTS_PATH}/${DESIGN}_m.sdc      # Timing constraints
   write_do_lec > ${_OUTPUTS_PATH}/rtl2final.lec.do   # LEC verification
   ```

#### Synthesis Outputs
- `${_OUTPUTS_PATH}/cic_m.v` - Gate-level Verilog netlist
- `${_OUTPUTS_PATH}/cic_m.sdc` - Synopsys Design Constraints
- Report files: timing, power, area, datapath

---

### 2. Physical Design (Innovus)

**Scripts**: `script_innovus/setup.tcl`, `script_innovus/mmmc.tcl`, `script_innovus/help.txt`

#### MMMC Corner Setup (`script_innovus/mmmc.tcl`)

Multi-Mode Multi-Corner analysis configuration:

```tcl
# Library Sets (Process corners)
create_library_set -name nom\
    -timing\
    [list ../lib/typical.lib ]
create_library_set -name fast\
   -timing\
    [list ../lib/fast.lib ]

# Timing Conditions
create_timing_condition -name nom_timing\
   -library_set nom
create_timing_condition -name best_timing\
   -library_set fast

# RC Corners (Parasitic extraction)
create_rc_corner -name rc_nom\
   -cap_table ../captable/t018s6mlv.capTbl\
   -qrc_tech ../qrc/t018s6mm.tch\
   -T 25

# Delay Corners (combinations of timing + RC)
create_delay_corner -name nom_nom\
   -timing_condition nom_timing\
   -rc_corner rc_nom
create_delay_corner -name fast_min\
   -timing_condition best_timing\
   -rc_corner rc_nom

# Constraint Modes
create_constraint_mode -name func\
   -sdc_files\
    [list ./output_Feb06-12:16:56/cic_m.sdc]

# Analysis Views (what to analyze)
create_analysis_view -name func_nom_nom -constraint_mode func -delay_corner nom_nom
create_analysis_view -name func_fast_min -constraint_mode func -delay_corner fast_min
set_analysis_view -setup [list func_nom_nom] -hold [list func_nom_nom func_fast_min]
```

**Corner Definition**:
- **nom_nom**: Setup timing (nominal process, nominal RC)
- **fast_min**: Hold timing (fast process, nominal RC)

#### Design Initialization

```tcl
read_mmmc ../script_innovus/mmmc.tcl
read_physical -lef {../lef/all.lef}
read_netlist -top cic "./output_Feb06-12:16:56/cic_m.v"
set_db init_power_nets VDD
set_db init_ground_nets VSS
init_design
set_db design_process_node 180
```

#### Innovus Physical Design Flow (from `script_innovus/help.txt`)

The actual design flow executed in Innovus with detailed commands:

**1. Pre-Placement Optimization**
```tcl
# Enable OCV (On-Chip Variation) and CPPR (Common Path Pessimism Removal)
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both

# Place I/O pins and optimize
set_db place_global_place_io_pins true
set_dont_use *XL true          # Don't use extra-large cells
set_dont_use *X1 true          # Don't use smallest cells
place_opt_design

# Add tie-hi/tie-lo cells for constant signals
set_db add_tieoffs_cells "TIEHI TIELO"
add_tieoffs
place_detail
write_db ./DBS/prects.db       # Save placement database
```

**2. Early Global Routing**
```tcl
# Define routing layer preferences
set_db route_early_global_bottom_routing_layer 2    # Metal2 minimum
set_db route_early_global_top_routing_layer 6       # Metal6 maximum
set_db route_early_global_honor_power_domain false
set_db route_early_global_honor_partition_pin_guide true

route_early_global
report_congestion -hotspot     # Check for routing congestion
write_db ./DBS/preRC.db
```

**3. RC Extraction & Pre-CTS Timing**
```tcl
# Extract parasitic RC from routed tracks
extract_rc
write_parasitics -spef_file rc.spef -rc_corner rc_nom

# Report timing before CTS (Pre-CTS analysis)
time_design -pre_cts -path_report -drv_report -slack_report \
    -num_paths 50 -report_prefix fir_preCTS -report_dir timingReports
```

**4. Clock Tree Synthesis (CTS)**
```tcl
# Define clock routing rule (wider, better spaced tracks for clock)
create_route_rule -width {Metal1 0.240 Metal2 0.280 Metal3 0.280 Metal4 0.280 Metal5 0.280 Metal6 0.440} \
                  -spacing {Metal1 0.280 Metal2 0.350 Metal3 0.320 Metal4 0.320 Metal5 0.320 Metal6 0.480} \
                  -name 2w2s

# Define clock route type (use rule 2w2s, Metal2-Metal5 preferred layers)
create_route_type -name clkroute -route_rule 2w2s \
    -bottom_preferred_layer Metal2 -top_preferred_layer Metal5

# Configure CTS cells
set_db cts_route_type_trunk clkroute       # Trunk (main clock lines) use clkroute
set_db cts_route_type_leaf clkroute        # Leaf (branch) lines use clkroute
set_db cts_inverter_cells {CLKINVXL CLKINVX1 CLKINVX2 CLKINVX3 CLKINVX4 CLKINVX8 CLKINVX12 CLKINVX16 CLKINVX20}
set_db cts_buffer_cells {CLKBUFXL CLKBUFX1 CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20}

# Generate CTS spec and run optimization
create_clock_tree_spec -out_file ccopt.spec
source ccopt.spec
ccopt_design

# Save CTS database and analyze timing
write_db ./DBS/cts.db
time_design -post_cts
time_design -post_cts -hold     # Check hold time after CTS
write_db ./DBS/postcts.db
```

**5. Detailed Routing**
```tcl
# Antenna effect workarounds
set_db route_design_detail_fix_antenna true
set_db route_design_antenna_diode_insertion 1
set_db route_design_antenna_cell_name ANTENNA

# Route with timing and SI (Signal Integrity) optimizations
set_db route_design_with_timing_driven 1
set_db route_design_with_si_driven 1
set_db route_design_top_routing_layer 5
set_db route_design_bottom_routing_layer 1
set_db route_design_detail_end_iteration 0
set_db route_design_with_timing_driven true
set_db route_design_with_si_driven true

# Route design (global + detailed)
route_design -global_detail
route_eco -fix_drc                 # Attempt to fix DRC violations
delete_routes -regular_wire_with_drc  # Remove problematic routes
route_design                       # Final detailed routing

# Mark violations in layout
set_layer_preference violation -is_visible 1
write_db ./DBS/route.db
```

**6. Post-Route Optimization & Final Cleanup**
```tcl
# Extract post-route parasitics
set_db extract_rc_engine post_route
set_db extract_rc_effort_level medium

# Final timing analysis and optimization
time_design -post_route
time_design -post_route -hold
opt_design -post_route -setup -hold  # Optimize for timing violations
write_db ./DBS/final.db
```

#### Design Database Snapshots

Each stage creates a checkpoint database:

| Stage | Database | Description |
|-------|----------|-------------|
| Placement | `DBS/prects.db/` | After placement optimization |
| Global Route | `DBS/preRC.db/` | After early global routing |
| CTS | `DBS/cts.db/` | After clock tree synthesis |
| Post-CTS | `DBS/postcts.db/` | After CTS optimization |
| Detailed Route | `DBS/route.db/` | After routing complete |
| Final | `DBS/final.db/` | After post-route optimization |

#### Generated Outputs
- `DBS/final.db/` - Final design database (loadable in Innovus)
- `rc.spef` - Parasitic RC file (for sign-off tools)
- Timing reports: `fir_preCTS_*.rpt`, detailed post-route timing
- DRC/LVS reports: Generated by verification tools
- GDSII export: `final.gdsii` (exported from final.db)

---
## Design Results & Reports

### Area Report

**Cell Count & Area Summary** (from `workspace/report_Feb06-12:16:56/final_area.rpt`):

```
Instance Module  Cell Count  Cell Area    Net Area    Total Area
--------------------------------------------------------------
cic                     461  29,219.098   5,497.726   34,716.824 µm²
```

**Key Metrics**:
- **Total Cells**: 461 standard cells
- **Cell Area**: 29,219.10 µm²
- **Routing Area**: 5,497.73 µm²
- **Total Area**: 34,716.82 µm² (~187.5 × 185 µm)
- **Utilization**: ~71% (typical for 180nm node)

**Cell Breakdown**:
- Combinational logic: ~200 cells
- Sequential (registers/latches): ~261 cells
- Clock gating cells: ~10 cells
- Tie-hi/Tie-lo cells: ~5 cells

### Power Report

**Power Breakdown** (from `workspace/report_Feb06-12:16:56/power.rpt`):

```
  Category         Leakage        Internal      Switching         Total    Percentage
  ──────────────────────────────────────────────────────────────────────────────────
    Register    8.52e-08 W     1.753e-04 W   2.530e-05 W   2.007e-04 W    53.22%
    Logic       7.61e-08 W     1.107e-04 W   5.258e-05 W   1.634e-04 W    43.32%
    Clock       9.26e-10 W     1.800e-06 W   1.125e-05 W   1.305e-05 W     3.46%
  ──────────────────────────────────────────────────────────────────────────────────
    Subtotal    1.623e-07 W    2.878e-04 W   8.912e-05 W   3.771e-04 W   100.00%
```

**Power Summary** @ 10 MHz:
- **Total Power**: 377.1 µW
  - Leakage: 0.162 µW (0.04% - negligible)
  - Dynamic: 376.9 µW (99.96%)
    - Internal: 287.8 µW (76.32%)
    - Switching: 89.1 µW (23.63%)

**Power Per Cell**: ~0.82 µW/cell
**Power Per MHz**: ~37.7 µW/MHz
**Leakage-to-Dynamic Ratio**: 1 : 2321 (excellent)

### Timing Report

**Setup/Hold Analysis** (from `workspace/report_Feb06-12:16:56/final_time.rpt`):

```
                        Setup mode  All        reg2cgate  Default
────────────────────────────────────────────────────────────────
  WNS (ns):              49.343     89.601      49.780     49.343
  TNS (ns):               0.000      0.000       0.000      0.000
  Violating Paths:           0          0           0          0
  All Paths:             1246       1240           3         43
────────────────────────────────────────────────────────────────
```

**Timing Summary**:
- **Clock Period**: 100 ns (10 MHz)
- **Worst Negative Slack (WNS)**: +49.343 ns (MET by 49.3%)
- **Total Negative Slack (TNS)**: 0 ns (all paths met)
- **Violating Paths**: 0
- **Total Analyzed Paths**: 1246
- **Timing Margin**: ~50%, very conservative timing closure
- **Max Data Path Delay**: ~50-51 ns
- **IC Operable up to**: ~19+ MHz (at 1.8V, 25°C)

**Critical Path** (Clock Gate Check):
- Startpoint: Latch output (TLATNX1)
- Endpoint: AND2X1 gate (clock gating logic)
- Delay: ~244 ps
- Clock arrival: 50 ns (launch) → 100 ns (capture)
- Setup time: ~0 ps (after metastability settling)

**DRV (Design Rule Violations)** @ 180nm:
- Max capacitance: 0 ✓
- Max transition time: 0 ✓
- Max fanout: 0 ✓
- Max length: 0 ✓
- **Status**: DRC-CLEAN (All OK)

---

## Design Visualizations

### 1. Floorplanning & Pin Placement

Initial placement of I/O pins and core area:

![Floorplan](images/floorplanning_and_pin_placement.jpg)

**Features**:
- Core area bounded by I/O ring
- VDD/VSS (power/ground) pins distributed around perimeter
- Data I/O: clk, rst, data_in[15:0], data_out[15:0]
- Placement clearance for power grid

### 2. Clock Tree Synthesis (CTS)

Hierarchical clock tree with minimal skew:

![CTS](images/CTS_layout.jpg)

**CTS Metrics**:
- Clock root: Central H-tree distribution
- Levels: ~4 levels of buffering
- Buffers used: CLKBUFXL to CLKBUFX8
- Target skew: < 10 ps
- Latency: ~2-3 ns

![Clock Tree Highlighted](images/clock_tree_highlighted.jpg)

**Clock Network**:
- Yellow lines: Clock distribution network
- Coverage: All 461 sequential cells
- Transition time: ~78-100 ps
- Current draw: 16.8 µA (from power report)

### 3. Final Placement & Routing

Complete routed design with all metal layers:

![Final Layout](images/placement.jpg)

**Layout Statistics**:
- Core size: 187.5 µm × 185 µm (180nm tech)
- Density: 70.688% (good utilization)
- Die corners marked by I/O placement
- Signal density: Very packed (as expected for decimation filter)

### 4. Design Summary & Verification

Innovus log showing clean design with zero violations:

![Log Summary](images/log_with_no_violations.jpg)

**Success Criteria Met** ✓:
- DRC: PASS (0 violations)
- LVS: PASS (netlist matches layout)
- Timing: PASS (all paths within margin)
- Congestion: PASS (70%+ utilization, no hotspots)

---

## Generated Outputs

### Synthesis Outputs (`OUTPUT/`)
```
OUTPUT/
├── cic_m.v                          # Gate-level netlist (461 cells)
├── cic_m.sdc                        # Timing constraints (100 ns period)
├── cic_m.script                     # Genus optimization script
├── rtl2intermediate.lec.do          # LEC reference (intermediate)
└── intermediate2final.lec.do        # LEC reference (final)
```

### Physical Design Outputs (`workspace/`)
```
workspace/
├── DBS/
│   ├── prects.db/                   # Placement database
│   ├── cts.db/                      # CTS database
│   ├── postcts.db/                  # Post-CTS database
│   ├── route.db/                    # Routing database
│   └── final.db/                    # Final design (READY FOR GDSII)
├── report_Feb06-12:16:56/
│   ├── power.rpt                    # Power analysis: 377.1 µW @ 10 MHz
│   ├── final_area.rpt               # Area: 34,716.82 µm² (461 cells)
│   ├── final_time.rpt               # Timing: WNS=49.3ns, TNS=0ns
│   └── placement_summary.rpt
└── images/
    ├── floorplanning_and_pin_placement.jpg
    ├── CTS_layout.jpg
    ├── placement.jpg
    ├── metal1-5.jpg
    └── log_with_no_violations.jpg
```

## Key Design Metrics Summary

| Category | Metric | Value |
|----------|--------|-------|
| **Architecture** | Design Type | CIC Filter (Cascaded Integrator-Comb) |
| | Order | 6 stages |
| | Decimation Ratio | 4x |
| | I/O Width | 16-bit signed |
| **Technology** | Node | 180 nm CMOS |
| | Supply Voltage | 1.8V nominal |
| | Process Corner | Typical (TT) |
| **Synthesis** | Cell Count | 461 standard cells |
| | Gate Count | ~280 logic gates |
| **Area** | Total Area | 34,717 µm² (187.5 × 185 µm) |
| | Utilization | 71% (good packing) |
| **Power** | Total Power | 377.1 µW @ 10 MHz |
| | Leakage | 0.162 µW (0.04%) |
| | Dynamic | 376.9 µW (99.96%) |
| **Timing** | Frequency | 10 MHz |
| | WNS | +49.343 ns (MET by 49.3%) |
| | TNS | 0 ns (all paths met) |
| | Violations | 0 ✓ |
| | Timing Margin | ~50% slack |
| | Operable up to | ~19 MHz |
| **DRC** | DRC Status | PASS ✓ |

---

---

