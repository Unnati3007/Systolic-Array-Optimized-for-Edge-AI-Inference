# Systolic-Array-Optimized-for-Edge-AI-Inference
# Systolic Array Optimized for Edge AI Inference

A hardware accelerator for deep neural network inference, implemented in **Verilog** on FPGA. Uses a **16×16 systolic array** with a weight-stationary dataflow to accelerate matrix multiplication — the core operation in every DNN layer — achieving **128 GOPS** peak throughput at **250 MHz** with **22% lower power** than floating-point FPGA baselines.

---

## What is a Systolic Array?

A systolic array is a grid of simple processing elements (PEs) that rhythmically pass data between neighbours. Each PE does one multiply-accumulate (MAC) per clock cycle. Because data flows through the array like blood through a heart (systole), the design name is "systolic."

```
Weight Matrix (stationary in PEs)
         w00  w01  w02  ...  w0,15
         w10  w11  w12  ...  w1,15
          .                   .
         w15,0 ...        w15,15

Input activations flow →→→ across rows
Partial sums accumulate ↓↓↓ down columns
Output at bottom row = one output tile
```

**Weight-stationary** means weights are loaded once and stay in the PEs; inputs stream through. This maximises weight reuse and minimises costly off-chip DRAM accesses.

---

## Results

| Metric | This Design | FP32 FPGA Baseline |
|--------|-------------|-------------------|
| Clock frequency | **250 MHz** | 200 MHz |
| Peak throughput | **128 GOPS** | 51 GOPS |
| Power consumption | **~3.1 W** | ~4.0 W |
| Power efficiency | **22% better** | baseline |
| Precision loss | **< 1%** (INT8 vs FP32) | — |
| Array size | 16 × 16 PEs | — |

---

## Tech Stack

- **Verilog HDL** — RTL design
- **Xilinx Vivado** — synthesis, place & route, timing analysis
- **ModelSim / Questa** — functional simulation and testbenches
- **Python + NumPy** — golden reference model for verification
- **Target FPGA** — Xilinx Zynq UltraScale+ (or equivalent)

---

## Project Structure

```
Systolic-Array-Optimized-for-Edge-AI-Inference/
├── rtl/
│   ├── pe.v                  # Processing Element (MAC unit)
│   ├── systolic_array.v      # 16x16 PE grid
│   ├── weight_buffer.v       # On-chip SRAM weight buffer
│   ├── activation_buffer.v   # Input activation double buffer
│   ├── output_buffer.v       # Accumulator output buffer
│   ├── quantizer.v           # INT8 quantization / dequantization
│   └── top.v                 # Top-level module
├── tb/
│   ├── tb_pe.v               # PE unit testbench
│   ├── tb_systolic_array.v   # Full array testbench
│   └── tb_top.v              # System-level testbench
├── scripts/
│   ├── generate_weights.py   # Generate test weight matrices
│   └── verify_output.py      # Compare RTL output vs NumPy golden model
├── constraints/
│   └── timing.xdc            # Vivado timing constraints (250 MHz)
└── README.md
```

---

## Key Design Decisions

**INT8 Quantization**
Weights and activations are quantized from FP32 to INT8 before loading. Each PE performs 8-bit × 8-bit multiply → 32-bit accumulate (avoiding overflow). Dequantization happens once at the output, incurring less than 1% accuracy loss on standard benchmarks.

**Double Buffering**
While the array computes on tile N, the DMA prefetches tile N+1 into the shadow buffer. This hides memory latency and keeps the array busy 100% of the time.

**Timing Closure at 250 MHz**
Pipeline registers are inserted between PE rows every 4 rows to break the critical path. The design meets 250 MHz timing with positive slack on a Zynq UltraScale+ target.

---

## Simulation

```bash
# Simulate the PE unit
vsim -do "vsim tb_pe; run -all"

# Simulate the full 16x16 array
vsim -do "vsim tb_systolic_array; run -all"

# Verify against NumPy golden model
python scripts/verify_output.py --rtl-output sim_output.txt --tolerance 0.01
```
