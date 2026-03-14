# Trade-offs

> **Audience**: All

Key trade-offs made in wasm-num's design and their consequences.

## 1. BitVec N Everywhere vs. Distinct Types

**Decision**: All numeric types are `BitVec N` aliases.

| | Chosen: BitVec aliases | Alternative: Distinct types |
|---|---|---|
| **Pro** | No conversion boilerplate, natural composition | Type safety — can't accidentally mix I32 and F32 |
| **Pro** | Reinterpret is zero-cost (identity function) | Clearer intent in signatures |
| **Con** | No compile-time prevention of type confusion | Lots of wrapping/unwrapping |
| **Con** | — | Reinterpret needs explicit conversion |

**Why chosen**: The WebAssembly spec itself treats numeric values as untyped bit patterns at the value level. Instructions determine interpretation, not the values. `BitVec N` mirrors this faithfully.

## 2. Set α vs. Nondeterminism Monad

**Decision**: Non-deterministic operations return `Set α`.

| | Chosen: Set α | Alternative: Nondeterminism monad |
|---|---|---|
| **Pro** | Simple — just a predicate (`α → Prop`) | Compositional — monadic bind |
| **Pro** | Natural for proof reasoning | Familiar to PL researchers |
| **Con** | Not directly executable | Heavier abstraction |
| **Con** | Composition requires explicit set operations | May mask spec structure |

**Why chosen**: `Set α` is the simplest possible representation of "any of these values is valid." It's natural in Lean 4's type theory and aligns with the spec's notation of sets of allowed values.

## 3. Typeclass vs. Module Parameter for WasmFloat

**Decision**: `WasmFloat N` is a typeclass.

| | Chosen: Typeclass | Alternative: Module functor/parameter |
|---|---|---|
| **Pro** | Automatic instance resolution | Explicit dependency tracking |
| **Pro** | Ergonomic — no threading parameters | No implicit state |
| **Con** | Instance coherence concerns | Verbose — parameter threading everywhere |
| **Con** | Harder to reason about multiple instances | — |

**Why chosen**: Lean 4's typeclass system handles instance resolution cleanly. In practice, there is exactly one `WasmFloat 32` and one `WasmFloat 64` instance per runtime, making coherence a non-issue.

## 4. Pure Lean vs. C FFI for Float Operations

**Decision**: No C FFI — pure Lean only.

| | Chosen: Pure Lean | Alternative: C FFI for hardware floats |
|---|---|---|
| **Pro** | Fully verifiable — no trusted code | Fast — hardware float speed |
| **Pro** | Portable — no native deps | Bit-exact IEEE 754 from hardware |
| **Con** | Default float stubs are placeholders | Verification gap at FFI boundary |
| **Con** | — | Platform-dependent |

**Why chosen**: The core purpose of wasm-num is formal verification. C FFI would introduce an unverified trust boundary. Users needing performance can supply a `WasmFloat` instance backed by verified C bindings externally.

## 5. Proof Separation vs. Co-located Proofs

**Decision**: Proofs in separate files from definitions.

| | Chosen: Separated | Alternative: Co-located |
|---|---|---|
| **Pro** | Fast `lake build WasmNum` (no proof checking) | Self-contained files |
| **Pro** | Clean definition files | Proofs next to the code they verify |
| **Con** | Must maintain parallel file structure | Slow builds even for definitions-only |
| **Con** | Easy to forget proofs for new definitions | — |

**Why chosen**: Build speed matters for iteration. Definitions change frequently during development; proofs lag behind. Separation prevents proofs from blocking definition changes.

## 6. FlatMemory ByteArray vs. Fin-indexed Array

**Decision**: Memory data stored as `ByteArray`.

| | Chosen: ByteArray | Alternative: Array (Fin N → Byte) |
|---|---|---|
| **Pro** | Efficient representation | Bounds guaranteed by type |
| **Pro** | Natural for byte-level operations | No runtime bounds checks |
| **Con** | Requires `inv_dataSize` proof | Larger type, more complex |
| **Con** | — | Resizing (grow) is awkward |

**Why chosen**: `ByteArray` is Lean 4's native byte container with O(1) read/write. The `inv_dataSize` invariant on `FlatMemory` provides the same guarantees as a sized type, with better ergonomics for memory growth.

## See Also

- [Principles](principles.md) — design philosophy
- [Patterns](patterns.md) — how decisions manifest
- [ADRs](adr/) — formal decision records
