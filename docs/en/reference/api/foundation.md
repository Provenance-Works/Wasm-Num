# Foundation API Reference

> **Module**: `WasmNum.Foundation`
> **Source**: `WasmNum/Foundation/`

## Types

> **Source**: `WasmNum/Foundation/Types.lean`

All WebAssembly numeric types are aliases for `BitVec N`:

```lean
abbrev I32   := BitVec 32
abbrev I64   := BitVec 64
abbrev F32   := BitVec 32
abbrev F64   := BitVec 64
abbrev V128  := BitVec 128
abbrev Byte  := BitVec 8
abbrev Addr32 := BitVec 32
abbrev Addr64 := BitVec 64
```

> **Note:** `I32` and `F32` are the same type (`BitVec 32`). The interpretation depends on which operations you apply.

## Basic Definitions

> **Source**: `WasmNum/Foundation/Defs.lean`

```lean
def pageSize : Nat := 65536   -- Wasm page size: 64 KiB
```

## BitVecOps

> **Source**: `WasmNum/Foundation/BitVec.lean`
> **Namespace**: `BitVecOps`

### `getByte`

```lean
def getByte (v : BitVec N) (i : Nat) : Byte
```

Extract the i-th byte from a `BitVec` in little-endian order (LSB = byte 0).

### `toLittleEndian`

```lean
def toLittleEndian (v : BitVec N) : Vector Byte (N / 8)
```

Decompose a `BitVec` into bytes in little-endian order.

### `fromLittleEndian`

```lean
def fromLittleEndian (bytes : Vector Byte n) : BitVec (n * 8)
```

Recompose bytes in little-endian order into a `BitVec`.

### `toBytes` / `fromBytes`

Aliases for `toLittleEndian` / `fromLittleEndian`. WebAssembly uses little-endian exclusively.

### `signExtend`

```lean
def signExtend (v : BitVec m) : BitVec N
```

Sign-extend from width `m` to width `N`. Requires proof that `m ≤ N`.

### `zeroExtend`

```lean
def zeroExtend (v : BitVec m) : BitVec N
```

Zero-extend from width `m` to width `N`. Requires proof that `m ≤ N`.

### `extractBits`

```lean
def extractBits (v : BitVec N) (lo width : Nat) : BitVec width
```

Extract a range of bits starting at `lo` with the given `width`.

### `concat`

```lean
def concat (a : BitVec m) (b : BitVec n) : BitVec (m + n)
```

Concatenation wrapper for `BitVec.append`.

---

## WasmFloat Typeclass

> **Source**: `WasmNum/Foundation/WasmFloat.lean`

The central abstraction for IEEE 754 floating-point operations (ADR-001).

```lean
class WasmFloat (N : Nat) where
```

### Classification Predicates

| Method | Type | Description |
|--------|------|-------------|
| `isNaN` | `BitVec N → Bool` | True if value is any NaN |
| `isInfinite` | `BitVec N → Bool` | True if ±∞ |
| `isZero` | `BitVec N → Bool` | True if ±0 |
| `isNegative` | `BitVec N → Bool` | True if sign bit = 1 |
| `isSubnormal` | `BitVec N → Bool` | True if subnormal |
| `isCanonicalNaN` | `BitVec N → Bool` | True if canonical NaN |
| `isArithmeticNaN` | `BitVec N → Bool` | True if quiet (arithmetic) NaN |
| `canonicalNaN` | `BitVec N` | Positive canonical NaN constant |

### Arithmetic Operations

All use round-to-nearest, ties-to-even:

| Method | Type | Description |
|--------|------|-------------|
| `add` | `BitVec N → BitVec N → BitVec N` | Addition |
| `sub` | `BitVec N → BitVec N → BitVec N` | Subtraction |
| `mul` | `BitVec N → BitVec N → BitVec N` | Multiplication |
| `div` | `BitVec N → BitVec N → BitVec N` | Division |
| `sqrt` | `BitVec N → BitVec N` | Square root |
| `fma` | `BitVec N → BitVec N → BitVec N → BitVec N` | Fused multiply-add |

### Rounding Primitives

| Method | Type | Description |
|--------|------|-------------|
| `nearestInt` | `BitVec N → BitVec N` | Round to nearest, ties-to-even |
| `ceilInt` | `BitVec N → BitVec N` | Round toward +∞ |
| `floorInt` | `BitVec N → BitVec N` | Round toward -∞ |
| `truncInt` | `BitVec N → BitVec N` | Round toward zero |

### Comparisons

