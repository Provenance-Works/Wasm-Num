/-!
# WasmFloat Typeclass

Abstract interface to IEEE 754 floating-point operations (ADR-001).
This is the sole interface between wasm-num and any IEEE 754 implementation.
External 754 bridge provides instances for `WasmFloat 32` and `WasmFloat 64`.

BitVec N is the universal representation type (ADR-002):
no `toBitVec`/`fromBitVec` conversions needed.

Wasm spec: Section 4.3.1 "Representations", Section 4.3.3 "Floating-Point Operations"
-/

namespace WasmNum

/-- Abstract IEEE 754 floating-point operations on `BitVec N`.
    The sole interface between wasm-num and any IEEE 754 implementation.
    Instances for `WasmFloat 32` and `WasmFloat 64` are provided by an external
    754 bridge package. -/
class WasmFloat (N : Nat) where
  -- Classification predicates
  /-- True if the bit pattern represents NaN -/
  isNaN : BitVec N → Bool
  /-- True if the bit pattern represents +Infinity or -Infinity -/
  isInfinite : BitVec N → Bool
  /-- True if the bit pattern represents +0 or -0 -/
  isZero : BitVec N → Bool
  /-- True if the sign bit is 1 (negative) -/
  isNegative : BitVec N → Bool
  /-- True if the bit pattern represents a subnormal number -/
  isSubnormal : BitVec N → Bool
  /-- True if the bit pattern is a canonical NaN (either sign) -/
  isCanonicalNaN : BitVec N → Bool
  /-- True if the bit pattern is an arithmetic NaN (quiet NaN) -/
  isArithmeticNaN : BitVec N → Bool

  /-- The positive canonical NaN bit pattern -/
  canonicalNaN : BitVec N

  -- Arithmetic operations (round-to-nearest, ties-to-even)
  /-- IEEE 754 addition -/
  add : BitVec N → BitVec N → BitVec N
  /-- IEEE 754 subtraction -/
  sub : BitVec N → BitVec N → BitVec N
  /-- IEEE 754 multiplication -/
  mul : BitVec N → BitVec N → BitVec N
  /-- IEEE 754 division -/
  div : BitVec N → BitVec N → BitVec N
  /-- IEEE 754 square root -/
  sqrt : BitVec N → BitVec N
  /-- IEEE 754 fused multiply-add -/
  fma : BitVec N → BitVec N → BitVec N → BitVec N

  -- IEEE 754 round-to-integral primitives used by Wasm rounding wrappers
  /-- Round to nearest integer (ties-to-even) -/
  nearestInt : BitVec N → BitVec N
  /-- Round toward +Infinity -/
  ceilInt : BitVec N → BitVec N
  /-- Round toward -Infinity -/
  floorInt : BitVec N → BitVec N
  /-- Round toward zero -/
  truncInt : BitVec N → BitVec N

  -- Ordered IEEE 754 comparison primitives
  /-- Ordered less-than (NaN compares unordered) -/
  lt : BitVec N → BitVec N → Bool
  /-- Ordered less-or-equal (NaN compares unordered) -/
  le : BitVec N → BitVec N → Bool
  /-- Ordered equality (+0 == -0 is true; NaN != NaN) -/
  eq : BitVec N → BitVec N → Bool

  /-- NaN payload overlap relation used by nans_N{z}.
      True when the payload of the first value overlaps the payload of the second. -/
  payloadOverlap : BitVec N → BitVec N → Prop

  -- Conversion to integers
  /-- Truncate float to signed integer. None for NaN/Inf/overflow. -/
  truncToInt : BitVec N → Option Int
  /-- Truncate float to unsigned natural. None for NaN/Inf/overflow/negative. -/
  truncToNat : BitVec N → Option Nat

  -- Conversion from integers
  /-- Convert signed integer to float (round ties-to-even) -/
  convertFromInt : Int → BitVec N
  /-- Convert unsigned natural to float (round ties-to-even) -/
  convertFromNat : Nat → BitVec N

  /-- Extract sign bit (MSB) -/
  sign_bit : BitVec N → Bool

  -- Structural properties (proof obligations for instances)
  /-- The canonical NaN pattern is a NaN -/
  isNaN_canonicalNaN : isNaN canonicalNaN = true
  /-- Every canonical NaN is a NaN -/
  isCanonicalNaN_isNaN : ∀ v, isCanonicalNaN v = true → isNaN v = true
  /-- Every arithmetic NaN is a NaN -/
  isArithmeticNaN_isNaN : ∀ v, isArithmeticNaN v = true → isNaN v = true

/-- Promotion: f32 to f64 (exact, no rounding).
    Wasm spec: `f64.promote_f32` -/
class WasmFloatPromote where
  /-- Promote a 32-bit float to 64-bit (exact for non-NaN values) -/
  promote : BitVec 32 → BitVec 64

/-- Demotion: f64 to f32 (may round).
    Wasm spec: `f32.demote_f64` -/
class WasmFloatDemote where
  /-- Demote a 64-bit float to 32-bit (with rounding) -/
  demote : BitVec 64 → BitVec 32

end WasmNum
