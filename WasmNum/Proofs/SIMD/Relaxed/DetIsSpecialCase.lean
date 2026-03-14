import WasmNum.Integration.Profile

/-!
# Deterministic ⊆ Non-deterministic Proofs

Proofs that a `DeterministicWasmProfile`'s concrete choices are always
members of the corresponding non-deterministic specification sets.

These are essentially unpacking the proof obligations stored in the
`DeterministicWasmProfile` structure.

Wasm spec: Relaxed SIMD proposal (deterministic specialization)
-/

namespace WasmNum.Proofs.SIMD.Relaxed

open WasmNum
open WasmNum.Integration
open WasmNum.SIMD

variable [WasmFloat 32] [WasmFloat 64]

/-- The deterministic madd (f32x4) result is in the non-deterministic madd set. -/
theorem det_madd_mem (p : DeterministicWasmProfile) (a b c : V128) :
    p.relaxedProfile.relaxedMaddImpl a b c ∈
      SIMD.Relaxed.madd Shape.f32x4 a b c :=
  p.relaxedMadd_mem a b c

/-- The deterministic nmadd (f32x4) result is in the non-deterministic nmadd set. -/
theorem det_nmadd_mem (p : DeterministicWasmProfile) (a b c : V128) :
    p.relaxedProfile.relaxedNmaddImpl a b c ∈
      SIMD.Relaxed.nmadd Shape.f32x4 a b c :=
  p.relaxedNmadd_mem a b c

/-- The deterministic madd (f64x2) result is in the non-deterministic madd set. -/
theorem det_madd_f64_mem (p : DeterministicWasmProfile) (a b c : V128) :
    p.relaxedProfile.relaxedMaddF64Impl a b c ∈
      SIMD.Relaxed.madd Shape.f64x2 a b c :=
  p.relaxedMaddF64_mem a b c

/-- The deterministic nmadd (f64x2) result is in the non-deterministic nmadd set. -/
theorem det_nmadd_f64_mem (p : DeterministicWasmProfile) (a b c : V128) :
    p.relaxedProfile.relaxedNmaddF64Impl a b c ∈
      SIMD.Relaxed.nmadd Shape.f64x2 a b c :=
  p.relaxedNmaddF64_mem a b c

/-- The deterministic min (f32x4) result is in the non-deterministic min set. -/
theorem det_minF32_mem (p : DeterministicWasmProfile) (a b : V128) :
    V128.zipLanes Shape.f32x4 p.relaxedProfile.relaxedMinImpl32 a b ∈
      SIMD.Relaxed.min Shape.f32x4 a b :=
  p.relaxedMinF32_mem a b

/-- The deterministic max (f32x4) result is in the non-deterministic max set. -/
theorem det_maxF32_mem (p : DeterministicWasmProfile) (a b : V128) :
    V128.zipLanes Shape.f32x4 p.relaxedProfile.relaxedMaxImpl32 a b ∈
      SIMD.Relaxed.max Shape.f32x4 a b :=
  p.relaxedMaxF32_mem a b

/-- The deterministic min (f64x2) result is in the non-deterministic min set. -/
theorem det_minF64_mem (p : DeterministicWasmProfile) (a b : V128) :
    V128.zipLanes Shape.f64x2 p.relaxedProfile.relaxedMinImpl64 a b ∈
      SIMD.Relaxed.min Shape.f64x2 a b :=
  p.relaxedMinF64_mem a b

/-- The deterministic max (f64x2) result is in the non-deterministic max set. -/
theorem det_maxF64_mem (p : DeterministicWasmProfile) (a b : V128) :
    V128.zipLanes Shape.f64x2 p.relaxedProfile.relaxedMaxImpl64 a b ∈
      SIMD.Relaxed.max Shape.f64x2 a b :=
  p.relaxedMaxF64_mem a b

/-- The deterministic swizzle result is in the non-deterministic swizzle set. -/
theorem det_swizzle_mem (p : DeterministicWasmProfile) (v idx : V128) :
    p.relaxedProfile.relaxedSwizzleImpl v idx ∈
      SIMD.Relaxed.swizzle v idx :=
  p.relaxedSwizzle_mem v idx

/-- The deterministic laneselect result is in the non-deterministic laneselect set. -/
theorem det_laneselect_mem (p : DeterministicWasmProfile) (s : SIMD.Shape) (a b mask : V128) :
    p.relaxedProfile.relaxedLaneselectImpl a b mask ∈
      SIMD.Relaxed.laneselect s a b mask :=
  p.relaxedLaneselect_mem s a b mask

/-- The deterministic dot product result is in the non-deterministic dot set. -/
theorem det_dot_mem (p : DeterministicWasmProfile) (a b : V128) :
    p.relaxedProfile.relaxedDotI8x16I7x16SImpl a b ∈
      SIMD.Relaxed.dot_i8x16_i7x16_s a b :=
  p.relaxedDot_mem a b

/-- The deterministic dot-add result is in the non-deterministic dot-add set. -/
theorem det_dotAdd_mem (p : DeterministicWasmProfile) (a b c : V128) :
    p.relaxedProfile.relaxedDotI8x16I7x16AddSImpl a b c ∈
      SIMD.Relaxed.dot_i8x16_i7x16_add_s a b c :=
  p.relaxedDotAdd_mem a b c

/-- The deterministic Q15 multiply result is in the non-deterministic q15mulr set. -/
theorem det_q15mulrS_mem (p : DeterministicWasmProfile) (a b : V128) :
    p.relaxedProfile.relaxedQ15MulrSImpl a b ∈
      SIMD.Relaxed.q15mulrS a b :=
  p.relaxedQ15MulrS_mem a b

/-- The deterministic NaN selection is in the spec-permitted NaN set. -/
theorem det_selectNaN_mem (p : DeterministicWasmProfile)
    (N : Nat) [WasmFloat N] (inputs : List (BitVec N)) :
    p.nanProfile.selectNaN N inputs ∈ Numerics.NaN.nansN N inputs :=
  p.selectNaN_mem N inputs

end WasmNum.Proofs.SIMD.Relaxed
