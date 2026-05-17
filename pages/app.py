import streamlit as st
import numpy as np
import plotly.graph_objects as go

# Page config
st.set_page_config(page_title="Audio SoC Simulator", page_icon="🎵", layout="wide")

# CSS Styling
st.markdown("""
<style>
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
              padding: 2rem; border-radius: 10px; color: white; text-align: center; margin-bottom: 2rem; }
    .header h1 { margin: 0; font-size: 2.5rem; }
    .header p { margin: 0.5rem 0 0 0; opacity: 0.95; }
    .metric { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
              padding: 1.5rem; border-radius: 10px; color: white; text-align: center; }
    .metric h3 { margin: 0; font-size: 0.85rem; opacity: 0.85; text-transform: uppercase; }
    .metric .value { font-size: 1.8rem; font-weight: bold; margin: 0.75rem 0 0 0; }
    .info { background: #f0f4ff; border-left: 4px solid #667eea; padding: 1.5rem; border-radius: 8px; margin: 1rem 0; }
    .box { background: #f8f9ff; border: 2px solid #e0e7ff; border-radius: 8px; padding: 1.5rem; margin: 0.5rem 0; }
    .box h3 { color: #667eea; margin-top: 0; }
</style>
""", unsafe_allow_html=True)

# --- GLOBAL CACHED FUNCTIONS (Moved out of tabs for perfect execution) ---
@st.cache_data
def generate_waveform(freq, vol, filt, samples=2000):
    sample_rate = 44100
    t = np.linspace(0, samples / sample_rate, samples)
    waveform = np.sin(2 * np.pi * freq * t) * (vol / 100)
    
    if filt < 5000:
        alpha = filt / (filt + 1000)
        filtered = np.zeros_like(waveform)
        filtered[0] = waveform[0]
        for i in range(1, len(waveform)):
            filtered[i] = alpha * waveform[i] + (1 - alpha) * filtered[i-1]
        waveform = filtered
    
    return t, waveform

# Header
st.markdown("""
<div class="header">
    <h1>🎵 Audio SoC Interactive Simulator</h1>
    <p>Custom RISC-V System-on-Chip for Deterministic Real-Time Audio Processing</p>
</div>
""", unsafe_allow_html=True)

# Sidebar controls
st.sidebar.header("⚙️ Audio Parameters")
volume = st.sidebar.slider("Volume (Gain)", 0, 100, 50, step=5)
frequency = st.sidebar.slider("Frequency", 100, 2000, 440, step=50)
filter_cutoff = st.sidebar.slider("Filter Cutoff", 200, 5000, 1000, step=200)

# --- ADDED FEATURE: Real Sound Engine ---
st.sidebar.markdown("---")
st.sidebar.subheader("🔊 Live Audio Engine")
# Generate 1.0 second of playable audio array based on user parameters
playback_rate = 44100
t_audio = np.linspace(0, 1.0, playback_rate, endpoint=False)
audio_data = np.sin(2 * np.pi * frequency * t_audio) * (volume / 100)
# Simple lowpass filter implementation for playback array
if filter_cutoff < 5000:
    alpha_a = filter_cutoff / (filter_cutoff + 1000)
    audio_data = np.convolve(audio_data, [alpha_a, 1 - alpha_a], mode='same')
st.sidebar.audio(np.clip(audio_data, -1.0, 1.0), sample_rate=playback_rate)

# Metrics row
col1, col2, col3, col4 = st.columns(4)
with col1:
    st.markdown('<div class="metric"><h3>Sample Rate</h3><div class="value">44.1K</div></div>', unsafe_allow_html=True)
with col2:
    st.markdown('<div class="metric"><h3>Jitter</h3><div class="value">±0 µs</div></div>', unsafe_allow_html=True)
with col3:
    st.markdown('<div class="metric"><h3>Cycles/Sample</h3><div class="value">22</div></div>', unsafe_allow_html=True)
with col4:
    st.markdown('<div class="metric"><h3>Multiplier</h3><div class="value">1 cycle</div></div>', unsafe_allow_html=True)

st.markdown("---")

# Tabs
tab1, tab2, tab3, tab4 = st.tabs(["🎛️ Waveform", "📡 Pipeline", "🔧 Modules", "📋 Specs"])

# TAB 1: Waveform
with tab1:
    st.header("Real-Time Audio Output")
    
    t, waveform = generate_waveform(frequency, volume, filter_cutoff)
    
    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=t[:1000] * 1000,
        y=waveform[:1000],
        mode='lines',
        name='Audio Output',
        line=dict(color='#667eea', width=2),
        fill='tozeroy',
        fillcolor='rgba(102, 126, 234, 0.2)'
    ))
    fig.update_layout(
        title=f"Waveform: {frequency} Hz @ {volume}% volume",
        xaxis_title="Time (ms)",
        yaxis_title="Amplitude",
        hovermode='x unified',
        height=400
    )
    st.plotly_chart(fig, use_container_width=True)
    
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Frequency Target", f"{frequency} Hz")
    with col2:
        st.metric("Volume Gain", f"{volume}%")
    with col3:
        st.metric("Filter Cutoff", f"{filter_cutoff} Hz")

