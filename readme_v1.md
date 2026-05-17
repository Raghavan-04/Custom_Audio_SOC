#  RV32IM Audio SoC

**A custom RISC-V System-on-Chip (SoC) optimized for real-time, jitter-free audio processing.**

##  System Specifications

| Feature | Specification | Technical Implementation |
| --- | --- | --- |
| **ISA Support** | **RV32IM** | Full RV32I Base + M-Extension (Hardware Multiplication) |
| **Core Architecture** | **Single-Cycle Deterministic** | Every instruction executes in 1 clock cycle (CPI = 1.0) |
| **Math Performance** | **1-Cycle Multiplication** | Dedicated ALU hardware reduces math latency from ~32 cycles to 1 |
| **Audio Timing** | **44.1 kHz Stable** | Hardware Timer Interrupts (IRQ) at 22μs intervals for zero-jitter |
| **Peripheral Access** | **MMIO** | Memory-Mapped I/O for Audio PWM (0x400) and Timer (0x500) |
| **Verification** | **Cycle-Accurate Sim** | RTL verified via Verilator & GTKWave for nanosecond precision |

---


## Development Timeline

### Phase 0: The Foundation (Baseline RV32I)

Began by building the core "brain" of the system—a Single-Cycle RISC-V Processor based on the RV32I instruction set.

- **CPU Architecture:** Designed fundamental logic blocks including ALU, Register File (32x GP registers), and Control Unit.
- **Instruction Handling:** Implemented fetch → decode → execute pipeline for basic 32-bit instructions.
- **Single-Cycle Determinism:** Ensured every instruction takes exactly one clock cycle (CPI = 1.0) — the cornerstone of predictable audio timing.

---

### Phase 1.1: Hardware Multiplier (RV32M)

The ALU only added/subtracted. Audio volume mixing and filters (EQ) required multiplication.

- **The Upgrade:** Implemented a dedicated **Hardware Multiplier** block in the ALU path.
- **The Benefit:** Multiplication dropped from ~32 software loops to **1 cycle** — a 35x speedup for DSP operations.

---

### Phase 1.2: Timer Interrupt (The Metronome)

The CPU was "guessing" when to send audio samples using wasteful delay loops.

- **The Upgrade:** Built a hardware timer that sends an **Interrupt Signal (IRQ)** exactly every 22µs (for 44.1kHz audio).
- **The Benefit:** CPU can now process audio effects (echo, reverb, filters) and only jumps to sample delivery when it's *exactly* time to play.

---

### Phase 1.3: AMBA AXI4-Lite Router Matrix (The Traffic Controller)

Peripherals were directly wired to the CPU — fine for 2 devices, but doesn't scale.

- **The Upgrade:** Implemented a **Centralized AXI4-Lite Router** (`axi_router.sv`) with:
  - 3 independent slots with VALID/READY handshaking
  - Address decoding matrix for memory-mapped routing
  - Standardized AW/W/B channel separation

- **The Benefit:** New peripherals plug into slots without rewiring the CPU. The router handles all transaction arbitration.

```
[CPU Master] ---> [AXI ROUTER] ---> Slot 0: Audio PWM (0x400)
                        |--------> Slot 1: Data SRAM (0x1000)
                        |--------> Slot 2: AXI-to-APB Bridge
```

---

### Phase 1.4: AXI-to-APB Bridge & Low-Power Peripheral Bus

AXI4-Lite is powerful but overkill for simple configuration registers (Timer, GPIO).

- **The Upgrade:** Designed an **AXI-to-APB Bridge** that:
  - Captures AXI transactions targeting `0x500`-`0x6FF`
  - Converts them to low-overhead APB protocol (`PSEL`, `PENABLE`, `PWRITE`, `PRDATA`)
  - Routes to subordinate APB slaves

- **The Benefit:** 
  - Timer and GPIO consume less silicon area
  - Lower power consumption for config registers
  - Standard AMBA ecosystem compatibility

---

### Phase 1.5: APB Peripheral Integration

Added two native APB slaves to complete the peripheral subsystem:

