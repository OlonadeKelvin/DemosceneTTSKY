# 🎨 DemosceneTTSKY: Algorithmic Pattern Generator

[![GDS](https://github.com/OlonadeKelvin/DemosceneTTSKY/actions/workflows/gds.yaml/badge.svg)](https://github.com/OlonadeKelvin/DemosceneTTSKY/actions/workflows/gds.yaml)
[![Docs](https://github.com/OlonadeKelvin/DemosceneTTSKY/actions/workflows/docs.yaml/badge.svg)](https://github.com/OlonadeKelvin/DemosceneTTSKY/actions/workflows/docs.yaml)

> **An algorithmic pattern generator that turns math into art.**
> Pure logic gates, no CPU, no memory. Just a VGA monitor, a speaker, and the infinite beauty of hardware math.

## Overview

Algorithmic Pattern Generator is a single-chip VGA visual synthesizer designed for the **[Tiny Tapeout 09 Demoscene competition](https://tinytapeout.com)**. It generates a 640×480 @ 60Hz colour video signal entirely from combinational logic and a few registers. No framebuffer, no ROM, no microcontroller – every pixel’s colour is calculated on the fly using bitwise equations.

An internal **Linear Feedback Shift Register (LFSR)** acts as a virtual DJ, autonomously switching between 8 distinct visual patterns, morphing colour palettes, and tweaking mathematical parameters every second. The result is an endless, mesmerizing lightshow that never repeats.

Optionally, an audio output is generated during video blanking intervals, producing crunchy Bytebeat-style chiptune music – turning the chip into a full audiovisual performance unit.

## How It Works (The Magic)

### 1. VGA Timing Generator
- Counts pixels horizontally (0–799) and lines vertically (0–524) at 25 MHz.
- Generates proper **hsync** (negative pulse of 96 pixels) and **vsync** (negative pulse of 2 lines) as per VGA specification.
- Active display region: 640×480 pixels.
- Outputs current `(x, y)` coordinate for the render engine.

### 2. The Render Engine (Math is Art)
Instead of storing an image, we **evaluate a mathematical function `f(x, y, t)`** for each pixel. The hardware implements 8 carefully crafted equations using only bitwise shifts, XORs, ANDs, ORs, and additions. These are all **single‑cycle** combinational operations – perfect for 25 MHz.

#### Our 8 Visual Equations:

| Mode | Equation (simplified) | Visual Style |
| :--- | :--- | :--- |
| 0 | `(x ^ y) & (x >> s) & (y >> s)` | Sierpinski fractal weave |
| 1 | `(x ^ y ^ (y>>1) ^ (x<<1)) + t` | Organic plasma clouds |
| 2 | `((x*3+y)>>1) ^ ((x+y*3)>>2) + t` | Rotating moiré tunnels |
| 3 | `(x>>1) - (y>>1) ^ (x \| y) + t` | Pulsating cellular ripples |
| 4 | `(x & y) - (x \| y) ^ t` | Concentric interference rings |
| 5 | `(x<<1) ^ (y<<1) ^ ((x+y) >> s)` | Sharp metallic landscapes |
| 6 | `(x*y) & 0xFF` (shift-add multiplier) | Soft pastel fractal swirls |
| 7 | `x ^ y ^ (x>>(y%8)) ^ (y>>(x%8)) ^ t` | Chaotic glitch art |

> `s` is a shift amount (0–7), `t` is a frame counter that increments every vsync (60 Hz).  
> All operations are 10‑bit intermediate; final result is truncated to 8‑bit luminance/colour index.

### 3. Autonomous Show Controller (LFSR Sequencer)
- A 16‑bit LFSR (taps at 0,2,3,5) runs freely.
- Every **60 frames** (~1 second), it captures a new random value:
  - Bits `[2:0]` → select the visual mode (0–7).
  - Bits `[5:3]` → set a global shift amount `s` (0–7).
  - Bits `[7:6]` → choose one of four colour palettes.
- This creates a **non‑repeating, self‑directed visual performance** – the chip is its own VJ.

### 4. Colour Output (6-bit RGB)
The 8‑bit computed pixel value is mapped to 6‑bit colour via a palette lookup, which is dynamically switched by the LFSR.
- Simple resistor DAC on the dedicated output pins provides a beautiful analogue VGA signal.
- Possible palettes: natural, channel‑swapped, muted, inverted.

### 5. Audio 
During the blanking periods (when no pixel is being drawn), the same arithmetic engine that once drove the Base Edition Bytebeat kicks in. An extra pin outputs an 8‑bit audio waveform, derived from a free‑running counter, producing retro chiptune melodies. The transition is seamless and adds a powerful sensory layer.

### 6. Manual Override Feature
The system supports a manual override mode using ui_in:
- ui_in[4] = 1 enable manual mode control
- ui_in[7:5] select visual mode (0–7)
- ui_in[4] = 0 fully autonomous LFSR-driven mode

This allows:
live debugging of patterns
deterministic visual selection
interactive demo control

