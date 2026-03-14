import WasmNum.Memory.Core.Bounds

/-!
# Memory Bounds Proofs

Formal proofs about bounds checking predicates.
These theorems establish safety properties for memory access validation.

Wasm spec: Section 4.4.7 trap conditions
- FR-504: Bounds correctness proofs
-/

set_option autoImplicit false

namespace WasmNum.Memory.Proofs

open WasmNum.Memory

/-- In-bounds for `n` bytes implies in-bounds for any smaller access size. -/
theorem inBounds_mono {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (addr : BitVec addrWidth) {m n : Nat} (hmn : m ≤ n)
    (h : inBounds mem addr n) : inBounds mem addr m := by
  unfold inBounds at *; omega

/-- The Bool check agrees with the Prop (forward direction). -/
theorem inBoundsB_true_of_inBounds {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (addr : BitVec addrWidth) (n : Nat)
    (h : inBounds mem addr n) : inBoundsB mem addr n = true := by
  rwa [inBoundsB_iff]

/-- If effective address computation succeeds and the access is in bounds,
    the underlying address offset is within the data size. -/
theorem effectiveInBounds_data_le {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (accessBytes : Nat)
    (h : effectiveInBounds mem base offset accessBytes)
    (addr : BitVec addrWidth) (hea : effectiveAddr base offset = some addr) :
    addr.toNat + accessBytes ≤ mem.data.size := by
  unfold effectiveInBounds at h
  rw [hea] at h
  exact h

end WasmNum.Memory.Proofs
