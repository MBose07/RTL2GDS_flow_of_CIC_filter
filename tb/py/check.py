import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy import signal

def plot_full_analysis(input_wav, output_wav, s_type="Software"):
    # 1. Load the files
    fs_in, data_in = wavfile.read(input_wav)
    fs_out, data_out = wavfile.read(output_wav)

    # Mono conversion
    if len(data_in.shape) > 1: data_in = data_in.mean(axis=1)
    if len(data_out.shape) > 1: data_out = data_out.mean(axis=1)

    # Normalize for comparison
    data_in_norm = data_in / np.max(np.abs(data_in))
    data_out_norm = data_out / np.max(np.abs(data_out))

    # Create time axes (in seconds)
    t_in = np.arange(len(data_in_norm)) / fs_in
    t_out = np.arange(len(data_out_norm)) / fs_out

    # Create the figure with two subplots
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))

    # --- TOP PLOT: TIME DOMAIN ---
    ax1.plot(t_in, data_in_norm, label='Input Signal', color='gray', alpha=0.4)
    ax1.plot(t_out, data_out_norm, label=f'{s_type} Output', color='blue', alpha=0.8)
    
    ax1.set_title(f"Time Domain: Input vs {s_type} CIC Output")
    ax1.set_xlabel("Time (seconds)")
    ax1.set_ylabel("Normalized Amplitude")
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    # Optional: zoom into a specific 50ms window to see the samples clearly
    # ax1.set_xlim([0.5, 0.55]) 

    # --- BOTTOM PLOT: FREQUENCY DOMAIN (FFT) ---
    f_in, p_in = signal.welch(data_in_norm, fs_in, nperseg=8192)
    f_out, p_out = signal.welch(data_out_norm, fs_out, nperseg=8192)

    p_in_db = 10 * np.log10(p_in / np.max(p_in))
    p_out_db = 10 * np.log10(p_out / np.max(p_out))

    ax2.plot(f_in, p_in_db, label='Input Spectrum', color='gray', alpha=0.4)
    ax2.plot(f_out, p_out_db, label=f'{s_type} Spectrum', color='red', linewidth=1.5)

    ax2.set_title(f"Frequency Response: Input vs {s_type} Output")
    ax2.set_xlabel("Frequency (Hz)")
    ax2.set_ylabel("Magnitude (dB)")
    ax2.set_xlim([0, 5000])  # Zoomed to the passband as requested
    ax2.set_ylim([-140, 5])
    ax2.legend()
    ax2.grid(True, which="both", ls="-", alpha=0.3)

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    # You can call this for your software golden model
    plot_full_analysis('./py/input_audio.wav', './py/software_output.wav', s_type="Software")
    
    # Or call it for your actual Verilog result
    plot_full_analysis('./py/input_audio.wav', './py/filtered_output.wav', s_type="RTL")