# DemosceneTTSKY: Algorithmic Pattern Generator

[![GDS](https://github.com/OlonadeKelvin/DemosceneTTSKY/actions/workflows/gds.yaml/badge.svg)](https://github.com/OlonadeKelvin/DemosceneTTSKY/actions/workflows/gds.yaml)
[![Docs](https://github.com/OlonadeKelvin/DemosceneTTSKY/actions/workflows/docs.yaml/badge.svg)](https://github.com/OlonadeKelvin/DemosceneTTSKY/actions/workflows/docs.yaml)

## Overview
This project is an ASIC design submitted for the **Tiny Tapeout 09 Demoscene**. It implements a generative hardware engine that produces complex auditory and visual patterns using minimal logic gates.

Instead of relying on memory blocks, this design calculates a continuous stream of byte-sized data in real-time by applying bitwise operations (shifts, XORs, ANDs) against a cascading time counter. The result is a hardware-based "Bytebeat" engine.

## How it Works
*   **Inputs (`ui_in`):** Acts as real-time control switches to shift the mathematical equations and alter the generated pattern.
*   **Outputs (`uo_out`):** An 8-bit stream of generative data that can be interpreted as a raw audio waveform, an oscilloscope X/Y plot, or shifting VGA colors.
*   **Clock (`clk`):** Drives the internal state and dictates the speed of the pattern evolution.

## To-Do List (WIP)
- [ ] Implement the core 16-bit counter.
- [ ] Design the bitwise permutation logic.
- [ ] Write the `cocotb` testbench for verification.
- [ ] Pass OpenLane GDS hardening.

## License
This project is open-source and licensed under the MIT License.
