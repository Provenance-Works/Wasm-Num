# Glossary

> **Audience**: All

Domain terminology, abbreviations, and definitions used throughout wasm-num.

## WebAssembly Types

| Term | Definition |
|------|-----------|
| **I32** | 32-bit integer type. Represented as `BitVec 32`. |
| **I64** | 64-bit integer type. Represented as `BitVec 64`. |
| **F32** | 32-bit floating-point type (IEEE 754 binary32). Represented as `BitVec 32`. |
| **F64** | 64-bit floating-point type (IEEE 754 binary64). Represented as `BitVec 64`. |
| **V128** | 128-bit SIMD vector type. Represented as `BitVec 128`. |
| **Byte** | 8-bit value. Alias for `BitVec 8`. |

## IEEE 754 Floating-Point

| Term | Definition |
|------|-----------|
| **NaN** | Not a Number. Special float values with all exponent bits set and non-zero significand. |
| **Canonical NaN** | A NaN with only the MSB of the significand set. The spec requires specific behavior for canonical NaNs. |
| **Arithmetic NaN** | A quiet NaN (MSB of significand set). Also called signaling-suppressed NaN. |
| **NaN Propagation** | The process of selecting a NaN result when an operation's input(s) are NaN. Spec defines a set of allowed outputs. |
| **nansN** | The spec function `nans_N{z*}` defining the set of allowed NaN results: canonical NaNs ∪ arithmetic NaNs with overlapping payloads. |
| **Payload** | The significand bits of a NaN value. Different NaNs can carry different payloads. |
| **Subnormal** | A float with zero exponent and non-zero significand. Represents very small values near zero. |
| **Round ties-to-even** | The default IEEE 754 rounding mode: if the exact result is equidistant between two representable values, choose the one with an even least significant digit. |

## SIMD

| Term | Definition |
|------|-----------|
| **Shape** | Describes how a V128 is partitioned into lanes. Defined by lane width × lane count = 128 (e.g., i32x4). |
| **Lane** | One element within a V128 vector. E.g., i32x4 has 4 lanes, each 32 bits. |
| **Lanewise** | Applying an operation independently to each lane of a SIMD vector. |
| **Splat** | Replicating a scalar value across all lanes of a V128. |
| **Swizzle** | Rearranging lanes of a vector based on index values from another vector. |
| **Shuffle** | Selecting lanes from two input vectors based on static indices. |
| **Bitmask** | Extracting the most significant bit of each lane into a scalar I32. |
| **Narrow** | Converting wider lanes to narrower lanes with saturation. E.g., i16x8 → i8x16. |
| **Extend** | Converting narrower lanes to wider lanes with sign or zero extension. E.g., i8x16 → i16x8. |
| **Relaxed SIMD** | A Wasm proposal allowing implementation-defined results for certain SIMD operations to enable hardware-native behavior. |
| **Q15** | Fixed-point format where 15 fractional bits represent values in [-1, 1). Used in `i16x8.q15mulr_sat_s`. |
| **FMA** | Fused multiply-add: `a * b + c` computed with a single rounding step. |

## Memory

| Term | Definition |
|------|-----------|
| **FlatMemory** | The byte-addressable linear memory model. Parameterized by address width (32 or 64). |
| **Page** | The unit of memory allocation. Always 65536 bytes (64 KiB). |
| **Memory32** | `FlatMemory 32` — linear memory with 32-bit addresses. Max 65536 pages (4 GiB). |
| **Memory64** | `FlatMemory 64` — linear memory with 64-bit addresses. Max 2^48 pages. |
| **Effective Address** | `base + offset` — the actual byte address accessed by a load/store instruction. |
| **Bounds Check** | Verifying that `effective_address + access_size ≤ memory.data.size` before a load/store. |
| **Little-Endian** | Byte order where the least significant byte comes first. Wasm uses LE exclusively. |
| **Packed Load** | Loading fewer bytes than the target type width, then extending (sign or zero). E.g., `i32.load8_s`. |
| **Packed Store** | Storing only the low bytes of a value. E.g., `i32.store8` stores only the low byte. |
| **Data Segment** | A read-only byte array that can be copied into linear memory via `memory.init`. Can be dropped. |
| **GrowthPolicy** | A typeclass for deterministic `memory.grow` behavior. Implementation must prove its result is in `growSpec`. |
| **Multi-Memory** | A Wasm proposal allowing multiple independent linear memories per module. |

## Architecture & Design

| Term | Definition |
|------|-----------|
| **BitVec N** | Lean 4 / Mathlib type representing an N-bit bitvector. The universal representation for all Wasm numeric types. |
| **WasmFloat** | Typeclass providing IEEE 754 operations. Decouples numeric semantics from any specific float implementation. |
| **WasmProfile** | Structure bundling `NaNProfile` + `RelaxedProfile`. Determines runtime behavior for non-deterministic operations. |
| **DeterministicWasmProfile** | Extends `WasmProfile` with proofs that each deterministic choice is in the spec-allowed set. |
| **NaNProfile** | Configuration for NaN selection. Contains a `selectNaN` function and a proof that results are valid NaNs. |
| **RelaxedProfile** | Configuration for all relaxed SIMD operations. Provides deterministic implementations. |
| **Set α** | Lean 4 type `α → Prop`. Used to model non-determinism — a set of all valid results. |
| **Non-determinism** | When the spec allows multiple valid behaviors. Modeled as `Set (BitVec N)` — functions return the full set of allowed outputs. |
| **Trap** | A runtime error that terminates execution. In wasm-num, modeled as `Option` types (none = trap). |
| **ADR** | Architecture Decision Record — a document capturing a significant design decision, its context, and consequences. |

## Lean 4 / Mathlib

| Term | Definition |
|------|-----------|
| **Lean 4** | The proof assistant and programming language used to implement wasm-num. |
| **Mathlib** | The community mathematics library for Lean 4. Provides `BitVec`, `Finset`, algebraic structures, and proof tactics. |
| **Lake** | Lean 4's build system and package manager. Configured via `lakefile.toml`. |
| **Typeclass** | A Lean mechanism for ad-hoc polymorphism (similar to Haskell typeclasses or Rust traits). |
| **Structure** | A named product type in Lean 4 (similar to a record or struct). |
| **Inductive** | An algebraic data type in Lean 4 (tagged union / sum type). |
| **abbrev** | A transparent definition in Lean 4 that creates a type alias. `abbrev I32 := BitVec 32`. |
| **Prop** | The type of propositions in Lean 4. A type whose values are proofs. |
| **omega** | A Lean 4 tactic for deciding linear arithmetic over naturals and integers. |
| **simp** | A Lean 4 tactic for simplification using rewrite rules. |
| **decide** | A Lean 4 tactic for decidable propositions — brute-force evaluation. |

## Abbreviations

| Abbreviation | Full Form |
|--------------|-----------|
| **Wasm** | WebAssembly |
| **IEEE 754** | IEEE Standard for Floating-Point Arithmetic |
| **SIMD** | Single Instruction, Multiple Data |
| **LE** | Little-Endian |
| **MSB** | Most Significant Bit |
| **LSB** | Least Significant Bit |
| **OOB** | Out Of Bounds |
| **FMA** | Fused Multiply-Add |
| **SAT** | Saturating (clamp to representable range) |
| **FFI** | Foreign Function Interface |
| **CI/CD** | Continuous Integration / Continuous Deployment |
| **ADR** | Architecture Decision Record |

## See Also

- [Architecture Overview](../architecture/)
- [Foundation API](api/foundation.md)
- [Design Principles](../design/principles.md)
