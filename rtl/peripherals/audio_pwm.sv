module audio_pwm (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        we_i,     // Write Enable from CPU
    input  logic [31:0] wdata_i,  // Data from CPU
    output logic        pwm_o     // To Physical Pin
);
    logic [7:0] sample_reg;
    logic [7:0] counter;

    // CPU Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            sample_reg <= 8'h0;
        else if (we_i) 
            sample_reg <= wdata_i[7:0];
    end

    // PWM Generation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 8'h0;
            pwm_o   <= 1'b0;
        end else begin
            counter <= counter + 1;
            pwm_o   <= (counter < sample_reg);
        end
    end
endmodule