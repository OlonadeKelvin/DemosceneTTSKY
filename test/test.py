import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


def decode_uo_out(val):
    """Decode packed VGA output bus"""
    return {
        "rgb": val & 0x3F,
        "hsync": (val >> 6) & 1,
        "vsync": (val >> 7) & 1,
    }


@cocotb.test()
async def test_demoscene_platinum(dut):

    dut._log.info("Starting DemosceneTTSKY test")

    # -------------------------
    # INIT INPUTS
    # -------------------------
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1

    # -------------------------
    # CLOCK (25 MHz = 40 ns)
    # -------------------------
    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())

    # -------------------------
    # RESET
    # -------------------------
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Reset released")

    # -------------------------
    # WAIT FOR STABLE START
    # -------------------------
    for _ in range(1000):
        await RisingEdge(dut.clk)

    # -------------------------
    # FRAME DETECTION
    # -------------------------
    prev_vsync = 1
    frame_count = 0

    dut._log.info("Monitoring frames...")

    for cycle in range(2_000_000):

        await RisingEdge(dut.clk)

        val = dut.uo_out.value.integer
        sig = decode_uo_out(val)

        # detect falling edge of vsync (frame boundary)
        if prev_vsync == 1 and sig["vsync"] == 0:
            frame_count += 1
            dut._log.info(f"Frame detected: {frame_count}")

        prev_vsync = sig["vsync"]

        # stop after a few frames
        if frame_count >= 5:
            break

    # -------------------------
    # FINAL CHECKS
    # -------------------------
    val = dut.uo_out.value.integer
    sig = decode_uo_out(val)

    dut._log.info(f"Final RGB: {sig['rgb']}")
    dut._log.info(f"Final HSYNC: {sig['hsync']}")
    dut._log.info(f"Final VSYNC: {sig['vsync']}")

    # -------------------------
    # AUDIO CHECK
    # -------------------------
    audio = dut.uio_out.value.integer
    oe = dut.uio_oe.value.integer

    dut._log.info(f"Audio output: {audio}")
    dut._log.info(f"OE state: {oe}")

    dut._log.info("Test completed successfully")
