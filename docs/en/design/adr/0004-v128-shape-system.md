# ADR-0004: V128 Shape System for SIMD

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2025 |
| **Deciders** | wasm-num maintainers |

## Context

WebAssembly SIMD operates on 128-bit vectors (`v128`) that can be interpreted as different lane configurations:

- i8x16 (16 lanes of 8-bit integers)
- i16x8 (8 lanes of 16-bit integers)
- i32x4 (4 lanes of 32-bit integers)
- i64x2 (2 lanes of 64-bit integers)
- f32x4 (4 lanes of 32-bit floats)
- f64x2 (2 lanes of 64-bit floats)

Many SIMD operations (add, sub, compare, etc.) work identically across shapes — only the lane width differs. We need a way to share this logic.

## Decision

Define a `Shape` structure that constrains `laneWidth × laneCount = 128`:

```lean
structure Shape where
  laneWidth : Nat
  laneCount : Nat
  laneType  : LaneType
  valid     : laneWidth * laneCount = 128
  widthPow2 : ∃ k, laneWidth = 2 ^ k ∧ 3 ≤ k ∧ k ≤ 6
```

SIMD operations take `Shape` as a parameter and use `mapLanes` / `zipLanes` for lanewise lifting:

```lean
def add (s : Shape) (a b : V128) : V128 := zipLanes s iadd a b
```

## Consequences

### Positive
- One implementation per operation, works for all 6 shapes
- Lane width constraint is machine-checked (can't create invalid shapes)
- `laneType` distinguishes integer from float shapes at the type level
- Compact — 6 concrete shapes defined as constants, not 6 separate implementations

### Negative
- Shape parameter adds a level of indirection
- Some operations are shape-specific (e.g., `popcnt_i8x16`) and can't be generalized

### Neutral
- `Shape.all : List Shape` enumerates all valid shapes for exhaustive testing
- Relaxed SIMD uses shapes for lanewise operations too

## Alternatives Considered

### Separate Types per Shape
Define `I8x16`, `I16x8`, etc. as distinct types. Rejected: massive code duplication (every lanewise operation × 6 shapes).

### Fin-indexed Vectors
Use `Vector (BitVec laneWidth) laneCount`. Rejected: converting between `V128` and `Vector` adds overhead; the shape system keeps everything as `BitVec 128` with extraction functions.

### Type-level Shape Encoding
Use dependent types to encode shape info in the type. Rejected: unnecessary complexity; runtime `Shape` parameter is simpler and sufficient.
