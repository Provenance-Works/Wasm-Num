# ADR-0006: Strict Separation of Definitions and Proofs

| | |
|---|---|
| **Status** | Accepted |
| **Date** | 2025 |
| **Deciders** | wasm-num maintainers |

## Context

Lean 4 allows definitions and proofs to coexist in the same file. However:

- Proof checking is expensive (often slower than type checking definitions)
- During development, definitions change frequently while proofs may be temporarily broken
- Users who only need definitions should not pay the compile-time cost of proofs
- The codebase needs multiple build targets: definitions-only, definitions+proofs, tests

## Decision

Maintain strict separation:

1. **Definition files** (`WasmNum/`) contain only `def`, `structure`, `inductive`, `class`, `abbrev`, `instance`, etc. No `theorem`, `lemma`, or proof terms.
2. **Proof files** live in `WasmNum/Proofs/` and `Proofs/`, mirroring the definition hierarchy.
3. **Build targets**:
   - `WasmNum` — definitions only (fast build)
   - `WasmNumProofs` — definitions + all proofs
   - `TestAll` — definitions + tests

## Consequences

### Positive
- `lake build WasmNum` is fast — no proof checking
- Definitions are clean and readable (no proof clutter)
- Proof failures don't block definition development
- Clear ownership: definition files vs. proof files

### Negative
- Must maintain parallel directory structure (definitions ↔ proofs)
- Easy to add a definition without adding corresponding proofs
- Import management is slightly more complex (proof files import definition files)

### Neutral
- `WasmNumProofs.lean` re-exports everything (definitions + proofs)
- Some proofs live in `WasmNum/Proofs/` (co-located but still separate files), others in top-level `Proofs/`

## Alternatives Considered

### Co-located Proofs
Put theorems in the same file as definitions. Rejected: build speed penalty is unacceptable for development iteration.

### Proof-only Build Target
Keep proofs in definition files but have a build flag to skip them. Rejected: Lean 4's build system doesn't support conditional compilation this way.

### Separate Package for Proofs
Put proofs in a completely separate Lake package. Rejected: over-engineering; separate files within the same package is sufficient.
