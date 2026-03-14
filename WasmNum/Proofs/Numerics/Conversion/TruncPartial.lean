import WasmNum.Numerics.Conversion.TruncPartial
import WasmNum.Numerics.Conversion.Reinterpret

/-!
# Trapping Conversion Proofs

Proofs for partial (trapping) float-to-integer conversions.

- NaN always traps (returns `none`)
- Infinity always traps
- Reinterpret roundtrips are identity

Wasm spec: Section 4.4 "Conversions"
-/

namespace WasmNum.Proofs.Numerics.Conversion

open WasmNum
open WasmNum.Numerics.Conversion

variable {N M : Nat}

/-- NaN always causes partial truncation (signed) to return none -/
theorem truncToIntS_nan [WasmFloat N] (v : BitVec N)
    (hnan : WasmFloat.isNaN v = true) :
    truncToIntS N M v = none := by
  simp [truncToIntS, hnan]

/-- NaN always causes partial truncation (unsigned) to return none -/
theorem truncToIntU_nan [WasmFloat N] (v : BitVec N)
    (hnan : WasmFloat.isNaN v = true) :
    truncToIntU N M v = none := by
  simp [truncToIntU, hnan]

/-- Infinity always causes partial truncation (signed) to return none -/
theorem truncToIntS_inf [WasmFloat N] (v : BitVec N)
    (hinf : WasmFloat.isInfinite v = true) :
    truncToIntS N M v = none := by
  simp [truncToIntS, hinf]

/-- Infinity always causes partial truncation (unsigned) to return none -/
theorem truncToIntU_inf [WasmFloat N] (v : BitVec N)
    (hinf : WasmFloat.isInfinite v = true) :
    truncToIntU N M v = none := by
  simp [truncToIntU, hinf]

/-- Reinterpret f32 as i32 then back is identity -/
@[simp]
theorem reinterpretI32AsF32_reinterpretF32AsI32 (v : F32) :
    reinterpretI32AsF32 (reinterpretF32AsI32 v) = v := rfl

/-- Reinterpret i32 as f32 then back is identity -/
@[simp]
theorem reinterpretF32AsI32_reinterpretI32AsF32 (v : I32) :
    reinterpretF32AsI32 (reinterpretI32AsF32 v) = v := rfl

/-- Reinterpret f64 as i64 then back is identity -/
@[simp]
theorem reinterpretI64AsF64_reinterpretF64AsI64 (v : F64) :
    reinterpretI64AsF64 (reinterpretF64AsI64 v) = v := rfl

/-- Reinterpret i64 as f64 then back is identity -/
@[simp]
theorem reinterpretF64AsI64_reinterpretI64AsF64 (v : I64) :
    reinterpretF64AsI64 (reinterpretI64AsF64 v) = v := rfl

end WasmNum.Proofs.Numerics.Conversion
