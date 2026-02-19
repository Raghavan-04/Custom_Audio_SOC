### TIMELINE (in progress)

### 0->1 : The Foundation (Baseline RV32I)
Began by building the core "brain" of the system—a Single-Cycle RISC-V Processor based on the RV32I instruction set.

* **CPU Architecture:** Designed the fundamental logic blocks including the ALU (Arithmetic Logic Unit), Register File (32 general-purpose registers), and Control Unit.

* **Instruction Handling:** Implemented the logic to fetch, decode, and execute basic 32-bit instructions from memory.

* **Single-Cycle Determinism:** Chose a single-cycle design specifically to ensure every instruction takes exactly one clock cycle, which is the cornerstone of predictable audio timing.

### 1.1 Add a Timer Interrupt

Right now, the CPU has to "guess" when to send the next audio sample using delay loops.

* **The Upgrade:** Build a hardware timer that sends an **Interrupt Signal** to the CPU exactly every 22 microseconds (for 44.1kHz audio).
* **The Benefit:** This lets the CPU do other math (like calculating an echo or reverb) and only jump to the audio code when it's exactly time to play a sound.

### 1.2 Multiplier Hardware (RV32M) 

The current ALU only adds and subtracts. To do audio volume mixing or filters (EQ), multiplication of signals is needed.

* **The Upgrade:** Implement a **Hardware Multiplier** block in the ALU.
* **The Benefit:** Instead of taking 32 clock cycles to multiply two numbers in software, the hardware can do it in **1 cycle**.


### 1.3 System Integration & Verification
This section describes how the "Manager" (Control Unit), "Machines" (ALU), and "Peripherals" (Timer/PWM) were brought together.


* **SoC Top-Level Integration:** Orchestrated the physical wiring in `audio_soc_top.sv` to map the Audio PWM to address `0x400` and the Timer to `0x500`, creating a Memory-Mapped I/O (MMIO) interface.
* **ALU Decoding Logic:** Implemented an auxiliary decoding layer in `cpu_top.sv` to detect the `M-extension` signature (`funct7 == 7'b0000001`), allowing the processor to distinguish between standard addition and the new hardware multiplication.
* **Interrupt Vectoring:** Programmed the Program Counter (PC) to perform a hardware-forced jump to address `0x20` upon receiving a high `irq_signal` from the timer.

---

### 1.4 Hardware Multiplication Verification <----Current


* **Test Methodology:** Developed a bare-metal assembly firmware (`start.S`) that utilizes the `mul` instruction within an Interrupt Service Routine (ISR) to scale audio samples in real-time.
* **Waveform Analysis:** Confirmed via GTKWave that the `alu_result` signal correctly computes the volume-scaled product () within a single clock cycle immediately following a timer trigger at counter value `0x0c`.
* **Deterministic Performance:** Verified that the transition from software-based multiplication loops to the hardware multiplier reduced the audio processing latency by approximately 31 clock cycles per sample.
* This is where explanation for  the "Hardware Multiplication" image .


---

### Updated Key Results


| Metric | Achievement |
| --- | --- |
| **Instruction Set** | Upgraded from RV32I to **RV32IM** (Integer + Multiplication). |
| **Math Efficiency** | Multiplication latency reduced from **32 cycles** to **1 cycle**. |
| **Audio Fidelity** | Achieved jitter-free **44.1kHz** sample delivery via hardware interrupts. |
| **SoC Interface** | Implemented functional **MMIO** for Audio PWM and Timer peripherals. |



---

## Path 2: Physical Design (The "Silicon" Path)

This is where the SystemVerilog code is taken to see how it looks as a physical chip using the **OpenLane** flow.

### 2.1 Logic Synthesis

A tool (like Yosys) is used to turn the "if/else" code into a "Netlist" of actual logic gates (NAND, NOR, Flip-Flops) from a real foundry like **SkyWater 130nm**.

### 2.2 Floorplanning & Routing

The decision is made where the CPU sits on the silicon die versus where the Audio PWM sits. The computer then "draws" the tiny copper wires that connect them.

* **Goal:** Calculate the **Power, Performance, and Area (PPA)**. It will be possible to say, "This Audio SoC takes up 0.5 mm² and uses 10mW of power."

---

## Path 3: Advanced Audio (The "Musician" Path)

### 3.1 Wavetable Synthesis

Instead of just a square wave (beep-boop), a small **SRAM Data Memory** can be added to store a "lookup table" of a real violin or piano wave.

* **The Upgrade:** Modify `audio_soc_top.sv` to include a 1KB Data SRAM.

---

## Roadmap Summary

| Phase | Goal | Key Task |
| --- | --- | --- |
| **Expansion** | Better Performance | Add Hardware Multiplier (RV32M) |
| **Control** | Precise Timing | Implement Timer Interrupts |
| **Silicon** | Physical Chip | Run the OpenLane RTL-to-GDSII flow |
| **Software** | Better Sound | Write a C-based Wavetable Synthesizer |

---### 1. The Audio SoC File Flow

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

