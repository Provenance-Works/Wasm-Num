import WasmNum.Foundation

/-!
# Saturating (Total) Conversions

Float-to-integer conversions that saturate instead of trapping.
NaN maps to 0, infinity and out-of-range values saturate to the
min/max representable integer.

Wasm spec: Section 4.4 "Conversions"
- FR-202: trunc_sat_u / trunc_sat_s (Total)
-/

namespace WasmNum.Numerics.Conversion

open WasmNum

/-- Generic signed saturating truncation: float N → integer M (signed).
    NaN → 0, -Inf → min, +Inf → max, out-of-range → saturate.
    Wasm spec: `iM.trunc_sat_fN_s` -/
def truncSatToIntS (N M : Nat) [WasmFloat N] (v : BitVec N) : BitVec M :=
  if WasmFloat.isNaN v then 0#M
  else match WasmFloat.truncToInt v with
    | none =>
      -- Infinity or overflow: saturate based on sign
      if WasmFloat.isNegative v then
        BitVec.ofInt M (-(2 ^ (M - 1)))
      else
        BitVec.ofInt M (2 ^ (M - 1) - 1)
    | some i =>
      if i < -(2 ^ (M - 1) : Int) then
        BitVec.ofInt M (-(2 ^ (M - 1)))
      else if i ≥ 2 ^ (M - 1) then
        BitVec.ofInt M (2 ^ (M - 1) - 1)
      else
        BitVec.ofInt M i

/-- Generic unsigned saturating truncation: float N → integer M (unsigned).
    NaN → 0, -Inf → 0, +Inf → max, negative → 0, overflow → max.
    Wasm spec: `iM.trunc_sat_fN_u` -/
def truncSatToIntU (N M : Nat) [WasmFloat N] (v : BitVec N) : BitVec M :=
  if WasmFloat.isNaN v then 0#M
  else match WasmFloat.truncToNat v with
    | none =>
      if WasmFloat.isNegative v then 0#M
      else BitVec.ofNat M (2 ^ M - 1)
    | some n =>
      if n ≥ 2 ^ M then BitVec.ofNat M (2 ^ M - 1)
      else BitVec.ofNat M n

-- Concrete instances for all 8 Wasm trunc_sat instructions

def truncSatF32ToI32S [WasmFloat 32] (v : F32) : I32 := truncSatToIntS 32 32 v
def truncSatF32ToI32U [WasmFloat 32] (v : F32) : I32 := truncSatToIntU 32 32 v
def truncSatF64ToI32S [WasmFloat 64] (v : F64) : I32 := truncSatToIntS 64 32 v
def truncSatF64ToI32U [WasmFloat 64] (v : F64) : I32 := truncSatToIntU 64 32 v
def truncSatF32ToI64S [WasmFloat 32] (v : F32) : I64 := truncSatToIntS 32 64 v
def truncSatF32ToI64U [WasmFloat 32] (v : F32) : I64 := truncSatToIntU 32 64 v
def truncSatF64ToI64S [WasmFloat 64] (v : F64) : I64 := truncSatToIntS 64 64 v
def truncSatF64ToI64U [WasmFloat 64] (v : F64) : I64 := truncSatToIntU 64 64 v

end WasmNum.Numerics.Conversion
