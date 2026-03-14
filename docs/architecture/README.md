# Architecture Overview

> **Audience**: Developers, Architects, Contributors

wasm-num is a formally verified Lean 4 formalization of the WebAssembly numeric layer. It covers integer/float operations, type conversions, 128-bit SIMD (including relaxed SIMD), and linear memory, all backed by machine-checked proofs.

## System Context

wasm-num is a pure Lean 4 library — it has no runtime, no I/O, and no C FFI. It is consumed by downstream Lean projects that need verified WebAssembly numeric semantics.

```mermaid
graph TD
    Downstream["Downstream Lean Project<br/>(Wasm interpreter, verifier, etc.)"] -->|"import WasmNum"| WasmNum["wasm-num<br/>Lean 4 Library"]
    WasmNum -->|"depends on"| Mathlib["Mathlib4<br/>(BitVec, Finset, algebra)"]
    WasmNum -->|"formalizes"| WasmSpec["WebAssembly Specification<br/>(Section 4: Numerics, 5: Memory)"]
    FloatBridge["IEEE 754 Bridge<br/>(external WasmFloat instance)"] -->|"provides instances"| WasmNum
    style WasmNum fill:#4CAF50,color:white
    style Mathlib fill:#2196F3,color:white
    style WasmSpec fill:#9E9E9E,color:white
    style FloatBridge fill:#FF9800,color:white
    style Downstream fill:#7E57C2,color:white
```

## Layered Architecture

wasm-num uses a strict layered architecture with **no circular dependencies**. Higher layers import lower layers; never the reverse.

```mermaid
graph TD
    subgraph "Layer 4 — Integration"
        Integration_Profile["Integration.Profile<br/>DeterministicWasmProfile"]
        Integration_Runtime["Integration.Runtime<br/>Instruction wrappers"]
    end

    subgraph "Layer 3 — Memory"
        Mem_Core["Memory.Core<br/>FlatMemory · Address · Bounds · Page"]
        Mem_Load["Memory.Load<br/>Scalar · Packed · SIMD"]
        Mem_Store["Memory.Store<br/>Scalar · Packed · SIMD"]
        Mem_Ops["Memory.Ops<br/>Size · Grow · Fill · Copy · Init"]
        Mem_Multi["MultiMemory · Memory64"]
    end

    subgraph "Layer 2 — SIMD"
        V128_Core["V128 Core<br/>Shape · Type · Lanes"]
        SIMD_Ops["SIMD.Ops<br/>Bitwise · IntLanewise · FloatLanewise"]
        SIMD_Extra["SIMD.Ops<br/>Bitmask · Narrow · Extend · Dot · Shuffle"]
        SIMD_Relaxed["SIMD.Relaxed<br/>Madd · MinMax · Swizzle · Trunc · Dot"]
    end

    subgraph "Layer 1 — Numerics"
        NaN["NaN Propagation<br/>nansN · propagateNaN₁/₂"]
        Float["Float Ops<br/>fmin · fmax · rounding · sign · compare"]
        Integer["Integer Ops<br/>arithmetic · bitwise · shift · compare · bits"]
        Conversion["Conversions<br/>trunc · trunc_sat · promote · demote · reinterpret"]
    end

    subgraph "Layer 0 — Foundation"
        Types["Types<br/>I32 · I64 · F32 · F64 · V128 · Byte"]
        BitVecOps["BitVecOps<br/>toBytes · fromBytes · signExtend"]
        WasmFloat["WasmFloat Typeclass<br/>IEEE 754 abstraction"]
        Profile["Profiles<br/>NaNProfile · RelaxedProfile · WasmProfile"]
    end

    Integration_Profile --> NaN
    Integration_Profile --> SIMD_Relaxed
    Integration_Runtime --> Mem_Load
    Integration_Runtime --> Mem_Store
    Integration_Runtime --> Mem_Ops
    Integration_Runtime --> Mem_Core

    Mem_Load --> Mem_Core
    Mem_Store --> Mem_Core
    Mem_Ops --> Mem_Core
    Mem_Multi --> Mem_Core

    SIMD_Ops --> V128_Core
    SIMD_Extra --> V128_Core
    SIMD_Relaxed --> SIMD_Ops
    SIMD_Ops --> Integer
    SIMD_Ops --> Float

    NaN --> WasmFloat
    Float --> NaN
    Conversion --> WasmFloat
    Integer --> Types
    Float --> Types

    V128_Core --> Types
    V128_Core --> BitVecOps

    Types --> BitVecOps
    Profile --> WasmFloat
    Profile --> Types

    style Types fill:#1565C0,color:white
    style BitVecOps fill:#1565C0,color:white
    style WasmFloat fill:#1565C0,color:white
    style Profile fill:#1565C0,color:white
    style NaN fill:#2E7D32,color:white
    style Float fill:#2E7D32,color:white
    style Integer fill:#2E7D32,color:white
    style Conversion fill:#2E7D32,color:white
    style V128_Core fill:#E65100,color:white
    style SIMD_Ops fill:#E65100,color:white
    style SIMD_Extra fill:#E65100,color:white
    style SIMD_Relaxed fill:#E65100,color:white
    style Mem_Core fill:#6A1B9A,color:white
    style Mem_Load fill:#6A1B9A,color:white
    style Mem_Store fill:#6A1B9A,color:white
    style Mem_Ops fill:#6A1B9A,color:white
    style Mem_Multi fill:#6A1B9A,color:white
    style Integration_Profile fill:#C62828,color:white
    style Integration_Runtime fill:#C62828,color:white
```

