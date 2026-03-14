# Development Setup

> **Audience**: Contributors

Complete instructions for setting up a wasm-num development environment.

## Prerequisites

| Tool | Version | Required | Purpose |
|------|---------|:--------:|---------|
| **elan** | latest | Yes | Lean toolchain manager |
| **Lean 4** | v4.29.0-rc6 | Yes (auto via elan) | Language & compiler |
| **Git** | ≥ 2.0 | Yes | Version control |
| **VS Code** | latest | Recommended | Editor |
| **lean4 extension** | latest | Recommended | VS Code Lean 4 support |

## Step 1: Install elan

elan manages Lean 4 toolchain versions (similar to rustup for Rust).

**Linux / macOS:**

```bash
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
```

**Windows:**

Download and run the installer from [https://github.com/leanprover/elan/releases](https://github.com/leanprover/elan/releases), or use:

```powershell
choco install elan
```

Verify:

```bash
elan --version
lean --version  # should show v4.29.0-rc6 after clone
```

## Step 2: Clone the Repository

```bash
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num
```

elan reads `lean-toolchain` and installs the correct Lean version automatically.

## Step 3: Get Mathlib Cache

Mathlib is large. Avoid building from source:

```bash
lake exe cache get
```

This downloads pre-built `.olean` files for Mathlib. If the cache server is slow, retry or set `MATHLIB_CACHE_URL`.

## Step 4: Build

```bash
# Build core definitions
lake build WasmNum

# Build proofs (includes definitions)
lake build WasmNumProofs

# Run tests
lake build TestAll
```

## Step 5: Editor Setup

### VS Code

1. Install the **lean4** extension (`leanprover.lean4`)
2. Open the `wasm-num` folder as workspace root
3. The extension auto-detects `lakefile.toml` and `lean-toolchain`
4. Open any `.lean` file — the Lean server starts automatically

### Emacs

Use `lean4-mode`. Ensure `lean` is on your `PATH` (elan handles this).

### Neovim

Use `lean.nvim`. Configure LSP to use the `lean` binary managed by elan.

## Troubleshooting Setup

| Problem | Solution |
|---------|----------|
| `lean` not found | Ensure elan's bin directory is on PATH (`~/.elan/bin`) |
| Wrong Lean version | Run `elan override set leanprover/lean4:v4.29.0-rc6` in the project directory |
| Mathlib cache miss | Run `lake exe cache get` — downloads pre-built oleans |
| Lake build timeout | Set `LAKE_WORKERS=1` for low-memory machines |
| VS Code not loading | Restart window (`Ctrl+Shift+P` → "Reload Window") after installing lean4 extension |

## See Also

- [Build](build.md) — build targets and options
- [Troubleshooting](../guides/troubleshooting.md) — detailed troubleshooting guide
- [Installation](../getting-started/installation.md) — user-level installation
