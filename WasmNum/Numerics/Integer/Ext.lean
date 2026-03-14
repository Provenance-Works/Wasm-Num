import WasmNum.Foundation

/-!
# Integer Sign Extension

Sign-extend a sub-width value within the same integer type.

Wasm spec: Section 4.3.2 "Integer Operations"
- FR-155: iextend_s
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Generic sign extension from `fromWidth` bits within a BitVec N.
    Extracts the low `fromWidth` bits and sign-extends to full width N.
    Wasm spec: `iN.extend_s` from sub-widths -/
def iextend_s (fromWidth : Nat) (v : BitVec N) : BitVec N :=
  (v.extractLsb' 0 fromWidth).signExtend N

end WasmNum.Numerics.Integer
