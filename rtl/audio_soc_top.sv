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

    // 1. Program Counter
    assign pc_next = pc_curr + 4;
    pc u_pc (.clk(clk), .rst_n(rst_n), .d(pc_next), .q(pc_curr));

    // 2. Instruction Memory (Simple ROM for simulation)
    // In a real chip, this would be an SRAM macro
    instr_mem u_imem (.addr(pc_curr), .instr(instr));

    // 3. The CPU Core
    // This is where you instantiate the modules we wrote: 
    // decoder, control_unit, regfile, and alu.
    // ... (Wiring logic here)

    // 4. Audio Peripheral (Memory Mapped to 0x400)
    audio_pwm u_audio (
        .clk(clk),
        .rst_n(rst_n),
        .we_i(mem_we && (alu_result == 32'h400)),
        .wdata_i(read_data2),
        .pwm_o(audio_out)
    );

endmodule