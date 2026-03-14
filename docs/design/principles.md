# Design Principles

> **Audience**: All

Core design principles guiding wasm-num's architecture and implementation.

## 1. Spec as Source of Truth

Every definition in wasm-num corresponds directly to a concept in the [WebAssembly specification](https://webassembly.github.io/spec/core/). Naming, structure, and behavior match the spec as closely as Lean 4's type system allows.

- Module boundaries follow spec sections (numerics, memory, SIMD)
- Function names derive from spec instruction names (`iadd`, `fmin`, `truncSatF32ToI32S`)
- Non-determinism is preserved where the spec allows it, not silently resolved

## 2. BitVec N as Universal Currency

All WebAssembly numeric values — integers, floats, SIMD vectors — are represented as `BitVec N`. This avoids separate type hierarchies and enables natural composition: the same `BitVec 32` is an `I32` when used with integer ops and an `F32` when used with float ops.

See [ADR-002](adr/0002-bitvec-universal-representation.md).

## 3. Abstraction at External Boundaries, Concrete Internally

Typeclasses are used only where the spec mandates implementation variability:

- **WasmFloat** — IEEE 754 operations (implementation-defined precision details)
- **GrowthPolicy** — `memory.grow` success/failure (implementation-defined)
- **Profiles** — NaN selection, relaxed SIMD behavior (host-defined)

All other operations are concrete functions on `BitVec N`. No unnecessary abstraction.

## 4. Non-determinism as First-Class Sets

Where the WebAssembly spec allows multiple valid behaviors, wasm-num returns `Set α` — the complete set of spec-conforming values. This design:

- Preserves specification completeness (no premature narrowing)
- Enables proof reasoning about all possible behaviors
- Allows deterministic instantiation via profiles

See [ADR-003](adr/0003-nondeterminism-as-sets.md).

## 5. Proof Separation

Definitions and proofs live in separate files and build targets. This ensures:

- `lake build WasmNum` compiles fast (no proof checking)
- Definitions are readable without proof clutter
- Proof changes never require rebuilding definitions
- Users who only need definitions don't pay the proof cost

See [ADR-006](adr/0006-proof-separation.md).

## 6. Pure Lean — No FFI

wasm-num is 100% pure Lean 4. No C FFI, no system calls, no IO. This guarantees:

- Complete formal verification (no unverified escape hatches)
- Portability (no native dependencies)
- Reproducibility (no platform-dependent behavior)

See [ADR-007](adr/0007-no-c-ffi.md).

## 7. Layered Architecture

Strict 5-layer hierarchy (Foundation → Numerics → SIMD → Memory → Integration) with no cross-layer back-dependencies. Each layer can be understood, built, and tested independently.

## 8. Mathlib as Foundation

wasm-num builds on Mathlib's `BitVec`, `Finset`, and algebraic infrastructure. This avoids reinventing fundamentals and enables reuse of Mathlib's thousands of existing theorems.

## See Also

- [Trade-offs](trade-offs.md) — costs of these principles
- [Patterns](patterns.md) — how principles manifest in code
- [ADRs](adr/) — formal decision records
