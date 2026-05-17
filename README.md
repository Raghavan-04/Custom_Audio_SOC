
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
+--------------------------------------------------------------------------+
|                          AUDIO SoC TOP-LEVEL (audio_soc_top.sv)          |
|                                                                          |
|  +---------------------------+          +-----------------------------+  |
|  |       RISC-V CPU CORE     |          |     INSTRUCTION MEMORY      |  |
|  |        (cpu_top.sv)       | <======> |       (instr_mem.sv)        |  |
|  |                           |   Bus    |       [Firmware.hex]        |  |
|  |  +---------------------+  |          +-----------------------------+  |
|  |  |    Control Unit     |  |                                           |
|  |  | (Instruction Decoder)  |  |          +-----------------------------+  |
|  |  +----------+----------+  |          |   AXI4-LITE ROUTER MATRIX   |  |
|  |             |             | <======> |      (axi_router.sv)        |  |
|  |  +----------v----------+  | AXI Master+--------------+--------------+  |
|  |  |  Hardware Multiplier|  |   Bus                   |                 |
|  |  |    (1-Cycle Math)   |  |              +----------+----------+      |
|  |  +----------+----------+  |              |                     |      |
|  |             |             |              | Slot 1 (AXI)        | Slot 0 (AXI)|
|  |  +----------v----------+  |              v                     v      |
|  |  |  ALU / RegFile      |  |      +---------------+     +---------------+
|  |  | (32x Registers)     |  |      |   1KB SRAM    |     |   AUDIO PWM   |
|  |  +----------^----------+  |      |(data_sram_axi)|     |(audio_pwm_axi)|
|  +-------------|-------------+      +---------------+     +-------+-------+
|                |                                                  |      |
|                |              Slot 2 (AXI-to-APB Bridge)          v      |
|                |              +-------------------------+   [Audio Out]  |
|                |              |  (Mapped to Top Level)  |                |
|                |              +------------+------------+                |
|                |                           |                             |
|                |                           | APB Peripheral Bus          |
|                |                           v                             |
|                |                  +--------+--------+                    |
|                |                  |                 |                    |
|                |            +-----v------+    +-----v------+             |
|                |            | TIMER APB  |    |  GPIO APB  |             |
|                |            |(timer_apb) |    | (gpio_apb) |             |
|                |            +-----+------+    +-----+------+             |
|                |                  |                 |                    |
|       [ IRQ Signal (22µs) ] <-----+                 v                    |
|                                                [8x GPIO Pins]            |
+--------------------------------------------------------------------------+

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
  [ IRQ Signal ]+-----> (Interrupt Logic)               | (32-bit Instr)
                        |                               v
             +----------v----------------+-------------------+
             |       CONTROL UNIT        |   REGISTER FILE   |
             |   (Instruction Decoder)   | (32 Gen-Purpose)  |
             +----------+----------------+---------+---------+
                        |                          |
              (Control: alu_op)           (Sample Payload WData)
                        |                          |
             +----------v----------------+---------v---------+
             |       ALU DECODER         |  HARDWARE MULTIPLIER |
             |   (M-Extension Logic)     |  (Single-Cycle Unit) |
             +----------+----------------+---------+---------+
                        |                          |
                (Select: ADD vs. MUL)       (32-bit Target Addr)
                        |                          |
                        v                          v
             +-----------------------------------------------+
             |       CENTRALIZED AXI4-LITE BUS ROUTER        |
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

