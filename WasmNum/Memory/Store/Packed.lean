import WasmNum.Memory.Store.Scalar

/-!
# Packed Stores (Truncating)

Store sub-width integers to memory by truncating wider values.
These operations write fewer bytes than the source type width.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `i32.store8`, `i32.store16`
- `i64.store8`, `i64.store16`, `i64.store32`
- FR-510: Packed Stores
-/

set_option autoImplicit false

namespace WasmNum.Memory.Store

open WasmNum
open WasmNum.Memory

-- === i32 packed stores ===

/-- `i32.store8`: truncate i32 to 8 bits and store 1 byte -/
def i32Store8 {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : I32) : Option (FlatMemory addrWidth) :=
  storeN mem addr (val.truncate 8) (by omega)

/-- `i32.store16`: truncate i32 to 16 bits and store 2 bytes -/
def i32Store16 {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : I32) : Option (FlatMemory addrWidth) :=
  storeN mem addr (val.truncate 16) (by omega)

-- === i64 packed stores ===

/-- `i64.store8`: truncate i64 to 8 bits and store 1 byte -/
def i64Store8 {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : I64) : Option (FlatMemory addrWidth) :=
  storeN mem addr (val.truncate 8) (by omega)

/-- `i64.store16`: truncate i64 to 16 bits and store 2 bytes -/
def i64Store16 {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : I64) : Option (FlatMemory addrWidth) :=
  storeN mem addr (val.truncate 16) (by omega)

/-- `i64.store32`: truncate i64 to 32 bits and store 4 bytes -/
def i64Store32 {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : I64) : Option (FlatMemory addrWidth) :=
  storeN mem addr (val.truncate 32) (by omega)

end WasmNum.Memory.Store
