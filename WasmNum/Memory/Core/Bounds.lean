import WasmNum.Memory.Core.Address

/-!
# Bounds Checking

Bounds checking predicates and helpers for memory access validation.
Every load/store must verify that the effective address + access size
does not exceed the memory's byte size.

Wasm spec: Section 4.4.7 "Memory Instructions" (trap conditions)
- FR-504: Bounds Checking
-/

set_option autoImplicit false

namespace WasmNum.Memory

open WasmNum

/-- Predicate: an access of `accessBytes` bytes starting at `addr` is in bounds
    for a memory of the given address width.
    Wasm spec: trap if `ea + N/8 > |mem.data|` -/
def inBounds {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth) (accessBytes : Nat) : Prop :=
  addr.toNat + accessBytes ≤ mem.data.size

/-- Decidable in-bounds check (Bool version) -/
def inBoundsB {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth) (accessBytes : Nat) : Bool :=
  addr.toNat + accessBytes ≤ mem.data.size

/-- The Bool check agrees with the Prop -/
theorem inBoundsB_iff {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth) (accessBytes : Nat) :
    inBoundsB mem addr accessBytes = true ↔ inBounds mem addr accessBytes := by
  simp [inBoundsB, inBounds]

/-- Proposition: effective address does not overflow and access is within memory bounds.
    Wasm spec: trap if effective address overflows or if ea + N/8 > |mem.data| -/
def effectiveInBounds {addrWidth : Nat} (mem : FlatMemory addrWidth) (base : BitVec addrWidth)
    (offset : Nat) (accessBytes : Nat) : Prop :=
  match effectiveAddr base offset with
  | some addr => inBounds mem addr accessBytes
  | none => False

/-- Decidable effective in-bounds check (Bool version) -/
def effectiveInBoundsB {addrWidth : Nat} (mem : FlatMemory addrWidth) (base : BitVec addrWidth)
    (offset : Nat) (accessBytes : Nat) : Bool :=
  match effectiveAddr base offset with
  | some addr => inBoundsB mem addr accessBytes
  | none => false

end WasmNum.Memory
