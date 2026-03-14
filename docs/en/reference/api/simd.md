# SIMD API Reference

> **Module**: `WasmNum.SIMD`
> **Source**: `WasmNum/SIMD/`

## V128 Shape

> **Source**: `WasmNum/SIMD/V128/Shape.lean`

### `LaneType`

```lean
inductive LaneType where
  | int
  | float
```

### `Shape`

```lean
structure Shape where
  laneWidth : Nat
  laneCount : Nat
  laneType  : LaneType
  valid     : laneWidth * laneCount = 128
  widthPow2 : ∃ k, laneWidth = 2 ^ k ∧ 3 ≤ k ∧ k ≤ 6
```

### Concrete Shapes

| Constant | Lane Width | Lane Count | Type |
|----------|:----------:|:----------:|------|
| `Shape.i8x16` | 8 | 16 | int |
| `Shape.i16x8` | 16 | 8 | int |
| `Shape.i32x4` | 32 | 4 | int |
| `Shape.i64x2` | 64 | 2 | int |
| `Shape.f32x4` | 32 | 4 | float |
| `Shape.f64x2` | 64 | 2 | float |

| Utility | Description |
|---------|-------------|
| `Shape.all : List Shape` | List of all 6 concrete shapes |

---

## V128 Type

> **Source**: `WasmNum/SIMD/V128/Type.lean`

```lean
abbrev V128 := BitVec 128
```

---

## V128 Lanes

> **Source**: `WasmNum/SIMD/V128/Lanes.lean`

### Core Lane Operations

| Function | Signature | Description |
|----------|-----------|-------------|
| `lane` | `(s : Shape) → V128 → Fin s.laneCount → BitVec s.laneWidth` | Extract lane i |
| `replaceLane` | `(s : Shape) → V128 → Fin s.laneCount → BitVec s.laneWidth → V128` | Replace lane i |
| `ofLanes` | `(s : Shape) → (Fin s.laneCount → BitVec s.laneWidth) → V128` | Create from lane function |
| `splat` | `(s : Shape) → BitVec s.laneWidth → V128` | Replicate value across all lanes |

### Higher-Order Lane Operations

| Function | Signature | Description |
|----------|-----------|-------------|
| `mapLanes` | `(s : Shape) → (BitVec s.laneWidth → BitVec s.laneWidth) → V128 → V128` | Apply unary op lanewise |
| `zipLanes` | `(s : Shape) → (BitVec s.laneWidth → BitVec s.laneWidth → BitVec s.laneWidth) → V128 → V128 → V128` | Apply binary op lanewise |

### Constants

| Constant | Value |
|----------|-------|
| `V128.zero` | All zero bits |
| `V128.allOnes` | All one bits |

---

## Ops Bitwise

> **Source**: `WasmNum/SIMD/Ops/Bitwise.lean`

Shape-independent (operate on full 128-bit vector):

| Function | Signature | Description |
|----------|-----------|-------------|
| `v128_not` | `V128 → V128` | Bitwise NOT |
| `v128_and` | `V128 → V128 → V128` | AND |
| `v128_andnot` | `V128 → V128 → V128` | `a AND (NOT b)` |
| `v128_or` | `V128 → V128 → V128` | OR |
| `v128_xor` | `V128 → V128 → V128` | XOR |
| `v128_bitselect` | `V128 → V128 → V128 → V128` | Bitwise selection |
| `v128_any_true` | `V128 → I32` | 1 if any bit set, 0 otherwise |
| `boolToMask` | `(n : Nat) → Bool → BitVec n` | Bool to all-1s or all-0s mask |

---

## Ops IntLanewise

> **Source**: `WasmNum/SIMD/Ops/IntLanewise.lean`

All take a `Shape` parameter and operate lanewise:

### Arithmetic

| Function | Signature |
|----------|-----------|
| `add` | `Shape → V128 → V128 → V128` |
| `sub` | `Shape → V128 → V128 → V128` |
| `neg` | `Shape → V128 → V128` |
| `mul` | `Shape → V128 → V128 → V128` |

### Saturating Arithmetic

| Function | Signature |
|----------|-----------|
| `addSatS` / `addSatU` | `Shape → V128 → V128 → V128` |
| `subSatS` / `subSatU` | `Shape → V128 → V128 → V128` |

### Min/Max

| Function | Signature |
|----------|-----------|
| `minS` / `minU` | `Shape → V128 → V128 → V128` |
| `maxS` / `maxU` | `Shape → V128 → V128 → V128` |

### Shifts

