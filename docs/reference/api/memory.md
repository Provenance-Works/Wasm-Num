# Memory API Reference

> **Module**: `WasmNum.Memory`
> **Source**: `WasmNum/Memory/`

## Page Model

> **Source**: `WasmNum/Memory/Core/Page.lean`

| Definition | Value | Description |
|------------|-------|-------------|
| `pageSize` | `65536` | Wasm page size: 64 KiB |
| `maxPages 32` | `65536` | Max pages for Memory32 (4 GiB) |
| `maxPages 64` | `281474976710656` | Max pages for Memory64 (2^48; 16 EiB) |

**Theorems**: `pageSize_pos`, `maxPages_32`, `maxPages_64`.

---

## FlatMemory

> **Source**: `WasmNum/Memory/Core/FlatMemory.lean`

```lean
structure FlatMemory (addrWidth : Nat) where
  data      : ByteArray
  pageCount : Nat
  maxLimit  : Option Nat
  inv_dataSize : data.size = pageCount * pageSize
  inv_maxValid : ∀ max, maxLimit = some max → pageCount ≤ max
  inv_addrFits : pageCount * pageSize ≤ 2 ^ addrWidth
  inv_maxFits  : ∀ max, maxLimit = some max → max * pageSize ≤ 2 ^ addrWidth
```

| Alias | Definition |
|-------|-----------|
| `Memory32` | `FlatMemory 32` |
| `Memory64` | `FlatMemory 64` |

### Construction

| Function | Signature | Description |
|----------|-----------|-------------|
| `FlatMemory.empty` | `(addrWidth : Nat) → (maxLimit : Option Nat) → FlatMemory addrWidth` | Create 0-page memory |
| `Memory32.empty` | `Memory32` | Empty 32-bit memory |
| `Memory64.empty` | `Memory64` | Empty 64-bit memory |

### Low-Level Access

| Function | Signature | Description |
|----------|-----------|-------------|
| `readByte` | `FlatMemory addrWidth → Nat → Option (BitVec 8)` | Read single byte |
| `writeByte` | `FlatMemory addrWidth → Nat → BitVec 8 → Option (FlatMemory addrWidth)` | Write single byte |
| `readLittleEndian` | `FlatMemory addrWidth → Nat → (N : Nat) → Option (BitVec N)` | Read N bits (LE) |
| `writeLittleEndian` | `FlatMemory addrWidth → Nat → (N : Nat) → BitVec N → Option (FlatMemory addrWidth)` | Write N bits (LE) |

**Theorems**: `readByte_writeByte_same`, `readByte_writeByte_ne`.

---

## Address

> **Source**: `WasmNum/Memory/Core/Address.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `effectiveAddr` | `BitVec addrWidth → Nat → Option (BitVec addrWidth)` | `base + offset`, none on overflow |

**Theorem**: `effectiveAddr_toNat`.

---

## Bounds

> **Source**: `WasmNum/Memory/Core/Bounds.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `inBounds` | `FlatMemory addrWidth → BitVec addrWidth → Nat → Prop` | Access is in bounds |
| `inBoundsB` | `... → Bool` | Decidable version |
| `effectiveInBounds` | `FlatMemory addrWidth → BitVec addrWidth → Nat → Nat → Prop` | Address + bounds combined |
| `effectiveInBoundsB` | `... → Bool` | Decidable version |

---

## Load Scalar

> **Source**: `WasmNum/Memory/Load/Scalar.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `loadN` | `FlatMemory addrWidth → BitVec addrWidth → (N : Nat) → Option (BitVec N)` | Generic N-bit load |
| `i32Load` | `... → Option I32` | Load 32-bit integer |
| `i64Load` | `... → Option I64` | Load 64-bit integer |
| `f32Load` | `... → Option F32` | Load 32-bit float |
| `f64Load` | `... → Option F64` | Load 64-bit float |

---

## Load Packed

> **Source**: `WasmNum/Memory/Load/Packed.lean`

Sub-width loads with sign or zero extension:

| Function | Loads | Extends to | Extension |
|----------|:-----:|:----------:|-----------|
| `i32Load8S` / `i32Load8U` | 8 bits | 32 | signed / unsigned |
| `i32Load16S` / `i32Load16U` | 16 bits | 32 | signed / unsigned |
| `i64Load8S` / `i64Load8U` | 8 bits | 64 | signed / unsigned |
| `i64Load16S` / `i64Load16U` | 16 bits | 64 | signed / unsigned |
| `i64Load32S` / `i64Load32U` | 32 bits | 64 | signed / unsigned |

---

## Load SIMD

> **Source**: `WasmNum/Memory/Load/SIMD.lean`

| Function | Description |
|----------|-------------|
| `v128Load` | Full 128-bit load |
| `v128Load8x8S` / `v128Load8x8U` | Load 8 bytes, extend to i16x8 |
| `v128Load16x4S` / `v128Load16x4U` | Load 4 halfwords, extend to i32x4 |
| `v128Load32x2S` / `v128Load32x2U` | Load 2 words, extend to i64x2 |
| `v128Load8Splat` / `v128Load16Splat` / `v128Load32Splat` / `v128Load64Splat` | Load and replicate to all lanes |
| `v128Load32Zero` / `v128Load64Zero` | Load into low lane, zero others |
| `v128Load8Lane` / `v128Load16Lane` / `v128Load32Lane` / `v128Load64Lane` | Load into specific lane |

---

## Store Scalar

> **Source**: `WasmNum/Memory/Store/Scalar.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `storeN` | `FlatMemory addrWidth → BitVec addrWidth → BitVec N → Option (FlatMemory addrWidth)` | Generic N-bit store |
| `i32Store` | `... → I32 → Option (FlatMemory addrWidth)` | Store 32-bit |
| `i64Store` | `... → I64 → ...` | Store 64-bit |
| `f32Store` / `f64Store` | `... → F32/F64 → ...` | Store float |

