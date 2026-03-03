

# 🚀 RV32IM Audio SoC

A custom RISC-V System-on-Chip (SoC) designed for **deterministic, real-time audio synthesis**. By implementing a single-cycle execution model and hardware-accelerated math, this SoC eliminates jitter and ensures high-fidelity 44.1 kHz signal processing.

## ⚡ Key Highlights

* **Deterministic Timing:** Single-cycle execution ($CPI = 1.0$) ensures predictable audio sample delivery by executing every instruction in exactly one clock cycle.
* **Hardware Acceleration:** Dedicated RV32M hardware multiplier reduces math latency from ~32 cycles to **1 cycle**.
* **Zero-Jitter Audio:** Hardware timer interrupts (IRQ) trigger at precise **22µs** intervals for stable 44.1 kHz output.
* **Silicon Ready:** RTL designed for the **OpenLane** (SkyWater 130nm) physical design flow.

---
## **System-on-Chip (SoC) Architectural Block Diagram**

```text

+--------------------------------------------------------------------------+
|                          AUDIO SoC TOP-LEVEL (audio_soc_top.sv)          |
|                                                                          |
|  +---------------------------+          +-----------------------------+  |
|  |       RISC-V CPU CORE     |          |       INSTRUCTION MEMORY    |  |
|  |       (cpu_top.sv)        | <======> |       (instr_mem.sv)        |  |
|  |                           |  Bus     |      [Firmware.hex]         |  |
|  |  +---------------------+  |          +-----------------------------+  |
|  |  |   Control Unit      |  |                                           |
|  |  | (RV32IM Decoder)    |  |          +-----------------------------+  |
|  |  +----------+----------+  |          |        DATA MEMORY /        |  |
|  |             |             | <======> |     PERIPHERAL INTERFACE    |  |
|  |  +----------v----------+  |  MMIO    |      (Memory Mapped I/O)    |  |
|  |  |  Hardware Multiplier|  |  Bus     +--------------+--------------+  |
|  |  |  (1-Cycle Math)     |  |                         |                 |
|  |  +----------+----------+  |             +-----------+-----------+     |
|  |             |             |             |                       |     |
|  |  +----------v----------+  |      +------v-------+        +------v------+
|  |  |  ALU / RegFile      |  |      | TIMER MODULE |        |  AUDIO PWM  |
|  |  | (32x Registers)     |  |      |  (timer.sv)  |        | (audio_pwm.v)|
|  |  +----------^----------+  |      +------+-------+        +------+------+
|  +-------------|-------------+             |                       |     |
|                |                           |                       |     |
|      [ IRQ Signal (22us) ] <---------------+                [ Audio Out ]|
+--------------------------------------------------------------------------+
```



### **Breakdown of the Components**

* **RISC-V CPU Core (`cpu_top.sv`):** The central engine that handles instruction fetching and decoding. It now includes the **Hardware Multiplier** in the ALU for single-cycle DSP operations.
* **M-Extension Logic:** A sub-unit within the ALU that specifically triggers when it sees the `funct7 == 7'b0000001` signature, executing the `mul` instruction instantly.
* **Timer Module (`timer.sv`):** A dedicated hardware "metronome" that counts clock cycles. When it reaches the threshold (your counter hit `0x0c` in verification), it sends an **IRQ (Interrupt Request)** signal directly to the CPU's Program Counter.
* **MMIO Bus (Memory Mapped I/O):** This is the internal wiring harness. When the CPU writes to a specific memory address (like `0x400`), the data is automatically routed to the **Audio PWM** instead of the RAM.
* **Audio PWM Engine (`audio_pwm.sv`):** Receives the digital result from the hardware multiplier and converts it into high-speed pulses to create analog sound.


## 🏗️ Dataflow & Control Architecture

This diagram illustrates the separation between the **Control Path** (instruction decoding and interrupt logic) and the **Data Path** (arithmetic execution and MMIO).

