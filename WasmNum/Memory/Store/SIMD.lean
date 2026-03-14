import WasmNum.Memory.Store.Scalar
import WasmNum.SIMD.V128.Lanes

/-!
# SIMD Stores

SIMD-specific store operations: v128.store and v128.store_lane.

Wasm spec: SIMD proposal, Section "Memory Instructions"
- `v128.store`
- `v128.store8_lane`, `v128.store16_lane`, `v128.store32_lane`, `v128.store64_lane`
- FR-511: SIMD Stores
-/

set_option autoImplicit false

namespace WasmNum.Memory.Store

open WasmNum
open WasmNum.Memory
open WasmNum.SIMD

-- === v128.store ===

/-- `v128.store`: store 128 bits (16 bytes) -/
def v128Store {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : V128) : Option (FlatMemory addrWidth) :=
  storeN mem addr val (by omega)

-- === v128.store_lane ===

/-- `v128.store8_lane`: store 1 byte from the specified lane -/
def v128Store8Lane {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (v : V128) (lane : Fin 16) : Option (FlatMemory addrWidth) :=
  storeN mem addr (V128.lane Shape.i8x16 v lane) (by decide)

/-- `v128.store16_lane`: store 2 bytes from the specified lane -/
def v128Store16Lane {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (v : V128) (lane : Fin 8) : Option (FlatMemory addrWidth) :=
  storeN mem addr (V128.lane Shape.i16x8 v lane) (by decide)

/-- `v128.store32_lane`: store 4 bytes from the specified lane -/
def v128Store32Lane {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (v : V128) (lane : Fin 4) : Option (FlatMemory addrWidth) :=
  storeN mem addr (V128.lane Shape.i32x4 v lane) (by decide)

/-- `v128.store64_lane`: store 8 bytes from the specified lane -/
def v128Store64Lane {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (v : V128) (lane : Fin 2) : Option (FlatMemory addrWidth) :=
  storeN mem addr (V128.lane Shape.i64x2 v lane) (by decide)

end WasmNum.Memory.Store
