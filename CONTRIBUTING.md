# Contributing to wasm-num

Thank you for your interest in contributing to wasm-num! This is a formal verification project — contributions to definitions, proofs, tests, and documentation are all valuable.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to abide by its terms.

## How Can I Contribute?

### Reporting Bugs

Found a spec mismatch, incorrect definition, or unsound proof?

1. **Check existing issues** — your issue may already be reported.
2. **Open a bug report** using the [bug report template](https://github.com/Provenance-Works/wasm-num/issues/new?template=bug_report.yml).
3. Include:
   - The specific Wasm spec section involved (e.g., "Section 4.3.3 fmin")
   - Lean version and Mathlib commit (from `lean-toolchain` and `lake-manifest.json`)
   - Steps to reproduce (Lean code snippet if applicable)
   - Expected vs. actual behavior

### Suggesting Features

Have an idea for a new formalization, a missing Wasm instruction, or improved proof coverage?

1. **Open a feature request** using the [feature request template](https://github.com/Provenance-Works/wasm-num/issues/new?template=feature_request.yml).
2. Reference the relevant Wasm spec section if applicable.

### Your First Contribution

Look for issues labeled:

- [`good first issue`](https://github.com/Provenance-Works/wasm-num/labels/good%20first%20issue) — well-scoped, mentored tasks
- [`help wanted`](https://github.com/Provenance-Works/wasm-num/labels/help%20wanted) — we'd love help with these

Good first contributions include:
- Adding `#eval` tests for existing definitions
- Proving simple lemmas in `WasmNum/Proofs/`
- Improving doc comments on definitions
- Filling in proof stubs (search for `sorry` in `Proofs/`)

### Pull Request Process

1. **Fork** the repository and clone your fork.
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feat/your-feature-name
   ```
3. **Make your changes** (see [Development Setup](#development-setup) below).
4. **Ensure the build passes**:
   ```bash
   lake build
   ```
5. **Check for `sorry`** — library definitions and proofs must not contain `sorry`:
   ```bash
   grep -rn '\bsorry\b' WasmNum/ --include="*.lean" | grep -v '^\s*--'
   ```
6. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/):
   ```
   feat(simd): add i64x2.abs lanewise operation
   fix(memory): correct bounds check for 64-bit addresses
   proof(nan): prove propagateNaN₂ preserves arithmetic NaN
   docs: update architecture diagram for Memory64
   test: add #eval tests for trunc_sat conversions
   ```
7. **Push** and open a Pull Request against `main`.
8. Fill in the PR template, linking any related issues.
9. A maintainer will review your PR. Address feedback promptly.

## Development Setup

### Prerequisites

- **Lean 4** — Install via [elan](https://github.com/leanprover/elan):
  ```bash
  curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
  ```
- **VS Code** (recommended) with the [lean4 extension](https://marketplace.visualstudio.com/items?itemName=leanprover.lean4)

### Clone and Build

```bash
git clone https://github.com/<your-fork>/wasm-num.git
cd wasm-num

# Fetch Mathlib cache (saves significant build time)
lake exe cache get

# Build everything
lake build
```

### Build Targets

| Command | What it builds |
|---------|----------------|
| `lake build WasmNum` | Definitions only |
| `lake build WasmNumProofs` | Definitions + proofs |
| `lake build TestAll` | All tests |
| `lake build` | Everything (default targets: WasmNum, WasmNumProofs) |

### Running Tests

```bash
lake build TestAll
```

Tests use `#eval` to execute deterministic operations and check results. Test modules are in `WasmTest/`.

## Project Structure

```
WasmNum/               # Definition modules (Layer 0–4)
├── Foundation/        # Core types, WasmFloat typeclass, profiles
├── Numerics/          # NaN, float, integer, conversion operations
├── SIMD/              # V128, lanewise ops, relaxed SIMD
├── Memory/            # FlatMemory, load/store, memory ops
├── Integration/       # Deterministic wrappers, runtime adapter
└── Proofs/            # Machine-checked proofs (mirrors definition hierarchy)

WasmTest/              # Executable tests (#eval)
Proofs/                # Additional proof stubs (legacy layout)
docs/                  # Design docs, ADRs, requirements, research
```

### Key Conventions

- **Definitions and proofs are separated** ([ADR-006](docs/adr/006-proof-separation.md)). Definitions go in `WasmNum/`, proofs go in `WasmNum/Proofs/`.
- **`@[simp]` lemmas** may live alongside definitions. All other theorems go in `Proofs/`.
- **Non-deterministic operations** return `Set α`. Deterministic variants live in `Integration/`.
- **No C FFI** ([ADR-007](docs/adr/007-no-c-ffi.md)) — everything is pure Lean.
- **No `sorry` in merged code** — definitions and proofs must be complete.
- **`autoImplicit = false`** — all implicit arguments must be declared explicitly.

## Style Guide

### Lean Code

- Follow Mathlib naming conventions where applicable.
- Use `snake_case` for definitions and lemmas.
- Use `CamelCase` for types, structures, and typeclasses.
- Keep lines under 100 characters when practical.
- Add module-level doc comments (`/-! ... -/`) to every file.
- Add definition-level doc comments (`/-- ... -/`) to public definitions.

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
[optional footer(s)]
```

Types: `feat`, `fix`, `proof`, `test`, `docs`, `refactor`, `ci`, `chore`

Scopes: `foundation`, `numerics`, `nan`, `float`, `integer`, `conversion`, `simd`, `v128`, `relaxed`, `memory`, `integration`

### Branch Naming

```
feat/<description>     — New features or definitions
fix/<description>      — Bug fixes
proof/<description>    — New or improved proofs
docs/<description>     — Documentation changes
test/<description>     — Test additions
refactor/<description> — Refactoring
ci/<description>       — CI/CD changes
```

## Community

- **Questions?** Open a [Discussion](https://github.com/Provenance-Works/wasm-num/discussions).
- **Found a security issue?** See [SECURITY.md](SECURITY.md). Do not open a public issue.

We aim to respond to issues and PRs within a few days. For complex formal verification PRs, review may take longer — we want to get it right.

## License

By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
