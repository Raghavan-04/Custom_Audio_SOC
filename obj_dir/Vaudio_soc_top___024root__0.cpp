// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaudio_soc_top.h for the primary calling header

#include "Vaudio_soc_top__pch.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaudio_soc_top___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vaudio_soc_top___024root___eval_triggers__act(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_triggers__act\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    ((((~ (IData)(vlSelfRef.rst_n)) 
                                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__rst_n__0)) 
                                                      << 1U) 
                                                     | ((IData)(vlSelfRef.clk) 
                                                        & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__rst_n__0 = vlSelfRef.rst_n;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vaudio_soc_top___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
}

bool Vaudio_soc_top___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___trigger_anySet__act\n"); );
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

void Vaudio_soc_top___024root___nba_sequent__TOP__0(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___nba_sequent__TOP__0\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*7:0*/ __Vdly__audio_soc_top__DOT__u_audio__DOT__counter;
    __Vdly__audio_soc_top__DOT__u_audio__DOT__counter = 0;
    // Body
    __Vdly__audio_soc_top__DOT__u_audio__DOT__counter 
        = vlSelfRef.audio_soc_top__DOT__u_audio__DOT__counter;
    if (vlSelfRef.rst_n) {
        vlSelfRef.audio_soc_top__DOT__pc_curr = vlSelfRef.audio_soc_top__DOT__pc_next;
        __Vdly__audio_soc_top__DOT__u_audio__DOT__counter 
            = (0x000000ffU & ((IData)(1U) + (IData)(vlSelfRef.audio_soc_top__DOT__u_audio__DOT__counter)));
        vlSelfRef.audio_out = ((IData)(vlSelfRef.audio_soc_top__DOT__u_audio__DOT__counter) 
                               < (IData)(vlSelfRef.audio_soc_top__DOT__u_audio__DOT__sample_reg));
        if (((IData)(vlSelfRef.audio_soc_top__DOT__mem_we) 
             & (0x00000400U == vlSelfRef.audio_soc_top__DOT__alu_result))) {
            vlSelfRef.audio_soc_top__DOT__u_audio__DOT__sample_reg 
                = (0x000000ffU & vlSelfRef.audio_soc_top__DOT__read_data2);
        }
    } else {
        vlSelfRef.audio_soc_top__DOT__pc_curr = 0U;
        __Vdly__audio_soc_top__DOT__u_audio__DOT__counter = 0U;
        vlSelfRef.audio_out = 0U;
        vlSelfRef.audio_soc_top__DOT__u_audio__DOT__sample_reg = 0U;
    }
    vlSelfRef.audio_soc_top__DOT__u_audio__DOT__counter 
        = __Vdly__audio_soc_top__DOT__u_audio__DOT__counter;
    vlSelfRef.audio_soc_top__DOT__pc_next = ((IData)(4U) 
                                             + vlSelfRef.audio_soc_top__DOT__pc_curr);
}

void Vaudio_soc_top___024root___eval_nba(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_nba\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vaudio_soc_top___024root___nba_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[1U] = 1U;
    }
}

void Vaudio_soc_top___024root___trigger_orInto__act(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___trigger_orInto__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vaudio_soc_top___024root___eval_phase__act(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_phase__act\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vaudio_soc_top___024root___eval_triggers__act(vlSelf);
    Vaudio_soc_top___024root___trigger_orInto__act(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    return (0U);
}

void Vaudio_soc_top___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vaudio_soc_top___024root___eval_phase__nba(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_phase__nba\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vaudio_soc_top___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vaudio_soc_top___024root___eval_nba(vlSelf);
        Vaudio_soc_top___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vaudio_soc_top___024root___eval(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vaudio_soc_top___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("rtl/audio_soc_top.sv", 1, "", "NBA region did not converge after 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vaudio_soc_top___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("rtl/audio_soc_top.sv", 1, "", "Active region did not converge after 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
        } while (Vaudio_soc_top___024root___eval_phase__act(vlSelf));
    } while (Vaudio_soc_top___024root___eval_phase__nba(vlSelf));
}

#ifdef VL_DEBUG
void Vaudio_soc_top___024root___eval_debug_assertions(Vaudio_soc_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaudio_soc_top___024root___eval_debug_assertions\n"); );
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk & 0xfeU)))) {
        Verilated::overWidthError("clk");
    }
    if (VL_UNLIKELY(((vlSelfRef.rst_n & 0xfeU)))) {
        Verilated::overWidthError("rst_n");
    }
}
#endif  // VL_DEBUG
