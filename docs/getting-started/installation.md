# Installation

> **Audience**: Users, Developers

## Prerequisites

### Lean 4

Install Lean 4 via [elan](https://github.com/leanprover/elan) (the Lean toolchain manager):

**Linux / macOS:**
```bash
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
```

**Windows:**
```powershell
# Via winget
winget install leanprover.elan

# Or download from https://github.com/leanprover/elan/releases
```

The exact Lean version is pinned in `lean-toolchain` (currently `leanprover/lean4:v4.29.0-rc6`). elan will automatically install the correct version when you build.

### Lake

Lake is Lean 4's build system and package manager. It is bundled with every Lean 4 installation — no separate install needed.

## As a Dependency

Add wasm-num to your project's `lakefile.toml`:

```toml
[[require]]
name = "wasm-num"
scope = "Provenance-Works"
```

Then import what you need:

```lean
-- All definitions (no proofs)
import WasmNum

-- Definitions + all proofs
import WasmNumProofs

-- Specific modules
import WasmNum.Numerics.Integer.Arithmetic
import WasmNum.SIMD.V128.Lanes
import WasmNum.Memory.Core.FlatMemory
```

## From Source

```bash
# Clone
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num

# Fetch Mathlib cache (avoids rebuilding Mathlib from source)
lake exe cache get

# Build definitions + proofs
lake build
```

> **Note:** The first `lake exe cache get` downloads ~2 GB of prebuilt Mathlib oleans. Subsequent builds are incremental and fast.

## Verify Installation

```bash
# Build definitions only
lake build WasmNum

# Build definitions + proofs
lake build WasmNumProofs

# Run test suite
lake build TestAll
```

All three commands should complete with exit code 0 and no `sorry` warnings.

## Editor Setup

**VS Code** (recommended):
1. Install the [lean4 extension](https://marketplace.visualstudio.com/items?itemName=leanprover.lean4)
2. Open the wasm-num folder
3. The extension automatically detects `lean-toolchain` and configures the language server

**Emacs**: Use [lean4-mode](https://github.com/leanprover/lean4-mode)

**Neovim**: Use [lean.nvim](https://github.com/Julian/lean.nvim)

## See Also

- [Quickstart](quickstart.md) — minimal working example
- [Development Setup](../development/setup.md) — full contributor setup
- [Configuration](../guides/configuration.md) — build options
