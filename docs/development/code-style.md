# Code Style

> **Audience**: Contributors

Code conventions for wasm-num.

## Lean Options

```toml
# lakefile.toml
[[lean_lib]]
leanOptions = [
  { name = "autoImplicit",        value = false },
  { name = "relaxedAutoImplicit", value = false }
]
```

All universe variables, type variables, and implicit arguments must be explicitly declared.

## Naming Conventions

### Functions

| Pattern | Convention | Example |
|---------|-----------|---------|
| Integer ops | `i` prefix + operation | `iadd`, `isub`, `imul`, `idiv_u`, `idiv_s` |
| Float ops | `f` prefix + operation | `fmin`, `fmax`, `fabs`, `fneg`, `fcopysign` |
| Signed/unsigned variants | `_s` / `_u` suffix | `idiv_s`, `idiv_u`, `ilt_s`, `ilt_u` |
| SIMD integer ops | descriptive name | `add`, `sub`, `shl`, `shrS`, `shrU` (in SIMD namespace) |
| SIMD float ops | `f` prefix + Lane suffix | `fadd`, `fminLane`, `fpminLane` |
| Conversions | `<from>To<To><kind>` | `truncF32ToI32S`, `convertI32SToF64` |
| Memory ops | descriptive | `i32Load`, `f64Store`, `fill`, `copy`, `growSpec` |

### Types

| Pattern | Convention | Example |
|---------|-----------|---------|
| Type aliases | PascalCase abbreviation | `I32`, `I64`, `F32`, `F64`, `V128`, `Byte` |
| Structures | PascalCase | `FlatMemory`, `WasmProfile`, `Shape`, `GrowResult` |
| Typeclasses | PascalCase | `WasmFloat`, `GrowthPolicy` |
| Inductive types | PascalCase | `LaneType`, `DataSegment`, `MemoryInstance` |

### Proofs

| Pattern | Convention | Example |
|---------|-----------|---------|
| Property theorems | `property_subject` | `iadd_comm`, `readByte_writeByte_same` |
| Membership proofs | `_mem` suffix | `selectNaN_mem`, `growSpec_failure_mem` |
| Bound proofs | descriptive | `effectiveAddr_toNat`, `pageSize_pos` |

## Module Organization

- One concept per file (e.g., `Arithmetic.lean` for integer arithmetic)
- Group by subdirectory: `Integer/`, `Float/`, `NaN/`, `Conversion/`
- Proofs in `WasmNum/Proofs/` or `Proofs/` mirroring the definition structure
- Tests in `WasmTest/` mirroring the definition structure

## Import Order

1. Mathlib imports (if needed)
2. Foundation imports
3. Same-layer imports
4. No cross-layer downward imports (enforced by architecture)

## Documentation in Code

- Docstrings on public definitions: `/-- ... -/`
- Brief inline comments for non-obvious logic
- No boilerplate comments on obvious definitions

## See Also

- [Project Structure](project-structure.md)
- [Architecture](../architecture/) — layer rules
- [Contributing](../../CONTRIBUTING.md)
