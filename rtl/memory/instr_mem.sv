module instr_mem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);
    // 1024 word memory (4KB)
    logic [31:0] rom [0:1023];

    // Load the compiled HEX file (we will generate this next)
    initial begin
        $readmemh("dv/hex/firmware.hex", rom);
    end

    // Instruction alignment (RISC-V instructions are 4-byte aligned)
    assign instr = rom[addr[11:2]]; 
endmodule