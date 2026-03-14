# ADR-0002: BitVec N as Universal Representation

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2025 |
| **Deciders** | wasm-num maintainers |

## Context

WebAssembly has four numeric types (i32, i64, f32, f64) plus v128. At the bit level, integers and floats of the same width are interchangeable — `reinterpret` instructions convert between them with no computation. The type system needs to handle:

- Operations that work on "any 32-bit value" (reinterpret, memory load/store)
- Operations specific to integer interpretation (shifts, div)
- Operations specific to float interpretation (fmin, sqrt)
- SIMD vectors that pack multiple lanes of any type

## Decision

Represent all WebAssembly numeric types as `BitVec N` aliases:

```lean
abbrev I32  := BitVec 32
abbrev I64  := BitVec 64
abbrev F32  := BitVec 32
abbrev F64  := BitVec 64
abbrev V128 := BitVec 128
abbrev Byte := BitVec 8
```

The *interpretation* of a bit pattern is determined by which operations are applied to it, not by its type. `reinterpret` is the identity function.

## Consequences

### Positive
- `reinterpretI32AsF32` is literally `id` — zero cost, zero proof burden
- Memory load/store work uniformly on `BitVec N` — no wrapping/unwrapping
- Mathlib's `BitVec` theorems apply directly to all Wasm numeric types
- Simple, small type universe — easy to reason about

### Negative
- No compile-time prevention of applying integer ops to float-intended values
- Type signatures don't distinguish I32 from F32 (both are `BitVec 32`)
- Requires discipline to apply the correct operations

### Neutral
- SIMD V128 is `BitVec 128` — lane extraction uses the Shape system (ADR-004)
- The lack of type distinction mirrors the spec's value-level treatment

## Alternatives Considered

### Wrapper Types (newtype pattern)
Define `structure I32 := (val : BitVec 32)` etc. Rejected: overwhelming conversion boilerplate, especially for memory operations and reinterpret. The spec doesn't distinguish at the value level.

### Sum Type for Wasm Values
Define `inductive WasmValue := | i32 : I32 → ... | f32 : F32 → ...`. Rejected: adds pattern matching overhead everywhere; inappropriate for a numerics library (each operation knows its types statically).

### Untyped Nat/Int
Use natural numbers or integers. Rejected: loses bit-width information, modular arithmetic semantics become manual.
