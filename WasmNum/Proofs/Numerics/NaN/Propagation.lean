import WasmNum.Numerics.NaN.Propagation
import Mathlib.Data.Set.Basic

/-!
# NaN Propagation Correctness Proofs

Proofs that NaN propagation definitions satisfy expected properties:
- Canonical NaN is always in the NaN set
- Subset relationships between NaN categories
- nansN with empty inputs is canonicalNans
- nansN results are always NaNs

Wasm spec: Section 4.3.3 "nans_N{z*}" correctness
-/

namespace WasmNum.Proofs.Numerics.NaN

open WasmNum
open WasmNum.Numerics.NaN

/-- Canonical NaN is in the set of all NaNs -/
theorem canonicalNaN_mem_nans (N : Nat) [WasmFloat N] :
    WasmFloat.canonicalNaN ∈ nans N :=
  WasmFloat.isNaN_canonicalNaN

/-- Every canonical NaN is a NaN -/
theorem canonicalNans_subset_nans (N : Nat) [WasmFloat N] :
    canonicalNans N ⊆ nans N := by
  intro v hv
  exact WasmFloat.isCanonicalNaN_isNaN v hv

/-- Every arithmetic NaN is a NaN -/
theorem arithmeticNans_subset_nans (N : Nat) [WasmFloat N] :
    arithmeticNans N ⊆ nans N := by
  intro v hv
  exact WasmFloat.isArithmeticNaN_isNaN v hv

/-- nansN with empty inputs returns exactly the canonical NaN set -/
@[simp]
theorem nansN_nil (N : Nat) [WasmFloat N] :
    nansN N [] = canonicalNans N := by
  simp [nansN]

/-- nansN result set is always a subset of all NaNs -/
theorem nansN_subset_nans (N : Nat) [WasmFloat N]
    (inputs : List (BitVec N)) :
    nansN N inputs ⊆ nans N := by
  intro v hv
  simp only [nansN] at hv
  split at hv
  · exact canonicalNans_subset_nans N hv
  · rcases hv with h | ⟨h, _⟩
    · exact canonicalNans_subset_nans N h
    · exact WasmFloat.isArithmeticNaN_isNaN v h

/-- Overlapping arithmetic NaNs are a subset of all NaNs -/
theorem overlappingArithmeticNans_subset_nans (N : Nat) [WasmFloat N]
    (inputs : List (BitVec N)) :
    overlappingArithmeticNans N inputs ⊆ nans N := by
  intro v ⟨hArith, _⟩
  exact WasmFloat.isArithmeticNaN_isNaN v hArith

end WasmNum.Proofs.Numerics.NaN
