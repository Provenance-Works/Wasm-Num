import WasmNum.Foundation
import WasmNum.Numerics.NaN.Propagation

/-!
# Float Min/Max

Wasm-specific fmin and fmax operations.
These differ from IEEE 754 minimum/maximum in NaN and signed-zero handling.
Results are `Set (BitVec N)` due to NaN non-determinism (ADR-003).

Wasm spec: Section 4.3.3 "Floating-Point Operations"
- FR-102: fmin/fmax
-/

namespace WasmNum.Numerics.Float

open WasmNum

variable {N : Nat}

/-- Wasm fmin: returns the minimum of two floats.
    - If either input is NaN, result is from `nansN`.
    - If both inputs are zero (possibly different signs), returns the negative zero.
    - Otherwise, returns the smaller value.
    Wasm spec: `fmin(z1, z2)` -/
def fmin [WasmFloat N] (a b : BitVec N) : Set (BitVec N) :=
  NaN.propagateNaN₂ (fun x y =>
    if WasmFloat.isZero x && WasmFloat.isZero y then
      if WasmFloat.isNegative x then x else y
    else if WasmFloat.lt x y then x
    else y
  ) a b

/-- Wasm fmax: returns the maximum of two floats.
    - If either input is NaN, result is from `nansN`.
    - If both inputs are zero (possibly different signs), returns the positive zero.
    - Otherwise, returns the larger value.
    Wasm spec: `fmax(z1, z2)` -/
def fmax [WasmFloat N] (a b : BitVec N) : Set (BitVec N) :=
  NaN.propagateNaN₂ (fun x y =>
    if WasmFloat.isZero x && WasmFloat.isZero y then
      if WasmFloat.isNegative x then y else x
    else if WasmFloat.lt y x then x
    else y
  ) a b

end WasmNum.Numerics.Float
