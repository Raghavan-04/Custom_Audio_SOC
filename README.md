

# 🚀 RV32IM Audio SoC

A custom RISC-V System-on-Chip (SoC) designed for **deterministic, real-time audio synthesis**. By implementing a single-cycle execution model and hardware-accelerated math, this SoC eliminates jitter and ensures high-fidelity 44.1 kHz signal processing.

## ⚡ Key Highlights

* **Deterministic Timing:** Single-cycle execution ($CPI = 1.0$) ensures predictable audio sample delivery by executing every instruction in exactly one clock cycle.
* **Hardware Acceleration:** Dedicated RV32M hardware multiplier reduces math latency from ~32 cycles to **1 cycle**.
* **Zero-Jitter Audio:** Hardware timer interrupts (IRQ) trigger at precise 22$\mu$s intervals for stable 44.1 kHz output.
* **Silicon Ready:** RTL designed for the **OpenLane** (SkyWater 130nm) physical design flow.

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

## 🛠️ System Architecture

### 1. Hardware-Accelerated Math (RV32M)

To handle real-time audio effects like reverb or EQ, the ALU features a dedicated hardware multiplier. This allows the processor to scale audio samples in a single clock cycle, providing a significant performance boost over software-based multiplication loops.

### 2. Precise Interrupt Service Routine (ISR)

The system utilizes a hardware timer to maintain audio fidelity. Every 22$\mu$s, an `irq_signal` forces a hardware jump to address `0x20`, where the CPU processes the next audio sample. This hardware-level precision prevents the timing "drift" common in software-only delay loops.

### 3. Memory-Mapped I/O (MMIO)

The SoC treats peripherals as memory addresses, simplifying firmware interaction:

* **Audio Output**: Writing to address `0x400` sends a digital value directly to the PWM peripheral.
* **Timer Control**: Address `0x500` provides direct control over the hardware interrupt intervals.

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
