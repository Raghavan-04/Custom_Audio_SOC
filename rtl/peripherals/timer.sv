module timer (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        we_i,      // Write Enable from CPU
    input  logic [31:0] wdata_i,   // Data from CPU (Sets the threshold)
    output logic        irq        // The interrupt signal
);
    logic [31:0] count;
    logic [31:0] threshold_reg;

    // Register the threshold value when the CPU writes to it
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            threshold_reg <= 32'hFFFF; // Default slow rate
        else if (we_i)
            threshold_reg <= wdata_i;
    end

    // Counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            irq   <= 0;
        end else begin
            if (count >= threshold_reg) begin
                count <= 0;
                irq   <= 1; // Trigger interrupt
            end else begin
                count <= count + 1;
                irq   <= 0;
            end
        end
    end
endmodule