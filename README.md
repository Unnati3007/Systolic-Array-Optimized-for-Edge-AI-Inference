# Systolic-Array-Optimized-for-Edge-AI-Inference
An RTL design of a Systolic Array architecture aimed at optimizing Matrix-Vector Multiplications for Deep Learning algorithms. The project emphasizes efficient throughput and data reuse for edge-AI inference workloads.
Objective: Develop a specialized Verilog accelerator to perform matrix-vector multiplication in Deep Learning networks with minimal latency.
Approach: Developed a 16X16 Systolic Array that employs a Weight Stationary scheme and fine-tuned RTL to achieve timing closure at 250 MHz. Used INT8 quantization to minimize chip area and energy consumption without compromising accuracy for AI/ML workloads.
Outcome: Achieved power savings of 22% and reached peak performance of 128 GOPS with <1% accuracy degradation.
