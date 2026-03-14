# Configuration Guide

> **Audience**: Users, Developers

## Build Configuration (`lakefile.toml`)

wasm-num's build is configured via `lakefile.toml`:

```toml
[package]
name = "wasm-num"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["WasmNum", "WasmNumProofs"]
```

### Lean Options

| Option | Value | Effect |
|--------|-------|--------|
| `pp.unicode.fun` | `true` | Pretty-prints `fun a ↦ b` instead of `fun a => b` |
| `autoImplicit` | `false` | All implicit arguments must be declared explicitly |

### Build Targets

| Target | Description |
|--------|-------------|
| `WasmNum` | Definitions only (no proofs) |
| `WasmNumProofs` | Definitions + machine-checked proofs |
| `TestAll` | Executable test suite |

### Dependencies

| Dependency | Scope | Purpose |
|------------|-------|---------|
| `mathlib` | `leanprover-community` | `BitVec`, `Finset`, algebraic infrastructure, tactics |

## Toolchain (`lean-toolchain`)

```
leanprover/lean4:v4.29.0-rc6
```

elan reads this file and automatically installs/uses the correct Lean version. To change the Lean version, edit this file — but ensure compatibility with the current Mathlib revision.

## Mathlib Cache

Mathlib is large. Use the prebuilt cache to avoid building from source:

```bash
lake exe cache get
```

This downloads ~2 GB of prebuilt `.olean` files. Only needed once (or after Mathlib version bumps).

## Lake Workers

Control build parallelism:

```bash
# Use all cores
lake build -j 0

# Use 4 workers (default in CI)
lake build -j 4
```

## See Also

- [Reference: Configuration](../reference/configuration.md) — full option reference
- [Build](../development/build.md) — build system documentation
- [Troubleshooting](troubleshooting.md) — common build problems
