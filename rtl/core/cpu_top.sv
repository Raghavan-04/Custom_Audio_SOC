module cpu_top (
    input  logic        clk,
    input  logic        rst_n,
    // External Memory/Peripheral Interface
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    output logic        mem_we,
    input  logic [31:0] mem_rdata
);
    // Internal Wires (Simplified for Single Cycle)
    logic [31:0] pc, instr, reg_d1, reg_d2, alu_res, imm;
    logic        reg_we, alu_s, mem_reg;
    logic [1:0]  alu_op;

    // --- Instantiate Sub-modules ---
    // Note: You will need to add your Register File and PC modules here
    // as we build them out in the next steps.
    
    assign mem_addr  = alu_res;
    assign mem_wdata = reg_d2;
    // Control unit decides if we write to audio/memory
endmodule