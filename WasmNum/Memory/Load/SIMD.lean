import WasmNum.Memory.Load.Scalar
import WasmNum.SIMD.V128.Lanes

/-!
# SIMD Loads

SIMD-specific load operations: v128.load, load-and-extend, load-splat,
load-zero, and load-lane.

Wasm spec: SIMD proposal, Section "Memory Instructions"
- `v128.load`, `v128.load8x8_s/u`, `v128.load16x4_s/u`, `v128.load32x2_s/u`
- `v128.load8_splat`, `v128.load16_splat`, `v128.load32_splat`, `v128.load64_splat`
- `v128.load32_zero`, `v128.load64_zero`
- `v128.load8_lane`, `v128.load16_lane`, `v128.load32_lane`, `v128.load64_lane`
- FR-508: SIMD Loads
-/

set_option autoImplicit false

namespace WasmNum.Memory.Load

open WasmNum
open WasmNum.Memory
open WasmNum.SIMD

-- === v128.load ===

/-- `v128.load`: load 128 bits (16 bytes) as V128 -/
def v128Load {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  loadN mem addr 128 (by omega)

-- === v128.loadNxM_s/u (load and extend) ===

/-- `v128.load8x8_s`: load 8 bytes, sign-extend each to 16 bits → i16x8 -/
def v128Load8x8S {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun raw =>
    V128.ofLanes Shape.i16x8 fun i =>
      ((raw.extractLsb' (i.val * 8) 8) : BitVec 8).signExtend 16

/-- `v128.load8x8_u`: load 8 bytes, zero-extend each to 16 bits → i16x8 -/
def v128Load8x8U {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun raw =>
    V128.ofLanes Shape.i16x8 fun i =>
      ((raw.extractLsb' (i.val * 8) 8) : BitVec 8).zeroExtend 16

/-- `v128.load16x4_s`: load 4 halfwords, sign-extend each to 32 bits → i32x4 -/
def v128Load16x4S {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun raw =>
    V128.ofLanes Shape.i32x4 fun i =>
      ((raw.extractLsb' (i.val * 16) 16) : BitVec 16).signExtend 32

/-- `v128.load16x4_u`: load 4 halfwords, zero-extend each to 32 bits → i32x4 -/
def v128Load16x4U {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun raw =>
    V128.ofLanes Shape.i32x4 fun i =>
      ((raw.extractLsb' (i.val * 16) 16) : BitVec 16).zeroExtend 32

/-- `v128.load32x2_s`: load 2 words, sign-extend each to 64 bits → i64x2 -/
def v128Load32x2S {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun raw =>
    V128.ofLanes Shape.i64x2 fun i =>
      ((raw.extractLsb' (i.val * 32) 32) : BitVec 32).signExtend 64

/-- `v128.load32x2_u`: load 2 words, zero-extend each to 64 bits → i64x2 -/
def v128Load32x2U {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun raw =>
    V128.ofLanes Shape.i64x2 fun i =>
      ((raw.extractLsb' (i.val * 32) 32) : BitVec 32).zeroExtend 64

-- === v128.load_splat ===

/-- `v128.load8_splat`: load 1 byte, broadcast to all 16 lanes -/
def v128Load8Splat {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 8 (by omega)).map fun v => V128.splat Shape.i8x16 v

/-- `v128.load16_splat`: load 2 bytes, broadcast to all 8 lanes -/
def v128Load16Splat {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 16 (by omega)).map fun v => V128.splat Shape.i16x8 v

/-- `v128.load32_splat`: load 4 bytes, broadcast to all 4 lanes -/
def v128Load32Splat {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 32 (by omega)).map fun v => V128.splat Shape.i32x4 v

/-- `v128.load64_splat`: load 8 bytes, broadcast to both lanes -/
def v128Load64Splat {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun v => V128.splat Shape.i64x2 v

-- === v128.load_zero ===

/-- `v128.load32_zero`: load 32 bits into lane 0, zero other lanes -/
def v128Load32Zero {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 32 (by omega)).map fun v => BitVec.zeroExtend 128 v

/-- `v128.load64_zero`: load 64 bits into lane 0, zero other lanes -/
def v128Load64Zero {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun v => BitVec.zeroExtend 128 v

-- === v128.load_lane ===

/-- `v128.load8_lane`: load 1 byte into specified lane, keep other lanes -/
def v128Load8Lane {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (v : V128) (lane : Fin 16) : Option V128 :=
  (loadN mem addr 8 (by omega)).map fun byte =>
    V128.replaceLane Shape.i8x16 v lane byte

/-- `v128.load16_lane`: load 2 bytes into specified lane, keep other lanes -/
def v128Load16Lane {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (v : V128) (lane : Fin 8) : Option V128 :=
  (loadN mem addr 16 (by omega)).map fun hw =>
    V128.replaceLane Shape.i16x8 v lane hw

/-- `v128.load32_lane`: load 4 bytes into specified lane, keep other lanes -/
def v128Load32Lane {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (v : V128) (lane : Fin 4) : Option V128 :=
  (loadN mem addr 32 (by omega)).map fun w =>
    V128.replaceLane Shape.i32x4 v lane w

/-- `v128.load64_lane`: load 8 bytes into specified lane, keep other lanes -/
def v128Load64Lane {addrWidth : Nat} (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (v : V128) (lane : Fin 2) : Option V128 :=
  (loadN mem addr 64 (by omega)).map fun dw =>
    V128.replaceLane Shape.i64x2 v lane dw

end WasmNum.Memory.Load
