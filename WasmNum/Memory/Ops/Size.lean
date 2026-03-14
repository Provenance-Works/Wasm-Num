import WasmNum.Memory.Core.FlatMemory

/-!
# memory.size

Returns the current memory size in pages.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `memory.size` returns the current number of pages
- FR-513: Memory Size
-/

set_option autoImplicit false

namespace WasmNum.Memory.Ops

open WasmNum.Memory

/-- `memory.size`: return current size in pages.
    Wasm spec: returns `sz` where `sz * 64Ki = |mem.data|` -/
def memorySize {addrWidth : Nat} (mem : FlatMemory addrWidth) : Nat :=
  mem.pageCount

end WasmNum.Memory.Ops