| Peripheral | Address | Purpose |
| --- | --- | --- |
| **Timer APB** (`timer_apb.sv`) | `0x500` | Precise 22µs IRQ generator |
| **GPIO APB** (`gpio_apb.sv`) | `0x600` | 8-bit control for LEDs/switches |

**Verification:** Confirmed via GTKWave that:
- `psel` and `penable` strobe correctly during APB transactions
- Timer counter asserts `irq_out` at `LOAD_VALUE` match
- GPIO `pins_out` updates on APB write to `0x600`

---

### Phase 1.6: Data SRAM for Wavetable Synthesis

To move beyond square waves (beep-boop) to real instrument sounds, the system needed a lookup table.

- **The Upgrade:** Added **1KB AXI4-Lite Data SRAM** (`data_sram_axi.sv`) mapped to `0x1000`-`0x13FF`.
- **The Benefit:** Stores precomputed waveforms (sine, piano, violin) for wavetable synthesis. CPU performs table lookups in 1 cycle instead of calculating waves in real-time.

---

### Phase 2.0: System Integration & Verification (Current)

All components now talk through the standardized AMBA fabric:

```
INSTRUCTION MEMORY (0x0000)
        ↑
        │ (Instruction Fetch)
        ↓
    CPU CORE (RV32IM)
        │
        ↓ (AXI Master Transaction)
    AXI ROUTER MATRIX
        ├──→ AUDIO PWM (0x400) ──→ [Speaker Out]
        ├──→ DATA SRAM (0x1000) ──→ [Wavetable Lookup]
        └──→ AXI-to-APB BRIDGE
                ├──→ TIMER (0x500) ──→ [IRQ to CPU]
                └──→ GPIO (0x600) ──→ [LEDs/Buttons]
```

**Verification Completed:**
- Cycle-accurate simulation via Verilator
- AXI handshake waveforms validated in GTKWave
- APB strobe timing confirmed
- Hardware multiplier produces `alu_result` within 1 clock cycle

---

## Timeline Summary Table

| Phase | Goal | Key Addition | Status |
| --- | --- | --- | --- |
| **Phase 0** | Basic CPU | RV32I Single-Cycle Core | ✅ Complete |
| **Phase 1.1** | Fast Math | Hardware Multiplier (RV32M) | ✅ Complete |
| **Phase 1.2** | Precise Timing | Timer Interrupt (22µs IRQ) | ✅ Complete |
| **Phase 1.3** | Scalable Bus | AXI4-Lite Router Matrix | ✅ Complete |
| **Phase 1.4** | Low-Power Config | AXI-to-APB Bridge | ✅ Complete |
| **Phase 1.5** | Peripheral Suite | Timer APB + GPIO APB | ✅ Complete |
| **Phase 1.6** | Wavetable Ready | 1KB AXI Data SRAM | ✅ Complete |
| **Phase 2.0** | Integration | Full System Verification | 🔄 Current |
| **Phase 3.0** | Physical Design | OpenLane → GDSII | ⏳ Planned |


---
### 1. The Audio SoC File Flow

This chart shows how source files are processed by the two different toolchains (**RISC-V GCC** for software and **Verilator** for hardware) to create the final simulation.

| Folder | Role | Key File |
| --- | --- | --- |
| **`dv/firmware/`** | The "Software" | `start.S` (Assembly instructions) |
| **`dv/hex/`** | The "Brain Food" | `firmware.hex` (Machine code for the CPU) |
| **`rtl/core/`** | The "Brain" | `cpu_top.sv` (Coordinates the math and logic) |
| **`rtl/peripherals/`** | The "Voice" | `audio_pwm.sv` (Converts numbers to electrical pulses) |
| **`obj_dir/`** | The "Simulator" | `Vaudio_soc_top` (The executable produced by Verilator) |

---

### 2. Example: How a "Play Sound" Command Works

Let's trace exactly what happens when the assembly code runs the instruction: `sw t1, 0(t0)` (Store the value `0xFF` to address `0x400`).

#### **Step A: The Software (Software Layer)**

1. The `start.S` contains: `li t1, 0xFF` and `sw t1, 0(t0)`.
2. GCC converts this into hex: `0xff028023`.
3. This hex code is stored in `firmware.hex`.

