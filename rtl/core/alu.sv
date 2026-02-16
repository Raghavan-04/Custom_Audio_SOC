module alu (
    input  logic [31:0] a, b,
    input  logic [3:0]  alu_ctrl,
    output logic [31:0] result,
    output logic        zero
);
    always_comb begin
        case (alu_ctrl)
            4'b0000: result = a & b;      // AND
            4'b0001: result = a | b;      // OR
            4'b0010: result = a + b;      // ADD
            4'b0110: result = a - b;      // SUB
            4'b1000: result = a * b;      // MUL
            4'b0111: result = (a < b) ? 1 : 0; // SLT
            default: result = 32'b0;
        endcase
        zero = (result == 32'b0);
    end
endmodule