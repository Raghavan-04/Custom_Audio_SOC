module audio_soc_top (
    input  logic clk,
    input  logic rst_n,
    output logic audio_out
);
    // Interconnect Wires
    logic [31:0] pc_curr, pc_next;
    logic [31:0] instr;
    logic [31:0] alu_result, read_data2;
    logic        mem_we;
    
    // New Interrupt Signals
    logic        irq_signal; // Triggered by Timer
    logic [31:0] mepc_val;   // Saved PC during interrupt

    // 1. Program Counter (Updated with IRQ and MEPC)
    // Note: The logic for pc_next (pc+4 vs 0x20) should now move INSIDE the pc module
    // to handle the interrupt priority.
    pc u_pc (
        .clk(clk), 
        .rst_n(rst_n), 
        .d(pc_next),   // This usually comes from your branch/jump logic now
        .q(pc_curr),
        .irq(irq_signal), 
        .mepc(mepc_val)
    );

    // 2. Instruction Memory
    instr_mem u_imem (.addr(pc_curr), .instr(instr));

    // 3. Programmable Timer (The IRQ Source)
    // Maps to address 0x500 to set the "heartbeat" interval
    // 3. Programmable Timer (The IRQ Source)
    timer u_timer (
        .clk(clk),
        .rst_n(rst_n),
        .we_i(mem_we && (alu_result == 32'h500)),
        .wdata_i(read_data2),
        .irq(irq_signal)  // FIXED: Changed .irq_o to .irq to match timer.sv
    );

    // 4. Audio Peripheral (Memory Mapped to 0x400)
    audio_pwm u_audio (
        .clk(clk),
        .rst_n(rst_n),
        .we_i(mem_we && (alu_result == 32'h400)),
        .wdata_i(read_data2),
        .pwm_o(audio_out)
    );

    // 5. Basic Next-PC Logic (Simplified)
    // In a full RV32I, this would include Branch/Jump results.
    assign pc_next = pc_curr + 4;

endmodule