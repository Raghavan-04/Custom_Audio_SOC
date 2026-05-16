import streamlit as st
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyBboxPatch
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import time

# Page configuration
st.set_page_config(
    page_title="Audio SoC Interactive Simulator",
    page_icon="🎵",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
<style>
    .main {
        padding-top: 0rem;
    }
    
    .header-container {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 2rem;
        border-radius: 10px;
        margin-bottom: 2rem;
        color: white;
        text-align: center;
    }
    
    .header-container h1 {
        margin: 0;
        font-size: 2.5rem;
        font-weight: bold;
    }
    
    .header-container p {
        margin: 0.5rem 0 0 0;
        font-size: 1.1rem;
        opacity: 0.95;
    }
    
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1.5rem;
        border-radius: 10px;
        color: white;
        text-align: center;
        margin: 0.5rem 0;
    }
    
    .metric-card h3 {
        margin: 0;
        font-size: 0.9rem;
        opacity: 0.9;
        font-weight: normal;
    }
    
    .metric-card .value {
        font-size: 2rem;
        font-weight: bold;
        margin: 0.5rem 0 0 0;
    }
    
    .module-active {
        border: 3px solid #667eea;
        background-color: rgba(102, 126, 234, 0.1);
    }
    
    .info-box {
        background-color: #f0f4ff;
        border-left: 4px solid #667eea;
        padding: 1rem;
        border-radius: 5px;
        margin: 1rem 0;
    }
    
    .warning-box {
        background-color: #fff3cd;
        border-left: 4px solid #ffc107;
        padding: 1rem;
        border-radius: 5px;
        margin: 1rem 0;
    }
</style>
""", unsafe_allow_html=True)

# App title
st.markdown("""
<div class="header-container">
    <h1>🎵 Audio SoC Interactive Simulator</h1>
    <p>Custom RISC-V System-on-Chip for Deterministic Real-Time Audio Processing</p>
