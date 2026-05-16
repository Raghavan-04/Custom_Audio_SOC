let waveformChart = null;
let audioContext = null;
let oscillator = null;
let gainNode = null;
let isPlaying = false;

// Initialize Chart.js waveform
function initWaveform() {
    const ctx = document.getElementById('waveform');
    const volume = parseInt(document.getElementById('volume').value);
    const frequency = parseInt(document.getElementById('frequency').value);
    const filter = parseInt(document.getElementById('filter').value);
    
    const data = generateWaveformData(volume, frequency, filter, 500);
    
    waveformChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Audio Output',
                data: data.values,
                borderColor: '#2563eb',
                backgroundColor: 'rgba(37, 99, 235, 0.05)',
                borderWidth: 2,
                tension: 0.2,
                fill: true,
                pointRadius: 0,
                pointHoverRadius: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'nearest',
                intersect: false
            },
            plugins: {
                legend: { display: false },
                tooltip: { enabled: false }
            },
            scales: {
                y: {
                    min: -1,
                    max: 1,
                    ticks: {
                        color: '#666666'
                    },
                    grid: {
                        color: 'rgba(200, 200, 200, 0.1)'
                    }
                },
                x: {
                    display: false,
                    grid: { display: false }
                }
            }
        }
    });
}

// Generate waveform data
function generateWaveformData(volume, frequency, filterCutoff, samples = 500) {
    const sampleRate = 44100;
    const values = [];
    const labels = [];
    
    for (let i = 0; i < samples; i++) {
        const t = i / sampleRate;
        
        // Generate base sine wave
        let sample = Math.sin(2 * Math.PI * frequency * t) * (volume / 100);
        
        // Apply simple low-pass filter
        if (filterCutoff < 5000) {
            const fc = filterCutoff / sampleRate;
            const alpha = fc / (fc + 0.0159); // Smoothing factor
            if (i > 0) {
                sample = alpha * sample + (1 - alpha) * (values[i - 1] || sample);
            }
        }
        
        values.push(Math.max(-1, Math.min(1, sample)));
        labels.push((i / 44.1).toFixed(1));
    }
    
    return { values, labels };
}

// Update waveform chart
function updateWaveform() {
    if (!waveformChart) {
        initWaveform();
        return;
    }
    
    const volume = parseInt(document.getElementById('volume').value);
    const frequency = parseInt(document.getElementById('frequency').value);
    const filter = parseInt(document.getElementById('filter').value);
    
    const data = generateWaveformData(volume, frequency, filter, 500);
    
    waveformChart.data.datasets[0].data = data.values;
    waveformChart.data.labels = data.labels;
    waveformChart.update('none');
}

// Animate timer pulse
function animateTimerPulse() {
    const timerFill = document.getElementById('timer-fill');
    const timerVal = document.getElementById('timer-val');
    
    timerFill.style.animation = 'none';
    
    setTimeout(() => {
        timerFill.style.animation = 'timing 0.022s linear forwards';
        
        let microseconds = 0;
        const interval = setInterval(() => {
            microseconds += 1;
            timerVal.textContent = microseconds + ' µs';
            
            if (microseconds >= 22) {
                clearInterval(interval);
                timerVal.textContent = '0 µs';
            }
        }, 0.5);
    }, 10);
}

