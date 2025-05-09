# Axi-stream-processor
axi stream data processor controllled by axi-lite-register

# AXI-Stream Processor with AXI-Lite Control

## Overview
This design implements a **configurable AXI-Stream processor** that performs one of three operations on incoming AXI-Stream data, based on a control value written via an AXI-Lite register interface.

### Supported Modes (Controlled via AXI-Lite)

| Mode | Function                          | Description |
|------|-----------------------------------|-------------|
| 0    | **Pass-through**                  | Outputs data as received |
| 1    | **Byte reversal**                 | Reverses byte order within each word (endianness swap) |
| 2    | **Add constant**                  | Adds a configurable constant to each input word |

---
## File Structure

- `rtl/axi_lite_ctrl.v` – AXI-Lite control logic handling mode selection and constant value configuration.
- `rtl/axi_stream_fifo.v` – AXI-Stream processor and FIFO with data transformation logic.
- `rtl/top_axi_processor.v` – Synthesisable top-level module connecting AXI-Lite and AXI-Stream logic.
  
## Design Approach

- **Modularization:** The design is split into two RTL modules:
  - `axi_lite_ctrl`: Controls operation mode and constant value via AXI-Lite writes.
  - `axi_stream_fifo`: Applies the selected transformation using a small FIFO for buffering and backpressure.
  
- **AXI Protocol Compliance:**
  - Fully compliant AXI-Stream handshake (uses `TVALID`, `TREADY`, `TLAST`, `TKEEP`, and `TSTRB`)
  - AXI-Lite write and read operations are supported with proper acknowledgment and readback.

- **Parameterization:**
  - Data width is parameterizable (`DATA_WIDTH = 32` or `64` bits).
  - FIFO is implemented with a 16-depth array of registers.
  

---

## Specification

1. **AXI-Stream input and output interfaces** are always active and follow valid AXI protocol.
2. **Data width parameter** is either 32 or 64 bits. If 64-bit is selected, the byte reversal logic must cover all 8 bytes.
3. **FIFO** with axi-stream interface is used as buffer between input and output interface to maintain the data without loss.
4. **TLAST, TKEEP, and TSTRB** are stored and passed through with the data word without transformation.

---

