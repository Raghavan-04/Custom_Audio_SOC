// =============================================================================
// Module Name:  axi_router
// Description:  Centralized AMBA AXI4-Lite Bus Interconnect Matrix. Decodes 
//               system master addresses and handles multi-slot handshaking.
// =============================================================================

module axi_router (
    // CPU Master Input Interface
    input  logic [31:0] m_axi_awaddr,
    input  logic        m_axi_awvalid,
    output logic        m_axi_awready,
    input  logic [31:0] m_axi_wdata,
    input  logic        m_axi_wvalid,
    output logic        m_axi_wready,
    output logic [1:0]  m_axi_bresp,
    output logic        m_axi_bvalid,
    input  logic        m_axi_bready,

    // Slot 0 Interface: Audio PWM AXI (0x400)
    output logic        s0_axi_awvalid,
    input  logic        s0_axi_awready,
    output logic        s0_axi_wvalid,
    input  logic        s0_axi_wready,
    input  logic        s0_axi_bvalid,

    // Slot 1 Interface: Data SRAM AXI (0x1000)
    output logic        s1_axi_awvalid,
    input  logic        s1_axi_awready,
    output logic        s1_axi_wvalid,
    input  logic        s1_axi_wready,
    input  logic        s1_axi_bvalid,

    // Slot 2 Interface: APB Subsystem Bridge (0x500 Timer / 0x600 GPIO)
    output logic        s2_axi_awvalid,
    input  logic        s2_axi_awready,
    output logic        s2_axi_wvalid,
    input  logic        s2_axi_wready,
    input  logic        s2_axi_bvalid
);

    // Address Decoder Select Lines
    logic slot0_sel, slot1_sel, slot2_sel;

    assign slot0_sel = (m_axi_awaddr == 32'h400); // Audio
    assign slot1_sel = (m_axi_awaddr >= 32'h1000 && m_axi_awaddr <= 32'h13FF); // SRAM
    assign slot2_sel = (m_axi_awaddr == 32'h500) || (m_axi_awaddr == 32'h600);  // Timer/GPIO

    // Route Valid Signals Out to Subordinates based on decoded memory mapping
    assign s0_axi_awvalid = m_axi_awvalid && slot0_sel;
    assign s0_axi_wvalid  = m_axi_wvalid  && slot0_sel;

    assign s1_axi_awvalid = m_axi_awvalid && slot1_sel;
    assign s1_axi_wvalid  = m_axi_wvalid  && slot1_sel;

    assign s2_axi_awvalid = m_axi_awvalid && slot2_sel;
    assign s2_axi_wvalid  = m_axi_wvalid  && slot2_sel;

    // Route Ready and Response Signals Back to CPU Master
    assign m_axi_awready = slot0_sel ? s0_axi_awready :
                           slot1_sel ? s1_axi_awready :
                           slot2_sel ? s2_axi_awready : 1'b0;

    assign m_axi_wready  = slot0_sel ? s0_axi_wready  :
                           slot1_sel ? s1_axi_wready  :
                           slot2_sel ? s2_axi_wready  : 1'b0;

    assign m_axi_bvalid  = slot0_sel ? s0_axi_bvalid  :
                           slot1_sel ? s1_axi_bvalid  :
                           slot2_sel ? s2_axi_bvalid  : 1'b0;

    assign m_axi_bresp   = 2'b00; // Always return OKAY status

endmodule