## Key Design Decisions

| Decision | Summary | ADR |
|----------|---------|-----|
| IEEE 754 Independence | `WasmFloat` typeclass decouples from any specific float library | [ADR-001](../design/adr/0001-typeclass-mediated-754-independence.md) |
| BitVec Universal Representation | All numeric types (`I32`, `F32`, `V128`, etc.) are `BitVec N` | [ADR-002](../design/adr/0002-bitvec-universal-representation.md) |
| Non-determinism as Sets | Spec-level non-determinism modeled as `Set α` | [ADR-003](../design/adr/0003-nondeterminism-as-sets.md) |
| V128 Shape System | Compile-time proofs ensure lane width × count = 128 | [ADR-004](../design/adr/0004-v128-shape-system.md) |
| Parameterized Address Width | `FlatMemory addrWidth` supports both Memory32 and Memory64 | [ADR-005](../design/adr/0005-flatmemory-parameterized-address-width.md) |
| Proof Separation | Definitions in `WasmNum/`, proofs in `WasmNum/Proofs/` | [ADR-006](../design/adr/0006-proof-separation.md) |
| No C FFI | Everything is pure Lean — no foreign function interface | [ADR-007](../design/adr/0007-no-c-ffi.md) |

## Component Index

| Component | Location | Responsibility |
|-----------|----------|---------------|
| Types | `WasmNum/Foundation/Types.lean` | Core type aliases (`I32`, `I64`, `F32`, `F64`, `V128`, `Byte`) |
| BitVecOps | `WasmNum/Foundation/BitVec.lean` | Byte extraction, endianness, sign/zero extension |
| WasmFloat | `WasmNum/Foundation/WasmFloat.lean` | IEEE 754 typeclass abstraction |
| Profiles | `WasmNum/Foundation/Profile.lean` | NaN and relaxed SIMD non-determinism selectors |
| NaN | `WasmNum/Numerics/NaN/` | NaN propagation sets and deterministic specialization |
| Float Ops | `WasmNum/Numerics/Float/` | fmin, fmax, rounding, sign, comparisons |
| Integer Ops | `WasmNum/Numerics/Integer/` | Arithmetic, bitwise, shifts, comparisons, saturating |
| Conversions | `WasmNum/Numerics/Conversion/` | trunc, trunc_sat, promote, demote, reinterpret, extend |
| V128 Core | `WasmNum/SIMD/V128/` | Shape system, lane access, splat, mapLanes, zipLanes |
| SIMD Ops | `WasmNum/SIMD/Ops/` | Bitwise, integer/float lanewise, bitmask, narrow, extend, dot |
| Relaxed SIMD | `WasmNum/SIMD/Relaxed/` | Non-deterministic relaxed SIMD operations |
| Memory Core | `WasmNum/Memory/Core/` | FlatMemory, page model, address calculation, bounds |
| Load/Store | `WasmNum/Memory/Load/`, `Store/` | Scalar, packed, and SIMD memory access |
| Memory Ops | `WasmNum/Memory/Ops/` | size, grow, fill, copy, init, data.drop |
| MultiMemory | `WasmNum/Memory/MultiMemory.lean` | Multi-memory store with 32/64-bit instances |
| Integration | `WasmNum/Integration/` | Deterministic profiles and instruction-level runtime wrappers |
| Proofs | `WasmNum/Proofs/` | Machine-checked proofs (parallel hierarchy to definitions) |

## Related Documents

- [Component Details](components.md)
- [Module Dependencies](module-dependency.md)
- [Data Model](data-model.md)
- [Data Flow](data-flow.md)
- [Design Principles](../design/principles.md)
- [API Reference](../reference/api/)
