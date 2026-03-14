# ADR-0007: No C FFI — Pure Lean Only

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2025 |
| **Deciders** | wasm-num maintainers |

## Context

Lean 4 supports C FFI for interoperability with system libraries. For wasm-num, the primary temptation is using C FFI for:

- IEEE 754 floating-point operations via hardware (`math.h`, Berkeley SoftFloat)
- Performance-critical operations
- Platform-specific optimizations

However, wasm-num's primary purpose is *formal verification* — providing machine-checked guarantees about WebAssembly numeric semantics.

## Decision

wasm-num uses no C FFI. The entire codebase is pure Lean 4.

- Float operations are abstracted via the `WasmFloat` typeclass (ADR-001)
- Default stub instances exist for testing
- Users wanting hardware floats must supply their own `WasmFloat` instance externally

## Consequences

### Positive
- **Fully verifiable** — no unverified code in the trusted computing base
- **Portable** — no native library dependencies, builds on any platform Lean supports
- **Reproducible** — no platform-dependent behavior (identical results everywhere)
- **Auditability** — security and correctness reviewers can inspect everything
- **Simplified build** — no C compiler or linker needed

### Negative
- Default float stubs return placeholder values (canonical NaN) — not usable for real float computation
- Cannot leverage hardware float speed
- Users must provide their own `WasmFloat` bridge for production use

### Neutral
- Pure Lean is sufficient for all non-float operations (integers, memory, SIMD structure)
- Test suite validates non-float paths; float-dependent tests use the stub's classification (which is correct)

## Alternatives Considered

### C FFI for SoftFloat
Link Berkeley SoftFloat for correct IEEE 754 arithmetic. Rejected: introduces trusted C code, native build dependencies, and a verification gap.

### Lean 4 Native Float
Use Lean 4's `Float` type. Rejected: `Float` is platform-dependent double precision, not bit-exact, and unsuitable for formal reasoning about both f32 and f64.

### Optional FFI (Build Flag)
Support both pure and FFI modes. Rejected: complexity of maintaining two code paths; the typeclass approach (ADR-001) already provides this flexibility without build flags.
