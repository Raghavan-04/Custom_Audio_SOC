// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaudio_soc_top.h for the primary calling header

#include "Vaudio_soc_top__pch.h"

void Vaudio_soc_top___024root___ctor_var_reset(Vaudio_soc_top___024root* vlSelf);

Vaudio_soc_top___024root::Vaudio_soc_top___024root(Vaudio_soc_top__Syms* symsp, const char* namep)
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vaudio_soc_top___024root___ctor_var_reset(this);
}

void Vaudio_soc_top___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vaudio_soc_top___024root::~Vaudio_soc_top___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
