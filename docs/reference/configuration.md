# Configuration Reference

> **Audience**: All

Complete reference for all configurable options in wasm-num.

## lakefile.toml

The primary build configuration file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `name` | `String` | `"wasm-num"` | Package name |
| `version` | `String` | `"0.1.0"` | Package version |
| `leanOptions` | `Array` | see below | Compiler/checker options |
| `[[require]]` | `Table` | see below | Dependencies |
| `[[lean_lib]]` | `Table` | see below | Build targets |

### Dependencies

| Name | Source | Description |
|------|--------|-------------|
| `mathlib` | `leanprover-community/mathlib4` | Community math library. Pinned in `lake-manifest.json`. |

### Build Targets

| Target | Root File | Description |
|--------|-----------|-------------|
| `WasmNum` | `WasmNum.lean` | Core definitions only |
| `WasmNumProofs` | `WasmNumProofs.lean` | Definitions + all proofs |
| `TestAll` | `TestAll.lean` | Full test suite (414 tests) |

### Lean Options

| Option | Type | Value | Description |
|--------|------|-------|-------------|
| `autoImplicit` | `Bool` | `false` | Disable auto-implicit arguments. All variables must be explicitly declared. |
| `relaxedAutoImplicit` | `Bool` | `false` | Disable relaxed auto-implicit (companion to `autoImplicit`). |

## lean-toolchain

Pins the exact Lean 4 version.

| Format | Current Value |
|--------|---------------|
| `leanprover/lean4:v{version}` | `leanprover/lean4:v4.29.0-rc6` |

## lake-manifest.json

Auto-generated dependency lock file. Contains exact revisions for all transitive dependencies.

| Dependency | Type | Rev (pinned) |
|------------|------|-------------|
| `mathlib` | `git` | `09c7a883755f6005ca7f950a3935bfa9928cb5cb` |

> **Warning:** Do not edit `lake-manifest.json` manually. Use `lake update` to refresh.

## Configuration Files Summary

| File | Purpose | Editable |
|------|---------|----------|
| `lakefile.toml` | Build targets, dependencies, options | Yes |
| `lean-toolchain` | Lean version pin | Yes (carefully) |
| `lake-manifest.json` | Dependency lock | No (auto-generated) |

## See Also

- [Installation](../getting-started/installation.md)
- [Build](../development/build.md)
- [Configuration Guide](../guides/configuration.md) — how-to guide for common config tasks