#### **Step B: The Hardware (RTL Layer)**

1. **Fetch:** The `pc.sv` sends address `0x0` to `instr_mem.sv`. It returns `0xff028023`.
2. **Decode:** `decoder.sv` sees the `opcode` for a "Store" and the `data` `0xFF`.
3. **Control:** `control_unit.sv` sees the address is `0x400` and sets `mem_we` (Write Enable) to **High**.
4. **Execute:** The `cpu_top.sv` places `0xFF` on the data bus.

#### **Step C: The Peripheral (Output Layer)**

1. `audio_pwm.sv` sees `we_i` is High and the address is its own (`0x400`).
2. It saves `0xFF` into its internal `sample_reg`.
3. The PWM counter starts. Since `sample_reg` is maxed out at `0xFF`, the `audio_out_pin` stays **High** for the entire cycle.
4. **Result:** A solid line at 3.3V (digital High) is visible in **GTKWave**.

---

### 3. Verification Checklist (What to check in GTKWave)

When `make sim` finishes, look for these three things to confirm the "from scratch" design works:

1. **`pc_curr`**: Does it increment? If it stays at 0, the clock or reset logic is broken.
2. **`instr`**: Does it match the values in `firmware.hex`?
3. **`audio_out_pin`**: Does it toggle when the CPU reaches the `sw` (Store Word) instruction?


---

## 1. The Hardware Layer (`rtl/`)

These files define the actual physical logic (the "Silicon") of the chip.

| File | Purpose | Why it's used |
| --- | --- | --- |
| **`audio_soc_top.sv`** | **The Motherboard** | The master file that "plugs in" the CPU, the Memory, and the Audio hardware. It defines the physical pins of the chip. |
| **`core/cpu_top.sv`** | **The Brain Hub** | Coordinates the internal CPU signals. It connects the ALU, Register File, and Decoder together. |
| **`core/alu.sv`** | **The Calculator** | Performs all math. For an audio chip, this is used for volume scaling and calculating signal filters. |
| **`core/decoder.sv`** | **The Translator** | Slices the 32-bit instruction into pieces so the CPU knows which registers to use. |
| **`core/control_unit.sv`** | **The Manager** | Decides if a command is a "Read," a "Write," or a "Math" operation. It tells the Audio peripheral when to listen. |
| **`core/regfile.sv`** | **The Workspace** | Fast internal storage for the CPU to keep its current audio samples. |
| **`core/pc.sv`** | **The Pointer** | Tracks the address of the next instruction to execute. Without this, the CPU wouldn't know where to go next. |
| **`peripherals/audio_pwm.sv`** | **The Voice** | Converts digital numbers (0–255) into a Pulse Width Modulated signal that moves a speaker. |
| **`memory/instr_mem.sv`** | **The Library** | Holds the compiled code. The CPU "reads" from this file to know what to do. |

---

## 2. The Software Layer (`dv/firmware/`)

These files are the "Instructions" given to the hardware. Hardware without software is just dead silicon.

| File | Purpose | Why it's used |
| --- | --- | --- |
| **`start.S`** | **The First Words** | Assembly code that runs the moment the chip wakes up. It tells the CPU: "Look at the Audio address and play a sound." |
| **`firmware.hex`** | **Machine Code** | A text file containing the binary 0s and 1s of the assembly code. This is what the Verilog `instr_mem.sv` actually reads. |

---

## 3. The Verification Layer (`dv/` and Root)

These files don't go onto the chip; they live on the **development machine** to prove the chip works before manufacturing it.

| File | Purpose | Why it's used |
| --- | --- | --- |
| **`tb_audio_soc.cpp`** | **The Virtual World** | A C++ file that acts as the physical environment. It toggles the clock, releases the reset, and records the results. |
| **`Makefile`** | **The Architect** | Automates the entire process. Instead of typing 50 commands, just type `make sim`. |
| **`waveform.vcd`** | **The Recording** | A digital "tape" of the simulation. This is opened in **GTKWave** to see the signals moving over time. |

---


## 1. The Full Workflow Map

This diagram shows the journey from the keyboard to the "silicon" gates on the development machine.

---

## 2. Step-by-Step Breakdown

