import numpy as np
from scipy.io import wavfile
from scipy import signal
import os

def process_audio_for_verilog(input_wav, input_txt, in_bit_width=11, decimation_ratio=8):
    """Converts Audio to Text scaled for a specific INPUT bit-width"""
    print(f"--- Preparing {in_bit_width}-bit Input: {input_wav} ---")
    sample_rate, data = wavfile.read(input_wav)
    
    if len(data.shape) > 1:
        data = data.mean(axis=1)
    
    data_float = data / np.max(np.abs(data)) if np.max(np.abs(data)) > 0 else data

    # 1. Anti-Aliasing Filter
    cutoff = 0.8 / decimation_ratio
    b, a = signal.butter(N=6, Wn=cutoff, btype='low')
    filtered_data = signal.filtfilt(b, a, data_float)

    # 2. Scale to INPUT bit-width
    # Use in_bit_width here
    max_val = (2**(in_bit_width - 1)) - 1
    scaled_data = (filtered_data * max_val).astype(np.int32)

    with open(input_txt, 'w') as f:
        for sample in scaled_data:
            f.write(f"{sample}\n")
    
    print(f"Created {input_txt} scaled for {in_bit_width}-bit Verilog input.")
    return sample_rate

def convert_verilog_output_to_wav(output_txt, output_wav, original_sample_rate, out_bit_width=20, decimation_ratio=8):
    """Converts Text back to Audio, acknowledging the OUTPUT bit-width"""
    print(f"\n--- Recovering {out_bit_width}-bit Output: {output_txt} ---")
    if not os.path.exists(output_txt):
        print(f"Error: {output_txt} not found.")
        return

    with open(output_txt, 'r') as f:
        # We read the integers regardless of width, but knowing the width 
        # helps us understand the expected range.
        data = [int(line.strip()) for line in f if line.strip()]
    
    data_array = np.array(data, dtype=np.float32)

    # 2. Normalize 
    # Even if the Verilog output is 24-bit, this normalization 
    # brings it back to the float range [-1.0, 1.0] correctly.
    data_array -= np.mean(data_array) 
    if np.max(np.abs(data_array)) > 0:
        data_norm = data_array / np.max(np.abs(data_array))
    else:
        data_norm = data_array

    # 3. Save as standard 16-bit WAV for listening
    new_rate = int(original_sample_rate / decimation_ratio)
    audio_out = (data_norm * 32767).astype(np.int16)
    wavfile.write(output_wav, new_rate, audio_out)
    
    print(f"Created {output_wav} (Recovered from {out_bit_width}-bit RTL data).")

# ==========================================
# MAIN EXECUTION FLOW
# ==========================================
if __name__ == "__main__":
    # Settings
    RAW_AUDIO = '/home/moulikbose/STUFFFF/explo/CIC/tb/py/input_audio.wav'
    VERILOG_IN = 'input.txt'
    VERILOG_OUT = 'output.txt'
    FINAL_WAV = './py/filtered_output.wav'
    
    R = 4
    
    # --- CHANGE WIDTHS HERE ---
    IN_W  = 16 # Verilog Input bit-width (e.g., 16-bit)
    OUT_W = 16  # Verilog Output bit-width (e.g., 24-bit after growth)
    # --------------------------
    
    # Step 1: Prepare (Uses IN_W)
    fs = process_audio_for_verilog(RAW_AUDIO, VERILOG_IN, in_bit_width=IN_W, decimation_ratio=R)
    
    print(f"\n>>> Verilog expects: {IN_W} bits | Verilog should provide: {OUT_W} bits")
    input(">>> Press Enter AFTER your simulation has generated 'output.txt'...")
    
    # Step 2: Convert (Uses OUT_W)
    convert_verilog_output_to_wav(VERILOG_OUT, FINAL_WAV, fs, out_bit_width=OUT_W, decimation_ratio=R)