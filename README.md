

# Backend Physical Design using OpenLane

## Overview

This branch contains the backend physical design flow for the **Custom Audio SoC** project. The implementation utilizes **OpenLane**, an open-source RTL-to-GDSII flow that integrates various ASIC design tools from the **OpenROAD Project**.

The primary objective is to transform verified RTL into a fabrication-ready GDSII layout, ensuring all timing, power, and area constraints are met.

---

## Design Flow

The backend process follows the industry-standard ASIC pipeline:

1. **Synthesis**: Converts RTL (Verilog) into a gate-level netlist using target standard cell libraries.
2. **Floorplanning**: Defines the core area, aspect ratio, IO pin placement, and Power Distribution Network (PDN).
3. **Placement**: Positions standard cells within the core while optimizing for timing and congestion.
4. **Clock Tree Synthesis (CTS)**: Constructs the clock distribution network to minimize skew and insertion delay.
5. **Routing**: Performs global and detailed routing to connect all cells through metal layers.
6. **Sign-off Checks**:
* **DRC**: Design Rule Check.
* **LVS**: Layout Versus Schematic.
* **STA**: Static Timing Analysis.


7. **GDSII Generation**: Produces the final layout file required for chip fabrication.

---

## Directory Structure

```text
backend/
├── configs/      # OpenLane configuration files (config.json/tcl)
├── scripts/      # Automation scripts for flow execution
├── floorplan/    # Floorplan constraints and macro placement files
└── reports/      # Timing, power, and DRC reports from OpenLane runs

```

---

## Prerequisites & Installation

Ensure you have **Docker**, **Python 3.x**, and **Git** installed on your system.

### Set up the OpenLane Environment

```bash
git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane
make setup

```

---

## Running the Flow

Follow these steps to execute the physical design flow:

1. **Enter the OpenLane directory:**
```bash
cd OpenLane

```


2. **Mount the Docker container:**
```bash
make mount

```


3. **Run the flow (Interactive or Automated):**
* *For Automated Run:*
```bash
./flow.tcl -design <design_name>

```


* *For Interactive Manual Steps:*
```tcl
./flow.tcl -interactive
prep -design <design_name>
run_synthesis
run_floorplan
# ... and so on

```





---

## Expected Outputs

Upon a successful run, all artifacts are stored in the `runs/` directory:

* **Gate-level Netlist**: Found in `results/synthesis/`.
* **Physical Layout**: Final GDSII and LEF files.
* **Reports**: Comprehensive logs for timing ($T_{setup}$, $T_{hold}$), power consumption, and area utilization.

---

## Design Target

The backend flow is specifically tuned for the **Custom Audio SoC**, featuring:

* **CPU**: 32-bit RISC-V core.
* **Audio**: Memory-mapped PWM peripheral.
* **Logic**: Interrupt-driven control systems.

> **Note**: Ensure that the `PDK_ROOT` environment variable is correctly set to point to your specific technology node (e.g., Sky130) before initiating the flow.

---
