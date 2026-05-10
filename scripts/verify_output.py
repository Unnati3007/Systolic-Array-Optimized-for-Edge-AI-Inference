"""
verify_output.py
Compare RTL simulation output against a NumPy golden reference model.
Usage: python verify_output.py --rtl-output sim_output.txt --tolerance 0.01
"""

import argparse
import numpy as np


def numpy_matmul_int8(weights: np.ndarray, activations: np.ndarray) -> np.ndarray:
    """Golden reference: INT8 matmul with INT32 accumulation."""
    W = weights.astype(np.int32)
    A = activations.astype(np.int32)
    return W @ A  # shape: [16, batch]


def load_rtl_output(path: str) -> np.ndarray:
    """Load RTL simulation output (space-separated integers, one row per line)."""
    rows = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("//"):
                rows.append([int(x) for x in line.split()])
    return np.array(rows, dtype=np.int32)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--rtl-output", required=True)
    parser.add_argument("--size", type=int, default=16)
    parser.add_argument("--tolerance", type=float, default=0.01)
    args = parser.parse_args()

    np.random.seed(42)
    weights = np.random.randint(-128, 127, (args.size, args.size), dtype=np.int8)
    activations = np.random.randint(-128, 127, (args.size, args.size), dtype=np.int8)

    golden = numpy_matmul_int8(weights, activations)
    rtl_out = load_rtl_output(args.rtl_output)

    if rtl_out.shape != golden.shape:
        print(f"Shape mismatch: RTL={rtl_out.shape}, golden={golden.shape}")
        return

    max_err = np.max(np.abs(rtl_out - golden))
    rel_err = max_err / (np.max(np.abs(golden)) + 1e-9)
    print(f"Max absolute error : {max_err}")
    print(f"Max relative error : {rel_err:.6f}")

    if rel_err <= args.tolerance:
        print(f"PASS — RTL output matches golden model (tolerance={args.tolerance})")
    else:
        print(f"FAIL — relative error {rel_err:.4f} exceeds tolerance {args.tolerance}")


if __name__ == "__main__":
    main()
