# ADR-0003: Non-determinism Modeled as Set α

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2025 |
| **Deciders** | wasm-num maintainers |

## Context

The WebAssembly specification contains several sources of non-determinism:

1. **NaN propagation** — When a float operation has NaN inputs, the result can be any NaN from a specified set (`nans_N`)
2. **Relaxed SIMD** — Certain SIMD operations allow implementation-defined results (e.g., fused vs. unfused multiply-add)
3. **memory.grow** — Implementations may return failure even when growth is possible

The formalization must represent these spec-allowed sets of valid results without prematurely choosing one.

## Decision

Use `Set α` (Lean 4: `α → Prop`) to represent the set of all valid outputs:

```lean
def fmin [WasmFloat N] (a b : BitVec N) : Set (BitVec N) := ...

def propagateNaN₂ (op : BitVec N → BitVec N → BitVec N)
  (a b : BitVec N) : Set (BitVec N) := ...

def growSpec (mem : FlatMemory addrWidth) (delta : Nat) : Set (GrowResult addrWidth) := ...
```

Deterministic instantiation is provided through profiles:

```lean
def propagateNaN₂_det (p : DeterministicWasmProfile) ... : BitVec N := ...
-- with proof: result ∈ propagateNaN₂ ...
```

## Consequences

### Positive
- Spec-complete representation — no information loss
- Natural proof reasoning — membership (`∈`) and set operations
- Clean separation: spec-level (Set) vs. runtime-level (deterministic)
- `DeterministicWasmProfile` proves correctness of any specific choice

### Negative
- Set-returning functions are not directly executable
- Composition of non-deterministic functions requires explicit set comprehension
- Slightly more complex API for users who only want deterministic behavior

### Neutral
- Integration layer provides deterministic wrappers for all Set-returning operations
- Test suite uses deterministic wrappers (can't `#guard` a Set)

## Alternatives Considered

### Nondeterminism Monad
`NondetM α = List α` or similar monad with `bind`. Rejected: over-engineering for this use case; `Set α` is simpler and more natural in Lean's type theory.

### Pick One (Always Canonical NaN)
Always return canonical NaN. Rejected: loses spec information, prevents proving properties about the full valid set.

### Angelic / Demonic Choice
Model non-determinism categorically. Rejected: unnecessary theoretical machinery for a concrete spec.
