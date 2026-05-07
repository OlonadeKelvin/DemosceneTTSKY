import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_bytebeat(dut):
    dut._log.info("Starting Bytebeat Synthesizer Test")

    # Set initial input values to 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    
    # Start a 10 MHz Clock (100ns period)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Apply Reset
    dut._log.info("Resetting DUT")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Reset complete")
    
    # Test Pattern 0 (Original Mode)
    dut._log.info("Testing Pattern 0")
    dut.ui_in.value = 0b000_0_0000 # pat_sel=0, mask_en=0, shift=0
    await ClockCycles(dut.clk, 100)

    # Test Pattern 1 (Classic Bytebeat with mask and shift)
    dut._log.info("Testing Pattern 1")
    # pat_sel=1 (001), mask_en=1, shift=2 (010) -> 001_1_0010
    dut.ui_in.value = 0b001_1_0010 
    await ClockCycles(dut.clk, 100)

    # Test Pattern 5 (Square-wave mash)
    dut._log.info("Testing Pattern 5")
    # pat_sel=5 (101), mask_en=1, shift=4 (100) -> 101_1_0100
    dut.ui_in.value = 0b101_1_0100 
    
    # Let the counter run to generate a good chunk of waveform data
    await ClockCycles(dut.clk, 500)
    
    dut._log.info("All Bytebeat patterns simulated successfully!")