### Phase A: The "Song" (Firmware/Software)

* **File:** `dv/firmware/start.S` (Assembly)
* **What happens:** The command is written: `sw t1, 0(t0)`. This tells the CPU to take the volume level in register `t1` and push it out to the "Audio Address" stored in `t0`.
* **The Conversion:** Running `riscv64-unknown-elf-gcc` translates the human-readable "Play" command into a machine-readable `.hex` file.

### Phase B: The "Brain" (CPU RTL)

* **Files:** `rtl/core/decoder.sv`, `alu.sv`, `control_unit.sv`
* **What happens:** The CPU reads a 32-bit number from the `.hex` file.
1. The **Decoder** slices that number to see it's a "Store" command.
2. The **Control Unit** sets the "Write Enable" wire to **High**.
3. The **ALU** calculates the target address (0x400).


* **The Result:** An electrical "Write" pulse travels across the internal bus.

### Phase C: The "Instrument" (Audio Peripheral)

* **File:** `rtl/peripherals/audio_pwm.sv`
* **What happens:** The Audio PWM module is "listening" to the bus. When it sees its address (0x400) and the "Write Enable" signal is High, it catches the data (volume) and saves it.
* **The Transformation:** An internal counter in the PWM module starts counting from 0 to 255. It compares the counter to the saved volume to decide when the physical `audio_out` pin should be 1 (Up) or 0 (Down).

### Phase D: The "Proof" (Simulation)

* **File:** `dv/tb_audio_soc.cpp` (C++ Testbench)
* **What happens:** Since there is no physical chip yet, the development machine builds a "Digital Twin" of the SoC.
1. **Verilator** turns the Verilog into a high-speed C++ model.
2. The **Testbench** provides the "Batteries" (Clock and Reset).
3. **GTKWave** displays the recording (`waveform.vcd`).



---

## 3. How Data Flows Through the Files

| Data State | File Source | Tool Used | Output |
| --- | --- | --- | --- |
| **Logic Idea** | `top_soc.sv` | Text Editor | Source Code |
| **Instruction** | `start.S` | `riscv-gcc` | `firmware.hex` |
| **Clock/Reset** | `tb_audio_soc.cpp` | `verilator` | C++ Simulator |
| **Execution** | `obj_dir/Vtop` | `./Vtop` | `waveform.vcd` |

---
Since the "Brain" (CPU) and the "Voice" (Audio PWM) have been successfully built and verified in simulation, the next steps involve turning this project into a more powerful and "manufacturable" system.

Two distinct paths can be taken: **Enhancing the Hardware (Front-End)** or **Moving to Silicon (Back-End)**.

---
## Diagrams
```text
[ SYSTEM CONTROL & INTERRUPTS ]             [ DATA EXECUTION & BUS TRANSLATION ]
=================================           ====================================
     
+-------------------------------+           +-----------------------+
|     HARDWARE TIMER (MMIO)     |           |  INSTRUCTION MEMORY   |
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
                        |                +---------v---------+
                        |                | AXI4-LITE BRIDGE  |
  [ Write Enable (WE) ] +--------------->| (Valid Generator) |
                                         +---------+---------+
                                                   |
                                      (AWVALID / WVALID Handshake)
                                                   |
                                         +---------v---------+
                                         |   AXI AUDIO PWM   |
                                         |  (Address: 0x400) |
                                         +---------+---------+
                                                   |
                                             [ SPEAKER OUT ]
```




### The Complete AMBA Memory Map- future updates....

Every component on your chip will now sit on a clean, standardized address grid:

| Subsystem / Peripheral | Protocol | Address Range | Purpose |
| --- | --- | --- | --- |
| **Audio PWM Module** | AXI4-Lite | `0x0000_0400` | Audio sample stream engine |
| **System Timer** | AMBA APB | `0x0000_0500` | Precise 22µs real-time interrupt generator |
| **GPIO Controller** | AMBA APB | `0x0000_0600` | General purpose input/output (LEDs/Switches) |
| **Data SRAM (1KB)** | AXI4-Lite | `0x0000_1000` to `0x0000_13FF` | Audio Wavetable synth lookup tables |

---
