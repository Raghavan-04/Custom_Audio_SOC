// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vaudio_soc_top__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vaudio_soc_top::Vaudio_soc_top(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vaudio_soc_top__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , rst_n{vlSymsp->TOP.rst_n}
    , audio_out{vlSymsp->TOP.audio_out}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
    contextp()->traceBaseModelCbAdd(
        [this](VerilatedTraceBaseC* tfp, int levels, int options) { traceBaseModel(tfp, levels, options); });
}

Vaudio_soc_top::Vaudio_soc_top(const char* _vcname__)
    : Vaudio_soc_top(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vaudio_soc_top::~Vaudio_soc_top() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vaudio_soc_top___024root___eval_debug_assertions(Vaudio_soc_top___024root* vlSelf);
#endif  // VL_DEBUG
void Vaudio_soc_top___024root___eval_static(Vaudio_soc_top___024root* vlSelf);
void Vaudio_soc_top___024root___eval_initial(Vaudio_soc_top___024root* vlSelf);
void Vaudio_soc_top___024root___eval_settle(Vaudio_soc_top___024root* vlSelf);
void Vaudio_soc_top___024root___eval(Vaudio_soc_top___024root* vlSelf);

void Vaudio_soc_top::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vaudio_soc_top::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vaudio_soc_top___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vaudio_soc_top___024root___eval_static(&(vlSymsp->TOP));
        Vaudio_soc_top___024root___eval_initial(&(vlSymsp->TOP));
        Vaudio_soc_top___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vaudio_soc_top___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vaudio_soc_top::eventsPending() { return false; }

uint64_t Vaudio_soc_top::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vaudio_soc_top::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vaudio_soc_top___024root___eval_final(Vaudio_soc_top___024root* vlSelf);

VL_ATTR_COLD void Vaudio_soc_top::final() {
    Vaudio_soc_top___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vaudio_soc_top::hierName() const { return vlSymsp->name(); }
const char* Vaudio_soc_top::modelName() const { return "Vaudio_soc_top"; }
unsigned Vaudio_soc_top::threads() const { return 1; }
void Vaudio_soc_top::prepareClone() const { contextp()->prepareClone(); }
void Vaudio_soc_top::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vaudio_soc_top::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vaudio_soc_top___024root__trace_decl_types(VerilatedVcd* tracep);

void Vaudio_soc_top___024root__trace_init_top(Vaudio_soc_top___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vaudio_soc_top___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vaudio_soc_top___024root*>(voidSelf);
    Vaudio_soc_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(vlSymsp->name(), VerilatedTracePrefixType::SCOPE_MODULE);
    Vaudio_soc_top___024root__trace_decl_types(tracep);
    Vaudio_soc_top___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vaudio_soc_top___024root__trace_register(Vaudio_soc_top___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vaudio_soc_top::traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options) {
    (void)levels; (void)options;
    VerilatedVcdC* const stfp = dynamic_cast<VerilatedVcdC*>(tfp);
    if (VL_UNLIKELY(!stfp)) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vaudio_soc_top::trace()' called on non-VerilatedVcdC object;"
            " use --trace-fst with VerilatedFst object, and --trace-vcd with VerilatedVcd object");
    }
    stfp->spTrace()->addModel(this);
    stfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vaudio_soc_top___024root__trace_register(&(vlSymsp->TOP), stfp->spTrace());
}