---

## Store Packed

> **Source**: `WasmNum/Memory/Store/Packed.lean`

| Function | Stores | Description |
|----------|:------:|-------------|
| `i32Store8` | low 8 bits | Truncating i32 store |
| `i32Store16` | low 16 bits | Truncating i32 store |
| `i64Store8` | low 8 bits | Truncating i64 store |
| `i64Store16` | low 16 bits | Truncating i64 store |
| `i64Store32` | low 32 bits | Truncating i64 store |

---

## Store SIMD

> **Source**: `WasmNum/Memory/Store/SIMD.lean`

| Function | Description |
|----------|-------------|
| `v128Store` | Full 128-bit store |
| `v128Store8Lane` / `v128Store16Lane` / `v128Store32Lane` / `v128Store64Lane` | Store specific lane |

---

## memory.size

> **Source**: `WasmNum/Memory/Ops/Size.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `memorySize` | `FlatMemory addrWidth → Nat` | Returns current page count |

---

## memory.grow

> **Source**: `WasmNum/Memory/Ops/Grow.lean`

### `GrowResult`

```lean
inductive GrowResult (addrWidth : Nat) where
  | success : FlatMemory addrWidth → Nat → GrowResult addrWidth
  | failure : GrowResult addrWidth
```

### Spec-Level (Non-deterministic)

| Function | Signature | Description |
|----------|-----------|-------------|
| `growSpec` | `FlatMemory addrWidth → Nat → Set (GrowResult addrWidth)` | Spec-allowed result set |

**Theorem**: `growSpec_failure_mem` — failure is always in the allowed set.

### Deterministic

```lean
class GrowthPolicy (addrWidth : Nat) where
  chooseGrow     : FlatMemory addrWidth → Nat → GrowResult addrWidth
  chooseGrow_mem : ∀ mem deltaPages, chooseGrow mem deltaPages ∈ growSpec mem deltaPages
```

| Function | Signature | Description |
|----------|-----------|-------------|
| `growExec` | `[GrowthPolicy addrWidth] → FlatMemory addrWidth → Nat → GrowResult addrWidth` | Deterministic grow |

---

## memory.fill

> **Source**: `WasmNum/Memory/Ops/Fill.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `fill` | `FlatMemory addrWidth → BitVec addrWidth → BitVec 8 → BitVec addrWidth → Option (FlatMemory addrWidth)` | Fill `len` bytes starting at `dst` with `val`. None if OOB. |

---

## memory.copy

> **Source**: `WasmNum/Memory/Ops/Copy.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `copy` | `FlatMemory addrWidth → BitVec addrWidth → BitVec addrWidth → BitVec addrWidth → Option (FlatMemory addrWidth)` | Copy `len` bytes from `src` to `dst`. Overlap-safe (chooses direction). None if OOB. |

---

## memory.init

> **Source**: `WasmNum/Memory/Ops/Init.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `init` | `FlatMemory addrWidth → BitVec addrWidth → DataSegment → Nat → Nat → Option (FlatMemory addrWidth)` | Copy from data segment to memory. None if segment dropped or OOB. |

---

## DataDrop

> **Source**: `WasmNum/Memory/Ops/DataDrop.lean`

```lean
inductive DataSegment where
  | available : ByteArray → DataSegment
  | dropped   : DataSegment
```

| Function | Signature | Description |
|----------|-----------|-------------|
| `dataDrop` | `DataSegment → DataSegment` | Always returns `.dropped` |
| `DataSegment.bytes` | `DataSegment → Option ByteArray` | Get bytes if available |
| `DataSegment.isDropped` | `DataSegment → Bool` | Check if dropped |

---

## MultiMemory

> **Source**: `WasmNum/Memory/MultiMemory.lean`

```lean
inductive MemoryInstance where
  | mem32 : FlatMemory 32 → MemoryInstance
  | mem64 : FlatMemory 64 → MemoryInstance

inductive MemoryAddress where
  | addr32 : BitVec 32 → MemoryAddress
  | addr64 : BitVec 64 → MemoryAddress

structure MemoryStore where
  memories : Array MemoryInstance
```

| Function | Signature | Description |
|----------|-----------|-------------|
| `MemoryStore.get` | `MemoryStore → Nat → Option MemoryInstance` | Get memory by index |
| `MemoryStore.set` | `MemoryStore → Nat → MemoryInstance → Option MemoryStore` | Set memory by index |

---

## Memory64

> **Source**: `WasmNum/Memory/Memory64.lean`

64-bit address space support. `Memory64 = FlatMemory 64` with `maxPages 64 = 2^48`.

## Related

- [Foundation API](foundation.md) — core types
- [SIMD API](simd.md) — SIMD load/store
- [Integration API](integration.md) — instruction-level wrappers
- [Architecture: Data Flow](../../architecture/data-flow.md) — load/store flow diagrams
- [ADR-005: Parameterized Address Width](../../design/adr/0005-flatmemory-parameterized-address-width.md)
