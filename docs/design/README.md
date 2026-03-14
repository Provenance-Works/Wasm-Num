# Design

> **Audience**: All

Design philosophy, patterns, trade-offs, and architecture decision records (ADRs) for wasm-num.

## Documents

| Document | Description |
|----------|-------------|
| [Principles](principles.md) | Core design principles and philosophy |
| [Patterns](patterns.md) | Design patterns used and rationale |
| [Trade-offs](trade-offs.md) | Key trade-offs and alternatives considered |
| [ADRs](adr/) | Architecture Decision Records |

## Design Philosophy Summary

wasm-num is designed around three core principles:

1. **Spec Fidelity** — Every definition mirrors the WebAssembly specification structure and semantics
2. **Abstraction at Boundaries** — Typeclasses at external boundaries (WasmFloat, GrowthPolicy), concrete types internally
3. **Proof Separation** — Definitions and proofs are independently buildable; proofs never appear in definition files

## See Also

- [Architecture](../architecture/) — system design and diagrams
- [API Reference](../reference/api/) — what the code does
- [Glossary](../reference/glossary.md) — terminology