Shift amount is `I32`, taken modulo lane width:

| Function | Signature | Description |
|----------|-----------|-------------|
| `shl` | `Shape → V128 → I32 → V128` | Shift left |
| `shrS` | `Shape → V128 → I32 → V128` | Arithmetic shift right |
| `shrU` | `Shape → V128 → I32 → V128` | Logical shift right |

### Comparisons

Result: all-1s (true) or all-0s (false) per lane:

| Function | Signature |
|----------|-----------|
| `eqLane` / `neLane` | `Shape → V128 → V128 → V128` |
| `ltSLane` / `ltULane` | `Shape → V128 → V128 → V128` |
| `leSLane` / `leULane` | `Shape → V128 → V128 → V128` |
| `gtSLane` / `gtULane` | `Shape → V128 → V128 → V128` |
| `geSLane` / `geULane` | `Shape → V128 → V128 → V128` |

### Miscellaneous

| Function | Signature | Description |
|----------|-----------|-------------|
| `abs` | `Shape → V128 → V128` | Absolute value |
| `avgRU` | `Shape → V128 → V128 → V128` | Unsigned rounding average |
| `popcnt_i8x16` | `V128 → V128` | Population count (i8x16 only) |
| `q15mulrSatS` | `V128 → V128 → V128` | Q15 saturating multiply (i16x8) |

---

## Ops FloatLanewise

> **Source**: `WasmNum/SIMD/Ops/FloatLanewise.lean`

### Arithmetic (Set-returning — NaN non-determinism)

| Function | Signature |
|----------|-----------|
| `fadd` | `(s : Shape) → [WasmFloat s.laneWidth] → V128 → V128 → Set V128` |
| `fsub` | `(s : Shape) → [WasmFloat s.laneWidth] → V128 → V128 → Set V128` |
| `fmul` | same |
| `fdiv` | same |
| `fsqrt` | `(s : Shape) → [WasmFloat s.laneWidth] → V128 → Set V128` |

### Min/Max

| Function | Returns | Description |
|----------|---------|-------------|
| `fminLane` | `Set V128` | Lanewise fmin with NaN propagation |
| `fmaxLane` | `Set V128` | Lanewise fmax with NaN propagation |
| `fpminLane` | `V128` | Lanewise pseudo-min (deterministic) |
| `fpmaxLane` | `V128` | Lanewise pseudo-max (deterministic) |

### Rounding (Set-returning)

| Function | Returns |
|----------|---------|
| `fceilLane` / `ffloorLane` / `ftruncLane` / `fnearestLane` | `Set V128` |

### Bitwise (deterministic)

| Function | Returns | Description |
|----------|---------|-------------|
| `fabsLane` | `V128` | Clear sign bit per lane |
| `fnegLane` | `V128` | Toggle sign bit per lane |

### Comparisons (deterministic)

Result: all-1s (true) or all-0s (false) per lane:

| Function | Returns |
|----------|---------|
| `feqLane` / `fneLane` / `fltLane` / `fleLane` / `fgtLane` / `fgeLane` | `V128` |

---

## Ops Bitmask

> **Source**: `WasmNum/SIMD/Ops/Bitmask.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `allTrue` | `Shape → V128 → Bool` | True if all lanes are non-zero |
| `bitmask` | `Shape → V128 → I32` | Extract MSB of each lane into a bitmask |

---

## Ops Narrow

> **Source**: `WasmNum/SIMD/Ops/Narrow.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `narrowS` | `Shape → V128 → V128 → V128` | Narrow with signed saturation |
| `narrowU` | `Shape → V128 → V128 → V128` | Narrow with unsigned saturation |

---

## Ops Extend

> **Source**: `WasmNum/SIMD/Ops/Extend.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `extendLowS` / `extendLowU` | `Shape → V128 → V128` | Widen low half lanes |
| `extendHighS` / `extendHighU` | `Shape → V128 → V128` | Widen high half lanes |
| `extAddPairwiseS` / `extAddPairwiseU` | `Shape → V128 → V128` | Pairwise add with extension |
| `extMulS` / `extMulU` | `Shape → V128 → V128 → V128` | Extended multiply |

---

## Ops Dot

> **Source**: `WasmNum/SIMD/Ops/Dot.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `dot_i16x8_i32x4` | `V128 → V128 → V128` | i16x8 dot product → i32x4 |

---

## Ops Swizzle

