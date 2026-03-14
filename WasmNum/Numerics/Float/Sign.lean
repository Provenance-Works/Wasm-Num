import WasmNum.Foundation

/-!
# Float Sign Operations

Deterministic bitwise float operations: fabs, fneg, fcopysign.
These operate directly on the bit pattern and do NOT perform NaN propagation.

Wasm spec: Section 4.3.3 "Floating-Point Operations"
- FR-105: fcopysign, fabs, fneg
-/

namespace WasmNum.Numerics.Float

open WasmNum

variable {N : Nat}

/-- Sign bit mask: 1 in the MSB position, 0 elsewhere. -/
private def signMask (N : Nat) : BitVec N :=
  1#N <<< (N - 1)

/-- Wasm fabs: clear the sign bit.
    Wasm spec: `fabs(z)` — set sign bit to 0 -/
def fabs (a : BitVec N) : BitVec N :=
  a &&& ~~~(signMask N)

/-- Wasm fneg: toggle the sign bit.
    Wasm spec: `fneg(z)` — flip sign bit -/
def fneg (a : BitVec N) : BitVec N :=
  a ^^^ signMask N

/-- Wasm fcopysign: copy sign of `b` to magnitude of `a`.
    Wasm spec: `fcopysign(z1, z2)` — z1 with sign of z2 -/
def fcopysign (a b : BitVec N) : BitVec N :=
  (a &&& ~~~(signMask N)) ||| (b &&& signMask N)

end WasmNum.Numerics.Float
