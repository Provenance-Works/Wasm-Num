import WasmTest.Helpers
import WasmNum.Foundation.WasmFloat.Default

/-!
# Conversion Tests

Tests for all type conversion operations (Phase 6):
- Reinterpret (identity, deterministic)
- Integer width: wrap, extend_s, extend_u, extend_from_8/16/32
- TruncSat: saturating float→int (with default stub)
- TruncPartial: trapping float→int (with default stub)
- ConvertIntFloat: int→float (with default stub)
-/

open WasmNum
open WasmNum.Numerics.Conversion
open WasmNum.WasmFloat.Default
open WasmTest

#eval do
  let mut r := TestResult.empty

  -- ================================================================
  -- Reinterpret (identity functions)
  -- ================================================================

  r := r ++ assertEqual "reinterpretF32AsI32" (reinterpretF32AsI32 (0xDEADBEEF : F32)) (0xDEADBEEF : I32)
  r := r ++ assertEqual "reinterpretI32AsF32" (reinterpretI32AsF32 (0xCAFEBABE : I32)) (0xCAFEBABE : F32)
  r := r ++ assertEqual "reinterpretF64AsI64" (reinterpretF64AsI64 (0xDEADBEEFCAFEBABE : F64)) (0xDEADBEEFCAFEBABE : I64)
  r := r ++ assertEqual "reinterpretI64AsF64" (reinterpretI64AsF64 (0x1234567890ABCDEF : I64)) (0x1234567890ABCDEF : F64)

  -- roundtrip: i32 ↁEf32 ↁEi32
  let x32 : I32 := 0x42424242
  r := r ++ assertEqual "reinterpret i32 roundtrip" (reinterpretF32AsI32 (reinterpretI32AsF32 x32)) x32
  -- roundtrip: i64 ↁEf64 ↁEi64
  let x64 : I64 := 0x4242424242424242
  r := r ++ assertEqual "reinterpret i64 roundtrip" (reinterpretF64AsI64 (reinterpretI64AsF64 x64)) x64

  -- ================================================================
  -- Integer Width Conversions
  -- ================================================================

  -- wrapI64: truncate to low 32 bits
  r := r ++ assertEqual "wrapI64: simple" (wrapI64 (42 : I64)) (42 : I32)
  r := r ++ assertEqual "wrapI64: high bits dropped" (wrapI64 (0x1_00000042 : I64)) (0x42 : I32)
  r := r ++ assertEqual "wrapI64: all 1s" (wrapI64 (0xFFFFFFFFFFFFFFFF : I64)) (0xFFFFFFFF : I32)

  -- extendI32U: zero-extend i32 to i64
  r := r ++ assertEqual "extendI32U: basic" (extendI32U (42 : I32)) (42 : I64)
  r := r ++ assertEqual "extendI32U: high bit" (extendI32U (0x80000000 : I32)) (0x80000000 : I64)
  r := r ++ assertEqual "extendI32U: max" (extendI32U (0xFFFFFFFF : I32)) (0xFFFFFFFF : I64)

  -- extendI32S: sign-extend i32 to i64
  r := r ++ assertEqual "extendI32S: positive" (extendI32S (42 : I32)) (42 : I64)
  r := r ++ assertEqual "extendI32S: negative" (extendI32S (0xFFFFFFFF : I32)) (0xFFFFFFFFFFFFFFFF : I64) -- -1
  r := r ++ assertEqual "extendI32S: MSB set" (extendI32S (0x80000000 : I32)) (0xFFFFFFFF80000000 : I64)

  -- extend_from_8s: sign-extend low 8 bits
  r := r ++ assertEqual "extendI32From8S: 0x80" (extendI32From8S (0x80 : I32)) (0xFFFFFF80 : I32)
  r := r ++ assertEqual "extendI32From8S: 0x7F" (extendI32From8S (0x7F : I32)) (0x7F : I32)
  r := r ++ assertEqual "extendI32From8S: only low 8 bits" (extendI32From8S (0xFF80 : I32)) (0xFFFFFF80 : I32)

  -- extend_from_16s
  r := r ++ assertEqual "extendI32From16S: 0x8000" (extendI32From16S (0x8000 : I32)) (0xFFFF8000 : I32)
  r := r ++ assertEqual "extendI32From16S: 0x7FFF" (extendI32From16S (0x7FFF : I32)) (0x7FFF : I32)

  -- extend_from_8s (64-bit)
  r := r ++ assertEqual "extendI64From8S: 0x80" (extendI64From8S (0x80 : I64)) (0xFFFFFFFFFFFFFF80 : I64)
  r := r ++ assertEqual "extendI64From8S: 0x7F" (extendI64From8S (0x7F : I64)) (0x7F : I64)

  -- extend_from_16s (64-bit)
  r := r ++ assertEqual "extendI64From16S: 0x8000" (extendI64From16S (0x8000 : I64)) (0xFFFFFFFFFFFF8000 : I64)

  -- extend_from_32s (64-bit)
  r := r ++ assertEqual "extendI64From32S: 0x80000000" (extendI64From32S (0x80000000 : I64)) (0xFFFFFFFF80000000 : I64)
  r := r ++ assertEqual "extendI64From32S: 0x7FFFFFFF" (extendI64From32S (0x7FFFFFFF : I64)) (0x7FFFFFFF : I64)

  -- ================================================================
  -- TruncSat (with default WasmFloat stub)
  -- ================================================================
  -- Default stub: truncToInt/truncToNat return none for all inputs.
  -- NaN inputs ↁE0, non-NaN non-convertible ↁEsaturate based on sign.

  -- Canonical NaN ↁE0
  r := r ++ assertEqual "truncSatF32ToI32S NaN ↁE0" (truncSatF32ToI32S (0x7FC00000 : F32)) (0 : I32)
  r := r ++ assertEqual "truncSatF32ToI32U NaN ↁE0" (truncSatF32ToI32U (0x7FC00000 : F32)) (0 : I32)
  r := r ++ assertEqual "truncSatF64ToI32S NaN ↁE0" (truncSatF64ToI32S (0x7FF8000000000000 : F64)) (0 : I32)
  r := r ++ assertEqual "truncSatF64ToI64S NaN ↁE0" (truncSatF64ToI64S (0x7FF8000000000000 : F64)) (0 : I64)

  -- +0 (not NaN, not inf; stub ↁEtruncToInt=none, not negative) ↁEmax
  r := r ++ assertEqual "truncSatF32ToI32S +0 stub" (truncSatF32ToI32S (0x00000000 : F32)) (0x7FFFFFFF : I32) -- max i32_s
  -- -0 (isNegative=true, stub ↁEnone) ↁEmin
  r := r ++ assertEqual "truncSatF32ToI32S -0 stub" (truncSatF32ToI32S (0x80000000 : F32)) (0x80000000 : I32) -- min i32_s

  -- ================================================================
  -- TruncPartial (with default WasmFloat stub)
  -- ================================================================
  -- All trapping trunc operations return none with default stub

  r := r ++ assertNone "truncF32ToI32S NaN ↁEnone" (truncF32ToI32S (0x7FC00000 : F32))
  r := r ++ assertNone "truncF32ToI32U NaN ↁEnone" (truncF32ToI32U (0x7FC00000 : F32))
  r := r ++ assertNone "truncF64ToI32S NaN ↁEnone" (truncF64ToI32S (0x7FF8000000000000 : F64))
  -- +inf ↁEnone
  r := r ++ assertNone "truncF32ToI32S +inf ↁEnone" (truncF32ToI32S (0x7F800000 : F32))
  -- Non-NaN, non-inf, but stub returns none ↁEnone
  r := r ++ assertNone "truncF32ToI32S +0 stub ↁEnone" (truncF32ToI32S (0x00000000 : F32))

  r := r ++ assertNone "truncF64ToI64S NaN ↁEnone" (truncF64ToI64S (0x7FF8000000000000 : F64))
  r := r ++ assertNone "truncF64ToI64U NaN ↁEnone" (truncF64ToI64U (0x7FF8000000000000 : F64))

  -- ================================================================
  -- ConvertIntFloat (with default stub)
  -- ================================================================
  -- Stub: convertFromInt/convertFromNat always return 0#N

  r := r ++ assertEqual "convertI32SToF32 stub" (convertI32SToF32 (42 : I32)) (0 : F32)
  r := r ++ assertEqual "convertI32UToF32 stub" (convertI32UToF32 (42 : I32)) (0 : F32)
  r := r ++ assertEqual "convertI32SToF64 stub" (convertI32SToF64 (42 : I32)) (0 : F64)
  r := r ++ assertEqual "convertI64SToF64 stub" (convertI64SToF64 (1000 : I64)) (0 : F64)

  IO.println (r.summary "Conversion Operations")
  if r.failed > 0 then throw (IO.Error.userError "Conversion tests failed")
