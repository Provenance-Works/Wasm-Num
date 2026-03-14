# Architecture Decision Records

> **Audience**: All

Architecture Decision Records (ADRs) document significant design decisions in wasm-num—their context, the decision made, and consequences.

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-typeclass-mediated-754-independence.md) | IEEE 754 Independence via WasmFloat Typeclass | Accepted | 2025 |
| [0002](0002-bitvec-universal-representation.md) | BitVec N as Universal Representation | Accepted | 2025 |
| [0003](0003-nondeterminism-as-sets.md) | Non-determinism Modeled as Set α | Accepted | 2025 |
| [0004](0004-v128-shape-system.md) | V128 Shape System for SIMD | Accepted | 2025 |
| [0005](0005-flatmemory-parameterized-address-width.md) | FlatMemory Parameterized by Address Width | Accepted | 2025 |
| [0006](0006-proof-separation.md) | Strict Separation of Definitions and Proofs | Accepted | 2025 |
| [0007](0007-no-c-ffi.md) | No C FFI — Pure Lean Only | Accepted | 2025 |

## Template

See [template.md](template.md) for the ADR template used by this project.

## See Also

- [Design Principles](../principles.md)
- [Trade-offs](../trade-offs.md)
- [Architecture Overview](../../architecture/)
