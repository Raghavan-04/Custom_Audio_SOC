module audio_pwm_axi (
    input  logic        clk,
    input  logic        rst_n,

    // AXI-Lite Write Address Channel
    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,

    // AXI-Lite Write Data Channel
    input  logic [31:0] s_axi_wdata,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    // AXI-Lite Write Response Channel
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    output logic        audio_out
);

    logic [7:0] sample_reg;
    
    // --- AXI-Lite Handshake Logic ---
    
    // 1. We are ready for address/data if we aren't currently sending a response
    assign s_axi_awready = !s_axi_bvalid;
    assign s_axi_wready  = !s_axi_bvalid;

    // 2. Logic to capture the data
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_reg <= 8'h0;
            s_axi_bvalid <= 1'b0;
        end else begin
            // If both Address and Data are valid, and we are ready...
            if (s_axi_awvalid && s_axi_wvalid && s_axi_awready && s_axi_wready) begin
                // Only update if the address is our "Mailbox" (0x400)
                if (s_axi_awaddr == 32'h400) begin
                    sample_reg <= s_axi_wdata[7:0];
                end
                s_axi_bvalid <= 1'b1; // Tell CPU: "Got it!"
            end 
            // Once CPU acknowledges our response (BREADY), we drop BVALID
            else if (s_axi_bready && s_axi_bvalid) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    assign s_axi_bresp = 2'b00; // 00 = OKAY

    // --- Your original PWM logic goes here ---
    // (Counter and Comparator logic using sample_reg)
    // ... logic pwm_logic ...
    assign audio_out = (/* pwm_logic */); 

endmodule