import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

def drive_cic_inputs(dut, val, valid_in=True):
    """Constructs and drives all input pins in one single transaction"""
    # 1. Handle the 11-bit signed -> unsigned conversion
    val_unsigned = int(val) & 0x7FF
    
    # 2. Drive ui_in (Bits 7:0)
    dut.ui_in.value = val_unsigned & 0xFF
    
    # 3. Construct uio_in
    # Bit 0 = valid_in
    # Bits 2, 3, 4 = bits 8, 9, 10 of sample
    uio_val = 0x01 if valid_in else 0x00
    
    bit8  = (val_unsigned >> 8) & 0x1
    bit9  = (val_unsigned >> 9) & 0x1
    bit10 = (val_unsigned >> 10) & 0x1
    
    # Combine everything into one 8-bit byte for uio_in
    uio_val |= (bit8 << 2) | (bit9 << 3) | (bit10 << 4)
    
    dut.uio_in.value = uio_val

def sample_cic_output(dut):
    """Unpacks the 11-bit signed value from the output pins"""
    low_byte = dut.uo_out.value.integer
    # Extract bits 8, 9, 10 from uio_out[7:5]
    uio_val = dut.uio_out.value.integer
    bit8  = (uio_val >> 5) & 0x1
    bit9  = (uio_val >> 6) & 0x1
    bit10 = (uio_val >> 7) & 0x1
    
    combined = low_byte | (bit8 << 8) | (bit9 << 9) | (bit10 << 10)
    
    # Convert from 11-bit unsigned back to signed integer
    if combined & (1 << 10):
        combined -= (1 << 11)
    return combined

@cocotb.test()
async def test_cic_audio_processing(dut):
    cocotb.start_soon(Clock(dut.clk, 100, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0
    await Timer(1, units="us")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Load input.txt
    with open("input1.txt", "r") as f:
        input_samples = [int(line.strip()) for line in f if line.strip()]

    output_samples = []

    for sample in input_samples:
        await RisingEdge(dut.clk)
        
        # Drive the combined value
        drive_cic_inputs(dut, sample, valid_in=True)
        
        # WAIT for the hardware to process (one delta cycle or use FallingEdge)
        # Reading on FallingEdge is the safest way to avoid race conditions
        await FallingEdge(dut.clk)
        
        # Monitor valid_out (uio_out[1])
        if (dut.uio_out.value.integer >> 1) & 0x1:
            out_val = sample_cic_output(dut)
            output_samples.append(out_val)

    # Flush the filter
    for _ in range(200):
        await RisingEdge(dut.clk)
        drive_cic_inputs(dut, 0, valid_in=False)
        await FallingEdge(dut.clk)
        if (dut.uio_out.value.integer >> 1) & 0x1:
            output_samples.append(sample_cic_output(dut))

    with open("output1.txt", "w") as f:
        for s in output_samples:
            f.write(f"{s}\n")
    
    dut._log.info(f"Simulation finished. Received {len(output_samples)} samples.")