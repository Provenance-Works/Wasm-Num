import WasmTest.Helpers
import WasmNum.Foundation.WasmFloat.Default

/-!
# Float Operation Tests

Tests for deterministic bitwise float operations (Sign.lean, Compare.lean, PseudoMinMax.lean).
Non-deterministic Set-returning operations (MinMax, Rounding, fadd, etc.) cannot
be tested via #eval; structural coverage is via proofs.

Uses the default WasmFloat stub instances for comparison tests.
-/

open WasmNum
open WasmNum.Numerics.Float
open WasmNum.WasmFloat.Default
open WasmTest

-- IEEE 754 binary32 special values
private def f32_pos_zero  : F32 := 0x00000000#32
private def f32_neg_zero  : F32 := 0x80000000#32
private def f32_pos_one   : F32 := 0x3F800000#32  -- 1.0
private def f32_neg_one   : F32 := 0xBF800000#32  -- -1.0
private def f32_pos_inf   : F32 := 0x7F800000#32
private def f32_neg_inf   : F32 := 0xFF800000#32
private def f32_canon_nan : F32 := 0x7FC00000#32
private def f32_neg_canon : F32 := 0xFFC00000#32
private def f32_snan      : F32 := 0x7F800001#32  -- signaling NaN

-- IEEE 754 binary64 special values
private def f64_pos_zero  : F64 := 0x0000000000000000#64
private def f64_neg_zero  : F64 := 0x8000000000000000#64
private def f64_canon_nan : F64 := 0x7FF8000000000000#64
private def f64_pos_inf   : F64 := 0x7FF0000000000000#64