// Animate data flow through pipeline
function animateDataFlow() {
    const cpuBlock = document.getElementById('cpu-block');
    const busBlock = document.getElementById('bus-block');
    const pwmBlock = document.getElementById('pwm-block');
    const timerBlock = document.getElementById('timer-block');
    
    // CPU is active
    cpuBlock.classList.add('active');
    const volume = parseInt(document.getElementById('volume').value);
    const frequency = parseInt(document.getElementById('frequency').value);
    const filter = parseInt(document.getElementById('filter').value);
    
    document.getElementById('cpu-stat').textContent = 
        'Processing: multiply × ' + Math.floor(filter / 200);
    
    // Timer is active
    timerBlock.classList.add('active');
    animateTimerPulse();
    
    // After 80ms, bus is active
    setTimeout(() => {
        busBlock.classList.add('active');
        const pwmValue = Math.floor(volume * 255 / 100).toString(16).toUpperCase().padStart(2, '0');
        document.getElementById('bus-stat').textContent = 
            'Transfer: 0x' + pwmValue + ' (AXI handshake)';
    }, 80);
    
    // After 160ms, PWM is active
    setTimeout(() => {
        pwmBlock.classList.add('active');
        document.getElementById('pwm-stat').textContent = 
            'Output: ' + Math.floor(volume) + '% duty cycle';
    }, 160);
    
    // After 300ms, clear active states
    setTimeout(() => {
        cpuBlock.classList.remove('active');
        busBlock.classList.remove('active');
        pwmBlock.classList.remove('active');
        timerBlock.classList.remove('active');
        
        document.getElementById('cpu-stat').textContent = 'Idle';
        document.getElementById('bus-stat').textContent = 'Idle';
        document.getElementById('pwm-stat').textContent = 'Listening...';
    }, 300);
}

// Update simulator on input change
function updateSimulator() {
    const volume = parseInt(document.getElementById('volume').value);
    const frequency = parseInt(document.getElementById('frequency').value);
    const filter = parseInt(document.getElementById('filter').value);
    
    // Update displays
    document.getElementById('volume-val').textContent = volume + '%';
    document.getElementById('freq-val').textContent = frequency + ' Hz';
    document.getElementById('filter-val').textContent = filter + ' Hz';
    
    // Update waveform
    updateWaveform();
    
    // Animate pipeline
    animateDataFlow();
    
    // If audio is playing, update it
    if (isPlaying && audioContext) {
        updateAudioParameters();
    }
}

// Initialize Web Audio API
function initAudioContext() {
    if (!audioContext) {
        audioContext = new (window.AudioContext || window.webkitAudioContext)();
        gainNode = audioContext.createGain();
        gainNode.connect(audioContext.destination);
    }
}

// Update audio parameters in real-time
function updateAudioParameters() {
    if (!oscillator || !gainNode) return;
    
    const volume = parseInt(document.getElementById('volume').value);
    const frequency = parseInt(document.getElementById('frequency').value);
    
    oscillator.frequency.setValueAtTime(frequency, audioContext.currentTime);
    gainNode.gain.setValueAtTime(volume / 100 * 0.3, audioContext.currentTime); // 0.3 for safety
}

// Play audio
function playAudio() {
    initAudioContext();
    
    if (isPlaying) {
        stopAudio();
    }
    
    const volume = parseInt(document.getElementById('volume').value);
    const frequency = parseInt(document.getElementById('frequency').value);
    
    // Create oscillator
    oscillator = audioContext.createOscillator();
    oscillator.type = 'sine';
    oscillator.frequency.setValueAtTime(frequency, audioContext.currentTime);
    
    // Set volume
    gainNode.gain.setValueAtTime(volume / 100 * 0.3, audioContext.currentTime);
    
    // Connect and start
    oscillator.connect(gainNode);
    oscillator.start();
    
    isPlaying = true;
    document.getElementById('play-btn').textContent = 'Playing...';
    document.getElementById('play-btn').disabled = true;
}

// Stop audio
function stopAudio() {
    if (oscillator && isPlaying) {
        oscillator.stop();
        isPlaying = false;
        document.getElementById('play-btn').textContent = 'Play Audio';
        document.getElementById('play-btn').disabled = false;
    }
}

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
    initWaveform();
    animateDataFlow();
    
    // Range sliders
    document.getElementById('volume').addEventListener('input', updateSimulator);
    document.getElementById('frequency').addEventListener('input', updateSimulator);
    document.getElementById('filter').addEventListener('input', updateSimulator);
    
    // Auto-animate every 3 seconds
    setInterval(() => {
        if (!isPlaying) {
            animateDataFlow();
        }
    }, 3000);
});

// Cleanup on page unload
window.addEventListener('beforeunload', function() {
    stopAudio();
    if (audioContext) {
        audioContext.close();
    }
});