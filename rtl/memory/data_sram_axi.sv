// =============================================================================
// Module Name:  data_sram_axi
// Description:  AXI4-Lite 1KB Data SRAM. Provides storage for wavetable 
//               synthesis lookup data with standard AXI handshaking.
// =============================================================================

module data_sram_axi (
    input  logic        clk,
    input  logic        rst_n,

    // AXI4-Lite Ports
    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,
    input  logic [31:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready
);

    // 1024 Bytes = 256 words of 32-bit RAM
    logic [31:0] ram [255:0];
    logic [7:0]  ram_addr;

    // Simple single-cycle ready acknowledgment
    assign s_axi_awready = !s_axi_bvalid;
    assign s_axi_wready  = !s_axi_bvalid;
    assign s_axi_bresp   = 2'b00; // OKAY
    assign s_axi_arready = !s_axi_rvalid;
    assign s_axi_rresp   = 2'b00; // OKAY

    // Convert raw byte addresses to 32-bit word indices (Offset from 0x1000)
    assign ram_addr = s_axi_awaddr[9:2];

    // Write Channel Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_bvalid <= 1'b0;
        end else begin
            if (s_axi_awvalid && s_axi_wvalid && s_axi_awready && s_axi_wready) begin
                ram[ram_addr] <= s_axi_wdata;
                s_axi_bvalid  <= 1'b1;
            end else if (s_axi_bready && s_axi_bvalid) begin
                s_axi_bvalid  <= 1'b0;
            end
        end
    end

    // Read Channel Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= 32'h0;
        end else begin
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rdata  <= ram[s_axi_araddr[9:2]];
                s_axi_rvalid <= 1'b1;
            end else if (s_axi_rready && s_axi_rvalid) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule