# COSC 215 Spring 2025 - Password Cracker Project

This project implements a multi-layer hardware-based password cracking system in Verilog. It communicates with a provided C-based guard program using a serial communication protocol with handshaking.

> **Goal**: Crack the hidden password as fast as possible using optimized circuit design, parallelism, and smart password generation strategies.

---

## 🧩 Layers Overview

### 🔹 Layer 1: Bit Transmission (Provided)
- Sends 1 bit using `D`, `rq`, `ak` handshaking
- Waits for ack before de-asserting request

### 🔸 Layer 2: 16-Bit Passcode Sender
- Sends 16-bit passcodes in big-endian order
- Uses Layer 1 for each bit
- Only transmits when `rd` is high

### 🔺 Layer 3: Sequence Sender
- Sends sequence of passcodes
- Waits for `rd` to re-assert after each
- Stops if `rd` is not high within 1 ms (indicates success)


