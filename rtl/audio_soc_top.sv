module audio_soc_top (
    input  logic clk,
    input  logic rst_n,
    output logic audio_out
);

    // --- 1. Interconnect Wires ---
    logic [31:0] pc_curr, pc_next;
    logic [31:0] instr;
    logic [31:0] cpu_mem_addr, cpu_mem_wdata;
    logic        cpu_mem_we;
    logic [31:0] cpu_mem_rdata;
    
    // Interrupt Lines
    logic        irq_signal; 
    logic [31:0] mepc_val;   

    // --- 2. AMBA AXI4-Lite Bus Channels ---
    logic [31:0] m_axi_awaddr;
    logic        m_axi_awvalid, m_axi_awready;
    logic [31:0] m_axi_wdata;
    logic        m_axi_wvalid,  m_axi_wready;
    logic [1:0]  m_axi_bresp;
    logic        m_axi_bvalid,  m_axi_bready;

    // --- 3. The AXI4-Lite Translation Bridge Logic ---
    assign m_axi_awaddr  = cpu_mem_addr;
    assign m_axi_wdata   = cpu_mem_wdata;
    
    // AXI Transactions fire ONLY when CPU drives write enable high at address 0x400
    assign m_axi_awvalid = (cpu_mem_we && (cpu_mem_addr == 32'h400));
    assign m_axi_wvalid  = (cpu_mem_we && (cpu_mem_addr == 32'h400));
    assign m_axi_bready  = 1'b1; // Core is instantly ready for write confirmation signals

    // --- 4. Unification Bus Multiplexer ---
    // Maps instruction fetch data streams into the CPU's shared input data channel
    assign cpu_mem_rdata = instr;

    // --- 5. Instantiating Your Core CPU Engine ---
    cpu_top u_core (
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr(cpu_mem_addr),   // Connected to bridge target routing
        .mem_wdata(cpu_mem_wdata), // Connected to bridge data lanes
        .mem_we(cpu_mem_we),       // Connected to bridge handshake conditional gates
        .mem_rdata(cpu_mem_rdata)  // Connected to bus multiplexer
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

    // --- 7. Peripherals ---

    // Programmable Timer Module (Direct MMIO Target at 0x500)
    timer u_timer (
        .clk(clk),
        .rst_n(rst_n),
        .we_i(cpu_mem_we && (cpu_mem_addr == 32'h500)),
        .wdata_i(cpu_mem_wdata),
        .irq(irq_signal)  
    );

    // Upgraded AXI Audio Output Block (Target at 0x400)
    audio_pwm_axi u_audio (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_awaddr(m_axi_awaddr),
        .s_axi_awvalid(m_axi_awvalid),
        .s_axi_awready(m_axi_awready),
        .s_axi_wdata(m_axi_wdata),
        .s_axi_wvalid(m_axi_wvalid),
        .s_axi_wready(m_axi_wready),
        .s_axi_bresp(m_axi_bresp),
        .s_axi_bvalid(m_axi_bvalid),
        .s_axi_bready(m_axi_bready),
        .audio_out(audio_out)
    );

    // Next PC Sequential Increment
    assign pc_next = pc_curr + 4;

endmodule