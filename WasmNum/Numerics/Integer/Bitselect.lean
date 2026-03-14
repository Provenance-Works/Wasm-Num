import WasmNum.Foundation

/-!
# Integer Bitselect

Bit-level selection: for each bit position, select from `a` if mask bit is 1,
from `b` if mask bit is 0. Used by v128.bitselect.

Wasm spec: SIMD proposal — v128.bitselect
- FR-305: v128.bitselect
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Wasm ibitselect: `(a AND mask) OR (b AND NOT mask)`.
    Wasm spec: `v128.bitselect` -/
def ibitselect (a b mask : BitVec N) : BitVec N :=
  (a &&& mask) ||| (b &&& ~~~mask)

end WasmNum.Numerics.Integer
