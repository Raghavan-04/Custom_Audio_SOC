// =============================================================================
// Module Name:  timer_apb
// Description:  Native AMBA APB Subordinate Timer Peripheral. Generates precise 
//               22µs real-time audio interrupts controlled via an APB bus interface.
// =============================================================================

module timer_apb (
    input  logic        pclk,       // Connected to system clk
    input  logic        presetn,    // Connected to system rst_n

    // AMBA APB Interface Ports
    input  logic [31:0] paddr,      // APB Address Bus
    input  logic        psel,       // Peripheral Select Strobe
    input  logic        penable,    // Peripheral Enable/Access Strobe
    input  logic        pwrite,     // Write Strobe (1 = Write, 0 = Read)
    input  logic [31:0] pwdata,     // APB Write Data Bus
    output logic        pready,     // Peripheral Ready Acknowledge
    output logic [31:0] prdata,     // APB Read Data Bus
    output logic        pslverr,    // Peripheral Slave Error

    output logic        irq         // Outbound Interrupt Request to CPU Core
);

    logic [31:0] count_reg;
    logic [31:0] threshold_reg;

    // AMBA APB Control Handshake: 
    // This simple peripheral completes operations with zero wait-states
    assign pready  = 1'b1; 
    assign pslverr = 1'b0; 
    assign prdata  = (psel && !pwrite && (paddr == 32'h500)) ? threshold_reg : 32'h0;

    // APB Register Write Logic
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            threshold_reg <= 32'd1100; // Default: 1,100 cycles = 22µs at 50MHz
        end else begin
            // An official APB Write happens during the Access Phase (PSEL & PENABLE & PWRITE)
            if (psel && penable && pwrite) begin
                if (paddr == 32'h500) begin
                    threshold_reg <= pwdata;
                end
            end
        end
    end

    // Internal Counter & Interrupt Logic
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            count_reg <= '0;
            irq       <= 1'b0;
        end else begin
            if (count_reg >= threshold_reg) begin
                count_reg <= '0;
                irq       <= 1'b1; // Trigger hardware interrupt
            end else begin
                count_reg <= count_reg + 1;
                irq       <= 1'b0; // Clear interrupt strobe
            end
        end
    end

endmodule