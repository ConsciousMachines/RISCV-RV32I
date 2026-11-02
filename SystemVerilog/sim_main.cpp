#include <cstdint>
#include <cstdio>
#include <string>
#include "Vriscv.h"
#include "Vriscv___024root.h"   // gives access to internal signals via rootp
#include "verilated.h"
#include "verilated_vcd_c.h"

// Exit codes: 0 = PASS, 1 = FAIL (tohost != 1), 2 = TIMEOUT (tohost never written)
int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vriscv* top = new Vriscv;

    // Waveform only when run with +trace (keeps the 40-test sweep fast)
    VerilatedVcdC* tfp = nullptr;
    if (!std::string(Verilated::commandArgsPlusMatch("trace")).empty()) {
        Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
        tfp->open("wave.vcd");
    }

    const uint64_t MAX_TIME = 1000000;
    uint64_t time = 0;
    top->clk = 0;
    top->rst = 1;

    uint32_t tohost = 0;

    // lambda to perform one tick
    auto tick = [&]() {
        top->clk = !top->clk;
        top->eval();
        if (tfp) tfp->dump(time);
        if (time == 10) top->rst = 0;
        time += 5;
    };

    while (time < MAX_TIME) {
        tick();

        // Internal signal: <top>__DOT__<instance>__DOT__<signal>
        tohost = top->rootp->riscv__DOT__dmem_inst__DOT__tohost;
        if (tohost != 0) break;   // test finished
    }

    // do 6 more ticks to see signals converge 
    for (int i = 0; i < 6; i++) tick();


    int rc;
    if (tohost == 0)      { printf("TIMEOUT  (tohost never written, t=%llu)\n", (unsigned long long)time); rc = 2; }
    else if (tohost == 1) { printf("PASS     (t=%llu)\n", (unsigned long long)time); rc = 0; }
    else                  { printf("FAIL     tohost=0x%08x -> failed test #%u (t=%llu)\n",
                                   (unsigned)tohost, (unsigned)(tohost >> 1), (unsigned long long)time); rc = 1; }

    top->final();
    if (tfp) { tfp->close(); delete tfp; }
    delete top;
    return rc;
}
