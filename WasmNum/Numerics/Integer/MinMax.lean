import WasmNum.Foundation

/-!
# Integer Min/Max

Signed and unsigned min/max for SIMD lane operations.

Wasm spec: Section 4.3.2 "Integer Operations"
- FR-155: imin, imax (signed/unsigned)
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Wasm imin_u: unsigned minimum.
    Wasm spec: `iN.min_u` (SIMD) -/
def imin_u (a b : BitVec N) : BitVec N :=
  if a.toNat ≤ b.toNat then a else b

/-- Wasm imin_s: signed minimum.
    Wasm spec: `iN.min_s` (SIMD) -/
def imin_s (a b : BitVec N) : BitVec N :=
  if a.toInt ≤ b.toInt then a else b

/-- Wasm imax_u: unsigned maximum.
    Wasm spec: `iN.max_u` (SIMD) -/
def imax_u (a b : BitVec N) : BitVec N :=
  if a.toNat ≥ b.toNat then a else b

/-- Wasm imax_s: signed maximum.
    Wasm spec: `iN.max_s` (SIMD) -/
def imax_s (a b : BitVec N) : BitVec N :=
  if a.toInt ≥ b.toInt then a else b

end WasmNum.Numerics.Integer
