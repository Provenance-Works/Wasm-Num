import Mathlib.Data.Set.Basic
import WasmNum.Foundation.WasmFloat

/-!
# NaN Propagation

Wasm's NaN propagation rules as specified in the Wasm spec.
Non-deterministic results are modeled as `Set (BitVec N)` (ADR-003).

Lean identifier `nansN` corresponds to spec notation `nans_N{z*}`.

Wasm spec: Section 4.3.3 "Floating-Point Operations"

Rules:
1. If any input is NaN, result is from `nansN N nanInputs`
2. If no input is NaN but the operation produces NaN, result is from `nansN N []`
3. The sign of the result NaN is non-deterministic
-/

namespace WasmNum.Numerics.NaN

open WasmNum

variable {N : Nat}

/-- The set of all NaN values for a given bit width.
    Wasm spec: "a NaN value" -/
def nans (N : Nat) [WasmFloat N] : Set (BitVec N) :=
  { v | WasmFloat.isNaN v = true }

/-- Canonical NaN set: canonical payload, either sign.
    Wasm spec: nans_N{} (no input NaN operands) -/
def canonicalNans (N : Nat) [WasmFloat N] : Set (BitVec N) :=
  { v | WasmFloat.isCanonicalNaN v = true }

/-- Arithmetic NaN set: any NaN with an arithmetic (quiet) payload.
    Wasm spec: "an arithmetic NaN" -/
def arithmeticNans (N : Nat) [WasmFloat N] : Set (BitVec N) :=
  { v | WasmFloat.isArithmeticNaN v = true }

/-- Input-sensitive payload overlap relation.
    True when the payload of `v` overlaps at least one input NaN.
    Used by the `nansN` definition below. -/
def payloadOverlapsAny [WasmFloat N] (v : BitVec N) (inputs : List (BitVec N)) : Prop :=
  ∃ input, input ∈ inputs ∧ WasmFloat.payloadOverlap v input

/-- Arithmetic NaNs whose payload overlaps at least one input NaN.
    Wasm spec: "whose payload field is" one of the input payloads -/
def overlappingArithmeticNans (N : Nat) [WasmFloat N]
    (inputs : List (BitVec N)) : Set (BitVec N) :=
  { v | WasmFloat.isArithmeticNaN v = true ∧ payloadOverlapsAny v inputs }

/-- NaN propagation result set.
    Lean identifier for spec notation `nans_N{z*}`.

    - `nansN N []` = canonical NaNs (no input NaN operands)
    - `nansN N zs` (zs non-empty) = canonical NaNs plus overlapping arithmetic NaNs

    **Contract:** `inputs` must contain only the NaN operands of the current
    instruction (i.e., callers must pre-filter non-NaN values before calling).
    Wasm spec: Section 4.3.3 "nans_N{z*}" -/
def nansN (N : Nat) [WasmFloat N] (inputs : List (BitVec N)) : Set (BitVec N) :=
  if inputs.isEmpty then
    canonicalNans N
  else
    canonicalNans N ∪ overlappingArithmeticNans N inputs

/-- NaN propagation for unary operations.
    If the input is NaN, result is from `nansN N [a]`.
    If the input is not NaN but the result is NaN, result is from `nansN N []`.
    Otherwise the result is deterministic (singleton set). -/
def propagateNaN₁ [WasmFloat N] (op : BitVec N → BitVec N)
    (a : BitVec N) : Set (BitVec N) :=
  if WasmFloat.isNaN a then
    nansN N [a]
  else if WasmFloat.isNaN (op a) then
    nansN N []
  else
    {op a}

/-- NaN propagation for binary operations.
    If any input is NaN, all input NaN payloads are considered.
    Wasm spec: "if any input is NaN, result in nans_N{z1, z2}" -/
def propagateNaN₂ [WasmFloat N] (op : BitVec N → BitVec N → BitVec N)
    (a b : BitVec N) : Set (BitVec N) :=
  if WasmFloat.isNaN a || WasmFloat.isNaN b then
    nansN N ([a, b].filter (fun v => WasmFloat.isNaN v))
  else if WasmFloat.isNaN (op a b) then
    nansN N []
  else
    {op a b}

end WasmNum.Numerics.NaN
