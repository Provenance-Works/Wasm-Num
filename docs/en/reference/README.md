# Reference

> **Audience**: Developers, Users, Operators

Detailed reference documentation for wasm-num.

## Documents

| Document | Audience | Description |
|----------|----------|-------------|
| [API Reference](api/) | Developers | Complete API docs per architectural layer |
| [Configuration](configuration.md) | All | All configuration options (lakefile, toolchain, etc.) |
| [Environment](environment.md) | Users/Ops | Environment variables |
| [Errors](errors.md) | All | Error types, trap conditions, resolutions |
| [Glossary](glossary.md) | All | Domain terminology and abbreviations |

## API Reference by Layer

| Layer | Module | Documentation |
|-------|--------|---------------|
| 0 — Foundation | Types, BitVecOps, WasmFloat, Profiles | [foundation.md](api/foundation.md) |
| 1 — Numerics | NaN, Float, Integer, Conversion | [numerics.md](api/numerics.md) |
| 2 — SIMD | V128, Ops, Relaxed | [simd.md](api/simd.md) |
| 3 — Memory | FlatMemory, Load/Store, Ops | [memory.md](api/memory.md) |
| 4 — Integration | DeterministicWasmProfile, Runtime | [integration.md](api/integration.md) |

## See Also

- [Architecture](../architecture/) — system design
- [Guides](../guides/) — task-oriented how-tos
- [Getting Started](../getting-started/) — onboarding
