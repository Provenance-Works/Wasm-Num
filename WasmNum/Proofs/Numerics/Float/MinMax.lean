import WasmNum.Numerics.Float.MinMax
import WasmNum.Numerics.NaN.Propagation
import Mathlib.Data.Set.Basic

/-!
# Float Min/Max Spec Compliance Proofs

Proofs that fmin/fmax satisfy Wasm spec properties:
- NaN inputs produce NaN outputs (from nansN set)
- Non-NaN inputs produce deterministic (singleton) results

Wasm spec: Section 4.3.3 — fmin, fmax correctness
-/

namespace WasmNum.Proofs.Numerics.Float

open WasmNum
open WasmNum.Numerics.Float
open WasmNum.Numerics.NaN

variable {N : Nat}

/-- All elements of `nansN` are NaN -/
theorem nansN_isNaN [WasmFloat N] (inputs : List (BitVec N))
    (v : BitVec N) (hv : v ∈ nansN N inputs) :
    WasmFloat.isNaN v = true := by
  simp only [nansN] at hv
  split at hv
  · exact WasmFloat.isCanonicalNaN_isNaN v hv
  · rcases hv with h | ⟨h, _⟩
    · exact WasmFloat.isCanonicalNaN_isNaN v h
    · exact WasmFloat.isArithmeticNaN_isNaN v h

/-- fmin with NaN left input produces NaN results -/
theorem fmin_nan_left [WasmFloat N] (a b : BitVec N)
    (ha : WasmFloat.isNaN a = true) :
    ∀ v ∈ fmin a b, WasmFloat.isNaN v = true := by
  intro v hv
  simp only [fmin, propagateNaN₂, ha, Bool.true_or, ite_true] at hv
  exact nansN_isNaN _ v hv

/-- fmin with NaN right input produces NaN results -/
theorem fmin_nan_right [WasmFloat N] (a b : BitVec N)
    (hb : WasmFloat.isNaN b = true) :
    ∀ v ∈ fmin a b, WasmFloat.isNaN v = true := by
  intro v hv
  simp only [fmin, propagateNaN₂, hb, Bool.or_true, ite_true] at hv
  exact nansN_isNaN _ v hv

/-- fmax with NaN left input produces NaN results -/
theorem fmax_nan_left [WasmFloat N] (a b : BitVec N)
    (ha : WasmFloat.isNaN a = true) :
    ∀ v ∈ fmax a b, WasmFloat.isNaN v = true := by
  intro v hv
  simp only [fmax, propagateNaN₂, ha, Bool.true_or, ite_true] at hv
  exact nansN_isNaN _ v hv

/-- fmax with NaN right input produces NaN results -/
theorem fmax_nan_right [WasmFloat N] (a b : BitVec N)
    (hb : WasmFloat.isNaN b = true) :
    ∀ v ∈ fmax a b, WasmFloat.isNaN v = true := by
  intro v hv
  simp only [fmax, propagateNaN₂, hb, Bool.or_true, ite_true] at hv
  exact nansN_isNaN _ v hv

/-- fmin with non-NaN inputs is a singleton set -/
theorem fmin_det [WasmFloat N] (a b : BitVec N)
    (ha : WasmFloat.isNaN a = false) (hb : WasmFloat.isNaN b = false)
    (hop : WasmFloat.isNaN (
      if WasmFloat.isZero a && WasmFloat.isZero b then
        if WasmFloat.isNegative a then a else b
      else if WasmFloat.lt a b then a
      else b) = false) :
    ∃! v, v ∈ fmin a b := by
  simp only [fmin, propagateNaN₂, ha, hb, Bool.or_false, hop]
  exact ⟨_, rfl, fun _ hv => hv⟩

/-- fmax with non-NaN inputs is a singleton set -/
theorem fmax_det [WasmFloat N] (a b : BitVec N)
    (ha : WasmFloat.isNaN a = false) (hb : WasmFloat.isNaN b = false)
    (hop : WasmFloat.isNaN (
      if WasmFloat.isZero a && WasmFloat.isZero b then
        if WasmFloat.isNegative a then b else a
      else if WasmFloat.lt b a then a
      else b) = false) :
    ∃! v, v ∈ fmax a b := by
  simp only [fmax, propagateNaN₂, ha, hb, Bool.or_false, hop]
  exact ⟨_, rfl, fun _ hv => hv⟩

end WasmNum.Proofs.Numerics.Float
