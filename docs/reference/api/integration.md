# Integration API Reference

> **Module**: `WasmNum.Integration`
> **Source**: `WasmNum/Integration/`

## DeterministicWasmProfile

> **Source**: `WasmNum/Integration/Profile.lean`

Extends `WasmProfile` with proofs that every deterministic choice belongs to the spec-allowed set:

```lean
structure DeterministicWasmProfile [WasmFloat 32] [WasmFloat 64] extends WasmProfile where
  -- NaN selection
  selectNaN_mem : ∀ N [WasmFloat N] inputs,
    nanProfile.selectNaN N inputs ∈ nansN N inputs

  -- Relaxed SIMD membership proofs
  relaxedMadd_mem       : ∀ a b c, relaxedProfile.relaxedMaddImpl a b c ∈ Relaxed.madd Shape.f32x4 a b c
  relaxedNmadd_mem      : ∀ a b c, ...
  relaxedMaddF64_mem    : ∀ a b c, ...
  relaxedNmaddF64_mem   : ∀ a b c, ...
  relaxedMinF32_mem     : ∀ a b, ...
  relaxedMaxF32_mem     : ∀ a b, ...
  relaxedMinF64_mem     : ∀ a b, ...
  relaxedMaxF64_mem     : ∀ a b, ...
  relaxedSwizzle_mem    : ∀ v idx, ...
  relaxedTruncF32x4S_mem : ∀ v, ...
  relaxedTruncF32x4U_mem : ∀ v, ...
  relaxedTruncF64x2SZero_mem : ∀ v, ...
  relaxedTruncF64x2UZero_mem : ∀ v, ...
  relaxedLaneselect_mem : ∀ a b mask, ...
  relaxedDot_mem        : ∀ a b, ...
  relaxedDotAdd_mem     : ∀ a b acc, ...
  relaxedQ15MulrS_mem   : ∀ a b, ...
```

Each field carries a proof `∈ <Set-returning function>`, guaranteeing the deterministic implementation is a valid specialization of the non-deterministic spec.

---

## Runtime Wrappers

> **Source**: `WasmNum/Integration/Runtime.lean`

Deterministic instruction-level wrappers that compose effective address calculation, bounds checking, and load/store operations.

### Scalar Load Instructions

| Function | Signature | Description |
|----------|-----------|-------------|
| `i32LoadInstr` | `FlatMemory addrWidth → BitVec addrWidth → Nat → Option I32` | `i32.load` with addr+offset+bounds |
| `i64LoadInstr` | same pattern | `i64.load` |
| `f32LoadInstr` | same pattern | `f32.load` |
| `f64LoadInstr` | same pattern | `f64.load` |
| `v128LoadInstr` | same pattern | `v128.load` |

### Scalar Store Instructions

| Function | Signature | Description |
|----------|-----------|-------------|
| `i32StoreInstr` | `FlatMemory addrWidth → BitVec addrWidth → Nat → I32 → Option (FlatMemory addrWidth)` | `i32.store` |
| `i64StoreInstr` | same pattern | `i64.store` |
| `f32StoreInstr` | same pattern | `f32.store` |
| `f64StoreInstr` | same pattern | `f64.store` |
| `v128StoreInstr` | same pattern | `v128.store` |

### Packed Load Instructions

| Function | Loads | Extends | Extension |
|----------|:-----:|:-------:|-----------|
| `i32Load8SInstr` / `i32Load8UInstr` | 8 bits | 32 | signed / unsigned |
| `i32Load16SInstr` / `i32Load16UInstr` | 16 bits | 32 | signed / unsigned |
| `i64Load8SInstr` / `i64Load8UInstr` | 8 bits | 64 | signed / unsigned |
| `i64Load16SInstr` / `i64Load16UInstr` | 16 bits | 64 | signed / unsigned |
| `i64Load32SInstr` / `i64Load32UInstr` | 32 bits | 64 | signed / unsigned |

### Packed Store Instructions

| Function | Description |
|----------|-------------|
| `i32Store8Instr` / `i32Store16Instr` | Truncating i32 store |
| `i64Store8Instr` / `i64Store16Instr` / `i64Store32Instr` | Truncating i64 store |

### Memory Instructions

| Function | Signature | Description |
|----------|-----------|-------------|
| `memoryGrowInstr` | `[GrowthPolicy addrWidth] → FlatMemory addrWidth → Nat → (Option (FlatMemory addrWidth), Int)` | Grow: returns (new mem, old pages) or (none, -1) |
| `memorySizeInstr` | `FlatMemory addrWidth → Nat` | Current page count |
| `memoryFillInstr` | `FlatMemory addrWidth → BitVec addrWidth → BitVec 8 → BitVec addrWidth → Option (FlatMemory addrWidth)` | Fill bytes |
| `memoryCopyInstr` | `FlatMemory addrWidth → BitVec addrWidth → BitVec addrWidth → BitVec addrWidth → Option (FlatMemory addrWidth)` | Copy bytes (overlap-safe) |
| `memoryInitInstr` | `FlatMemory addrWidth → BitVec addrWidth → DataSegment → Nat → Nat → Option (FlatMemory addrWidth)` | Init from data segment |

## Related

- [Foundation API](foundation.md) — profiles and types
- [Memory API](memory.md) — underlying operations
- [Architecture: Data Flow](../../architecture/data-flow.md) — runtime flow diagrams
- [Design Principles](../../design/principles.md)
