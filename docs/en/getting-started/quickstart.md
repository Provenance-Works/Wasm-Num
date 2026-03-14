# Quickstart

> **Audience**: Users

Get wasm-num built and verified in under 5 minutes.

## 1. Clone and Build

```bash
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num
lake exe cache get
lake build
```

## 2. Verify

```bash
# Run the test suite (414 tests across 11 modules)
lake build TestAll
```

## 3. Explore

Open any file in VS Code with the lean4 extension to get interactive type-checking and go-to-definition.

### Example: Integer Arithmetic

```lean
import WasmNum.Foundation.Types
import WasmNum.Numerics.Integer.Arithmetic

open WasmNumerics

-- 32-bit modular addition
#eval iadd (3 : I32) (4 : I32)        -- 7
#eval iadd (0xFFFFFFFF : I32) (1 : I32) -- 0 (wraps)

-- Division (returns Option — None on div by zero)
#eval idiv_u (10 : I32) (3 : I32)     -- some 3
#eval idiv_u (10 : I32) (0 : I32)     -- none
```

### Example: Memory Operations

```lean
import WasmNum.Memory.Core.FlatMemory
import WasmNum.Memory.Load.Scalar
import WasmNum.Memory.Store.Scalar

open WasmMemory

-- Create 1-page memory (64 KiB)
#eval do
  let mem := FlatMemory.empty 32 (some 10)  -- 32-bit, max 10 pages
  -- Store a 32-bit value at address 0
  let some mem' := i32Store mem (0 : Addr32) (0x42 : I32) | return "store failed"
  -- Load it back
  let some val := i32Load mem' (0 : Addr32) | return "load failed"
  return s!"Loaded: {val}"  -- "Loaded: 66"
```

### Example: SIMD Lanes

```lean
import WasmNum.SIMD.V128.Lanes
import WasmNum.SIMD.Ops.IntLanewise

open WasmSIMD

-- Create a V128 by splatting a value across all i32 lanes
#eval
  let v := splat Shape.i32x4 (42 : BitVec 32)
  lane Shape.i32x4 v ⟨0, by omega⟩  -- 42
```

## Build Targets

| Command | What it builds | Time (cached) |
|---------|----------------|:-------------:|
| `lake build WasmNum` | Definitions only | ~30s |
| `lake build WasmNumProofs` | Definitions + proofs | ~2min |
| `lake build TestAll` | Test suite | ~30s |
| `lake build` | Default targets (WasmNum + WasmNumProofs) | ~2min |

## Next Steps

- [Architecture](../architecture/) — understand the layered design
- [API Reference](../reference/api/) — browse all operations
- [Design Decisions](../design/adr/) — understand why things are the way they are

## See Also

- [Installation](installation.md) — detailed install instructions
- [Troubleshooting](../guides/troubleshooting.md) — common problems