> **Source**: `WasmNum/SIMD/Ops/Swizzle.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `swizzle` | `V128 → V128 → V128` | Lane swizzle: idx values select lanes |

---

## Ops Shuffle

> **Source**: `WasmNum/SIMD/Ops/Shuffle.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `shuffle` | `Shape → V128 → V128 → Vector (Fin (2 * s.laneCount)) s.laneCount → V128` | Select lanes from two vectors |

---

## Ops SplatExtractReplace

> **Source**: `WasmNum/SIMD/Ops/SplatExtractReplace.lean`

Per-shape splat, extract, and replace operations:

| Shape | Splat | Extract | Replace |
|-------|-------|---------|---------|
| i8x16 | `splat_i8x16` | `extractLane_i8x16` | `replaceLane_i8x16` |
| i16x8 | `splat_i16x8` | `extractLane_i16x8` | `replaceLane_i16x8` |
| i32x4 | `splat_i32x4` | `extractLane_i32x4` | `replaceLane_i32x4` |
| i64x2 | `splat_i64x2` | `extractLane_i64x2` | `replaceLane_i64x2` |

---

## Ops Convert

> **Source**: `WasmNum/SIMD/Ops/Convert.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `convertI32x4` | `V128 → V128` | deterministic | i32x4 → f32x4 |
| `truncSatF32x4S` | `V128 → V128` | deterministic | f32x4 → i32x4 (signed saturating) |
| `truncSatF32x4U` | `V128 → V128` | deterministic | f32x4 → i32x4 (unsigned saturating) |
| `truncSatF64x2S` | `V128 → V128` | deterministic | f64x2 → i64x2 (signed saturating) |
| `truncSatF64x2U` | `V128 → V128` | deterministic | f64x2 → i64x2 (unsigned saturating) |
| `promoteF32x4` | `V128 → Set V128` | `Set` | f32x4 → f64x2 (low half, NaN handling) |
| `demoteF64x2` | `V128 → Set V128` | `Set` | f64x2 → f32x4 (with zero fill, NaN handling) |

---

## Relaxed Madd

> **Source**: `WasmNum/SIMD/Relaxed/Madd.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `madd` | `Shape → [WasmFloat s.laneWidth] → V128 → V128 → V128 → Set V128` | `Set` | Relaxed fused multiply-add |
| `nmadd` | same | `Set` | Relaxed negated fused multiply-add |

---

## Relaxed MinMax

> **Source**: `WasmNum/SIMD/Relaxed/MinMax.lean`

| Function | Signature | Returns |
|----------|-----------|---------|
| `min` | `Shape → [WasmFloat s.laneWidth] → V128 → V128 → Set V128` | `Set` |
| `max` | same | `Set` |

---

## Relaxed Swizzle

> **Source**: `WasmNum/SIMD/Relaxed/Swizzle.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `swizzle` | `V128 → V128 → Set V128` | `Set` | Out-of-bounds may zero or saturate |

---

## Relaxed Trunc

> **Source**: `WasmNum/SIMD/Relaxed/Trunc.lean`

| Function | Returns | Description |
|----------|---------|-------------|
| `truncF32x4S` | `Set V128` | f32x4 → i32x4 (relaxed signed) |
| `truncF32x4U` | `Set V128` | f32x4 → i32x4 (relaxed unsigned) |
| `truncF64x2SZero` | `Set V128` | f64x2 → i32x4 (relaxed signed, zero-fill) |
| `truncF64x2UZero` | `Set V128` | f64x2 → i32x4 (relaxed unsigned, zero-fill) |

---

## Relaxed Laneselect

> **Source**: `WasmNum/SIMD/Relaxed/Laneselect.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `laneselect` | `Shape → V128 → V128 → V128 → Set V128` | `Set` | MSB-based or bitwise selection |

---

## Relaxed Dot

> **Source**: `WasmNum/SIMD/Relaxed/Dot.lean`

| Function | Returns | Description |
|----------|---------|-------------|
| `dot_i8x16_i7x16_s` | `Set V128` | Relaxed i8×i7 signed dot |
| `dot_i8x16_i7x16_add_s` | `Set V128` | Relaxed dot with accumulate |

---

## Relaxed Q15

> **Source**: `WasmNum/SIMD/Relaxed/Q15.lean`

| Function | Returns | Description |
|----------|---------|-------------|
| `q15mulrS` | `Set V128` | Relaxed Q15 saturating rounding multiply |

## Related

- [Foundation API](foundation.md) — types and WasmFloat
- [Numerics API](numerics.md) — scalar operations used lanewise
- [Memory API](memory.md) — SIMD load/store
- [ADR-004: V128 Shape System](../../design/adr/0004-v128-shape-system.md)
