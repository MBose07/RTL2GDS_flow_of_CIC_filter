import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile

def align_by_first_peak(soft_wav, rtl_wav):
    fs_s, data_s = wavfile.read(soft_wav)
    fs_r, data_r = wavfile.read(rtl_wav)

    def norm(d):
        if len(d.shape) > 1: d = d.mean(axis=1)
        return d.astype(np.float32) / (np.max(np.abs(d)) + 1e-9)

    s_soft = norm(data_s)
    s_rtl = norm(data_r)

    # 1. Find the first sample that exceeds 10% of the maximum volume
    # This skips the "reset" silence in hardware.
    threshold = 0.1
    idx_s = np.where(np.abs(s_soft) > threshold)[0][0]
    idx_r = np.where(np.abs(s_rtl) > threshold)[0][0]

    print(f"Software starts at sample: {idx_s}")
    print(f"RTL starts at sample: {idx_r}")

    # 2. Align them
    s_soft_aligned = s_soft[idx_s:]
    s_rtl_aligned = s_rtl[idx_r:]

    # Trim to match
    length = min(len(s_soft_aligned), len(s_rtl_aligned))
    s_soft_aligned = s_soft_aligned[:length]
    s_rtl_aligned = s_rtl_aligned[:length]

    # 3. Final SNR Check
    error = s_soft_aligned - s_rtl_aligned
    mse = np.mean(error**2)
    snr = 10 * np.log10(np.mean(s_soft_aligned**2) / (mse + 1e-20))
    
    print(f"--- Alignment Result ---")
    print(f"New MSE: {mse:.2e} | New SNR: {snr:.2f} dB")

    # 4. Plot just the FIRST 500 samples to verify the "Snap"
    plt.figure(figsize=(12, 5))
    plt.plot(s_soft_aligned[:500], label="Software (Golden)", alpha=0.6, linewidth=2)
    plt.plot(s_rtl_aligned[:500], label="RTL (Aligned)", linestyle="--", color="orange")
    plt.title(f"MSE (SNR: {snr:.2f} dB)")
    plt.xlim([0,50])
    plt.legend()
    plt.show()

if __name__ == "__main__":
    align_by_first_peak('software_output.wav', 'filtered_output.wav')