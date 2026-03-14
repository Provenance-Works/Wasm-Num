import WasmNum.Foundation.Types

/-!
# Basic Definitions

Page size, memory limits, and other Wasm constants.

Wasm spec: Section 2.3.6 "Memory Types"
-/

namespace WasmNum

/-- Wasm page size: 64 KiB (2^16 bytes).
    Wasm spec: "the page size is fixed to be 65536" -/
def pageSize : Nat := 65536

end WasmNum
