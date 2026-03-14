import WasmNum.Foundation

/-!
# Float Comparisons

Wasm floating-point comparison operations.
All comparisons return `I32` (0 or 1). NaN always compares unordered.

Wasm spec: Section 4.3.3 "Floating-Point Operations"
- FR-106: feq, fne, flt, fgt, fle, fge
-/

namespace WasmNum.Numerics.Float

open WasmNum

variable {N : Nat}

/-- Wasm feq: ordered equality. NaN != anything (including itself).
    +0 == -0 is true.
    Wasm spec: `feq(z1, z2)` -/
def feq [WasmFloat N] (a b : BitVec N) : I32 :=
  if WasmFloat.isNaN a || WasmFloat.isNaN b then 0#32
  else if WasmFloat.eq a b then 1#32 else 0#32

/-- Wasm fne: ordered inequality. NaN != anything is true.
    Wasm spec: `fne(z1, z2)` -/
def fne [WasmFloat N] (a b : BitVec N) : I32 :=
  if WasmFloat.isNaN a || WasmFloat.isNaN b then 1#32
  else if WasmFloat.eq a b then 0#32 else 1#32

/-- Wasm flt: ordered less-than. NaN compares unordered (returns 0).
    Wasm spec: `flt(z1, z2)` -/
def flt [WasmFloat N] (a b : BitVec N) : I32 :=
  if WasmFloat.isNaN a || WasmFloat.isNaN b then 0#32
  else if WasmFloat.lt a b then 1#32 else 0#32

/-- Wasm fgt: ordered greater-than. NaN compares unordered (returns 0).
    Wasm spec: `fgt(z1, z2)` -/
def fgt [WasmFloat N] (a b : BitVec N) : I32 :=
  if WasmFloat.isNaN a || WasmFloat.isNaN b then 0#32
  else if WasmFloat.lt b a then 1#32 else 0#32

/-- Wasm fle: ordered less-or-equal. NaN compares unordered (returns 0).
    Wasm spec: `fle(z1, z2)` -/
def fle [WasmFloat N] (a b : BitVec N) : I32 :=
  if WasmFloat.isNaN a || WasmFloat.isNaN b then 0#32
  else if WasmFloat.le a b then 1#32 else 0#32

/-- Wasm fge: ordered greater-or-equal. NaN compares unordered (returns 0).
    Wasm spec: `fge(z1, z2)` -/
def fge [WasmFloat N] (a b : BitVec N) : I32 :=
  if WasmFloat.isNaN a || WasmFloat.isNaN b then 0#32
  else if WasmFloat.le b a then 1#32 else 0#32

end WasmNum.Numerics.Float
