import WasmNum.Foundation.WasmFloat
import WasmNum.Foundation.Types

/-!
# Profiles

Configuration for numerics non-deterministic choices (ADR-003).

- `NaNProfile` selects NaN propagation behavior
- `RelaxedProfile` selects relaxed SIMD implementation choices
- `WasmProfile` combines all profiles

Wasm spec: Section 4.3.3 "Floating-Point Operations" (NaN propagation)
Wasm spec: Relaxed SIMD proposal (implementation-defined choices)
-/

namespace WasmNum

/-- NaN handling profile: selects a specific NaN from the allowed set.
    Deterministic wrappers call `selectNaN` to pick one concrete NaN result
    from the non-deterministic `nansN` set.

    `selectNaN N inputs` receives the bit width N and the list of NaN operands
    from the current instruction, and returns a specific NaN value.

    Wasm spec: nans_N{z*} non-determinism -/
structure NaNProfile where
  /-- Given bit width and the NaN inputs of an operation, select one allowed result NaN -/
  selectNaN : (N : Nat) → [WasmFloat N] → List (BitVec N) → BitVec N
  /-- Proof: the selected result is always a NaN.
      The stronger obligation that it belongs to the Wasm-spec result set is
      carried by `Numerics.NaN.Deterministic.DeterministicWasmProfile`, which
      depends on the `nansN` definition from the Numerics layer. -/
  selectNaN_isNaN : ∀ (N : Nat) [WasmFloat N] (inputs : List (BitVec N)),
    WasmFloat.isNaN (selectNaN N inputs) = true

/-- Relaxed SIMD profile: selects concrete implementations for each
    relaxed SIMD operation. These are implementation-defined choices
    that must be fixed for a given execution run.

    Each field takes V128 arguments and produces a deterministic V128 result.
    The Integration layer carries proofs that these choices are within the
    spec-permitted non-deterministic sets.

    Wasm spec: Relaxed SIMD proposal -/
structure RelaxedProfile where
  /-- Relaxed fused multiply-add implementation (f32x4) -/
  relaxedMaddImpl : V128 → V128 → V128 → V128
  /-- Relaxed negated fused multiply-add implementation (f32x4) -/
  relaxedNmaddImpl : V128 → V128 → V128 → V128
  /-- Relaxed fused multiply-add implementation (f64x2) -/
  relaxedMaddF64Impl : V128 → V128 → V128 → V128
  /-- Relaxed negated fused multiply-add implementation (f64x2) -/
  relaxedNmaddF64Impl : V128 → V128 → V128 → V128
  /-- Relaxed min for f32 lanes -/
  relaxedMinImpl32 : BitVec 32 → BitVec 32 → BitVec 32
  /-- Relaxed max for f32 lanes -/
  relaxedMaxImpl32 : BitVec 32 → BitVec 32 → BitVec 32
  /-- Relaxed min for f64 lanes -/
  relaxedMinImpl64 : BitVec 64 → BitVec 64 → BitVec 64
  /-- Relaxed max for f64 lanes -/
  relaxedMaxImpl64 : BitVec 64 → BitVec 64 → BitVec 64
  /-- Relaxed swizzle implementation -/
  relaxedSwizzleImpl : V128 → V128 → V128
  /-- Relaxed trunc f32x4 signed implementation -/
  relaxedTruncF32x4SImpl : V128 → V128
  /-- Relaxed trunc f32x4 unsigned implementation -/
  relaxedTruncF32x4UImpl : V128 → V128
  /-- Relaxed trunc f64x2 signed with zero implementation -/
  relaxedTruncF64x2SZeroImpl : V128 → V128
  /-- Relaxed trunc f64x2 unsigned with zero implementation -/
  relaxedTruncF64x2UZeroImpl : V128 → V128
  /-- Relaxed laneselect implementation.
      This is Shape-independent by design: the Wasm spec allows either MSB-based
      or bitwise-based (v128.bitselect) lane selection. Since `v128.bitselect`
      is Shape-independent and satisfies the spec for all shapes, implementations
      should use bitselect here. The `DeterministicWasmProfile` requires this
      implementation to be a member of `Relaxed.laneselect s` for all shapes. -/
  relaxedLaneselectImpl : V128 → V128 → V128 → V128
  /-- Relaxed i8x16 dot product implementation -/
  relaxedDotI8x16I7x16SImpl : V128 → V128 → V128
  /-- Relaxed i8x16 dot product with accumulate implementation -/
  relaxedDotI8x16I7x16AddSImpl : V128 → V128 → V128 → V128
  /-- Relaxed Q15 multiply implementation -/
  relaxedQ15MulrSImpl : V128 → V128 → V128

/-- Combined profile for numerics/SIMD non-deterministic choices.
    Deterministic wrappers and execution relations take a `WasmProfile`
    as an explicit immutable parameter, so choices are fixed for a run.

    Memory.grow non-determinism is modeled separately via GrowthPolicy. -/
structure WasmProfile where
  /-- NaN propagation configuration -/
  nanProfile : NaNProfile
  /-- Relaxed SIMD implementation choices -/
  relaxedProfile : RelaxedProfile

end WasmNum
