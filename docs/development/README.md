# Development

> **Audience**: Contributors

Guides for setting up a development environment, building, testing, and contributing to wasm-num.

## Documents

| Document | Description |
|----------|-------------|
| [Dev Setup](setup.md) | Environment setup (every dependency, every tool) |
| [Build](build.md) | Build system, targets, options |
| [Testing](testing.md) | Test strategy, how to run, how to write tests |
| [CI/CD](ci-cd.md) | Pipeline documentation |
| [Release](release.md) | Release process and versioning |
| [Project Structure](project-structure.md) | Codebase navigation — every folder explained |
| [Code Style](code-style.md) | Code conventions |

## Quick Start

```bash
# Clone
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num

# Build definitions
lake build WasmNum

# Build proofs
lake build WasmNumProofs

# Run tests
lake build TestAll
```

## See Also

- [Getting Started](../getting-started/) — user-level onboarding
- [Contributing](../../CONTRIBUTING.md) — contribution guidelines
- [Architecture](../architecture/) — system design
