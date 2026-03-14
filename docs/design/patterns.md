# Design Patterns

> **Audience**: Developers

Design patterns used throughout wasm-num and the rationale behind each.

## 1. Typeclass Abstraction at Boundaries

**Pattern**: Use typeclasses for operations whose implementation may vary.

**Usage**: `WasmFloat N`, `GrowthPolicy addrWidth`

```lean
class WasmFloat (N : Nat) where
  add : BitVec N → BitVec N → BitVec N
  isNaN : BitVec N → Bool
  ...
```

**Rationale**: The WebAssembly spec defines behavior in terms of IEEE 754 but wasm-num must not depend on any specific float library. The typeclass lets users supply their own implementation while wasm-num reasons about the interface.

## 2. Set-returning Functions for Non-determinism

**Pattern**: Functions whose spec allows multiple valid outputs return `Set (BitVec N)`.

```lean
def fmin [WasmFloat N] (a b : BitVec N) : Set (BitVec N) := ...
```

**Rationale**: Preserves specification completeness. Proofs reason about all possible behaviors simultaneously. Deterministic wrappers select one element using profiles.

## 3. Profile-based Deterministic Instantiation

**Pattern**: Bundle implementation choices in a `WasmProfile` structure, then provide deterministic wrappers that pick concrete values from spec sets.

```lean
structure WasmProfile where
  nanProfile     : NaNProfile
  relaxedProfile : RelaxedProfile

def propagateNaN₂_det (p : DeterministicWasmProfile) ... : BitVec N := ...
```

**Rationale**: Decouples "what the spec allows" from "what this runtime does." Proof obligation: the deterministic choice ∈ the spec set.

## 4. Option for Trapping Operations

**Pattern**: Functions that can trap return `Option T`. `none` = trap.

```lean
def idiv_u (a b : BitVec N) : Option (BitVec N) :=
  if b == 0 then none else some (a / b)
```

**Rationale**: Simple, total, and composable. No exceptions or monads needed. The embedding runtime maps `none` to a Wasm trap.

## 5. Address Width Parameterization

**Pattern**: `FlatMemory` and all memory operations are parameterized by `addrWidth : Nat`.

```lean
structure FlatMemory (addrWidth : Nat) where ...

def i32Load (mem : FlatMemory addrWidth) (addr : BitVec addrWidth) : Option I32 := ...
```

**Rationale**: Supports both Memory32 (`addrWidth = 32`) and Memory64 (`addrWidth = 64`) with one code path. See [ADR-005](adr/0005-flatmemory-parameterized-address-width.md).

## 6. Shape-parameterized SIMD Operations

**Pattern**: SIMD operations take a `Shape` parameter describing how V128 is partitioned.

```lean
structure Shape where
  laneWidth : Nat
  laneCount : Nat
  valid     : laneWidth * laneCount = 128

def add (s : Shape) (a b : V128) : V128 := zipLanes s iadd a b
```

**Rationale**: One generic implementation handles all 6 concrete shapes (i8x16, i16x8, i32x4, i64x2, f32x4, f64x2). See [ADR-004](adr/0004-v128-shape-system.md).

## 7. Lanewise Lifting

**Pattern**: `mapLanes` and `zipLanes` lift scalar operations to lanewise SIMD operations.

```lean
def mapLanes (s : Shape) (f : BitVec s.laneWidth → BitVec s.laneWidth) (v : V128) : V128 := ...
def zipLanes (s : Shape) (f : BitVec s.laneWidth → BitVec s.laneWidth → BitVec s.laneWidth) (a b : V128) : V128 := ...
```

**Rationale**: Avoids duplicating every scalar operation for every SIMD shape. Scalar ops are proven correct once; lanewise lifting preserves correctness.

## 8. Invariant-carrying Structures

**Pattern**: Structures carry proof invariants alongside data.

```lean
structure FlatMemory (addrWidth : Nat) where
  data      : ByteArray
  pageCount : Nat
  inv_dataSize : data.size = pageCount * pageSize
  inv_addrFits : pageCount * pageSize ≤ 2 ^ addrWidth
```

**Rationale**: Impossible to construct invalid states. Proofs about memory operations can assume invariants without additional preconditions.

## 9. Proof Mirroring

**Pattern**: Proof files mirror the definition file hierarchy.

```
WasmNum/Numerics/Integer/Arithmetic.lean    → WasmNum/Proofs/Numerics/Integer/...
WasmNum/Memory/Core/FlatMemory.lean         → WasmNum/Proofs/Memory/FlatMemory.lean
```

**Rationale**: Easy to find proofs for any given definition. Build separation (definitions vs. proofs) is clean.

## See Also

- [Principles](principles.md) — why these patterns
- [Trade-offs](trade-offs.md) — costs and alternatives
- [Architecture](../architecture/) — where patterns are used
