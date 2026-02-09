// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VAUDIO_SOC_TOP__SYMS_H_
#define VERILATED_VAUDIO_SOC_TOP__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vaudio_soc_top.h"

// INCLUDE MODULE CLASSES
#include "Vaudio_soc_top___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vaudio_soc_top__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vaudio_soc_top* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vaudio_soc_top___024root       TOP;

    // CONSTRUCTORS
    Vaudio_soc_top__Syms(VerilatedContext* contextp, const char* namep, Vaudio_soc_top* modelp);
    ~Vaudio_soc_top__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