#eval do
  let mut r := TestResult.empty

  -- ================================================================
  -- Classification (WasmFloat default instance)
  -- ================================================================

  r := r ++ assertTrue "f32 +0 isZero" (WasmFloat.isZero f32_pos_zero)
  r := r ++ assertTrue "f32 -0 isZero" (WasmFloat.isZero f32_neg_zero)
  r := r ++ assertTrue "f32 canonNaN isNaN" (WasmFloat.isNaN f32_canon_nan)
  r := r ++ assertTrue "f32 sNaN isNaN" (WasmFloat.isNaN f32_snan)
  r := r ++ assertTrue "f32 +inf isInfinite" (WasmFloat.isInfinite f32_pos_inf)
  r := r ++ assertTrue "f32 -inf isInfinite" (WasmFloat.isInfinite f32_neg_inf)
  r := r ++ assertFalse "f32 1.0 not NaN" (WasmFloat.isNaN f32_pos_one)
  r := r ++ assertFalse "f32 1.0 not inf" (WasmFloat.isInfinite f32_pos_one)
  r := r ++ assertFalse "f32 1.0 not zero" (WasmFloat.isZero f32_pos_one)
  r := r ++ assertTrue "f32 -1.0 isNegative" (WasmFloat.isNegative f32_neg_one)
  r := r ++ assertFalse "f32 +1.0 not negative" (WasmFloat.isNegative f32_pos_one)
  r := r ++ assertTrue "f32 canonNaN isCanonicalNaN" (WasmFloat.isCanonicalNaN f32_canon_nan)
  r := r ++ assertTrue "f32 neg canonNaN isCanonicalNaN" (WasmFloat.isCanonicalNaN f32_neg_canon)
  r := r ++ assertFalse "f32 sNaN not canonical" (WasmFloat.isCanonicalNaN f32_snan)
  r := r ++ assertTrue "f32 canonNaN isArithmeticNaN" (WasmFloat.isArithmeticNaN f32_canon_nan)

  -- f64 classification
  r := r ++ assertTrue "f64 +0 isZero" (WasmFloat.isZero f64_pos_zero)
  r := r ++ assertTrue "f64 -0 isZero" (WasmFloat.isZero f64_neg_zero)
  r := r ++ assertTrue "f64 canonNaN isNaN" (WasmFloat.isNaN f64_canon_nan)
  r := r ++ assertTrue "f64 +inf isInfinite" (WasmFloat.isInfinite f64_pos_inf)

  -- ================================================================
  -- Sign Operations (bitwise, fully deterministic)
  -- ================================================================

  -- fabs: clear sign bit
  r := r ++ assertEqual "fabs +1.0" (fabs f32_pos_one) f32_pos_one
  r := r ++ assertEqual "fabs -1.0 = +1.0" (fabs f32_neg_one) f32_pos_one
  r := r ++ assertEqual "fabs -0 = +0" (fabs f32_neg_zero) f32_pos_zero
  r := r ++ assertEqual "fabs +inf" (fabs f32_pos_inf) f32_pos_inf
  r := r ++ assertEqual "fabs -inf" (fabs f32_neg_inf) f32_pos_inf
  r := r ++ assertEqual "fabs canonNaN" (fabs f32_canon_nan) f32_canon_nan
  r := r ++ assertEqual "fabs neg canonNaN" (fabs f32_neg_canon) f32_canon_nan

  -- fneg: toggle sign bit
  r := r ++ assertEqual "fneg +1.0 = -1.0" (fneg f32_pos_one) f32_neg_one
  r := r ++ assertEqual "fneg -1.0 = +1.0" (fneg f32_neg_one) f32_pos_one
  r := r ++ assertEqual "fneg +0 = -0" (fneg f32_pos_zero) f32_neg_zero
  r := r ++ assertEqual "fneg -0 = +0" (fneg f32_neg_zero) f32_pos_zero
  r := r ++ assertEqual "fneg canonNaN" (fneg f32_canon_nan) f32_neg_canon

  -- fcopysign: magnitude of a, sign of b
  r := r ++ assertEqual "fcopysign +1,-1 = -1" (fcopysign f32_pos_one f32_neg_one) f32_neg_one
  r := r ++ assertEqual "fcopysign -1,+1 = +1" (fcopysign f32_neg_one f32_pos_one) f32_pos_one
  r := r ++ assertEqual "fcopysign +1,+1 = +1" (fcopysign f32_pos_one f32_pos_one) f32_pos_one
  r := r ++ assertEqual "fcopysign -1,-1 = -1" (fcopysign f32_neg_one f32_neg_one) f32_neg_one
  -- copy sign from negative zero
  r := r ++ assertEqual "fcopysign +1,-0 = -1" (fcopysign f32_pos_one f32_neg_zero) f32_neg_one

  -- 64-bit sign operations
  r := r ++ assertEqual "fabs64 -0" (fabs f64_neg_zero) f64_pos_zero
  r := r ++ assertEqual "fneg64 +0 = -0" (fneg f64_pos_zero) f64_neg_zero

  -- ================================================================
  -- Comparisons (using default stub  Eall return false)
  -- ================================================================
  -- Note: default stub lt/le/eq all return false. We test the
  -- comparison wrappers react to NaN correctly. With stubs:
  -- feq NaN _ ↁE0, fne NaN _ ↁE1, flt/fgt/fle/fge NaN _ ↁE0

  r := r ++ assertEqual "feq NaN _  = 0" (feq f32_canon_nan f32_pos_one) (0 : I32)
  r := r ++ assertEqual "feq _ NaN  = 0" (feq f32_pos_one f32_canon_nan) (0 : I32)
  r := r ++ assertEqual "fne NaN _  = 1" (fne f32_canon_nan f32_pos_one) (1 : I32)
  r := r ++ assertEqual "fne _ NaN  = 1" (fne f32_pos_one f32_canon_nan) (1 : I32)
  r := r ++ assertEqual "flt NaN _  = 0" (flt f32_canon_nan f32_pos_one) (0 : I32)
  r := r ++ assertEqual "fgt NaN _  = 0" (fgt f32_canon_nan f32_pos_one) (0 : I32)
  r := r ++ assertEqual "fle NaN _  = 0" (fle f32_canon_nan f32_pos_one) (0 : I32)
  r := r ++ assertEqual "fge NaN _  = 0" (fge f32_canon_nan f32_pos_one) (0 : I32)

  -- non-NaN with stub (eq/lt/le ↁEfalse):
  r := r ++ assertEqual "feq non-NaN stub" (feq f32_pos_one f32_pos_one) (0 : I32)  -- stub eq=false
  r := r ++ assertEqual "fne non-NaN stub" (fne f32_pos_one f32_pos_one) (1 : I32)  -- stub eq=false ↁEne=1

  -- ================================================================
  -- Pseudo Min/Max (deterministic, SIMD ops)
  -- ================================================================
  -- With stub lt ↁEfalse: fpmin(a,b) = a, fpmax(a,b) = a

  r := r ++ assertEqual "fpmin stub: a returned" (fpmin f32_pos_one f32_neg_one) f32_pos_one
  r := r ++ assertEqual "fpmax stub: a returned" (fpmax f32_pos_one f32_neg_one) f32_pos_one

  IO.println (r.summary "Float Operations")
  if r.failed > 0 then throw (IO.Error.userError "Float tests failed")
