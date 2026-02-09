// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaudio_soc_top.h for the primary calling header

#include "Vaudio_soc_top__pch.h"

VL_ATTR_COLD void Vaudio_soc_top___024root___eval_static(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_static\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__rst_n__0 = vlSelfRef.rst_n;
}

VL_ATTR_COLD void Vaudio_soc_top___024root___eval_initial__TOP(Vaudio_soc_top___024root* vlSelf);
VL_ATTR_COLD void Vaudio_soc_top___024root____Vm_traceActivitySetAll(Vaudio_soc_top___024root* vlSelf);

VL_ATTR_COLD void Vaudio_soc_top___024root___eval_initial(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_initial\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vaudio_soc_top___024root___eval_initial__TOP(vlSelf);
    Vaudio_soc_top___024root____Vm_traceActivitySetAll(vlSelf);
}

VL_ATTR_COLD void Vaudio_soc_top___024root___eval_initial__TOP(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_initial__TOP\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    VL_READMEM_N(true, 32, 1024, 0, "dv/hex/firmware.hex"s
                 ,  &(vlSelfRef.audio_soc_top__DOT__u_imem__DOT__rom)
                 , 0, ~0ULL);
}

VL_ATTR_COLD void Vaudio_soc_top___024root___eval_final(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_final\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaudio_soc_top___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vaudio_soc_top___024root___eval_phase__stl(Vaudio_soc_top___024root* vlSelf);

VL_ATTR_COLD void Vaudio_soc_top___024root___eval_settle(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_settle\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vaudio_soc_top___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("rtl/audio_soc_top.sv", 1, "", "Settle region did not converge after 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
    } while (Vaudio_soc_top___024root___eval_phase__stl(vlSelf));
}

VL_ATTR_COLD void Vaudio_soc_top___024root___eval_triggers__stl(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_triggers__stl\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered
                                      [0U]) | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    vlSelfRef.__VstlFirstIteration = 0U;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vaudio_soc_top___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
}

VL_ATTR_COLD bool Vaudio_soc_top___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaudio_soc_top___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vaudio_soc_top___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vaudio_soc_top___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___trigger_anySet__stl\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

VL_ATTR_COLD void Vaudio_soc_top___024root___stl_sequent__TOP__0(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___stl_sequent__TOP__0\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.audio_soc_top__DOT__pc_next = ((IData)(4U) 
                                             + vlSelfRef.audio_soc_top__DOT__pc_curr);
}

VL_ATTR_COLD void Vaudio_soc_top___024root___eval_stl(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_stl\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        Vaudio_soc_top___024root___stl_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD bool Vaudio_soc_top___024root___eval_phase__stl(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_phase__stl\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vaudio_soc_top___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = Vaudio_soc_top___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vaudio_soc_top___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vaudio_soc_top___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaudio_soc_top___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vaudio_soc_top___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge rst_n)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vaudio_soc_top___024root____Vm_traceActivitySetAll(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root____Vm_traceActivitySetAll\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vm_traceActivity[0U] = 1U;
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
}

VL_ATTR_COLD void Vaudio_soc_top___024root___ctor_var_reset(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___ctor_var_reset\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16707436170211756652ull);
    vlSelf->rst_n = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1638864771569018232ull);
    vlSelf->audio_out = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16887251779955964156ull);
    vlSelf->audio_soc_top__DOT__pc_curr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11686488438370736918ull);
    vlSelf->audio_soc_top__DOT__pc_next = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1795388068092148672ull);
    vlSelf->audio_soc_top__DOT__alu_result = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16326752303799995800ull);
    vlSelf->audio_soc_top__DOT__read_data2 = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15693612374389528742ull);
    vlSelf->audio_soc_top__DOT__mem_we = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10132551505575031156ull);
    for (int __Vi0 = 0; __Vi0 < 1024; ++__Vi0) {
        vlSelf->audio_soc_top__DOT__u_imem__DOT__rom[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 8867020385600642536ull);
    }
    vlSelf->audio_soc_top__DOT__u_audio__DOT__sample_reg = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 8336601485232252697ull);
    vlSelf->audio_soc_top__DOT__u_audio__DOT__counter = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 4510913781188558058ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__rst_n__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