# TAB 2: Pipeline
with tab2:
    st.header("Data Processing Pipeline")
    col1, col2 = st.columns([2, 1])
    
    with col1:
        stages = ['Fetch', 'Decode', 'Execute', 'AXI Bus', 'PWM Output']
        x_pos = np.arange(len(stages))
        colors = ['#667eea', '#764ba2', '#f093fb', '#4facfe', '#00f2fe']
        
        fig_pipeline = go.Figure()
        fig_pipeline.add_trace(go.Scatter(
            x=x_pos,
            y=[1]*len(stages),
            mode='markers+text',
            marker=dict(size=40, color=colors),
            text=stages,
            textposition='top center',
            textfont=dict(size=10, color='white'),
            hovertemplate='<b>%{text}</b><extra></extra>',
            showlegend=False
        ))
        
        for i in range(len(stages) - 1):
            fig_pipeline.add_annotation(
                x=x_pos[i] + 0.4, y=1,
                ax=x_pos[i+1] - 0.4, ay=1,
                xref='x', yref='y', axref='x', ayref='y',
                arrowhead=2, arrowsize=1, arrowwidth=2, arrowcolor='#667eea',
                showarrow=True
            )
        
        fig_pipeline.update_layout(
            title="5-Stage Processing Pipeline",
            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            height=300,
            plot_bgcolor='rgba(240,244,255,0.5)',
            xaxis_range=[-0.5, 4.5],
            yaxis_range=[0.5, 1.5]
        )
        st.plotly_chart(fig_pipeline, use_container_width=True)
    
    with col2:
        st.markdown("""
        **Pipeline Stages:**
        
        1️⃣ **Fetch** - CPU reads instruction
        
        2️⃣ **Decode** - Instruction identified
        
        3️⃣ **Execute** - ALU executes operation
        
        4️⃣ **AXI Bus** - Safe data transfer
        
        5️⃣ **PWM Output** - Speaker conversion
        
        ⏱️ **Timing:** Every 22µs
        """)
    
    st.markdown("---")
    st.subheader("Module Activity Status")
    
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.markdown('<div class="info"><b>🧠 CPU</b><br>Single-cycle<br>Hardware multiplier</div>', unsafe_allow_html=True)
    with col2:
        st.markdown('<div class="info"><b>⏱️ Timer</b><br>22µs interrupt<br>44.1 kHz</div>', unsafe_allow_html=True)
    with col3:
        st.markdown('<div class="info"><b>🛣️ Bus</b><br>AXI4-Lite<br>Safe handshake</div>', unsafe_allow_html=True)
    with col4:
        st.markdown('<div class="info"><b>🔊 PWM</b><br>8-bit output<br>Speaker driver</div>', unsafe_allow_html=True)

# TAB 3: Modules
with tab3:
    st.header("System-on-Chip Modules")
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("RV32IM CPU Core")
        st.write("""
        **Specifications:**
        - 32-bit RISC-V processor with M-Extension
        - Single-cycle hardware multiplier (1 cycle vs 32+ software cycles)
        """)
        
        operations = ['32-bit Multiply', 'Gain Control', 'FIR Filter Tap']
        rv32i = [35, 16, 10]
        
        fig_mult = go.Figure(data=[
            go.Bar(name='Speedup', x=operations, y=rv32i, marker_color='#667eea')
        ])
        fig_mult.update_layout(
            title="Hardware Multiplier Speedup Factor",
            yaxis_title="Speedup (RV32I vs RV32IM)",
            height=300
        )
        st.plotly_chart(fig_mult, use_container_width=True)
    
    with col2:
        st.subheader("Hardware Timer")
        st.write("""
        - 22 microsecond intervals / 44.1 kHz sample clock
        - Zero jitter processing system (±0 µs)
        """)
        
        interrupt_times = np.arange(0, 100, 22) / 1000
        fig_timer = go.Figure()
        for t in interrupt_times:
            fig_timer.add_vline(x=t, line_dash='dash', line_color='#667eea', opacity=0.5)
        
        fig_timer.update_layout(
            title="22µs Interrupt Pattern Timing (ms)",
            xaxis_title="Time Interval",
            height=250
        )
        st.plotly_chart(fig_timer, use_container_width=True)

# TAB 4: Specifications
with tab4:
    st.header("Complete System Specifications")
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Instruction Set Architecture")
        specs1 = {"ISA": "RV32IM", "Word Size": "32-bit", "Execution Core": "Single-cycle"}
        for key, value in specs1.items():
            st.write(f"**{key}:** {value}")
    with col2:
        st.subheader("Clock & Timing")
        specs2 = {"Clock Model": "Single-Cycle Core", "Sample Rate": "44.1 kHz", "Sample Interval": "22.68 µs"}
        for key, value in specs2.items():
            st.write(f"**{key}:** {value}")
            
    st.markdown("---")
    st.subheader("Performance Benchmarking Table")
    benchmark_data = {
        'Operation': ['32-bit Multiply', 'Gain Control', 'FIR Filter Tap'],
        'RV32I (Software)': ['32-40 Cycles', '50 Cycles', '120 Cycles'],
        'RV32IM (Hardware)': ['1 Cycle', '3 Cycles', '12 Cycles'],
        'Speedup': ['35x', '16x', '10x']
    }
    st.dataframe(benchmark_data, use_container_width=True, hide_index=True)

st.markdown("""
<div style="text-align: center; color: #666; margin-top: 3rem; padding: 2rem 0; border-top: 1px solid #eee;">
    <p><strong>Audio SoC Interactive Simulator v1.1</strong></p>
</div>
""", unsafe_allow_html=True)