# ADR-0001: IEEE 754 Independence via WasmFloat Typeclass

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2025 |
| **Deciders** | wasm-num maintainers |

## Context

WebAssembly numeric semantics depend on IEEE 754 floating-point operations (add, sub, mul, div, sqrt, comparisons, rounding, classification). However:

- Lean 4 has no built-in IEEE 754 type with bit-exact semantics
- Mathlib's `Float` is platform-dependent and unsuitable for formal reasoning
- Different users may want different float implementations (software, hardware via FFI, verified libraries)
- The project must be able to reason about Wasm semantics *independent* of any specific float library

## Decision

Define a `WasmFloat N` typeclass that specifies the interface for IEEE 754 operations at width `N`:

```lean
class WasmFloat (N : Nat) where
  isNaN : BitVec N → Bool
  add : BitVec N → BitVec N → BitVec N
  sub : BitVec N → BitVec N → BitVec N
  mul : BitVec N → BitVec N → BitVec N
  div : BitVec N → BitVec N → BitVec N
  sqrt : BitVec N → BitVec N
  -- ... classification, comparison, rounding, conversion methods
  -- Structural proofs (e.g., isNaN_canonicalNaN)
```

All Wasm numeric operations that need floating-point take `[WasmFloat N]` as an instance argument. A default stub instance is provided for testing (classification correct, arithmetic returns canonical NaN).

## Consequences

### Positive
- wasm-num's correctness does not depend on any specific float library
- Users can plug in verified implementations (e.g., Flocq, Berkeley SoftFloat bindings)
- Proofs about Wasm semantics are parametric over *any* conforming float implementation
- Default stub enables testing of non-float-dependent code paths

### Negative
- Default stub cannot test actual float arithmetic correctness
- Users must supply their own `WasmFloat 32` and `WasmFloat 64` instances for production
- Typeclass resolution adds complexity

### Neutral
- Companion typeclasses `WasmFloatPromote` and `WasmFloatDemote` handle f32↔f64 conversions

## Alternatives Considered

### Direct IEEE 754 Implementation in Lean
Build a complete software float library in Lean 4. Rejected: massive effort, orthogonal to Wasm semantics, better done as a separate project.

### Lean 4 Native Float
Use `Float` (platform-dependent). Rejected: not bit-exact, not portable, no formal reasoning support.

### Module Functor / Parameterized Module
Thread a float module through all operations explicitly. Rejected: extremely verbose compared to typeclass inference.
