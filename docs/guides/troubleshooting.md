# Troubleshooting

> **Audience**: All

## Build Issues

### `lake exe cache get` fails or hangs

**Cause**: Network issues, or Mathlib cache server unavailable.

**Solutions**:
1. Retry — transient network errors are common.
2. Check the Mathlib cache status at [leanprover-community/mathlib4](https://github.com/leanprover-community/mathlib4).
3. If behind a proxy, configure `HTTPS_PROXY`:
   ```bash
   export HTTPS_PROXY=http://proxy:port
   lake exe cache get
   ```
4. As a last resort, build Mathlib from source (takes 30–60 minutes):
   ```bash
   lake build
   ```

### `lake build` runs out of memory

**Cause**: Building Mathlib or large proof files requires significant RAM (8+ GB recommended).

**Solutions**:
1. Reduce parallelism: `lake build -j 1`
2. Close other applications to free memory.
3. Use `lake exe cache get` to avoid building Mathlib from source.

### `sorry` warnings during build

**Cause**: Incomplete proofs in proof files.

**Note**: The main library (`WasmNum` target) and proofs (`WasmNumProofs` target) should contain no `sorry`. If you see `sorry` warnings:
1. Check you're on a release tag, not a development branch.
2. Run: `grep -rn '\bsorry\b' WasmNum/ --include="*.lean" | grep -v '^\s*--'`

### Wrong Lean version

**Cause**: elan not installed, or `lean-toolchain` not being picked up.

**Solution**:
```bash
# Check current version
lean --version

# It should match lean-toolchain content
cat lean-toolchain
# leanprover/lean4:v4.29.0-rc6

# If mismatched, ensure elan is installed and in PATH
elan show
```

## Editor Issues

### Lean 4 language server not starting

1. Ensure `lean-toolchain` exists in the project root.
2. Open the workspace root folder (not a subfolder) in VS Code.
3. Check the Lean 4 extension output panel for errors.
4. Try: `lake env printPaths` to verify Lake can resolve the environment.

### Slow type-checking

Mathlib-heavy files may take 10–30 seconds for initial checking. This is expected. Subsequent edits within the same file are incremental and faster.

## Test Issues

### Test failures

```bash
# Run tests and check output
lake build TestAll
```

Tests use `#eval` and print pass/fail counts. If tests fail:
1. Check the output for specific test names.
2. Ensure the full library builds first: `lake build WasmNum`
3. Check for `sorry` in the codebase.

## Proof Issues

### Proof using unintended axioms

Run the axiom audit:
```bash
# Check axioms used by WasmNumProofs
lake env lean --run WasmNumProofs.lean 2>&1 | grep "axiom"
```

Expected axioms (Lean/Mathlib standard):
- `propext`
- `Quot.sound`
- `Classical.choice`

## See Also

- [Installation](../getting-started/installation.md) — setup instructions
- [Configuration](configuration.md) — build options
- [Development Setup](../development/setup.md) — contributor environment
