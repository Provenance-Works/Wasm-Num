import WasmNum.Foundation.Profile
import WasmNum.Numerics.NaN.Propagation
import WasmNum.SIMD.Relaxed.Madd
import WasmNum.SIMD.Relaxed.MinMax
import WasmNum.SIMD.Relaxed.Swizzle
import WasmNum.SIMD.Relaxed.Trunc
import WasmNum.SIMD.Relaxed.Laneselect
import WasmNum.SIMD.Relaxed.Dot
import WasmNum.SIMD.Relaxed.Q15

/-!
# Integration Profile

`DeterministicWasmProfile` is a proof-carrying specialization of `WasmProfile`.
It extends the combined profile with proofs that every non-deterministic choice
(NaN propagation, relaxed SIMD) is within the Wasm-spec-permitted set.

This lives in the Integration layer because it depends on definitions from
both the Numerics layer (nansN) and the SIMD/Relaxed layer.

Wasm spec: NaN propagation (Section 4.3.3), Relaxed SIMD proposal
-/

namespace WasmNum.Integration

open WasmNum
open WasmNum.Numerics.NaN
open WasmNum.SIMD

/-- Proof-carrying deterministic specialization of `WasmProfile`.
    Carries membership proofs for all non-deterministic choices:
    - NaN propagation: `selectNaN` results are in `nansN`
    - Relaxed SIMD: each impl is within the spec-permitted set

    Requires `WasmFloat` instances for both 32-bit and 64-bit widths. -/
structure DeterministicWasmProfile [WasmFloat 32] [WasmFloat 64]
    extends WasmProfile where
  /-- The selected NaN is always a member of the Wasm-spec allowed result set. -/
  selectNaN_mem : ∀ (N : Nat) [WasmFloat N] (inputs : List (BitVec N)),
    toWasmProfile.nanProfile.selectNaN N inputs ∈ nansN N inputs
  /-- Relaxed madd (f32x4) is within spec-permitted set -/
  relaxedMadd_mem : ∀ (a b c : V128),
    toWasmProfile.relaxedProfile.relaxedMaddImpl a b c ∈
      Relaxed.madd Shape.f32x4 a b c
  /-- Relaxed nmadd (f32x4) is within spec-permitted set -/
  relaxedNmadd_mem : ∀ (a b c : V128),
    toWasmProfile.relaxedProfile.relaxedNmaddImpl a b c ∈
      Relaxed.nmadd Shape.f32x4 a b c
  /-- Relaxed madd (f64x2) is within spec-permitted set -/
  relaxedMaddF64_mem : ∀ (a b c : V128),
    toWasmProfile.relaxedProfile.relaxedMaddF64Impl a b c ∈
      Relaxed.madd Shape.f64x2 a b c
  /-- Relaxed nmadd (f64x2) is within spec-permitted set -/
  relaxedNmaddF64_mem : ∀ (a b c : V128),
    toWasmProfile.relaxedProfile.relaxedNmaddF64Impl a b c ∈
      Relaxed.nmadd Shape.f64x2 a b c
  /-- Relaxed min (f32x4) is within spec-permitted set -/
  relaxedMinF32_mem : ∀ (a b : V128),
    V128.zipLanes Shape.f32x4 toWasmProfile.relaxedProfile.relaxedMinImpl32 a b ∈
      Relaxed.min Shape.f32x4 a b
  /-- Relaxed max (f32x4) is within spec-permitted set -/
  relaxedMaxF32_mem : ∀ (a b : V128),
    V128.zipLanes Shape.f32x4 toWasmProfile.relaxedProfile.relaxedMaxImpl32 a b ∈
      Relaxed.max Shape.f32x4 a b
  /-- Relaxed min (f64x2) is within spec-permitted set -/
  relaxedMinF64_mem : ∀ (a b : V128),
    V128.zipLanes Shape.f64x2 toWasmProfile.relaxedProfile.relaxedMinImpl64 a b ∈
      Relaxed.min Shape.f64x2 a b
  /-- Relaxed max (f64x2) is within spec-permitted set -/
  relaxedMaxF64_mem : ∀ (a b : V128),
    V128.zipLanes Shape.f64x2 toWasmProfile.relaxedProfile.relaxedMaxImpl64 a b ∈
      Relaxed.max Shape.f64x2 a b
  /-- Relaxed swizzle is within spec-permitted set -/
  relaxedSwizzle_mem : ∀ (v idx : V128),
    toWasmProfile.relaxedProfile.relaxedSwizzleImpl v idx ∈
      Relaxed.swizzle v idx
  /-- Relaxed trunc f32x4 signed is within spec-permitted set -/
  relaxedTruncF32x4S_mem : ∀ (v : V128),
    toWasmProfile.relaxedProfile.relaxedTruncF32x4SImpl v ∈
      Relaxed.truncF32x4S v
  /-- Relaxed trunc f32x4 unsigned is within spec-permitted set -/
  relaxedTruncF32x4U_mem : ∀ (v : V128),
    toWasmProfile.relaxedProfile.relaxedTruncF32x4UImpl v ∈
      Relaxed.truncF32x4U v
  /-- Relaxed trunc f64x2 signed zero is within spec-permitted set -/
  relaxedTruncF64x2SZero_mem : ∀ (v : V128),
    toWasmProfile.relaxedProfile.relaxedTruncF64x2SZeroImpl v ∈
      Relaxed.truncF64x2SZero v
  /-- Relaxed trunc f64x2 unsigned zero is within spec-permitted set -/
  relaxedTruncF64x2UZero_mem : ∀ (v : V128),
    toWasmProfile.relaxedProfile.relaxedTruncF64x2UZeroImpl v ∈
      Relaxed.truncF64x2UZero v
  /-- Relaxed laneselect is within spec-permitted set for all shapes -/
  relaxedLaneselect_mem : ∀ (s : Shape) (a b mask : V128),
    toWasmProfile.relaxedProfile.relaxedLaneselectImpl a b mask ∈
      Relaxed.laneselect s a b mask
  /-- Relaxed i8x16 dot product is within spec-permitted set -/
  relaxedDot_mem : ∀ (a b : V128),
    toWasmProfile.relaxedProfile.relaxedDotI8x16I7x16SImpl a b ∈
      Relaxed.dot_i8x16_i7x16_s a b
  /-- Relaxed i8x16 dot product with accumulate is within spec-permitted set -/
  relaxedDotAdd_mem : ∀ (a b c : V128),
    toWasmProfile.relaxedProfile.relaxedDotI8x16I7x16AddSImpl a b c ∈
      Relaxed.dot_i8x16_i7x16_add_s a b c
  /-- Relaxed Q15 multiply is within spec-permitted set -/
  relaxedQ15MulrS_mem : ∀ (a b : V128),
    toWasmProfile.relaxedProfile.relaxedQ15MulrSImpl a b ∈
      Relaxed.q15mulrS a b

end WasmNum.Integration
