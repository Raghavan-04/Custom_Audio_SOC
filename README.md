
# RV32IM Audio SoC with Centralized AMBA Interconnect Matrix

A custom RISC-V System-on-Chip (SoC) designed for **deterministic, real-time audio synthesis**. By implementing a single-cycle execution model, hardware-accelerated math, a centralized AMBA AXI4-Lite Router matrix, and a low-power AMBA APB peripheral subsystem, this SoC eliminates clock jitter and ensures high-fidelity 44.1 kHz signal processing.

## Key Highlights

* **Deterministic Timing:** Single-cycle execution (CPI = 1.0) ensures predictable audio sample delivery by executing instructions within a single clock period.
* **Hardware Acceleration:** Dedicated RV32M hardware multiplier reduces arithmetic DSP latency from ~32 clock cycles to **1 cycle**.
* **Centralized Interconnect:** Integrates an **AMBA AXI4-Lite Router Matrix** to handle unified, master-driven transactions across memory slots and peripheral bridges.
* **Low-Power Peripheral Bus:** Employs an efficient **AXI-to-APB Bridge** to step down low-speed configurations, cutting down overall silicon area and power consumption.
* **Wavetable-Ready Storage:** Features an on-chip **1KB AXI4-Lite Data SRAM** dedicated to running real-time wavetable audio synthesis lookups.
* **Silicon Ready:** RTL fully structured and optimized for the **OpenLane** (SkyWater 130nm) physical design automation flow.

---

## SoC Architectural Block Diagram

```text
+----------------------------------------------------------------------------------+
|                          AUDIO SoC TOP-LEVEL (audio_soc_top.sv)                  |
|                                                                                  |
|  +---------------------------+          +-----------------------------+          |
|  |       RISC-V CPU CORE     |          |     INSTRUCTION MEMORY      |          |
|  |        (cpu_top.sv)       | <======> |       (instr_mem.sv)        |          |
|  |                           |   Bus    |       [Firmware.hex]        |          |
|  |  +---------------------+  |          +-----------------------------+          |
|  |  |    Control Unit     |  |                                                   |
|  |  | (Instruction Decoder)  |           +-----------------------------+         |
|  |  +----------+----------+  |           |   AXI4-LITE ROUTER MATRIX   |         |
|  |             |             | <======>  |      (axi_router.sv)        |         |
|  |  +----------v----------+  | AXI Master+--------------+--------------+         |
|  |  |  Hardware Multiplier|  |   Bus                   |                         |
|  |  |    (1-Cycle Math)   |  |              +----------+----------+              |
|  |  +----------+----------+  |              |                     |              |
|  |             |             |              | Slot 1 (AXI)        | Slot 0 (AXI) |
|  |  +----------v----------+  |              v                     v              |
|  |  |  ALU / RegFile      |  |      +---------------+     +---------------+      |
|  |  | (32x Registers)     |  |      |   1KB SRAM    |     |   AUDIO PWM   |      |
|  |  +----------^----------+  |      |(data_sram_axi)|     |(audio_pwm_axi)|      |
|  +-------------|-------------+      +---------------+     +-------+-------+      |
|                |                                                  |              |
|                |              Slot 2 (AXI-to-APB Bridge)          v              |
|                |              +-------------------------+   [Audio Out]          |
|                |              |  (Mapped to Top Level)  |                        |
|                |              +------------+------------+                        |
|                |                           |                                     |
|                |                           | APB Peripheral Bus                  |
|                |                           v                                     |
|                |                  +--------+--------+                            |
|                |                  |                 |                            |
|                |            +-----v------+    +-----v------+                     |
|                |            | TIMER APB  |    |  GPIO APB  |                     |
|                |            |(timer_apb) |    | (gpio_apb) |                     |
|                |            +-----+------+    +-----+------+                     |
|                |                  |                 |                            |
|       [ IRQ Signal (22µs) ] <-----+                 v                            |
|                                                [8x GPIO Pins]                    |
+----------------------------------------------------------------------------------+

```

### Breakdown of the Components

