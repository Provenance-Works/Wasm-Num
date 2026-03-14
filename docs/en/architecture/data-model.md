# Data Model

> **Audience**: Developers, Contributors

This document describes the core data types, structures, and their relationships in wasm-num.

## Type Universe

All WebAssembly numeric values are represented as `BitVec N` from Mathlib. This is ADR-002.

```mermaid
erDiagram
    BitVec ||--o{ I32 : "N = 32"
    BitVec ||--o{ I64 : "N = 64"
    BitVec ||--o{ F32 : "N = 32"
    BitVec ||--o{ F64 : "N = 64"
    BitVec ||--o{ V128 : "N = 128"
    BitVec ||--o{ Byte : "N = 8"
    BitVec ||--o{ Addr32 : "N = 32"
    BitVec ||--o{ Addr64 : "N = 64"

    WasmFloat ||--|| F32 : "instance for N=32"
    WasmFloat ||--|| F64 : "instance for N=64"

    Shape ||--|{ V128 : "interprets lanes"
    Shape {
        Nat laneWidth
        Nat laneCount
        LaneType laneType
        Proof valid "laneWidth * laneCount = 128"
    }

    LaneType {
        enum int
        enum float
    }

    FlatMemory {
        ByteArray data
        Nat pageCount
        OptionNat maxLimit
    }

    FlatMemory ||--o{ Memory32 : "addrWidth = 32"
    FlatMemory ||--o{ Memory64 : "addrWidth = 64"

    MemoryInstance ||--|| Memory32 : "mem32 variant"
    MemoryInstance ||--|| Memory64 : "mem64 variant"

    MemoryStore ||--|{ MemoryInstance : "contains array"

    DataSegment {
        variant available "ByteArray"
        variant dropped "unit"
    }

    GrowResult {
        variant success "FlatMemory + oldPageCount"
        variant failure "unit"
    }

    WasmProfile ||--|| NaNProfile : "contains"
    WasmProfile ||--|| RelaxedProfile : "contains"
    DeterministicWasmProfile ||--|| WasmProfile : "extends with proofs"

    NaNProfile {
        fn selectNaN "List BitVec → BitVec"
        proof selectNaN_isNaN
    }
```

## Core Type Aliases

All defined in `WasmNum/Foundation/Types.lean`:

```lean
abbrev I32   := BitVec 32    -- WebAssembly 32-bit integer
abbrev I64   := BitVec 64    -- WebAssembly 64-bit integer
abbrev F32   := BitVec 32    -- 32-bit float (bit-pattern)
abbrev F64   := BitVec 64    -- 64-bit float (bit-pattern)
abbrev V128  := BitVec 128   -- 128-bit SIMD vector
abbrev Byte  := BitVec 8     -- 8-bit value
abbrev Addr32 := BitVec 32   -- 32-bit memory address
abbrev Addr64 := BitVec 64   -- 64-bit memory address
```

> **Note:** `F32` and `I32` are the **same type** (`BitVec 32`). Interpretation as float vs. integer depends on which operations are applied. This matches Wasm's stack machine semantics.

## SIMD Shapes

The `Shape` structure constrains lane configurations with type-level proofs:

| Shape | Lane Width | Lane Count | Lane Type |
|-------|:----------:|:----------:|-----------|
| `i8x16` | 8 | 16 | int |
| `i16x8` | 16 | 8 | int |
| `i32x4` | 32 | 4 | int |
| `i64x2` | 64 | 2 | int |
| `f32x4` | 32 | 4 | float |
| `f64x2` | 64 | 2 | float |

Each shape carries proofs:
- `valid : laneWidth * laneCount = 128`
- `widthPow2 : ∃ k, laneWidth = 2 ^ k ∧ 3 ≤ k ∧ k ≤ 6`

## FlatMemory

The central memory structure, parameterized by address width:

```lean
structure FlatMemory (addrWidth : Nat) where
  data       : ByteArray
  pageCount  : Nat
  maxLimit   : Option Nat
  -- Invariants:
  inv_dataSize : data.size = pageCount * pageSize
  inv_maxValid : ∀ max, maxLimit = some max → pageCount ≤ max
  inv_addrFits : pageCount * pageSize ≤ 2 ^ addrWidth
  inv_maxFits  : ∀ max, maxLimit = some max → max * pageSize ≤ 2 ^ addrWidth
```

| Alias | Definition | Max Memory |
|-------|-----------|------------|
| `Memory32` | `FlatMemory 32` | 4 GiB (65536 pages) |
| `Memory64` | `FlatMemory 64` | 16 EiB (2^48 pages) |

## Profile Hierarchy

```mermaid
classDiagram
    class NaNProfile {
        +selectNaN(N, inputs) BitVec N
        +selectNaN_isNaN: proof
    }

    class RelaxedProfile {
        +relaxedMaddImpl(a, b, c) V128
        +relaxedNmaddImpl(a, b, c) V128
        +relaxedMinImpl32(a, b) BitVec 32
        +relaxedMaxImpl32(a, b) BitVec 32
        +relaxedSwizzleImpl(v, idx) V128
        +relaxedTruncF32x4SImpl(v) V128
        +relaxedLaneselectImpl(a, b, mask) V128
        +relaxedDotI8x16I7x16SImpl(a, b) V128
        +relaxedQ15MulrSImpl(a, b) V128
        ...14 fields total
    }

    class WasmProfile {
        +nanProfile: NaNProfile
        +relaxedProfile: RelaxedProfile
    }

    class DeterministicWasmProfile {
        +selectNaN_mem: ∈ nansN proof
        +relaxedMadd_mem: ∈ Relaxed.madd proof
        +relaxedSwizzle_mem: ∈ Relaxed.swizzle proof
        ...all membership proofs
    }

    WasmProfile *-- NaNProfile
    WasmProfile *-- RelaxedProfile
    DeterministicWasmProfile --|> WasmProfile : extends
```

## MultiMemory

```mermaid
classDiagram
    class MemoryStore {
        +memories: Array MemoryInstance
        +get(idx) Option MemoryInstance
        +set(idx, mem) Option MemoryStore
    }

    class MemoryInstance {
        <<enumeration>>
        mem32(FlatMemory 32)
        mem64(FlatMemory 64)
    }

    class MemoryAddress {
        <<enumeration>>
        addr32(BitVec 32)
        addr64(BitVec 64)
    }

    MemoryStore o-- MemoryInstance : contains
    MemoryInstance -- MemoryAddress : addressed by
```

## Related Documents

- [Architecture Overview](README.md)
- [Components](components.md)
- [Foundation API](../reference/api/foundation.md)
- [Memory API](../reference/api/memory.md)
- [Glossary](../reference/glossary.md)
