module audio_pwm_axi (
    input  logic        clk,
    input  logic        rst_n,

    // AXI4-Lite Write Address Channel (AW)
    input  logic [31:0] s_axi_awaddr,   // Write Target Address
    input  logic        s_axi_awvalid,  // Write Address Valid Strobe
    output logic        s_axi_awready,  // Peripheral Address Ready Flag

    // AXI4-Lite Write Data Channel (W)
    input  logic [31:0] s_axi_wdata,    // Inbound Data Word Payload
    input  logic        s_axi_wvalid,   // Write Data Valid Strobe
    output logic        s_axi_wready,   // Peripheral Data Ready Flag

    // AXI4-Lite Write Response Channel (B)
    output logic [1:0]  s_axi_bresp,    // Write Response Status (00 = OKAY)
    output logic        s_axi_bvalid,   // Response Status Valid Strobe
    input  logic        s_axi_bready,   // Manager Response Ready Flag

    output logic        audio_out       // Outbound physical PWM pin to speaker
);

    logic [7:0] sample_reg;
    logic [7:0] counter;

    // -------------------------------------------------------------------------
    // 1. AXI4-LITE WRITE CHANNEL HANDSHAKING ENGINE
    // -------------------------------------------------------------------------
    
    // The peripheral is ready to accept a new address/data transaction 
    // as long as it isn't currently holding an unacknowledged write response.
    assign s_axi_awready = !s_axi_bvalid;
    assign s_axi_wready  = !s_axi_bvalid;
    
    // Constant Response Code: 2'b00 represents an 'OKAY' transaction status
    assign s_axi_bresp   = 2'b00;

    // Bus Registration Control
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_reg   <= 8'h0;
            s_axi_bvalid <= 1'b0;
        end else begin
            // If both Address & Data channels validate simultaneously while ready:
            if (s_axi_awvalid && s_axi_wvalid && s_axi_awready && s_axi_wready) begin
                // Verify the address targeting matches our designated Audio address (0x400)
                if (s_axi_awaddr == 32'h400) begin
                    sample_reg <= s_axi_wdata[7:0]; // Capture lower byte payload
                end
                s_axi_bvalid <= 1'b1; // Raise valid response strobe to Manager
            end 
            // Drop response strobe once the Manager acknowledges receipt (bready)
            else if (s_axi_bready && s_axi_bvalid) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // 2. YOUR ORIGINAL PWM GENERATION LOGIC
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 8'h0;
            audio_out <= 1'b0;
        end else begin
            counter   <= counter + 1;
            audio_out <= (counter < sample_reg); // Pulse active while counter is below sample window
        end
    end

endmodule