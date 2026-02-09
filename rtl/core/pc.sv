module pc(
    input  logic        clk,
    input  logic        rst_n, //reset
    input  logic        irq, //Trigger input 
    input  logic [31:0] d,   //The normal next address usually pc+4
    output logic [31:0] q,   //The current address the cpu is executing
    output logic [31:0] mepc //Machine exception program counter
);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            q <= 32'h0;     //start at address 0 on power
        end else if (irq) begin 
    mepc <= d; 
    q <= 32'h20; 
end else begin
            q <= d;  //otherwise,just go to next normal instruction
        end
    end
endmodule