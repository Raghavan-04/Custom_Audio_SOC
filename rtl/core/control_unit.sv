module control_unit (
    input  logic [6:0] opcode,
    output logic       reg_write,
    output logic       alu_src,
    output logic       mem_to_reg,
    output logic [1:0] alu_op
);
    always_comb begin
        case (opcode)
            7'b0110011: begin // R-type (e.g., ADD)
                reg_write  = 1'b1;
                alu_src    = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b10;
            end
            7'b0010013: begin // I-type (e.g., ADDI)
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b0;
                alu_op     = 2'b00;
            end
            7'b0000011: begin // Load (e.g., LW)
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = 2'b00;
            end
            7'b0100011: begin // Store (e.g., SW to Audio)
                reg_write  = 1'b0;
                alu_src    = 1'b1;
                mem_to_reg = 1'b0;
                alu_op     = 2'b00;
            end
            default: begin
                reg_write  = 1'b0;
                alu_src    = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b00;
            end
        endcase
    end
endmodule