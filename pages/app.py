import streamlit as st
import numpy as np
import pandas as pd

# Set up page configuration
st.set_page_config(
    page_title="Audio SoC Interactive Simulator",
    page_icon="🔊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom Styling to mimic original style.css
st.markdown("""
<style>
    .header-box {
        background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
        color: white;
        padding: 30px;
        border-radius: 12px;
        margin-bottom: 25px;
        text-align: center;
    }
    .module-card {
        background-color: #f8fafc;
        border: 2px solid #e2e8f0;
        border-radius: 8px;
        padding: 15px;
        margin-bottom: 10px;
        min-height: 120px;
    }
    .module-card-active {
        background-color: #f0fdf4;
        border-color: #22c55e;
    }
    .module-title {
        font-weight: bold;
        color: #1e293b;
        font-size: 15px;
    }
    .module-status {
        font-size: 13px;
        color: #2563eb;
        font-weight: 600;
        margin-top: 8px;
    }
    .stat-val {
        font-size: 24px;
        font-weight: 700;
        color: #2563eb;
    }
</style>
""", unsafe_allow_html=True)

# Application Header
st.markdown("""
<div class="header-box">
    <h1>Audio SoC Interactive Simulator</h1>
    <p>A custom RISC-V System-on-Chip for deterministic real-time audio processing</p>
</div>
""", unsafe_allow_html=True)

# Audio Configuration Parameters (Sidebar Layout)
with st.sidebar:
    st.header("🎛️ Audio Parameters")
    
    volume = st.slider("Volume (Gain)", min_value=0, max_value=100, value=50, step=5, format="%d%%")
    frequency = st.slider("Frequency", min_value=100, max_value=2000, value=440, step=50, format="%d Hz")
    filter_cutoff = st.slider("Filter Cutoff", min_value=200, max_value=5000, value=1000, step=200, format="%d Hz")
    
    st.divider()
    st.markdown("### 🔊 Sound Output")
    
    # Generate 1.5 seconds of live playable audio based on sliders
    sample_rate = 44100
    duration = 1.5
    t_audio = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    audio_signal = np.sin(2 * np.pi * frequency * t_audio) * (volume / 100)
    
    # Process Filter onto full audio stream if active
    if filter_cutoff < 5000:
        fc = filter_cutoff / sample_rate
        alpha = fc / (fc + 0.0159)
        # Vectorized approximation of the lowpass for performance on longer arrays
        audio_signal = np.convolve(audio_signal, [alpha, 1 - alpha], mode='same')
    
    # Normalize limits safely
    audio_signal = np.clip(audio_signal, -1.0, 1.0)
    st.audio(audio_signal, sample_rate=sample_rate)

# Main Dashboard Grid split into 2 Sections
col1, col2 = st.columns([2, 1])

with col1:
    st.subheader("🖥️ SoC Processing Pipeline Status")
    
    # Dynamic calculations for pipeline step feedback
    pwm_hex = hex(int(volume * 255 / 100))[2:].upper().zfill(2)
    multiplier_val = int(filter_cutoff / 200)
    
    p_col1, p_col2, p_col3, p_col4 = st.columns(4)
    
    with p_col1:
        st.markdown(f"""
        <div class="module-card">
            <div class="module-title">RV32IM CPU</div>
            <p style='font-size:11px; color:#64748b;'>Single-cycle hardware execution</p>
            <div class="module-status">⚙️ × {multiplier_val} mult</div>
        </div>
        """, unsafe_allow_html=True)
        
    with p_col2:
        st.markdown(f"""
        <div class="module-card">
            <div class="module-title">Hardware Timer</div>
            <p style='font-size:11px; color:#64748b;'>22µs intervals<br>44.1 kHz clock</p>
            <div class="module-status" style="color:#10b981;">⏱️ Active</div>
        </div>
        """, unsafe_allow_html=True)
        
    with p_col3:
        st.markdown(f"""
        <div class="module-card">
            <div class="module-title">AXI4-Lite Bus</div>
            <p style='font-size:11px; color:#64748b;'>Valid/Ready handshake route</p>
            <div class="module-status">➡️ TX: 0x{pwm_hex}</div>
        </div>
        """, unsafe_allow_html=True)
        
    with p_col4:
        st.markdown(f"""
        <div class="module-card">
            <div class="module-title">Audio PWM Engine</div>
            <p style='font-size:11px; color:#64748b;'>8-bit output pulse width driver</p>
            <div class="module-status">🔊 {volume}% Duty</div>
        </div>
        """, unsafe_allow_html=True)

    # Real-Time Visual Waveform Logic
    st.subheader("📊 Output Waveform (500 Sample Frame)")
    
    samples_count = 500
    t_plot = np.arange(samples_count) / sample_rate
    plot_signal = np.sin(2 * np.pi * frequency * t_plot) * (volume / 100)
    
    # Precise calculation mirroring Javascript processing loop
    if filter_cutoff < 5000:
        fc = filter_cutoff / sample_rate
        alpha = fc / (fc + 0.0159)
        filtered_plot = np.zeros(samples_count)
        filtered_plot[0] = plot_signal[0]
        for i in range(1, samples_count):
            filtered_plot[i] = alpha * plot_signal[i] + (1 - alpha) * filtered_plot[i-1]
        plot_signal = filtered_plot

    plot_signal = np.clip(plot_signal, -1.0, 1.0)
    
    # Generate Time-axis labels matching millisecond presentation format
    time_ms = [f"{(i / 44.1):.1f} ms" for i in range(samples_count)]
    chart_data = pd.DataFrame({
        "Amplitude": plot_signal
    }, index=time_ms)
    
    st.line_chart(chart_data, y_label="Signal Value", x_label="Time Frame (ms)")

with col2:
    st.subheader("📈 Performance Metrics")
    m_col1, m_col2 = st.columns(2)
    m_col1.metric("Cycles / Sample", "22")
    m_col2.metric("Jitter Range", "±0 µs")
    st.metric("Sample Rate Output", "44.1 kHz (CD-Quality)")
    
    st.divider()
    st.subheader("📋 System Specifications")
    st.markdown("""
    * **Instruction Set Architecture:** RV32IM (32-bit RISC-V with M-extension)
    * **Clock Architecture:** Single-Cycle Constant execution time
    * **Interconnect Protocol:** AMBA AXI4-Lite Standardized Handshake
    * **Key Operational Feature:** Zero-jitter predictable timing environment
    """)

st.divider()

# Core Concept Workflow Description Box
st.info("""
💡 **Sample Processing Pipeline Flow:** 
Every 22 microseconds, the hardware timer fires an interrupt hook. The core CPU fetches the audio instructions, decodes processing contexts, handles mathematical functions via the hardware multiplier module, and dispatches target profiles via the AXI4-Lite bus framework to the underlying PWM audio engine blocks to manipulate hardware sound output profiles.
""")