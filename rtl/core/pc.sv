module pc (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] d,    // Next PC value
    output logic [31:0] q     // Current PC value
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 32'h0;
        else
            q <= d;
    end
endmodule