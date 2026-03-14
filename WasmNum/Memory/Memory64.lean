import WasmNum.Memory.Core.FlatMemory
import WasmNum.Memory.Core.Page

/-!
# Memory64 Support

Memory64 proposal support: convenience definitions and properties
for 64-bit addressed memory.

Memory64 reuses the same `FlatMemory 64` type parameterized by `addrWidth = 64`.
This module provides additional constants and theorems specific to 64-bit memories.

Wasm spec: Memory64 proposal
- FR-518: Memory64 Support
-/

set_option autoImplicit false

namespace WasmNum.Memory

open WasmNum

/-- Maximum pages for Memory64: 2^48 pages (spec-limited to 16 EiB).
    While `2^64 / 65536 = 2^48`, the spec may further constrain this. -/
theorem maxPages_64 : maxPages 64 = 281474976710656 := by native_decide

/-- Create an empty Memory64 with the given optional max limit. -/
def Memory64.empty (maxLimit : Option Nat := none)
    (h_maxFits : ∀ (max : Nat), maxLimit = some max → max * pageSize ≤ 2 ^ 64 := by
      intro max hmax; simp_all) : Memory64 :=
  FlatMemory.empty 64 maxLimit h_maxFits

/-- Create an empty Memory32 with the given optional max limit. -/
def Memory32.empty (maxLimit : Option Nat := none)
    (h_maxFits : ∀ (max : Nat), maxLimit = some max → max * pageSize ≤ 2 ^ 32 := by
      intro max hmax; simp_all) : Memory32 :=
  FlatMemory.empty 32 maxLimit h_maxFits

end WasmNum.Memory
