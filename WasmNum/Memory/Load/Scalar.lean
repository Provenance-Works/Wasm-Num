import WasmNum.Memory.Core.Bounds

/-!
# Scalar Loads

Full-width load operations for WebAssembly scalar types.
Each load reads N bits from memory in little-endian byte order,
returning `none` (trap) when the access would exceed memory bounds.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `i32.load`, `i64.load`, `f32.load`, `f64.load`
- FR-506: Scalar Loads
-/

set_option autoImplicit false

namespace WasmNum.Memory.Load

open WasmNum
open WasmNum.Memory

/-- Generic N-bit load from memory at the given address.
    Reads N/8 bytes in little-endian order.
    Returns `none` if out of bounds. Requires N divisible by 8.
    Wasm spec: load `t.load` reads `|t|/8` bytes. -/
def loadN {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (N : Nat) (hN : N % 8 = 0) : Option (BitVec N) :=
  mem.readLittleEndian addr.toNat N hN

/-- `i32.load`: load 32 bits (4 bytes) as I32 -/
def i32Load {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I32 :=
  loadN mem addr 32 (by omega)

/-- `i64.load`: load 64 bits (8 bytes) as I64 -/
def i64Load {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option I64 :=
  loadN mem addr 64 (by omega)

/-- `f32.load`: load 32 bits (4 bytes) as F32 (bit-pattern) -/
def f32Load {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option F32 :=
  loadN mem addr 32 (by omega)

/-- `f64.load`: load 64 bits (8 bytes) as F64 (bit-pattern) -/
def f64Load {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option F64 :=
  loadN mem addr 64 (by omega)

end WasmNum.Memory.Load
