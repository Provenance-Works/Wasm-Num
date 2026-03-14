import WasmNum.Foundation.Profile
import WasmNum.Numerics.NaN.Propagation

/-!
# Deterministic NaN Propagation

Deterministic NaN propagation using a `DeterministicWasmProfile`.
The profile's `NaNProfile.selectNaN` picks one concrete NaN result from
the non-deterministic `nansN` set, and the profile carries a proof that the
choice is spec-permitted.

Used by the integration layer for `#eval` testing and runtime execution.

Wasm spec: Section 4.3.3 (NaN propagation, determinized by profile)
-/

namespace WasmNum.Numerics.NaN

open WasmNum

variable {N : Nat}

/-- Proof-carrying deterministic specialization of `WasmProfile` for NaN
    propagation. The stronger membership proof lives in the Numerics layer so
    Foundation does not depend on `nansN`. Relaxed SIMD proof fields are added
    when that layer is implemented. -/
structure DeterministicWasmProfile extends WasmProfile where
  /-- The selected NaN is always a member of the Wasm-spec allowed result set. -/
  selectNaN_mem : ∀ (N : Nat) [WasmFloat N] (inputs : List (BitVec N)),
    nanProfile.selectNaN N inputs ∈ nansN N inputs

/-- Deterministic NaN propagation for unary operations.
    Uses `profile.nanProfile.selectNaN` to pick a concrete NaN. -/
def propagateNaN₁_det [WasmFloat N] (profile : DeterministicWasmProfile)
    (op : BitVec N → BitVec N) (a : BitVec N) : BitVec N :=
  if WasmFloat.isNaN a then
    profile.nanProfile.selectNaN N [a]
  else if WasmFloat.isNaN (op a) then
    profile.nanProfile.selectNaN N []
  else
    op a

/-- Deterministic NaN propagation for binary operations.
    Uses `profile.nanProfile.selectNaN` to pick a concrete NaN. -/
def propagateNaN₂_det [WasmFloat N] (profile : DeterministicWasmProfile)
    (op : BitVec N → BitVec N → BitVec N) (a b : BitVec N) : BitVec N :=
  if WasmFloat.isNaN a || WasmFloat.isNaN b then
    profile.nanProfile.selectNaN N ([a, b].filter (fun v => WasmFloat.isNaN v))
  else if WasmFloat.isNaN (op a b) then
    profile.nanProfile.selectNaN N []
  else
    op a b

end WasmNum.Numerics.NaN