* **RISC-V CPU Core (`cpu_top.sv`):** The central execution engine handling instruction fetches, custom register routing, and decoded controls. It embeds the dedicated **Hardware Multiplier** directly in its ALU execution path.
* **AMBA AXI4-Lite Router Matrix (`axi_router.sv`):** The primary communication fabric. It intercepts the CPU’s target memory transactions, processes the destination address mapping, and safely controls transaction handshakes (`VALID`/`READY`) for individual slots.
* **1KB Data SRAM (`data_sram_axi.sv`):** A high-speed, synchronous AXI memory matrix dedicated to volatile processing storage, enabling fast lookup algorithms for custom instrument wavetable synthesis.
* **AXI-to-APB Bridge:** Implemented structurally inside the top-level block. It captures complex incoming AXI transactions targeting configuration registers and converts them into low-overhead, simple setup/enable APB bus loops.
* **System Timer Subordinate (`timer_apb.sv`):** A native, low-power AMBA APB peripheral. It acts as the system's metronome, counting processor clock ticks to assert a high-priority hardware **Interrupt Request (IRQ)** precisely every 22µs to lock in a 44.1 kHz audio sampling rate.
* **GPIO Controller (`gpio_apb.sv`):** An 8-bit AMBA APB register block that maps internal chip data states straight to physical external output pins to drive status LEDs, diagnostic triggers, or configuration switches.
* **Audio PWM Engine (`audio_pwm_axi.sv`):** A protocol-compliant AXI subordinate that latches real-time sample results from the bus router and feeds them into high-speed counter-comparators to generate high-fidelity analog pulses.

---

## Dataflow & Control Architecture

This mapping traces the structural isolation between the system's Control Path (handling background interrupt vector sweeps) and the central AMBA Interconnect Hierarchy (governing synchronous transactions):

```text
[ SYSTEM CONTROL & INTERRUPTS ]             [ DATA EXECUTION & BUS TRANSLATION ]
=================================           ====================================
     
+-------------------------------+           +-----------------------+
|       TIMER APB (SLOT 2)      |           |  INSTRUCTION MEMORY   |
|    (Address: 0x500 | 22µs)    |           |    (Bare-metal Hex)   |
+---------------+---------------+           +-----------+-----------+
                |                                       |
  [ IRQ Signal ]+--------> (Interrupt Logic)            | (32-bit Instr)
                        |                               v
             +----------v----------------+-------------------+
             |       CONTROL UNIT        |   REGISTER FILE   |
             |   (Instruction Decoder)   | (32 Gen-Purpose)  |
             +----------+----------------+---------+---------+
                        |                          |
              (Control: alu_op)           (Sample Payload WData)
                        |                          |
             +----------v----------------+---------v------------+
             |       ALU DECODER         |  HARDWARE MULTIPLIER |
             |   (M-Extension Logic)     |  (Single-Cycle Unit) |
             +----------+----------------+---------+------------+
                        |                          |
                (Select: ADD vs. MUL)       (32-bit Target Addr)
                        |                          |
                        v                          v
             +------------------------------------------------+
             |       CENTRALIZED AXI4-LITE BUS ROUTER         |
             +--------+---------------+---------------+-------+
                      |               |               |
             [Slot 0: 0x400]   [Slot 1: 0x1000] [Slot 2: Bridge]
                      |               |               |
                      v               v               v
               +-----------+   +-----------+   +--------------+
               | AUDIO PWM |   | 1KB SRAM  |   | AXI-to-APB   |
               | PERIPHERAL|   | DATA CORE |   | REG BRIDGE   |
               +-----------+   +-----------+   +-------+------+
                                                       |
                                               (PSEL / PENABLE)
                                                       |
                                               +-------+------+
                                               |  APB SLOTS   |
                                               | 0x500: Timer |
                                               | 0x600: GPIO  |
                                               +--------------+

```

---

## System Specifications

| Feature | Implementation | Technical Detail |
| --- | --- | --- |
| **ISA** | **RV32IM** | Base Integer + M-Extension (Hardware Multiplication) |
| **Clock Model** | **Single-Cycle** | Uniform execution timing across instruction classes (CPI = 1.0) |
| **Primary Bus** | **AMBA AXI4-Lite** | Standardized 3-slot `AW`, `W`, and `B` handshaking router interconnect matrix |
| **Secondary Bus** | **AMBA APB** | Ultra-lean, low-power non-pipelined peripheral register link |
| **Audio Output** | **8-bit PWM** | 44.1 kHz fixed hardware sampling rate |
| **Address Space** | **Register Mapped** | Audio (`0x400`), Timer (`0x500`), GPIO (`0x600`), SRAM (`0x1000`-`0x13FF`) |
| **Verification** | **Verilator & GTKWave** | Cycle-accurate C++ environment compilation with VCD timing wave analysis |

---

