# FPGA Switch UART Project

This project reads a switch on the Basys3 FPGA, sends its state via a custom UART transmitter, and plots it live using Python.

## Features
- Reads a single input switch.
- Samples at ~2 kHz (configurable in Sampler.vhdl).
- Sends each sample over UART.
- Python script reads and plots the switch state in real-time.

## Setup

### FPGA
1. Open Vivado and create a new project.
2. Add all VHDL and Verilog (testbench) files
3. Set the Basys3 as the target board.
4. Assign pins using `Basys3.xdc`.
5. Synthesize, implement, and program the FPGA.

### Python
1. Install dependencies:
   ```bash
   pip install matplotlib
   pip install pyserial
