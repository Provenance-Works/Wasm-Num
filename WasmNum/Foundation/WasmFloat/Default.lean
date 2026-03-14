import WasmNum.Foundation.WasmFloat

/-!
# Default WasmFloat Instance (Testing Stub)

Provides stub `WasmFloat 32` and `WasmFloat 64` instances for testing
wasm-num without a real IEEE 754 implementation.

**Not suitable for production use.** Classification predicates use IEEE 754
bit-pattern checks, but arithmetic, rounding, comparisons, and conversions are
all placeholder implementations.

This module satisfies the typeclass structural properties required by WasmFloat
but does NOT implement correct IEEE 754 arithmetic.
-/

namespace WasmNum.WasmFloat.Default

/-! ## Binary32 (f32) Stub

IEEE 754 binary32 layout:
- Bit 31: sign
- Bits 30-23: exponent (8 bits, bias 127)
- Bits 22-0: significand (23 bits)

Canonical NaN: 0x7FC00000 (positive quiet NaN, canonical payload = 2^22)
-/

instance instWasmFloat32 : WasmFloat 32 where
  isNaN v :=
    v.extractLsb' 23 8 == 0xFF#8 && v.extractLsb' 0 23 != 0#23
  isInfinite v :=
    v.extractLsb' 23 8 == 0xFF#8 && v.extractLsb' 0 23 == 0#23
  isZero v :=
    v == 0x00000000#32 || v == 0x80000000#32
  isNegative v := v.getLsbD 31
  isSubnormal v :=
    v.extractLsb' 23 8 == 0x00#8 && v.extractLsb' 0 23 != 0#23
  isCanonicalNaN v :=
    v == 0x7FC00000#32 || v == 0xFFC00000#32
  isArithmeticNaN v :=
    v.extractLsb' 23 8 == 0xFF#8 && v.extractLsb' 0 23 != 0#23 && v.getLsbD 22
  canonicalNaN := 0x7FC00000#32
  -- Stub arithmetic: all operations return canonical NaN
  add _ _ := 0x7FC00000#32
  sub _ _ := 0x7FC00000#32
  mul _ _ := 0x7FC00000#32
  div _ _ := 0x7FC00000#32
  sqrt _ := 0x7FC00000#32
  fma _ _ _ := 0x7FC00000#32
  nearestInt _ := 0x7FC00000#32
  ceilInt _ := 0x7FC00000#32
  floorInt _ := 0x7FC00000#32
  truncInt _ := 0x7FC00000#32
  lt _ _ := false
  le _ _ := false
  eq _ _ := false
  payloadOverlap a b := a.extractLsb' 0 23 = b.extractLsb' 0 23
  truncToInt _ := none
  truncToNat _ := none
  convertFromInt _ := 0#32
  convertFromNat _ := 0#32
  sign_bit v := v.getLsbD 31
  isNaN_canonicalNaN := by native_decide
  isCanonicalNaN_isNaN := by
    intro v hv
    simp only [Bool.or_eq_true, beq_iff_eq] at hv
    cases hv with
    | inl h => subst h; native_decide
    | inr h => subst h; native_decide
  isArithmeticNaN_isNaN := by
    intro v hv
    simp only [Bool.and_eq_true] at hv ⊢
    exact ⟨hv.1.1, hv.1.2⟩

/-! ## Binary64 (f64) Stub

IEEE 754 binary64 layout:
- Bit 63: sign
- Bits 62-52: exponent (11 bits, bias 1023)
- Bits 51-0: significand (52 bits)

Canonical NaN: 0x7FF8000000000000 (positive quiet NaN, canonical payload = 2^51)
-/

instance instWasmFloat64 : WasmFloat 64 where
  isNaN v :=
    v.extractLsb' 52 11 == 0x7FF#11 && v.extractLsb' 0 52 != 0#52
  isInfinite v :=
    v.extractLsb' 52 11 == 0x7FF#11 && v.extractLsb' 0 52 == 0#52
  isZero v :=
    v == 0x0000000000000000#64 || v == 0x8000000000000000#64
  isNegative v := v.getLsbD 63
  isSubnormal v :=
    v.extractLsb' 52 11 == 0x000#11 && v.extractLsb' 0 52 != 0#52
  isCanonicalNaN v :=
    v == 0x7FF8000000000000#64 || v == 0xFFF8000000000000#64
  isArithmeticNaN v :=
    v.extractLsb' 52 11 == 0x7FF#11 && v.extractLsb' 0 52 != 0#52 && v.getLsbD 51
  canonicalNaN := 0x7FF8000000000000#64
  -- Stub arithmetic: all operations return canonical NaN
  add _ _ := 0x7FF8000000000000#64
  sub _ _ := 0x7FF8000000000000#64
  mul _ _ := 0x7FF8000000000000#64
  div _ _ := 0x7FF8000000000000#64
  sqrt _ := 0x7FF8000000000000#64
  fma _ _ _ := 0x7FF8000000000000#64
  nearestInt _ := 0x7FF8000000000000#64
  ceilInt _ := 0x7FF8000000000000#64
  floorInt _ := 0x7FF8000000000000#64
  truncInt _ := 0x7FF8000000000000#64
  lt _ _ := false
  le _ _ := false
  eq _ _ := false
  payloadOverlap a b := a.extractLsb' 0 52 = b.extractLsb' 0 52
  truncToInt _ := none
  truncToNat _ := none
  convertFromInt _ := 0#64
  convertFromNat _ := 0#64
  sign_bit v := v.getLsbD 63
  isNaN_canonicalNaN := by native_decide
  isCanonicalNaN_isNaN := by
    intro v hv
    simp only [Bool.or_eq_true, beq_iff_eq] at hv
    cases hv with
    | inl h => subst h; native_decide
    | inr h => subst h; native_decide
  isArithmeticNaN_isNaN := by
    intro v hv
    simp only [Bool.and_eq_true] at hv ⊢
    exact ⟨hv.1.1, hv.1.2⟩

end WasmNum.WasmFloat.Default
