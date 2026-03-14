# Testing

> **Audience**: Contributors

## Overview

wasm-num has 414 tests organized in the `WasmTest/` directory. Tests use Lean 4's `#guard` and `#eval` with assertions.

## Running Tests

```bash
lake build TestAll
```

Tests are compiled as part of the build. If compilation succeeds, all `#guard` assertions passed.

## Test Organization

| Module | Source | Coverage |
|--------|--------|----------|
| `WasmTest.Foundation` | `WasmTest/Foundation.lean` | BitVec ops, byte conversion, types |
| `WasmTest.Integer` | `WasmTest/Integer.lean` | All integer operations |
| `WasmTest.Float` | `WasmTest/Float.lean` | Float classification, sign ops, compare |
| `WasmTest.Conversion` | `WasmTest/Conversion.lean` | Type conversions |
| `WasmTest.Integration` | `WasmTest/Integration.lean` | Integration wrappers |
| `WasmTest.Memory.Core` | `WasmTest/Memory/Core.lean` | FlatMemory, page ops |
| `WasmTest.Memory.LoadStore` | `WasmTest/Memory/LoadStore.lean` | Scalar load/store |
| `WasmTest.Memory.Ops` | `WasmTest/Memory/Ops.lean` | Fill, copy, grow, init, data.drop |
| `WasmTest.SIMD.Core` | `WasmTest/SIMD/Core.lean` | V128 lanes, shapes |
| `WasmTest.SIMD.IntOps` | `WasmTest/SIMD/IntOps.lean` | SIMD integer operations |
| `WasmTest.SIMD.Misc` | `WasmTest/SIMD/Misc.lean` | Shuffle, swizzle, convert |
| `WasmTest.Helpers` | `WasmTest/Helpers.lean` | Test utilities |

## Writing Tests

Tests use `#guard` for compile-time assertions:

```lean
-- Simple equality
#guard iadd (0x0001 : I32) (0x0002 : I32) == (0x0003 : I32)

-- Option results
#guard idiv_u (0x000A : I32) (0x0002 : I32) == some (0x0005 : I32)

-- Trap conditions
#guard idiv_u (0x0001 : I32) (0x0000 : I32) == none
```

For `Set`-returning functions, use membership tests:

```lean
#guard (someValue : BitVec 32) ∈ propagateNaN₂ WasmFloat.add a b
```

## Test Conventions

- Place tests in `WasmTest/` mirroring the source structure
- Name tests descriptively — the test IS the spec
- Include edge cases: zero, max value, overflow, NaN, ±∞
- Import test module in `TestAll.lean`

## Proofs vs Tests

wasm-num has both executable tests and formal proofs:

| | Tests (`WasmTest/`) | Proofs (`WasmNum/Proofs/`, `Proofs/`) |
|---|---|---|
| **What** | Concrete value assertions | Universal quantifications |
| **When** | Every build | Every proof build |
| **Guarantees** | Specific cases correct | ALL cases correct |
| **Example** | `#guard iadd 1 2 == 3` | `theorem iadd_comm : iadd a b = iadd b a` |

## See Also

- [Build](build.md) — build targets
- [Dev Setup](setup.md) — environment setup
- [Project Structure](project-structure.md) — where tests live