| Method | Type | Description |
|--------|------|-------------|
| `lt` | `BitVec N → BitVec N → Bool` | Less than (NaN → false) |
| `le` | `BitVec N → BitVec N → Bool` | Less or equal (NaN → false) |
| `eq` | `BitVec N → BitVec N → Bool` | Equal (+0 == -0 → true, NaN → false) |

### Conversions

| Method | Type | Description |
|--------|------|-------------|
| `truncToInt` | `BitVec N → Option Int` | To integer (none on NaN/Inf/overflow) |
| `truncToNat` | `BitVec N → Option Nat` | To natural (none on NaN/Inf/negative) |
| `convertFromInt` | `Int → BitVec N` | From integer (round ties-to-even) |
| `convertFromNat` | `Nat → BitVec N` | From natural (round ties-to-even) |

### Other

| Method | Type | Description |
|--------|------|-------------|
| `sign_bit` | `BitVec N → Bool` | MSB (sign bit) |
| `payloadOverlap` | `BitVec N → BitVec N → Prop` | NaN payload overlap relation |

### Structural Proofs

Every `WasmFloat` instance must provide:

- `isNaN_canonicalNaN : isNaN canonicalNaN = true`
- `isCanonicalNaN_isNaN : ∀ v, isCanonicalNaN v = true → isNaN v = true`
- `isArithmeticNaN_isNaN : ∀ v, isArithmeticNaN v = true → isNaN v = true`

### Companion Typeclasses

```lean
class WasmFloatPromote where
  promote : BitVec 32 → BitVec 64    -- f32 → f64 (exact)

class WasmFloatDemote where
  demote : BitVec 64 → BitVec 32     -- f64 → f32 (may round)
```

---

## WasmFloat Default Stub

> **Source**: `WasmNum/Foundation/WasmFloat/Default.lean`

Provides `WasmFloat 32` and `WasmFloat 64` instances for testing. Classification is correct (binary32/binary64 layout), but arithmetic and rounding return placeholder values (canonical NaN).

> **Warning:** Not suitable for production. Use a proper IEEE 754 bridge.

---

## Profiles

> **Source**: `WasmNum/Foundation/Profile.lean`

### `NaNProfile`

```lean
structure NaNProfile where
  selectNaN : (N : Nat) → [WasmFloat N] → List (BitVec N) → BitVec N
  selectNaN_isNaN : ∀ N [WasmFloat N] inputs,
    WasmFloat.isNaN (selectNaN N inputs) = true
```

Selects a single NaN from the spec-allowed set. Carries a proof that the result is always a valid NaN.

### `RelaxedProfile`

```lean
structure RelaxedProfile where
  relaxedMaddImpl        : V128 → V128 → V128 → V128
  relaxedNmaddImpl       : V128 → V128 → V128 → V128
  relaxedMaddF64Impl     : V128 → V128 → V128 → V128
  relaxedNmaddF64Impl    : V128 → V128 → V128 → V128
  relaxedMinImpl32       : BitVec 32 → BitVec 32 → BitVec 32
  relaxedMaxImpl32       : BitVec 32 → BitVec 32 → BitVec 32
  relaxedMinImpl64       : BitVec 64 → BitVec 64 → BitVec 64
  relaxedMaxImpl64       : BitVec 64 → BitVec 64 → BitVec 64
  relaxedSwizzleImpl     : V128 → V128 → V128
  relaxedTruncF32x4SImpl : V128 → V128
  relaxedTruncF32x4UImpl : V128 → V128
  relaxedTruncF64x2SZeroImpl  : V128 → V128
  relaxedTruncF64x2UZeroImpl  : V128 → V128
  relaxedLaneselectImpl  : V128 → V128 → V128 → V128
  relaxedDotI8x16I7x16SImpl    : V128 → V128 → V128
  relaxedDotI8x16I7x16AddSImpl : V128 → V128 → V128 → V128
  relaxedQ15MulrSImpl    : V128 → V128 → V128
```

Deterministic implementations for all relaxed SIMD operations.

### `WasmProfile`

```lean
structure WasmProfile where
  nanProfile     : NaNProfile
  relaxedProfile : RelaxedProfile
```

Bundles NaN selection and relaxed SIMD implementations.

## Related

- [Numerics API](numerics.md)
- [Architecture: Data Model](../../architecture/data-model.md)
- [ADR-001: IEEE 754 Independence](../../design/adr/0001-typeclass-mediated-754-independence.md)
- [ADR-002: BitVec Universal Representation](../../design/adr/0002-bitvec-universal-representation.md)
- [Glossary](../glossary.md)
