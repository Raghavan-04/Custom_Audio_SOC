module cpu_top (
    input  logic        clk,
    input  logic        rst_n,
    // External Memory/Peripheral Interface
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    output logic        mem_we,
    input  logic [31:0] mem_rdata
);

    // --- 1. Internal Wires (The Conveyor Belts) ---
    logic [31:0] pc_curr, pc_next;
    logic [31:0] instr;
    logic [31:0] reg_d1, reg_d2, alu_res, imm;
    logic [31:0] alu_mux_out, wb_data;
    
    // Control Signals (The Intercom System)
    logic        reg_we, alu_s, mem_reg;
    logic [1:0]  alu_op;
    logic [3:0]  alu_ctrl;
    logic [2:0]  funct3;
    logic [6:0]  funct7;

    // --- 2. Instruction Slicing (The Fine Print) ---
    assign instr  = mem_rdata; // Instruction fetched from memory
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // --- 3. ALU Decoder (The Translation Logic) ---
    // This looks at the Director's general order (alu_op) and the 
    // fine print (funct7) to trigger the Hardware Multiplier.
    always_comb begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // Load/Store/I-Type: Default to ADD
            2'b01: alu_ctrl = 4'b0110; // Branch: Default to SUB
            2'b10: begin               // R-Type Math (ADD, SUB, MUL)
                // THE MULTIPLIER UPGRADE
                if (funct7 == 7'b0000001) begin
                    alu_ctrl = 4'b1000; // Found MUL signature!
                end else begin
                    case (funct3)
                        3'b000: alu_ctrl = (funct7[5]) ? 4'b0110 : 4'b0010; // SUB : ADD
                        3'b111: alu_ctrl = 4'b0000; // AND
                        3'b110: alu_ctrl = 4'b0001; // OR
                        default: alu_ctrl = 4'b0010;
                    endcase
                end
            end
            default: alu_ctrl = 4'b0010;
        endcase
    end

    // --- 4. Department Instantiations (Bolting the pieces in) ---

    // The Director (Main Control)
    control_unit u_ctrl (
        .opcode(instr[6:0]),
        .reg_write(reg_we),
        .alu_src(alu_s),
        .mem_to_reg(mem_reg),
        .alu_op(alu_op)
    );

    // The Workbench (Register File)
    regfile u_regfile (
        .clk(clk),
        .we3(reg_we),
        .ra1(instr[19:15]), // rs1
        .ra2(instr[24:20]), // rs2
        .wa3(instr[11:7]),  // rd
        .wd3(wb_data),      // Data to save back
        .rd1(reg_d1),
        .rd2(reg_d2)
    );

    // The Factory Floor (Upgraded ALU with Multiplier)
    assign alu_mux_out = alu_s ? imm : reg_d2; 
    
    alu u_alu (
        .a(reg_d1),
        .b(alu_mux_out),
        .alu_ctrl(alu_ctrl), // Connected to the decoder logic above
        .result(alu_res),
        .zero() 
    );

    // --- 5. Final Routing (Delivery) ---
    assign wb_data   = mem_reg ? mem_rdata : alu_res; // Choose ALU result or Memory
    assign mem_addr  = alu_res;   // Address for Data Memory / Audio PWM
    assign mem_wdata = reg_d2;    // Data to write to Audio PWM
    assign mem_we    = (instr[6:0] == 7'b0100011); // Write enable if opcode is STORE

endmodule