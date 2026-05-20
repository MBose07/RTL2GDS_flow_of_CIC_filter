import numpy as np
from scipy.io import wavfile

def apply_software_cic(input_wav, output_wav, R=4, N=6, D=4):
    print(f"Reading {input_wav}...")
    fs, data = wavfile.read(input_wav)

    # 1. Pre-process: Convert to Mono
    if len(data.shape) > 1:
        data = data.mean(axis=1)
    
    # 2. IMPORTANT: Remove DC Offset
    # If the average isn't exactly 0, 6 stages of integration will explode.
    data = data - np.mean(data)
    
    # 3. Convert to high-precision integers to mimic hardware registers
    # We use int64 to allow the numbers to grow very large
    x = data.astype(np.int64)

    # 4. Integrator Stages
    print(f"Integrating {N} stages...")
    for i in range(N):
        # np.cumsum mimics the 'integrator <= integrator + d_in' logic
        x = np.cumsum(x)

    # 5. Decimation
    print(f"Decimating by {R}...")
    x = x[::R]
    new_fs = int(fs / R)

    # 6. Comb Stages
    print(f"Comb filtering {N} stages...")
    for i in range(N):
        # y[n] = x[n] - x[n-D]
        diff = np.zeros_like(x)
        diff[D:] = x[D:] - x[:-D]
        x = diff

    # 7. Normalization
    # We check for NaNs or Inf just in case
    x = np.nan_to_num(x)
    
    print("Normalizing and saving...")
    max_val = np.max(np.abs(x))
    if max_val > 0:
        x_norm = x / max_val
    else:
        print("Warning: Output is still all zeros. Check input signal levels.")
        x_norm = x

    # 8. Save
    audio_out = (x_norm * 32767).astype(np.int16)
    wavfile.write(output_wav, new_fs, audio_out)
    print(f"Success! Output saved to {output_wav}")

if __name__ == "__main__":
    # Make sure 'input_audio.wav' is a valid, non-silent wav file
    apply_software_cic('./py/input_audio.wav', './py/software_output.wav', R=4, N=6, D=4)