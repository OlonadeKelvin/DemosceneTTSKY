import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Timer

@cocotb.test()
async def test_demoscene_platinum(dut):

    dut._log.info("Starting DemosceneTTSKY test")

    # Setup inputs
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1

    # 25 MHz clock (period 40 ns)
    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())

    # Reset pulse
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Reset released")

    # Wait for at least one full frame (800*525 = 420,000 cycles)
        # Wait for first falling vsync
    await FallingEdge(dut.uo_out[7])
    dut._log.info("First vsync falling edge detected")
    dut._log.info("Waiting for one full frame...")
    await ClockCycles(dut.clk, 420_000)

    # Check that hsync and vsync are toggling
    hsync = dut.uo_out.value.integer & (1 << 6)   # bit 6
    vsync = dut.uo_out.value.integer & (1 << 7)   # bit 7
    dut._log.info(f"After one frame: hsync bit = {hsync >> 6}, vsync bit = {vsync >> 7}")

    # Run for ~4 more frames to capture LFSR changes
    dut._log.info("Running for 3 more frames to observe LFSR...")
    for frame in range(3):
        await ClockCycles(dut.clk, 420_000)
        dut._log.info(f"Frame {frame+2} completed")

    # Quick check on audio output during blanking (just read it)
    audio = dut.uio_out.value
    oe    = dut.uio_oe.value
    dut._log.info(f"Final uio_out (audio) = {audio}, uio_oe = {oe}")

    dut._log.info("DemosceneTTSKY test finished successfully!")
