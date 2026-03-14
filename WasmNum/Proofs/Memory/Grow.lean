import WasmNum.Memory.Ops.Grow

/-!
# Memory Grow Proofs

Formal proofs about memory growth semantics.

Wasm spec: Section 4.4.7 "Memory Instructions"
- FR-514: Memory grow correctness proofs
-/

set_option autoImplicit false

namespace WasmNum.Memory.Proofs

open WasmNum.Memory
open WasmNum.Memory.Ops

/-- Failure is always a valid grow result. -/
theorem grow_failure_always_valid {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (delta : Nat) :
    GrowResult.failure ∈ growSpec mem delta :=
  growSpec_failure_mem mem delta

/-- Growing by 0 pages always has failure in the result set. -/
theorem grow_zero_failure {addrWidth : Nat} (mem : FlatMemory addrWidth) :
    GrowResult.failure ∈ growSpec mem 0 :=
  growSpec_failure_mem mem 0

/-- If grow succeeds, the old page count is preserved in the result. -/
theorem grow_success_oldPages {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (delta : Nat)
    (mem' : FlatMemory addrWidth) (oldPages : Nat)
    (h : GrowResult.success mem' oldPages ∈ growSpec mem delta) :
    oldPages = mem.pageCount := by
  unfold growSpec at h; dsimp only at h
  exact h.2.2.1

/-- If grow succeeds, the new page count is old + delta. -/
theorem grow_success_newPages {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (delta : Nat)
    (mem' : FlatMemory addrWidth) (oldPages : Nat)
    (h : GrowResult.success mem' oldPages ∈ growSpec mem delta) :
    mem'.pageCount = mem.pageCount + delta := by
  unfold growSpec at h; dsimp only at h
  exact h.2.2.2.1

/-- If grow succeeds, the new data size is correct. -/
theorem grow_success_dataSize {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (delta : Nat)
    (mem' : FlatMemory addrWidth) (oldPages : Nat)
    (h : GrowResult.success mem' oldPages ∈ growSpec mem delta) :
    mem'.data.size = (mem.pageCount + delta) * pageSize := by
  unfold growSpec at h; dsimp only at h
  exact h.2.2.2.2.1

/-- If grow succeeds, the max limit is preserved. -/
theorem grow_success_maxLimit {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (delta : Nat)
    (mem' : FlatMemory addrWidth) (oldPages : Nat)
    (h : GrowResult.success mem' oldPages ∈ growSpec mem delta) :
    mem'.maxLimit = mem.maxLimit := by
  unfold growSpec at h; dsimp only at h
  exact h.2.2.2.2.2.1

/-- If grow succeeds, existing bytes are preserved. -/
theorem grow_success_data_preserved {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (delta : Nat)
    (mem' : FlatMemory addrWidth) (oldPages : Nat)
    (h : GrowResult.success mem' oldPages ∈ growSpec mem delta)
    (i : Nat) (hi : i < mem.data.size) (hi' : i < mem'.data.size) :
    mem'.data.get i hi' = mem.data.get i hi := by
  unfold growSpec at h; dsimp only at h
  exact h.2.2.2.2.2.2.1 i hi hi'

/-- If grow succeeds, new bytes are zero-initialized. -/
theorem grow_success_zero_init {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (delta : Nat)
    (mem' : FlatMemory addrWidth) (oldPages : Nat)
    (h : GrowResult.success mem' oldPages ∈ growSpec mem delta)
    (i : Nat) (hlo : mem.data.size ≤ i) (hi' : i < mem'.data.size) :
    mem'.data.get i hi' = 0 := by
  unfold growSpec at h; dsimp only at h
  exact h.2.2.2.2.2.2.2 i hlo hi'

end WasmNum.Memory.Proofs
