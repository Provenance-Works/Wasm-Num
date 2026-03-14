/-!
# Wasm Value Types

Type aliases for WebAssembly value types.
All numeric types are represented as `BitVec N` (ADR-002).

Wasm spec: Section 2.3.1 "Number Types"
-/

namespace WasmNum

/-- WebAssembly 32-bit integer -/
abbrev I32 := BitVec 32

/-- WebAssembly 64-bit integer -/
abbrev I64 := BitVec 64

/-- WebAssembly 32-bit float (bit-pattern representation per ADR-002) -/
abbrev F32 := BitVec 32

/-- WebAssembly 64-bit float (bit-pattern representation per ADR-002) -/
abbrev F64 := BitVec 64

/-- WebAssembly 128-bit SIMD vector -/
abbrev V128 := BitVec 128

/-- Byte (8-bit value) -/
abbrev Byte := BitVec 8

/-- 32-bit memory address (Memory32) -/
abbrev Addr32 := BitVec 32

/-- 64-bit memory address (Memory64) -/
abbrev Addr64 := BitVec 64

end WasmNum