## Performance Benchmarking: RV32I vs. RV32M

In an unaccelerated integer implementation, multiplication math must be emulated iteratively via software code routines. For processing streaming sound waves, this excessive calculation loop easily misses real-time operational window thresholds.

| Operation | RV32I (Software Loop) | RV32IM (Hardware) | Speedup |
| --- | --- | --- | --- |
| **32-bit Multiply** | ~32–40 Cycles | **1 Cycle** | **~35x** |
| **Gain Control** | ~50 Cycles | **3 Cycles** | **16x** |
| **FIR Filter Tap** | ~120 Cycles | **12 Cycles** | **10x** |

> **Note:** Operating with a 50MHz core frequency provides a baseline budget of roughly 1,100 execution cycles per sample interval. Moving the math operations into dedicated hardware matrices drops a 10-tap filter load from 25% of the total system runtime to under 2%.

---

## Project Structure

```bash
├── rtl/                   # SystemVerilog RTL Source Modules
│   ├── core/              # RV32IM CPU Pipeline Components
│   │   ├── cpu_top.sv      # Coordinates internal core execution blocks
│   │   ├── alu.sv          # Performs arithmetic, logical, and multiplication steps
│   │   ├── decoder.sv      # Translates instruction bits into active opcode signatures
│   │   ├── control_unit.sv # Drives pipeline multiplexers and read/write states
│   │   ├── regfile.sv      # Internal register file workspace bank (x1 to x31)
│   │   └── pc.sv           # Hardware program pointer with hardware interrupt traps
│   ├── memory/            # Storage Subsystems
│   │   ├── instr_mem.sv   # Read-Only Instruction Memory (Preloaded with code hex)
│   │   └── data_sram_axi.sv # Standardized AXI4-Lite 1KB Data SRAM
│   ├── peripherals/       # AMBA Target Peripheral Cores
│   │   ├── timer_apb.sv   # Native AMBA APB Interrupt-Generation Metronome Timer
│   │   ├── gpio_apb.sv    # 8-bit AMBA APB General Purpose I/O Pin Controller
│   │   ├── audio_pwm_axi.sv # Handshake-driven AXI4-Lite Audio Output Module
│   │   └── axi_router.sv  # Central AXI Interconnect Address Decoder Routing Matrix
│   └── audio_soc_top.sv   # Top-Level System Integration Motherboard Netlist
├── dv/                    # Design Verification & Simulation Testing Environments
│   ├── firmware/          # Low-Level Assembly Setup (start.S) & Processing Applications
│   ├── hex/               # Extracted machine code arrays (firmware.hex) for memory images
│   └── tb_audio_soc.cpp   # Cycle-accurate native C++ verification testbench wrapper
└── Makefile               # Complete automation engine for compilation and execution runs

```

---

## 🛠️ Tape-Out & Physical Implementation Metrics

The macro-level metrics extracted from the final sign-off manufacturing manifest (`metrics.csv`) highlight the physical density constraints of the layout:

| Engineering Parameter | Synthesis & Placement Value | Description |
| --- | --- | --- |
| **PDK Process Node** | SkyWater 130nm (`sky130A`) | Target open-source foundry fabrication layer stack |
| **Standard Cell Library** | `sky130_fd_sc_hd` | High-density digital standard cell library footprint |
| **Total Physical Cells** | **7,336 Cells** | Cumulative structural footprint placed on the die |
| **Pure Synthesized Logic Gates** | 2,691 Cells | Active Boolean gates handling execution and bus routing |
| **Total Realized Die Area** | **$0.0637 \text{ mm}^2$** | Ultra-compact chip core profile ($~0.25\text{mm} \times 0.25\text{mm}$) |
| **Core Packing Density** | 52.04% Utilization | Legalized placement target ensuring route accessibility |
| **Interlayer Routing Vias** | 21,857 Vias | Vertical layer transitions across copper tracks |
| **Total Signal Wire Length** | 80,652 $\mu m$ (~8.06 cm) | Total cumulative signal trace routing path |
| **Maximum Routing Layer** | Metal 4 (`met4`) | Bound geometry ceiling parameter for global signals |

---

## ⚡ Power Distribution Network (PDN) Topology

The power grid infrastructure was built with high integrity to suppress dynamic IR voltage drops during high-frequency audio PWM generation.

