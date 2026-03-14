import WasmNum.Numerics.Conversion.TruncSat

/-!
# Saturating Conversion Proofs

Proofs for saturating float-to-integer conversions.

- NaN maps to 0
- Non-NaN with truncToInt/truncToNat = none saturates based on sign
- In-range values are passed through
- Out-of-range values are clamped

Wasm spec: Section 4.4 "Conversions"
-/

namespace WasmNum.Proofs.Numerics.Conversion

open WasmNum
open WasmNum.Numerics.Conversion

variable {N M : Nat}

-- ============================================================
-- NaN handling
-- ============================================================

/-- Signed saturating truncation of NaN returns 0 -/
theorem truncSatToIntS_nan [WasmFloat N] (v : BitVec N)
    (hnan : WasmFloat.isNaN v = true) :
    truncSatToIntS N M v = 0#M := by
  simp [truncSatToIntS, hnan]

/-- Unsigned saturating truncation of NaN returns 0 -/
theorem truncSatToIntU_nan [WasmFloat N] (v : BitVec N)
    (hnan : WasmFloat.isNaN v = true) :
    truncSatToIntU N M v = 0#M := by
  simp [truncSatToIntU, hnan]

-- ============================================================
-- Signed saturation: truncToInt = none (Infinity / overflow)
-- ============================================================

/-- Signed saturation when truncToInt fails and value is negative:
    result = signed minimum (-2^(M-1)).
    Covers -Infinity and negative overflow. -/
theorem truncSatToIntS_none_neg [WasmFloat N] (v : BitVec N)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToInt v = none)
    (hneg : WasmFloat.isNegative v = true) :
    truncSatToIntS N M v = BitVec.ofInt M (-(2 ^ (M - 1))) := by
  simp [truncSatToIntS, hnan, htrunc, hneg]

/-- Signed saturation when truncToInt fails and value is non-negative:
    result = signed maximum (2^(M-1) - 1).
    Covers +Infinity and positive overflow. -/
theorem truncSatToIntS_none_pos [WasmFloat N] (v : BitVec N)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToInt v = none)
    (hpos : WasmFloat.isNegative v = false) :
    truncSatToIntS N M v = BitVec.ofInt M (2 ^ (M - 1) - 1) := by
  simp [truncSatToIntS, hnan, htrunc, hpos]

-- ============================================================
-- Signed saturation: truncToInt = some i, out of range
-- ============================================================

/-- Signed saturation when truncated value underflows signed range -/
theorem truncSatToIntS_underflow [WasmFloat N] (v : BitVec N) (i : Int)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToInt v = some i)
    (hlo : i < -(2 ^ (M - 1) : Int)) :
    truncSatToIntS N M v = BitVec.ofInt M (-(2 ^ (M - 1))) := by
  simp [truncSatToIntS, hnan, htrunc, hlo]

/-- Signed saturation when truncated value overflows signed range -/
theorem truncSatToIntS_overflow [WasmFloat N] (v : BitVec N) (i : Int)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToInt v = some i)
    (hlo : ¬(i < -(2 ^ (M - 1) : Int)))
    (hhi : i ≥ 2 ^ (M - 1)) :
    truncSatToIntS N M v = BitVec.ofInt M (2 ^ (M - 1) - 1) := by
  simp [truncSatToIntS, hnan, htrunc, hlo, hhi]

-- ============================================================
-- Signed: in-range passthrough
-- ============================================================

/-- Signed truncation passes through in-range values unchanged -/
theorem truncSatToIntS_inrange [WasmFloat N] (v : BitVec N) (i : Int)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToInt v = some i)
    (hlo : ¬(i < -(2 ^ (M - 1) : Int)))
    (hhi : ¬(i ≥ (2 ^ (M - 1) : Int))) :
    truncSatToIntS N M v = BitVec.ofInt M i := by
  simp [truncSatToIntS, hnan, htrunc, hlo, hhi]

-- ============================================================
-- Unsigned saturation: truncToNat = none (Infinity / negative)
-- ============================================================

/-- Unsigned saturation when truncToNat fails and value is negative:
    result = 0. Covers -Infinity and negative values. -/
theorem truncSatToIntU_none_neg [WasmFloat N] (v : BitVec N)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToNat v = none)
    (hneg : WasmFloat.isNegative v = true) :
    truncSatToIntU N M v = 0#M := by
  simp [truncSatToIntU, hnan, htrunc, hneg]

/-- Unsigned saturation when truncToNat fails and value is non-negative:
    result = unsigned maximum (2^M - 1). Covers +Infinity. -/
theorem truncSatToIntU_none_pos [WasmFloat N] (v : BitVec N)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToNat v = none)
    (hpos : WasmFloat.isNegative v = false) :
    truncSatToIntU N M v = BitVec.ofNat M (2 ^ M - 1) := by
  simp [truncSatToIntU, hnan, htrunc, hpos]

-- ============================================================
-- Unsigned saturation: truncToNat = some n, overflow
-- ============================================================

/-- Unsigned saturation when truncated value overflows unsigned range -/
theorem truncSatToIntU_overflow [WasmFloat N] (v : BitVec N) (n : Nat)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToNat v = some n)
    (hhi : n ≥ 2 ^ M) :
    truncSatToIntU N M v = BitVec.ofNat M (2 ^ M - 1) := by
  simp [truncSatToIntU, hnan, htrunc, hhi]

-- ============================================================
-- Unsigned: in-range passthrough
-- ============================================================

/-- Unsigned truncation passes through in-range values unchanged -/
theorem truncSatToIntU_inrange [WasmFloat N] (v : BitVec N) (n : Nat)
    (hnan : WasmFloat.isNaN v = false)
    (htrunc : WasmFloat.truncToNat v = some n)
    (hhi : ¬(n ≥ 2 ^ M)) :
    truncSatToIntU N M v = BitVec.ofNat M n := by
  simp [truncSatToIntU, hnan, htrunc, hhi]

end WasmNum.Proofs.Numerics.Conversion
