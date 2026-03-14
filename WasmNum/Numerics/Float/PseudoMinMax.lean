import WasmNum.Foundation

/-!
# Float Pseudo Min/Max (SIMD)

Pseudo-minimum and pseudo-maximum for SIMD float operations.
Unlike fmin/fmax, these use C-like semantics (IEEE 754 totalOrder-based)
and do NOT perform NaN propagation — they are deterministic.

Wasm spec: SIMD proposal — `f32x4.pmin`, `f32x4.pmax`, etc.
- FR-107: fpmin, fpmax
-/

namespace WasmNum.Numerics.Float

open WasmNum

variable {N : Nat}

/-- Wasm fpmin (pseudo-minimum): if b < a then b else a.
    NaN propagation is NOT performed. `WasmFloat.lt` returns `false` for
    unordered (NaN) comparisons, so if either operand is NaN the
    first operand `a` is returned.
    Wasm spec: `fpmin(z1, z2)` = if z2 < z1 then z2 else z1 -/
def fpmin [WasmFloat N] (a b : BitVec N) : BitVec N :=
  if WasmFloat.lt b a then b else a

/-- Wasm fpmax (pseudo-maximum): if a < b then b else a.
    NaN propagation is NOT performed. `WasmFloat.lt` returns `false` for
    unordered (NaN) comparisons, so if either operand is NaN the
    first operand `a` is returned.
    Wasm spec: `fpmax(z1, z2)` = if z1 < z2 then z2 else z1 -/
def fpmax [WasmFloat N] (a b : BitVec N) : BitVec N :=
  if WasmFloat.lt a b then b else a

end WasmNum.Numerics.Float