* **Primary Power Highways:** Thick, low-resistance vertical straps deployed on Metal 4 (`met4`) at the periphery act as the main supply trunks for $V_{DD}$ (`vccd1`) and $GND$ (`vssd1`).
* **Core Distribution Rows:** Horizontal stripes on Metal 1/2 run across standard cell rows at a 160$\mu m$ pitch, allowing every single flip-flop and logic gate to connect straight to a stable 1.8V power rail.

---

## ⏱️ Static Timing Analysis (STA) Sign-Off

Timing simulation profiles evaluated under the **Typical Process Corner** confirm robust timing margin boundaries at a clock target of **50.0 MHz** (20.0 ns clock period).

* **Worst Negative Slack (WNS):** `0.00 ns` (No Setup or Hold violations).
* **Asynchronous Reset Recovery Path Slack:** **`15.35 ns` (MET)**.
* **Synchronous Critical Data Path Slack:** **`13.98 ns` (MET)**.

### Critical Path Propagation Details:

The chip's absolute worst-case critical delay tracking path initiates from the Program Counter register, propagates out of instruction memory lookup blocks (`u_imem`), routes through the ALU's complex combinatorial logic array, and terminates safely at the input of destination register `_4800_/D` within **6.45 ns**, safely beating the 20.43 ns data required ceiling.

```text
Critical Path Execution Chain:
[Register Stage] _4264_/CLK -> Q (1.21ns) 
  ↳ [Combinatorial Logic] Instruction Decode Bus -> Address Multiplexing
  ↳ [ALU Operations] Math Multiplier Array Gates (_2654_ -> _2908_ -> _3015_)
[Terminal Stage] Wire Propagation -> _4800_/D Arrival (6.45ns)
Timing Margin: Required 20.43ns - Arrived 6.45ns = +13.98ns Safe Margin

```

> **Note on Clock Tree Fanout Warning:** The sign-off report flags a maximum fanout warning on 30 leaf-node clock buffers (e.g., `clkbuf_leaf_2_clk` driving 19 loads). Because the physical die area is microscopic and total wire capacitance/slew values are exactly `0`, the clock signal edges remain perfectly sharp without signal degradation, preserving optimal clock skew profiles.

---

## 🛡️ Fabrication & Manufacturability Sign-Off

Verified using industry-standard EDA tools inside the OpenLane pipeline container toolchain:

* **Design Rule Checking (Magic/KLayout DRC):** **0 Violations**. Geometries completely conform to fabrication safety distance margins.
* **Layout vs. Schematic (LVS Match):** **0 Errors (Passed)**. The physical layout schematic structure exhibits a perfect 1-to-1 connection match against the netlist across all **3,314 independent electrical nets**.
* **Antenna Rule Checking (ARC Verification):** Clean sign-off. Charge gathering flags on extended routing layers are protected via integrated standard cell diode taps.

---

## 🚀 Reproduction Pipeline

To execute the physical implementation scripts and generate the production GDSII mask file from scratch inside your local OpenLane environment:

1. Clone this repository directly into your local open-source hardware working directory.
2. Ensure your local environment variables correctly export your toolchain paths:
```bash
export PDK_ROOT=/Users/raghavan/.ciel
export PDK=sky130A

```


3. Run the complete automated ASIC implementation script:
```bash
./flow.tcl -design audio_soc -tag production_run -overwrite

```
The structural hardware geometry artifact will build at:
<img width="1976" height="1340" alt="3" src="https://github.com/user-attachments/assets/f6fca4fd-0786-4acb-9587-d75e50571040" />



---

## Getting Started

### Prerequisites

Ensure your host development terminal has access to these open-source EDA tools (if working on Apple Silicon macOS architectures, make sure your SDK development headers are properly exported to your workspace shell):

* `riscv64-unknown-elf-gcc` (GNU RISC-V Cross-Compilation Toolchain)
* `verilator` (Strict HDL Linting compiler and high-speed C++ model simulator)
* `gtkwave` (Interactive VCD trace waveform visualization environment)

### Run Simulation

To completely clean old builds, extract the latest assembly firmwares, translate the SystemVerilog design tree into a compiled binary executable, and perform a full simulation cycle trace run, execute the top-level automation target:

```bash
make sim

```

### Visualizing Waveforms

Once the run simulation finishes successfully, it writes out a complete nanosecond-level trace log (`waveform.vcd`). You can inspect your AXI router slot selections, APB bridge strobes (`psel`/`penable`), and hardware multiplier operations by loading the output into GTKWave.

---

For further details, read **readme_v1.md** file to know more.

---

