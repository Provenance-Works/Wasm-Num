import WasmNum.Foundation

/-!
# Trapping (Partial) Conversions

Float-to-integer conversions that trap (return `none`) on NaN, Infinity,
or out-of-range values.

Wasm spec: Section 4.4 "Conversions"
- FR-201: trunc_u / trunc_s (Partial)
-/

namespace WasmNum.Numerics.Conversion

open WasmNum

/-- Generic signed truncation: float N → integer M (signed).
    Returns `none` for NaN, Infinity, or if truncated value is outside [-2^(M-1), 2^(M-1)).
    Wasm spec: `iM.trunc_fN_s` -/
def truncToIntS (N M : Nat) [WasmFloat N] (v : BitVec N) : Option (BitVec M) :=
  if WasmFloat.isNaN v || WasmFloat.isInfinite v then none
  else match WasmFloat.truncToInt v with
    | none => none
    | some i =>
      if -(2 ^ (M - 1) : Int) ≤ i && i < 2 ^ (M - 1) then
        some (BitVec.ofInt M i)
      else none

/-- Generic unsigned truncation: float N → integer M (unsigned).
    Returns `none` for NaN, Infinity, negative, or if truncated value >= 2^M.
    Wasm spec: `iM.trunc_fN_u` -/
def truncToIntU (N M : Nat) [WasmFloat N] (v : BitVec N) : Option (BitVec M) :=
  if WasmFloat.isNaN v || WasmFloat.isInfinite v then none
  else match WasmFloat.truncToNat v with
    | none => none
    | some n =>
      if n < 2 ^ M then
        some (BitVec.ofNat M n)
      else none

-- Concrete instances for all 8 Wasm trunc instructions

def truncF32ToI32S [WasmFloat 32] (v : F32) : Option I32 := truncToIntS 32 32 v
def truncF32ToI32U [WasmFloat 32] (v : F32) : Option I32 := truncToIntU 32 32 v
def truncF64ToI32S [WasmFloat 64] (v : F64) : Option I32 := truncToIntS 64 32 v
def truncF64ToI32U [WasmFloat 64] (v : F64) : Option I32 := truncToIntU 64 32 v
def truncF32ToI64S [WasmFloat 32] (v : F32) : Option I64 := truncToIntS 32 64 v
def truncF32ToI64U [WasmFloat 32] (v : F32) : Option I64 := truncToIntU 32 64 v
def truncF64ToI64S [WasmFloat 64] (v : F64) : Option I64 := truncToIntS 64 64 v
def truncF64ToI64U [WasmFloat 64] (v : F64) : Option I64 := truncToIntU 64 64 v

end WasmNum.Numerics.Conversion
