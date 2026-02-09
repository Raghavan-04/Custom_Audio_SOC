#include "Vaudio_soc_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vaudio_soc_top* top = new Vaudio_soc_top;

    // Enable Waveform Tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    // Initial State
    top->clk = 0;
    top->rst_n = 0;

    for (int i = 0; i < 5000; i++) {
        if (i > 20) top->rst_n = 1; // Release reset after 20 ticks
        
        top->clk = !top->clk;       // Toggle Clock
        top->eval();
        tfp->dump(i);               // Log signals to VCD
    }

    tfp->close();
    delete top;
    printf("Simulation Complete. Open waveform.vcd with GTKWave\n");
    return 0;
}