```text
[ SYSTEM CONTROL & INTERRUPTS ]             [ DATA EXECUTION PATH ]
=================================           =========================
     
+-------------------------------+           +-----------------------+
|     HARDWARE TIMER (MMIO)     |           |  INSTRUCTION MEMORY   |
|   (Address: 0x500 | 22us)     |           |    (Bare-metal Hex)   |
+---------------+---------------+           +-----------+-----------+
                |                                       |
  [ IRQ Signal ]+-----> (Interrupt Logic)               | (32-bit Instr)
                               |                        v
                    +----------v----------------+-------------------+
                    |      CONTROL UNIT         |   REGISTER FILE   |
                    |  (Instruction Decoder)    | (32 Gen-Purpose)  |
                    +----------+----------------+---------+---------+
                               |                          |
                  (Control Lines: alu_op)        (Sample A & B Data)
                               |                          |
                    +----------v----------------+---------v---------+
                    |      ALU DECODER          | HARDWARE MULTIPLIER |
                    |  (M-Extension Logic)      | (Single-Cycle Unit) |
                    +----------+----------------+---------+---------+
                               |                          |
                  (Select: ADD vs. MUL)          (32-bit Product)
                               |                          |
                               |                +---------v---------+
                               |                | MMIO INTERCONNECT |
 [ Write Enable (WE) ] --------+--------------->| (Address Decode)  |
                                                +---------+---------+
                                                          |
                                                 (8-bit Duty Cycle)
                                                          |
                                                +---------v---------+
                                                |  AUDIO PWM ENGINE |
                                                |  (Address: 0x400) |
                                                +---------+---------+
                                                          |
                                                    [ SPEAKER OUT ]

```

---

## 📑 System Specifications

| Feature | Implementation | Technical Detail |
| --- | --- | --- |
| **ISA** | **RV32IM** | Base Integer + M-Extension (Multiplication) |
| **Clock Model** | **Single-Cycle** | Constant execution time for all instructions |
| **Audio Output** | **8-bit PWM** | 44.1 kHz sampling rate |
| **I/O Mapping** | **MMIO** | Audio PWM (`0x400`), Timer (`0x500`) |
| **Verification** | **Verilator** | Cycle-accurate RTL simulation with GTKWave |

---

## 🏎️ Performance Benchmarking: RV32I vs. RV32M

In a standard **RV32I** (Integer-only) implementation, multiplication must be emulated in software. For real-time audio, this overhead often exceeds the **22µs** sample deadline.

| Operation | RV32I (Software Loop) | RV32IM (Hardware) | Speedup |
| --- | --- | --- | --- |
| **32-bit Multiply** | ~32–40 Cycles | **1 Cycle** | **~35x** |
| **Gain Control** | ~50 Cycles | **3 Cycles** | **16x** |
| **FIR Filter Tap** | ~120 Cycles | **12 Cycles** | **10x** |

> **Note:** With a 50MHz clock, the CPU has a budget of ~1,100 cycles per sample. RV32M reduces the cost of a 10-tap filter from 25% of the total CPU budget to less than 2%.

---

## 🛠️ System Architecture

### 1. Hardware-Accelerated Math (RV32M)

The ALU features a dedicated hardware multiplier allowing the processor to scale audio samples in a **single clock cycle**. This is essential for DSP tasks like volume scaling, mixing, and filtering.

### 2. Precise Interrupt Service Routine (ISR)

Every **22µs**, a hardware timer triggers an `irq_signal`. This forces a hardware jump to address `0x20`, where the CPU processes the next audio sample, ensuring a stable 44.1 kHz sample rate without software "drift."

### 3. Memory-Mapped I/O (MMIO)

The SoC treats peripherals as memory addresses:

* **Audio Output:** Writing to `0x400` updates the PWM duty cycle.
* **Timer Control:** Address `0x500` controls interrupt intervals.

---

## 📂 Project Structure

```bash
├── rtl/                   # SystemVerilog RTL Source
│   ├── core/              # RV32IM CPU (ALU, Decoder, RegFile, PC)
│   ├── memory/            # Instruction Memory (instr_mem.sv)
│   ├── peripherals/       # Audio PWM & Hardware Timer
│   └── audio_soc_top.sv   # Top-level SoC Integration & MMIO Logic
├── dv/                    # Design Verification & Software
│   ├── firmware/          # RISC-V Assembly (start.S) & Compiled ELF/BIN
│   ├── hex/               # Machine code (firmware.hex) for RTL simulation
│   └── tb_audio_soc.cpp   # Verilator C++ Testbench
├── openlane/              # Physical Design & Synthesis scripts
└── Makefile               # Simulation and Build Automation

```

---

## 🚀 Getting Started

### Prerequisites

* `riscv64-unknown-elf-gcc` (Toolchain)
* `verilator` (RTL Simulator)
* `gtkwave` (Waveform Viewer)

### Run Simulation

```bash
make sim

```

This command compiles the RISC-V assembly, generates the machine code hex, builds the Verilator model, and runs the simulation to produce `waveform.vcd`.

---

For further details, read **readme_v1.md** file to know more.

---

