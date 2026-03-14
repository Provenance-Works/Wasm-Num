import WasmNum.Memory.Core.Bounds

/-!
# Scalar Stores

Full-width store operations for WebAssembly scalar types.
Each store writes N bits to memory in little-endian byte order,
returning `none` (trap) when the access would exceed memory bounds.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `i32.store`, `i64.store`, `f32.store`, `f64.store`
- FR-509: Scalar Stores
-/

set_option autoImplicit false

namespace WasmNum.Memory.Store

open WasmNum
open WasmNum.Memory

/-- Generic N-bit store to memory at the given address.
    Writes N/8 bytes in little-endian order.
    Returns `none` if out of bounds. Requires N divisible by 8.
    Wasm spec: store `t.store` writes `|t|/8` bytes. -/
def storeN {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    {N : Nat} (val : BitVec N) (hN : N % 8 = 0) : Option (FlatMemory addrWidth) :=
  mem.writeLittleEndian addr.toNat N hN val

/-- `i32.store`: store 32 bits (4 bytes) -/
def i32Store {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : I32) : Option (FlatMemory addrWidth) :=
  storeN mem addr val (by omega)

/-- `i64.store`: store 64 bits (8 bytes) -/
def i64Store {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : I64) : Option (FlatMemory addrWidth) :=
  storeN mem addr val (by omega)

/-- `f32.store`: store 32 bits (4 bytes, bit-pattern) -/
def f32Store {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : F32) : Option (FlatMemory addrWidth) :=
  storeN mem addr val (by omega)

/-- `f64.store`: store 64 bits (8 bytes, bit-pattern) -/
def f64Store {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : F64) : Option (FlatMemory addrWidth) :=
  storeN mem addr val (by omega)

end WasmNum.Memory.Store
