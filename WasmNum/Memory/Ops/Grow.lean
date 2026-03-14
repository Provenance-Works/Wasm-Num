import Mathlib.Data.Set.Basic
import WasmNum.Memory.Core.FlatMemory

/-!
# memory.grow

Memory growth with non-deterministic failure modeling.
The Wasm spec allows `memory.grow` to fail even when capacity permits,
so we model the spec-level semantics as a `Set` of possible results
and provide a typeclass for deterministic runtime selection.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `memory.grow` may return -1 (failure) non-deterministically
- FR-514: Memory Grow
-/

set_option autoImplicit false

namespace WasmNum.Memory.Ops

open WasmNum
open WasmNum.Memory

/-- Result of `memory.grow`: either success with the new memory and old page count,
    or failure (returns -1 in Wasm). -/
inductive GrowResult (addrWidth : Nat) where
  /-- Growth succeeded: new memory state and previous page count -/
  | success (mem' : FlatMemory addrWidth) (oldPages : Nat) : GrowResult addrWidth
  /-- Growth failed (spec allows non-deterministic failure) -/
  | failure : GrowResult addrWidth

/-- Spec-level `memory.grow` relation: the set of allowed results.
    Growth is permitted when:
    1. The new page count respects the max limit (if any)
    2. The new byte size fits in the address space
    Even when both conditions hold, failure is always allowed.
    ADR-003: non-determinism modeled as `Set`. -/
def growSpec {addrWidth : Nat} (mem : FlatMemory addrWidth) (deltaPages : Nat)
    : Set (GrowResult addrWidth) :=
  let newCount := mem.pageCount + deltaPages
  let maxOk := match mem.maxLimit with
    | some m => newCount ≤ m
    | none => True
  let fitsOk := newCount * pageSize ≤ 2 ^ addrWidth
  fun result => match result with
    | GrowResult.failure => True
    | GrowResult.success mem' oldPages =>
        maxOk ∧ fitsOk ∧ oldPages = mem.pageCount ∧
        mem'.pageCount = newCount ∧
        mem'.data.size = newCount * pageSize ∧
        mem'.maxLimit = mem.maxLimit ∧
        -- Data preservation: existing bytes are unchanged
        (∀ (i : Nat) (hi : i < mem.data.size) (hi' : i < mem'.data.size),
          mem'.data.get i hi' = mem.data.get i hi) ∧
        -- Zero initialization: new bytes are zeroed
        (∀ (i : Nat) (_ : mem.data.size ≤ i) (hi' : i < mem'.data.size),
          mem'.data.get i hi' = 0)

/-- Typeclass for deterministic memory growth policy.
    An implementation picks one result from the spec-allowed set.
    Wasm spec: runtime chooses whether grow succeeds or fails. -/
class GrowthPolicy (addrWidth : Nat) where
  /-- Deterministically choose a grow result -/
  chooseGrow : FlatMemory addrWidth → Nat → GrowResult addrWidth
  /-- The chosen result is always in the spec-allowed set -/
  chooseGrow_mem : ∀ mem deltaPages,
    chooseGrow mem deltaPages ∈ growSpec mem deltaPages

/-- Runtime `memory.grow` using the deterministic policy.
    Wasm spec: `memory.grow` instruction semantics -/
def growExec {addrWidth : Nat} [GrowthPolicy addrWidth]
    (mem : FlatMemory addrWidth) (deltaPages : Nat) : GrowResult addrWidth :=
  GrowthPolicy.chooseGrow mem deltaPages

/-- Failure is always in the spec-allowed set. -/
theorem growSpec_failure_mem {addrWidth : Nat} (mem : FlatMemory addrWidth) (deltaPages : Nat) :
    GrowResult.failure ∈ growSpec mem deltaPages := by
  unfold growSpec
  show True
  trivial

end WasmNum.Memory.Ops
