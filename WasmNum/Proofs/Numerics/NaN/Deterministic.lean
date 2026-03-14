import WasmNum.Numerics.NaN.Deterministic
import Mathlib.Data.Set.Basic

/-!
# Deterministic NaN Propagation Proofs

Proves that deterministic NaN propagation (via `DeterministicWasmProfile`) returns values
that are members of the non-deterministic result sets.

Key theorems:
- `propagateNaN₁_det_mem`: det unary result is in the non-det set
- `propagateNaN₂_det_mem`: det binary result is in the non-det set
- `propagateNaN₁_det_singleton`: det unary result denotes a singleton set
- `propagateNaN₂_det_singleton`: det binary result denotes a singleton set

This establishes that deterministic behavior is a provably-correct
specialization of the non-deterministic model (ADR-003).
-/

namespace WasmNum.Proofs.Numerics.NaN

open WasmNum
open WasmNum.Numerics.NaN

variable {N : Nat}

/-- The deterministic unary NaN propagation result is always a member
    of the non-deterministic result set. -/
theorem propagateNaN₁_det_mem [WasmFloat N] (profile : DeterministicWasmProfile)
    (op : BitVec N → BitVec N) (a : BitVec N) :
    propagateNaN₁_det profile op a ∈ propagateNaN₁ op a := by
  unfold propagateNaN₁_det propagateNaN₁
  split
  · -- Case: WasmFloat.isNaN a = true
    exact profile.selectNaN_mem N [a]
  · -- Case: WasmFloat.isNaN a = false
    split
    · -- Sub-case: WasmFloat.isNaN (op a) = true
      exact profile.selectNaN_mem N []
    · -- Sub-case: WasmFloat.isNaN (op a) = false, result is singleton
      exact rfl

/-- The deterministic binary NaN propagation result is always a member
    of the non-deterministic result set. -/
theorem propagateNaN₂_det_mem [WasmFloat N] (profile : DeterministicWasmProfile)
    (op : BitVec N → BitVec N → BitVec N) (a b : BitVec N) :
    propagateNaN₂_det profile op a b ∈ propagateNaN₂ op a b := by
  unfold propagateNaN₂_det propagateNaN₂
  split
  · -- Case: at least one NaN input
    exact profile.selectNaN_mem N _
  · -- Case: no NaN inputs
    split
    · -- Sub-case: operation result is NaN
      exact profile.selectNaN_mem N []
    · -- Sub-case: operation result is not NaN, result is singleton
      exact rfl

/-- Deterministic unary NaN propagation denotes a singleton result set. -/
theorem propagateNaN₁_det_singleton [WasmFloat N] (profile : DeterministicWasmProfile)
    (op : BitVec N → BitVec N) (a : BitVec N) :
    ∃! v, v ∈ ({propagateNaN₁_det profile op a} : Set (BitVec N)) := by
  refine ⟨propagateNaN₁_det profile op a, ?_, ?_⟩
  · exact rfl
  · intro v hv
    simpa using hv

/-- Deterministic binary NaN propagation denotes a singleton result set. -/
theorem propagateNaN₂_det_singleton [WasmFloat N] (profile : DeterministicWasmProfile)
    (op : BitVec N → BitVec N → BitVec N) (a b : BitVec N) :
    ∃! v, v ∈ ({propagateNaN₂_det profile op a b} : Set (BitVec N)) := by
  refine ⟨propagateNaN₂_det profile op a b, ?_, ?_⟩
  · exact rfl
  · intro v hv
    simpa using hv

end WasmNum.Proofs.Numerics.NaN
