// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vaudio_soc_top.h for the primary calling header

#ifndef VERILATED_VAUDIO_SOC_TOP___024ROOT_H_
#define VERILATED_VAUDIO_SOC_TOP___024ROOT_H_  // guard

#include "verilated.h"


class Vaudio_soc_top__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vaudio_soc_top___024root final {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst_n,0,0);
    VL_OUT8(audio_out,0,0);
    CData/*0:0*/ audio_soc_top__DOT__mem_we;
    CData/*7:0*/ audio_soc_top__DOT__u_audio__DOT__sample_reg;
    CData/*7:0*/ audio_soc_top__DOT__u_audio__DOT__counter;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rst_n__0;
    IData/*31:0*/ audio_soc_top__DOT__pc_curr;
    IData/*31:0*/ audio_soc_top__DOT__pc_next;
    IData/*31:0*/ audio_soc_top__DOT__alu_result;
    IData/*31:0*/ audio_soc_top__DOT__read_data2;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<IData/*31:0*/, 1024> audio_soc_top__DOT__u_imem__DOT__rom;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlUnpacked<CData/*0:0*/, 2> __Vm_traceActivity;

    // INTERNAL VARIABLES
    Vaudio_soc_top__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vaudio_soc_top___024root(Vaudio_soc_top__Syms* symsp, const char* namep);
    ~Vaudio_soc_top___024root();
    VL_UNCOPYABLE(Vaudio_soc_top___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
