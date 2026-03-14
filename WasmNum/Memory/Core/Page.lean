import WasmNum.Foundation

/-!
# Memory Page Model

Page-related constants and limits for WebAssembly memories.
Memory sizes are always multiples of `pageSize` (64 KiB).

The maximum number of pages depends on the address width:
- Memory32 (addrWidth = 32): max 65536 pages (4 GiB)
- Memory64 (addrWidth = 64): max 2^48 pages (16 EiB, spec-limited)

Wasm spec: Section 2.3.6 "Memory Types"
- FR-501: Page Model
-/

namespace WasmNum.Memory

open WasmNum

/-- Maximum number of pages for a given address width.
    Wasm spec: memory address space limit.
    For 32-bit: 2^32 / 65536 = 65536 pages
    For 64-bit: 2^64 / 65536 = 2^48 pages -/
def maxPages (addrWidth : Nat) : Nat := 2 ^ addrWidth / pageSize

/-- Page size is positive (needed for invariant proofs) -/
theorem pageSize_pos : pageSize > 0 := by decide

/-- maxPages for 32-bit memories is 65536 -/
theorem maxPages_32 : maxPages 32 = 65536 := by native_decide

end WasmNum.Memory
