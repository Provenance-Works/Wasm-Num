import WasmNum.Integration.Profile
import WasmNum.Memory.Load.Scalar
import WasmNum.Memory.Load.Packed
import WasmNum.Memory.Load.SIMD
import WasmNum.Memory.Store.Scalar
import WasmNum.Memory.Store.Packed
import WasmNum.Memory.Store.SIMD
import WasmNum.Memory.Ops.Size
import WasmNum.Memory.Ops.Grow
import WasmNum.Memory.Ops.Fill
import WasmNum.Memory.Ops.Copy
import WasmNum.Memory.Ops.Init
import WasmNum.Memory.Memory64

/-!
# Integration Runtime

Top-level deterministic wrappers that compose load/store operations
with effective address calculation and bounds checking.
These mirror the Wasm instruction semantics:
  base + offset → effective address → bounds check → load/store.

Also provides convenience re-exports for runtime usage.

Wasm spec: Section 4.4.7 "Memory Instructions" full instruction semantics
- FR-519: Integration Runtime
-/

set_option autoImplicit false

namespace WasmNum.Integration

open WasmNum
open WasmNum.Memory
open WasmNum.Memory.Load
open WasmNum.Memory.Store
open WasmNum.Memory.Ops

-- === Instruction-level load wrappers (base + offset → result) ===

/-- `i32.load` instruction: compute effective address, bounds check, load.
    Returns `none` on address overflow or out-of-bounds access. -/
def i32LoadInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I32 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i32Load mem addr

/-- `i64.load` instruction -/
def i64LoadInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I64 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Load mem addr

/-- `f32.load` instruction -/
def f32LoadInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option F32 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => f32Load mem addr

/-- `f64.load` instruction -/
def f64LoadInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option F64 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => f64Load mem addr

/-- `v128.load` instruction -/
def v128LoadInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load mem addr

-- === Instruction-level store wrappers ===

/-- `i32.store` instruction -/
def i32StoreInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : I32)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i32Store mem addr val

/-- `i64.store` instruction -/
def i64StoreInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : I64)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Store mem addr val

/-- `f32.store` instruction -/
def f32StoreInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : F32)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => f32Store mem addr val

/-- `f64.store` instruction -/
def f64StoreInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : F64)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => f64Store mem addr val

/-- `v128.store` instruction -/
def v128StoreInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : V128)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Store mem addr val

-- === memory.grow instruction ===

/-- `memory.grow` instruction: returns old page count on success, or -1 (as max value) on failure.
    Wasm spec: push old size on success, -1 on failure -/
def memoryGrowInstr {addrWidth : Nat} [GrowthPolicy addrWidth]
    (mem : FlatMemory addrWidth) (deltaPages : Nat)
    : (Option (FlatMemory addrWidth)) × Int :=
  match growExec mem deltaPages with
  | .success mem' oldPages => (some mem', oldPages)
  | .failure => (none, -1)

-- === memory.size instruction ===

/-- `memory.size` instruction: returns current page count -/
def memorySizeInstr {addrWidth : Nat} (mem : FlatMemory addrWidth) : Nat :=
  memorySize mem

-- === Instruction-level packed load wrappers ===

/-- `i32.load8_s` instruction -/
def i32Load8SInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I32 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i32Load8S mem addr

/-- `i32.load8_u` instruction -/
def i32Load8UInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I32 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i32Load8U mem addr

/-- `i32.load16_s` instruction -/
def i32Load16SInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I32 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i32Load16S mem addr

/-- `i32.load16_u` instruction -/
def i32Load16UInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I32 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i32Load16U mem addr

/-- `i64.load8_s` instruction -/
def i64Load8SInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I64 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Load8S mem addr

/-- `i64.load8_u` instruction -/
def i64Load8UInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I64 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Load8U mem addr

/-- `i64.load16_s` instruction -/
def i64Load16SInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I64 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Load16S mem addr

/-- `i64.load16_u` instruction -/
def i64Load16UInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I64 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Load16U mem addr

/-- `i64.load32_s` instruction -/
def i64Load32SInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I64 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Load32S mem addr

/-- `i64.load32_u` instruction -/
def i64Load32UInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option I64 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Load32U mem addr

-- === Instruction-level packed store wrappers ===

/-- `i32.store8` instruction -/
def i32Store8Instr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : I32)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i32Store8 mem addr val

/-- `i32.store16` instruction -/
def i32Store16Instr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : I32)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i32Store16 mem addr val