</div>
""", unsafe_allow_html=True)

# Initialize session state
if 'audio_playing' not in st.session_state:
    st.session_state.audio_playing = False
if 'animation_frame' not in st.session_state:
    st.session_state.animation_frame = 0

# Sidebar controls
st.sidebar.header("⚙️ Audio Parameters")

volume = st.sidebar.slider("Volume (Gain)", 0, 100, 50, step=5, help="Output amplitude 0-100%")
frequency = st.sidebar.slider("Frequency", 100, 2000, 440, step=50, help="Sine wave frequency in Hz")
filter_cutoff = st.sidebar.slider("Filter Cutoff", 200, 5000, 1000, step=200, help="Low-pass filter frequency")

st.sidebar.markdown("---")
st.sidebar.header("📊 Display Options")
show_waveform = st.sidebar.checkbox("Show Waveform", value=True)
show_spectrum = st.sidebar.checkbox("Show Frequency Spectrum", value=True)
show_pipeline = st.sidebar.checkbox("Show Data Pipeline", value=True)
show_specs = st.sidebar.checkbox("Show Specifications", value=True)

# --- MAIN CONTENT ---

# Row 1: System Architecture & Metrics
col1, col2, col3, col4 = st.columns(4)

with col1:
    st.markdown('<div class="metric-card"><h3>Sample Rate</h3><div class="value">44.1K</div></div>', unsafe_allow_html=True)

with col2:
    st.markdown('<div class="metric-card"><h3>Jitter</h3><div class="value">±0 µs</div></div>', unsafe_allow_html=True)

with col3:
    st.markdown('<div class="metric-card"><h3>Cycles/Sample</h3><div class="value">22</div></div>', unsafe_allow_html=True)

with col4:
    st.markdown('<div class="metric-card"><h3>Multiplier</h3><div class="value">1 cycle</div></div>', unsafe_allow_html=True)

st.markdown("---")

# Row 2: Main simulator
tab1, tab2, tab3, tab4 = st.tabs(["🎛️ Waveform", "📡 Pipeline", "🔧 Modules", "📋 Specs"])

# TAB 1: Waveform
with tab1:
    st.header("Real-Time Audio Output")
    
    # Generate waveform data
    @st.cache_data
    def generate_waveform(freq, vol, filt, samples=2000):
        sample_rate = 44100
        t = np.linspace(0, samples / sample_rate, samples)
        
        # Generate sine wave
        waveform = np.sin(2 * np.pi * freq * t) * (vol / 100)
        
        # Apply simple low-pass filter
        if filt < 5000:
            # Simple exponential moving average filter
            alpha = filt / (filt + 1000)
            filtered = np.zeros_like(waveform)
            filtered[0] = waveform[0]
            for i in range(1, len(waveform)):
                filtered[i] = alpha * waveform[i] + (1 - alpha) * filtered[i-1]
            waveform = filtered
        
        return t, waveform
    
    t, waveform = generate_waveform(frequency, volume, filter_cutoff)
    
    # Create interactive plot
    fig = go.Figure()
    
    fig.add_trace(go.Scatter(
        x=t[:1000] * 1000,  # Convert to milliseconds
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
        height=400,
        template='plotly_light',
        showlegend=True
    )
    
    st.plotly_chart(fig, use_container_width=True)
    
    # Display current parameters
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Frequency", f"{frequency} Hz")
    with col2:
        st.metric("Volume", f"{volume}%")
    with col3:
        st.metric("Filter Cutoff", f"{filter_cutoff} Hz")


# TAB 2: Pipeline
with tab2:
    st.header("Data Processing Pipeline")
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        # Create pipeline visualization
        fig_pipeline = go.Figure()
        
        stages = ['Fetch', 'Decode', 'Execute', 'AXI Bus', 'PWM Output']
        x_pos = np.arange(len(stages))
        y_pos = [1, 1, 1, 1, 1]
        
        colors = ['#667eea', '#764ba2', '#f093fb', '#4facfe', '#00f2fe']
        
        fig_pipeline.add_trace(go.Scatter(
            x=x_pos,
            y=y_pos,
            mode='markers+text',
            marker=dict(size=40, color=colors),
            text=stages,
            textposition='top center',
            textfont=dict(size=10, color='white'),
            hovertemplate='<b>%{text}</b><extra></extra>',
            showlegend=False
        ))
        
        # Add connecting arrows
        for i in range(len(stages) - 1):
            fig_pipeline.add_annotation(
                x=x_pos[i] + 0.4,
                y=1,
                ax=x_pos[i+1] - 0.4,
                ay=1,
                xref='x',
                yref='y',
                axref='x',
                ayref='y',
                arrowhead=2,
                arrowsize=1,
                arrowwidth=2,
                arrowcolor='#667eea',
                showarrow=True,
                showlegend=False
            )
        
        fig_pipeline.update_layout(
            title="5-Stage Processing Pipeline",
            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            height=300,
            hovermode='closest',
            plot_bgcolor='rgba(240,244,255,0.5)',
            xaxis_range=[-0.5, 4.5],
            yaxis_range=[0.5, 1.5]
        )
        
        st.plotly_chart(fig_pipeline, use_container_width=True)
    
    with col2:
        st.markdown("""
        **Pipeline Stages:**
        
        1️⃣ **Fetch**
        CPU reads instruction from memory
        
        2️⃣ **Decode**
        Instruction decoder identifies operation
        
        3️⃣ **Execute**
        ALU executes (hardware multiplier if needed)
        
        4️⃣ **AXI Bus**
        Data transfers safely via handshake
        
        5️⃣ **PWM Output**
        Speaker driver converts to analog
        
        ⏱️ **Timing:** Every 22µs, timer fires interrupt
        """)
    
    st.markdown("---")
    
    # Module status animation
    st.subheader("Module Activity Status")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        with st.container():
            st.markdown('<div class="info-box"><b>🧠 CPU</b><br>Processing instructions<br>Single-cycle execution</div>', unsafe_allow_html=True)
    
    with col2:
        with st.container():
            st.markdown('<div class="info-box"><b>⏱️ Timer</b><br>22µs interrupt<br>44.1 kHz timing</div>', unsafe_allow_html=True)
    
    with col3:
        with st.container():
            st.markdown('<div class="info-box"><b>🛣️ Bus</b><br>AXI4-Lite protocol<br>Safe handshake</div>', unsafe_allow_html=True)
    
    with col4:
        with st.container():
            st.markdown('<div class="info-box"><b>🔊 PWM</b><br>8-bit output<br>Speaker driver</div>', unsafe_allow_html=True)


# TAB 3: Module Details
with tab3:
    st.header("System-on-Chip Modules")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("RV32IM CPU Core")
        st.write("""
        **Specifications:**
        - 32-bit RISC-V processor
        - Single-cycle execution model
        - All instructions complete in 1 clock cycle
        - Integrated hardware multiplier
        
        **Hardware Multiplier:**
        - Executes MUL in 1 cycle (vs 32+ in software)
        - 35x faster than software implementation
        - Essential for audio DSP operations
        - Supports volume scaling, mixing, filtering
        """)
        
        # Multiplier performance comparison
        operations = ['32-bit Multiply', 'Gain Control', 'FIR Filter Tap']
        rv32i = [35, 16, 10]  # Speedup factor
        
        fig_mult = go.Figure(data=[
            go.Bar(name='Speedup Factor', x=operations, y=rv32i, marker_color='#667eea')
        ])
        fig_mult.update_layout(
            title="RV32M Hardware Multiplier Speedup",
            yaxis_title="Speedup (RV32I vs RV32M)",
            height=300,
            template='plotly_light'
        )
        st.plotly_chart(fig_mult, use_container_width=True)
    
    with col2:
        st.subheader("Hardware Timer")
        st.write("""
        **Specifications:**
        - Independent background timer
        - 22 microsecond interrupt intervals
        - Generates precise 44.1 kHz sample rate
        - Hardware guarantees zero jitter
        - Interrupt Request (IRQ) signal to CPU
        
        **Performance:**
        - Absolute timing accuracy (±0 µs)
        - No software drift
        - Deterministic audio delivery
        - Lock-in to CD-quality 44.1 kHz
        
        **Interrupt Mechanism:**
        - IRQ fires every 22µs
        - Forces CPU to pause background code
        - Instantly processes next audio sample
        - Rock-solid sample rate guarantee
        """)
        
        # Timer interrupt visualization
        interrupt_times = np.arange(0, 100, 22) / 1000  # Convert to ms
        
        fig_timer = go.Figure()
        
        for t in interrupt_times:
            fig_timer.add_vline(
                x=t,
                line_dash='dash',
                line_color='#667eea',
                opacity=0.5
            )
        
        fig_timer.update_layout(
            title="Hardware Timer: 22µs Interrupts (44.1 kHz)",
            xaxis_title="Time (ms)",
            height=250,
            template='plotly_light'
        )
        st.plotly_chart(fig_timer, use_container_width=True)
    
    st.markdown("---")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("AXI4-Lite Bus Bridge")
        st.write("""
        **Protocol Details:**
        - AMBA AXI4-Lite standardized protocol
        - Valid/Ready handshake mechanism
        - Safe data transfer guarantee
        - No data loss or corruption
        
        **Handshake Process:**
        1. CPU sets AWVALID (address write valid)
        2. Peripheral sets AWREADY (address write ready)
        3. CPU sets WVALID (write data valid)
        4. Peripheral sets WREADY (write data ready)
        5. Safe transaction completed
        
        **Advantages:**
        - Industry standard (ARM AMBA)
        - Proven reliability
        - Prevents race conditions
        - Scalable to multiple peripherals
        """)
    
    with col2:
        st.subheader("Audio PWM Engine")
        st.write("""
        **Specifications:**
        - 8-bit Pulse Width Modulation output
        - Listens to AXI4-Lite bus (address 0x400)
        - Converts digital samples to analog pulses
        - Direct speaker driver capability
        
        **PWM Operation:**
        - Digital value (0-255) sets duty cycle
        - High-frequency pulses drive speaker
        - Low-pass filter in speaker smooths output
        - Produces analog audio signal
        
        **Performance:**
        - Real-time sample capture
        - Zero latency response
        - Supports up to 8-bit resolution
        - Direct hardware implementation
        """)


# TAB 4: Specifications
with tab4:
    st.header("Complete System Specifications")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Instruction Set Architecture")
        spec_data = {
            "ISA": "RV32IM",
            "Word Size": "32-bit",
            "Base Integer": "Included",
            "M-Extension": "Hardware Multiplier",
            "Special Features": "Single-cycle execution"
        }
        for key, value in spec_data.items():
            st.write(f"**{key}:** {value}")
    
    with col2:
        st.subheader("Clock & Timing")
        timing_data = {
            "Clock Model": "Single-Cycle",
            "Execution Time": "Uniform (1 cycle)",
            "Instruction Latency": "Constant",
            "Pipeline Stages": "5 (Fetch-Decode-Execute-AXI-PWM)",
            "Sample Rate": "44.1 kHz"
        }
        for key, value in timing_data.items():
            st.write(f"**{key}:** {value}")
    
    st.markdown("---")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Memory & I/O")
        memory_data = {
            "Instruction Memory": "On-chip ROM",
            "Data Memory": "On-chip RAM",
            "Audio Output": "Address 0x400 (AXI)",
            "Timer Control": "Address 0x500 (Direct MMIO)",
            "Bus Protocol": "AMBA AXI4-Lite"
        }
        for key, value in memory_data.items():
            st.write(f"**{key}:** {value}")
    
    with col2:
        st.subheader("Audio Characteristics")
        audio_data = {
            "Output Format": "8-bit PWM",
            "Sampling Rate": "44.1 kHz (exact)",
            "Jitter": "±0 microseconds",
            "Sample Interval": "22.68 microseconds",
            "Maximum Frequency": "22.05 kHz (Nyquist)"
        }
        for key, value in audio_data.items():
            st.write(f"**{key}:** {value}")
    
    st.markdown("---")
    
    st.subheader("Performance Benchmarking")
    
    bench_data = {
        'Operation': ['32-bit Multiply', 'Gain Control', 'FIR Filter Tap'],
        'RV32I (Software)': ['~32-40 Cycles', '~50 Cycles', '~120 Cycles'],
        'RV32IM (Hardware)': ['1 Cycle', '3 Cycles', '12 Cycles'],
        'Speedup': ['35x', '16x', '10x']
    }
    
    benchmark_df = st.dataframe(bench_data, use_container_width=True, hide_index=True)
    
    st.info("""
    **Analysis:** With a 50MHz clock, the CPU has a budget of ~1,100 cycles per sample. 
    RV32M reduces the cost of a 10-tap filter from 25% of the total CPU budget to less than 2%.
    """)

st.markdown("---")

# Footer
st.markdown("""
<div style="text-align: center; color: #666; margin-top: 3rem;">
    <p>Audio SoC Interactive Simulator v1.0 | Deterministic Real-Time Audio Processing</p>
    <p style="font-size: 0.9rem;">Built with Streamlit | Custom RISC-V Hardware Design</p>
</div>
""", unsafe_allow_html=True)