// =============================================================================
// Module Name:  audio_soc_top
// Description:  Master Top-Level SoC Integration Motherboard. Interconnects 
//               the RV32IM CPU Core to a centralized AMBA AXI4-Lite Router, 
//               an AXI Data SRAM, and an AXI-to-APB Peripheral Subsystem.
// =============================================================================

module audio_soc_top (
    input  logic        clk,
    input  logic        rst_n,
    output logic        audio_out,
    output logic [7:0]  gpio_pins   // Mapped to external physical pins/LEDs
);

    // --- 1. Internal Core CPU Connections ---
    logic [31:0] pc_curr, pc_next;
    logic [31:0] instr;
    logic [31:0] cpu_mem_addr, cpu_mem_wdata;
    logic        cpu_mem_we;
    logic [31:0] cpu_mem_rdata;
    
    // Interrupt Lines
    logic        irq_signal; 
    logic [31:0] mepc_val;   

    // --- 2. Centralized AMBA AXI4-Lite Master Bus Channels ---
    logic [31:0] m_axi_awaddr;
    logic        m_axi_awvalid, m_axi_awready;
    logic [31:0] m_axi_wdata;
    logic        m_axi_wvalid,  m_axi_wready;
    logic [1:0]  m_axi_bresp;
    logic        m_axi_bvalid,  m_axi_bready;

    // Map CPU execution ports directly to Master AXI4-Lite lines
    assign m_axi_awaddr  = cpu_mem_addr;
    assign m_axi_wdata   = cpu_mem_wdata;
    assign m_axi_bready  = 1'b1; 
    
    // Fire AXI valid assertions whenever the core attempts a peripheral write
    assign m_axi_awvalid = cpu_mem_we;
    assign m_axi_wvalid  = cpu_mem_we;
    assign cpu_mem_rdata = instr; // Static fallback loop for instruction streams

    // --- 3. Interconnect Router Slots (AXI Subordinate Interfaces) ---
    // Slot 0: Audio PWM Peripheral Channels (0x400)
    logic        s0_axi_awvalid, s0_axi_awready;
    logic        s0_axi_wvalid,  s0_axi_wready;
    logic        s0_axi_bvalid;

    // Slot 1: Data SRAM Memory Channels (0x1000)
    logic        s1_axi_awvalid, s1_axi_awready;
    logic        s1_axi_wvalid,  s1_axi_wready;
    logic        s1_axi_bvalid;

    // Slot 2: AXI-to-APB Subsystem Bridge Channels (0x500 / 0x600)
    logic        s2_axi_awvalid, s2_axi_awready;
    logic        s2_axi_wvalid,  s2_axi_wready;
    logic        s2_axi_bvalid;

    // --- 4. AMBA APB Internal Bus Distribution Wires ---
    logic [31:0] apb_paddr;
    logic [31:0] apb_pwdata;
    logic        apb_pwrite;
    logic        apb_psel;
    logic        apb_penable;
    logic        apb_pready;
    
    // Dedicated peripheral selector strobes
    logic        timer_psel;
    logic        gpio_psel;
    logic        timer_pready;
    logic        gpio_pready;
    logic [31:0] timer_prdata;
    logic [31:0] gpio_prdata;

    // --- 5. Instantiating Your Core CPU Engine ---
    cpu_top u_core (
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr(cpu_mem_addr),   
        .mem_wdata(cpu_mem_wdata), 
        .mem_we(cpu_mem_we),       
        .mem_rdata(cpu_mem_rdata)  
    );

    // --- 6. Execution Infrastructure ---

    // Program Counter Module
    pc u_pc (
        .clk(clk), 
        .rst_n(rst_n), 
        .d(pc_next),   
        .q(pc_curr),
        .irq(irq_signal), 
        .mepc(mepc_val)
    );
    
    // Instruction Memory Code Space Lookup
    instr_mem u_imem (
        .addr(pc_curr), 
        .instr(instr)
    );

    // --- 7. AMBA AXI4-LITE CENTRAL ROUTER MATRIX ---
    axi_router u_bus_router (
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),

        // Slot Outputs
        .s0_axi_awvalid(s0_axi_awvalid), .s0_axi_awready(s0_axi_awready),
        .s0_axi_wvalid(s0_axi_wvalid),   .s0_axi_wready(s0_axi_wready),
        .s0_axi_bvalid(s0_axi_bvalid),

        .s1_axi_awvalid(s1_axi_awvalid), .s1_axi_awready(s1_axi_awready),
        .s1_axi_wvalid(s1_axi_wvalid),   .s1_axi_wready(s1_axi_wready),
        .s1_axi_bvalid(s1_axi_bvalid),

        .s2_axi_awvalid(s2_axi_awvalid), .s2_axi_awready(s2_axi_awready),
        .s2_axi_wvalid(s2_axi_wvalid),   .s2_axi_wready(s2_axi_wready),
        .s2_axi_bvalid(s2_axi_bvalid)
    );

    // --- 8. HIGH-SPEED AXI SLOTS (SLOT 0 & SLOT 1) ---
    
    // SLOT 0: Upgraded AXI Audio Output Block (Target at 0x400)
    audio_pwm_axi u_audio (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_awaddr(m_axi_awaddr),
        .s_axi_awvalid(s0_axi_awvalid),
        .s_axi_awready(s0_axi_awready),
        .s_axi_wdata(m_axi_wdata),
        .s_axi_wvalid(s0_axi_wvalid),
        .s_axi_wready(s0_axi_wready),
        .s_axi_bresp(m_axi_bresp),
        .s_axi_bvalid(s0_axi_bvalid),
        .s_axi_bready(m_axi_bready),
        .audio_out(audio_out)
    );

    // SLOT 1: 1KB Data SRAM for Wavetable Lookup Buffers (Address: 0x1000 - 0x13FF)
    data_sram_axi u_data_storage (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_awaddr(m_axi_awaddr),
        .s_axi_awvalid(s1_axi_awvalid),
        .s_axi_awready(s1_axi_awready),
        .s_axi_wdata(m_axi_wdata),
        .s_axi_wvalid(s1_axi_wvalid),
        .s_axi_wready(s1_axi_wready),
        .s_axi_bresp(),
        .s_axi_bvalid(s1_axi_bvalid),
        .s_axi_bready(m_axi_bready),
        
        // Grounding the un-utilized read interface channels for our write application
        .s_axi_araddr(32'h0), .s_axi_arvalid(1'b0), .s_axi_arready(),
        .s_axi_rdata(),       .s_axi_rresp(),       .s_axi_rvalid(), .s_axi_rready(1'b1)
    );

    // --- 9. THE INTEGRATED AXI4-LITE TO AMBA APB BRIDGE (SLOT 2) ---
    always_comb begin
        apb_paddr   = m_axi_awaddr;
        apb_pwdata  = m_axi_wdata;
        apb_pwrite  = 1'b1; 
        apb_psel    = s2_axi_awvalid; // Setup State
        apb_penable = s2_axi_wvalid;  // Access State
    end

    // Route handshakes backward from APB space to satisfy the Interconnect Router
    assign s2_axi_awready = apb_pready;
    assign s2_axi_wready  = apb_pready;
    assign s2_axi_bvalid  = apb_psel && apb_penable && apb_pready;

    // Address Decode Routing within the low-power APB Subspace
    assign timer_psel = apb_psel && (apb_paddr == 32'h500);
    assign gpio_psel  = apb_psel && (apb_paddr == 32'h600);
    
    // Multiplex ready feedback lines back to the bridge
    assign apb_pready = timer_psel ? timer_pready : 
                        gpio_psel  ? gpio_pready  : 1'b1;

    // --- 10. LOW-POWER PERIPHERAL APB DEVICES ---
    
    // PERIPHERAL A: Programmable Timer Module (APB Target at 0x500)
    timer_apb u_timer (
        .pclk(clk),
        .presetn(rst_n),
        .paddr(apb_paddr),
        .psel(timer_psel),
        .penable(apb_penable),
        .pwrite(apb_pwrite),
        .pwdata(apb_pwdata),
        .pready(timer_pready),
        .prdata(timer_prdata),
        .pslverr(),
        .irq(irq_signal)
    );

    // PERIPHERAL B: 8-bit General Purpose Input/Output Pin Array (APB Target at 0x600)
    gpio_apb u_io_controller (
        .pclk(clk),
        .presetn(rst_n),
        .paddr(apb_paddr),
        .psel(gpio_psel),
        .penable(apb_penable),
        .pwrite(apb_pwrite),
        .pwdata(apb_pwdata),
        .pready(gpio_pready),
        .prdata(gpio_prdata),
        .gpio_pins(gpio_pins)
    );

    // Next PC Sequential Increment
    assign pc_next = pc_curr + 4;

endmodule