/-- `i64.store8` instruction -/
def i64Store8Instr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : I64)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Store8 mem addr val

/-- `i64.store16` instruction -/
def i64Store16Instr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : I64)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Store16 mem addr val

/-- `i64.store32` instruction -/
def i64Store32Instr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (val : I64)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => i64Store32 mem addr val

-- === Instruction-level SIMD load wrappers ===

/-- `v128.load8x8_s` instruction -/
def v128Load8x8SInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load8x8S mem addr

/-- `v128.load8x8_u` instruction -/
def v128Load8x8UInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load8x8U mem addr

/-- `v128.load16x4_s` instruction -/
def v128Load16x4SInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load16x4S mem addr

/-- `v128.load16x4_u` instruction -/
def v128Load16x4UInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load16x4U mem addr

/-- `v128.load32x2_s` instruction -/
def v128Load32x2SInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load32x2S mem addr

/-- `v128.load32x2_u` instruction -/
def v128Load32x2UInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load32x2U mem addr

/-- `v128.load8_splat` instruction -/
def v128Load8SplatInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load8Splat mem addr

/-- `v128.load16_splat` instruction -/
def v128Load16SplatInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load16Splat mem addr

/-- `v128.load32_splat` instruction -/
def v128Load32SplatInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load32Splat mem addr

/-- `v128.load64_splat` instruction -/
def v128Load64SplatInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load64Splat mem addr

/-- `v128.load32_zero` instruction -/
def v128Load32ZeroInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load32Zero mem addr

/-- `v128.load64_zero` instruction -/
def v128Load64ZeroInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load64Zero mem addr

/-- `v128.load8_lane` instruction -/
def v128Load8LaneInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (v : V128) (lane : Fin 16) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load8Lane mem addr v lane

/-- `v128.load16_lane` instruction -/
def v128Load16LaneInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (v : V128) (lane : Fin 8) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load16Lane mem addr v lane

/-- `v128.load32_lane` instruction -/
def v128Load32LaneInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (v : V128) (lane : Fin 4) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load32Lane mem addr v lane

/-- `v128.load64_lane` instruction -/
def v128Load64LaneInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (v : V128) (lane : Fin 2) : Option V128 :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Load64Lane mem addr v lane

-- === Instruction-level SIMD store wrappers ===

/-- `v128.store8_lane` instruction -/
def v128Store8LaneInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (v : V128) (lane : Fin 16)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Store8Lane mem addr v lane

/-- `v128.store16_lane` instruction -/
def v128Store16LaneInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (v : V128) (lane : Fin 8)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Store16Lane mem addr v lane

/-- `v128.store32_lane` instruction -/
def v128Store32LaneInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (v : V128) (lane : Fin 4)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Store32Lane mem addr v lane

/-- `v128.store64_lane` instruction -/
def v128Store64LaneInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (base : BitVec addrWidth) (offset : Nat) (v : V128) (lane : Fin 2)
    : Option (FlatMemory addrWidth) :=
  match effectiveAddr base offset with
  | none => none
  | some addr => v128Store64Lane mem addr v lane

-- === memory.fill instruction ===

/-- `memory.fill` instruction: fill `len` bytes starting at `dst` with `val`.
    Returns `none` (trap) if the region exceeds memory bounds. -/
def memoryFillInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst : BitVec addrWidth) (val : BitVec 8) (len : BitVec addrWidth)
    : Option (FlatMemory addrWidth) :=
  fill mem dst val len

-- === memory.copy instruction ===

/-- `memory.copy` instruction: copy `len` bytes from `src` to `dst`.
    Handles overlapping regions correctly.
    Returns `none` (trap) if either region exceeds memory bounds. -/
def memoryCopyInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst src : BitVec addrWidth) (len : BitVec addrWidth)
    : Option (FlatMemory addrWidth) :=
  copy mem dst src len

-- === memory.init instruction ===

/-- `memory.init` instruction: copy from data segment into memory.
    Returns `none` (trap) if segment is dropped or regions exceed bounds. -/
def memoryInitInstr {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst : BitVec addrWidth) (seg : DataSegment) (srcOffset : Nat) (len : Nat)
    : Option (FlatMemory addrWidth) :=
  init mem dst seg srcOffset len

-- === data.drop instruction ===

/-- `data.drop` instruction: drop a data segment so it cannot be used again. -/
def dataDropInstr (seg : DataSegment) : DataSegment :=
  dataDrop seg

end WasmNum.Integration
