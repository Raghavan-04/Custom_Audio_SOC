// =============================================================================
// Module Name:  gpio_apb
// Description:  Native AMBA APB General Purpose I/O Subordinate. Controls
//               external hardware status pins via standard APB register maps.
// =============================================================================

module gpio_apb (
    input  logic        pclk,
    input  logic        presetn,
    
    // APB Ports
    input  logic [31:0] paddr,
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [31:0] pwdata,
    output logic        pready,
    output logic [31:0] prdata,
    
    // External Physical Chip Interface
    output logic [7:0]  gpio_pins
);

    logic [7:0] gpio_reg;

    assign pready = 1'b1; // Zero wait-state peripheral access
    assign prdata = (psel && !pwrite && (paddr == 32'h600)) ? {24'h0, gpio_reg} : 32'h0;
    assign gpio_pins = gpio_reg;

    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            gpio_reg <= 8'h0;
        end else begin
            if (psel && penable && pwrite && (paddr == 32'h600)) begin
                gpio_reg <= pwdata[7:0];
            end
        end
    end

endmodule