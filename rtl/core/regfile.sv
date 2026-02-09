module regfile (
    input  logic        clk,
    input  logic        we,        // Write Enable
    input  logic [4:0]  rs1,       // Source Register 1 Address
    input  logic [4:0]  rs2,       // Source Register 2 Address
    input  logic [4:0]  rd,        // Destination Register Address
    input  logic [31:0] wd,        // Write Data
    output logic [31:0] rd1,       // Read Data 1
    output logic [31:0] rd2        // Read Data 2
);
    logic [31:0] rf [31:1]; // x1 to x31 (x0 is hardwired to 0)

    // Synchronous Write
    always_ff @(posedge clk) begin
        if (we && (rd != 5'b0)) begin
            rf[rd] <= wd;
        end
    end

    // Asynchronous Read
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : rf[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : rf[rs2];

endmodule