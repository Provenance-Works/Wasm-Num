# wasm-num

<!-- Badges -->
[![CI — Formal Verification Pipeline](https://github.com/Provenance-Works/wasm-num/actions/workflows/ci.yml/badge.svg)](https://github.com/Provenance-Works/wasm-num/actions/workflows/ci.yml)
[![Security Scan](https://github.com/Provenance-Works/wasm-num/actions/workflows/security-scan.yml/badge.svg)](https://github.com/Provenance-Works/wasm-num/actions/workflows/security-scan.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Lean 4](https://img.shields.io/badge/Lean_4-v4.29.0--rc6-blue)](https://lean-lang.org/)
[![Mathlib](https://img.shields.io/badge/Mathlib-latest-green)](https://github.com/leanprover-community/mathlib4)

> Formally verified WebAssembly numeric semantics, 128-bit SIMD, and linear memory model in Lean 4.

## Overview

**wasm-num** is a comprehensive Lean 4 formalization of the WebAssembly numeric layer — covering integer and floating-point operations, type conversions, 128-bit SIMD (including relaxed SIMD), and linear memory semantics. Every definition is backed by machine-checked proofs that verify conformance to the [WebAssembly specification](https://webassembly.github.io/spec/core/).

### Why wasm-num?

- **Spec-Complete Numerics** — All Wasm numeric instructions: integer arithmetic, bitwise, shifts, comparisons, conversions, floating-point operations, and NaN propagation.
- **Full SIMD Coverage** — V128 operations, 12 lane shapes, lanewise integer/float ops, shuffle, swizzle, narrowing/widening, and all relaxed SIMD proposals.
- **Linear Memory Model** — FlatMemory with page management, scalar/packed/SIMD loads and stores, memory.grow/copy/fill/init, multi-memory, and Memory64 support.
- **Machine-Checked Proofs** — Load–store roundtrip, lane bijections, NaN propagation correctness, deterministic-implies-spec, bounds safety, overlap correctness, and more.
- **IEEE 754 Independence** — The `WasmFloat` typeclass abstracts over any IEEE 754 implementation via [ADR-001](docs/en/design/adr/0001-ieee754-independence-via-wasmfloat.md). Plug in your own float library.
- **Non-determinism as Sets** — Spec-level non-determinism (NaN payloads, relaxed SIMD, memory.grow) is modeled as `Set α`, enabling both proof reasoning and deterministic runtime instantiation via profiles.
- **Built on Mathlib** — Leverages `BitVec`, `Finset`, and Mathlib's algebraic infrastructure.

### At a Glance

| Component | Definitions | Proofs | Tests |
|-----------|:-----------:|:------:|:-----:|
| Foundation (types, BitVec, WasmFloat, profiles) | 6 modules | — | 1 module |
| Numerics (NaN, float, integer, conversions) | 21 modules | 6 modules | 3 modules |
| SIMD (V128, lanewise, relaxed) | 19 modules | 4 modules | 3 modules |
| Memory (core, load/store, ops, multi-memory) | 13 modules | 4 modules | 3 modules |
| Integration (profiles, runtime) | 2 modules | — | 1 module |
| **Total** | **~70 modules** | **14 modules** | **12 modules** |

## Quick Start

### Prerequisites

- [Lean 4](https://lean-lang.org/lean4/doc/quickstart.html) (v4.29.0-rc6 or compatible — pinned via `lean-toolchain`)
- [Lake](https://github.com/leanprover/lake) (bundled with Lean 4)

### Build

```bash
# Clone the repository
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num

# Fetch and cache Mathlib (first build takes a while)
lake exe cache get

# Build all definitions and proofs
lake build
```

### Verify

```bash
# Build definitions only
lake build WasmNum

# Build definitions + proofs
lake build WasmNumProofs

# Run tests
lake build TestAll
```

## Architecture

wasm-num uses a strict layered architecture with no circular dependencies:

```
Layer 4: Integration
         WasmFloat instances · GrowthPolicy · Runtime adapter
         │
Layer 3: Memory
         FlatMemory · Load/Store · SIMD Memory Ops · Multi-Memory · Memory64
         │
Layer 2: SIMD
         V128 · Shapes · Lanewise Ops · Shuffle/Swizzle · Relaxed SIMD
         │
Layer 1: Wasm Numerics
         NaN Propagation · fmin/fmax/fnearest · Conversions · Integer Ops
         │
Layer 0: Foundation
         BitVec · WasmFloat typeclass · Profiles · Core types
```

All numeric types use `BitVec N` as the universal representation (integers and floats alike). Floating-point semantics are decoupled through the `WasmFloat` typeclass, allowing any IEEE 754 implementation to be plugged in without modifying wasm-num.

Non-deterministic operations return `Set α` at the spec level. The `WasmProfile` (= `NaNProfile` + `RelaxedProfile`) narrows these sets, and the Integration layer provides fully deterministic wrappers for runtime use.

For more details, see:

- [Architecture](docs/en/architecture/)
- [Design Decisions (ADRs)](docs/en/design/adr/)
- [Full Documentation](docs/) (English / 日本語)

## Module Map

```
WasmNum/
├── Foundation/          # Layer 0 — Types, BitVec utils, WasmFloat, Profiles
├── Numerics/
│   ├── NaN/             # NaN propagation (spec + deterministic)
│   ├── Float/           # fmin, fmax, rounding, sign, comparisons
│   ├── Integer/         # Arithmetic, bitwise, shifts, saturating, etc.
│   └── Conversion/      # trunc, trunc_sat, promote, demote, reinterpret, extend
├── SIMD/
│   ├── V128/            # V128 type, shapes, lane access
│   ├── Ops/             # Bitwise, int/float lanewise, shuffle, swizzle, bitmask, etc.
│   └── Relaxed/         # madd, relaxed min/max, relaxed trunc, laneselect, dot, q15
├── Memory/
│   ├── Core/            # FlatMemory, Address, Bounds, Page
│   ├── Load/            # Scalar, Packed, SIMD loads
│   ├── Store/           # Scalar, Packed, SIMD stores
│   └── Ops/             # size, grow, fill, copy, init, data.drop
├── Integration/         # Deterministic wrappers, runtime adapter
└── Proofs/              # Machine-checked proofs (parallel hierarchy)

WasmTest/                # Executable tests (#eval)
```

## Usage as a Dependency

Add wasm-num to your `lakefile.toml`:

```toml
[[require]]
name = "wasm-num"
scope = "Provenance-Works"
```

Then import what you need:

```lean
-- All definitions (no proofs)
import WasmNum

-- Definitions + all proofs
import WasmNumProofs

-- Specific modules
import WasmNum.Numerics.Integer.Arithmetic
import WasmNum.SIMD.V128.Lanes
import WasmNum.Memory.Core.FlatMemory
```

## Key Design Decisions

| ADR | Decision |
|-----|----------|
| [ADR-001](docs/en/design/adr/0001-ieee754-independence-via-wasmfloat.md) | IEEE 754 independence via `WasmFloat` typeclass |
| [ADR-002](docs/en/design/adr/0002-bitvec-as-universal-representation.md) | `BitVec N` as universal representation for all numeric types |
| [ADR-003](docs/en/design/adr/0003-nondeterminism-as-sets.md) | Non-determinism modeled as `Set α` |
| [ADR-004](docs/en/design/adr/0004-v128-shape-system.md) | V128 shape system for SIMD lane types |
| [ADR-005](docs/en/design/adr/0005-flatmemory-parameterized-address-width.md) | `FlatMemory` parameterized by address width |
| [ADR-006](docs/en/design/adr/0006-proof-separation.md) | Strict separation of definitions and proofs |
| [ADR-007](docs/en/design/adr/0007-no-c-ffi.md) | No C FFI — pure Lean only |

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before getting started.

All contributors must follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

To report a security vulnerability, please see [SECURITY.md](SECURITY.md). **Do not open a public issue.**

## License

Copyright 2026 [Provenance Works](https://github.com/Provenance-Works)

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full text.

## Acknowledgments

- [Lean 4](https://lean-lang.org/) — the proof assistant and programming language
- [Mathlib4](https://github.com/leanprover-community/mathlib4) — the community mathematics library
- [WebAssembly Specification](https://webassembly.github.io/spec/core/) — the formal specification this project formalizes
