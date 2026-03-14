# Numerics API Reference

> **Module**: `WasmNum.Numerics`
> **Source**: `WasmNum/Numerics/`

## NaN Propagation

> **Source**: `WasmNum/Numerics/NaN/Propagation.lean`

### Sets

| Function | Signature | Description |
|----------|-----------|-------------|
| `nans` | `(N : Nat) → [WasmFloat N] → Set (BitVec N)` | All NaN values for width N |
| `canonicalNans` | `(N : Nat) → [WasmFloat N] → Set (BitVec N)` | Canonical NaN set (±) |
| `arithmeticNans` | `(N : Nat) → [WasmFloat N] → Set (BitVec N)` | All quiet (arithmetic) NaN values |

### NaN Result Sets

| Function | Signature | Description |
|----------|-----------|-------------|
| `payloadOverlapsAny` | `BitVec N → List (BitVec N) → Prop` | Payload overlaps at least one input |
| `overlappingArithmeticNans` | `(N : Nat) → List (BitVec N) → Set (BitVec N)` | Arithmetic NaNs with overlapping payloads |
| `nansN` | `(N : Nat) → [WasmFloat N] → List (BitVec N) → Set (BitVec N)` | Spec `nans_N{z*}`: canonical ∪ overlapping arithmetic NaNs |

### Propagation Functions

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `propagateNaN₁` | `(op : BitVec N → BitVec N) → BitVec N → Set (BitVec N)` | `Set` | Unary NaN propagation |
| `propagateNaN₂` | `(op : BitVec N → BitVec N → BitVec N) → BitVec N → BitVec N → Set (BitVec N)` | `Set` | Binary NaN propagation |

---

## NaN Deterministic

> **Source**: `WasmNum/Numerics/NaN/Deterministic.lean`

### `DeterministicWasmProfile`

Extends `WasmProfile` with a proof that `selectNaN` always produces a value in `nansN`:

```lean
structure DeterministicWasmProfile extends WasmProfile where
  selectNaN_mem : ∀ N [WasmFloat N] inputs,
    nanProfile.selectNaN N inputs ∈ nansN N inputs
```

### Deterministic Propagation

| Function | Signature | Description |
|----------|-----------|-------------|
| `propagateNaN₁_det` | `DeterministicWasmProfile → (BitVec N → BitVec N) → BitVec N → BitVec N` | Deterministic unary |
| `propagateNaN₂_det` | `DeterministicWasmProfile → (BitVec N → BitVec N → BitVec N) → BitVec N → BitVec N → BitVec N` | Deterministic binary |

---

## Float MinMax

> **Source**: `WasmNum/Numerics/Float/MinMax.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `fmin` | `[WasmFloat N] → BitVec N → BitVec N → Set (BitVec N)` | `Set` | Wasm `fmin` with signed-zero handling |
| `fmax` | `[WasmFloat N] → BitVec N → BitVec N → Set (BitVec N)` | `Set` | Wasm `fmax` with signed-zero handling |

**Behavior**:
- If either operand is NaN: result ∈ `nansN`
- Both zero, different signs: `fmin` returns -0, `fmax` returns +0
- Otherwise: returns the smaller/larger value

---

## Float Rounding

> **Source**: `WasmNum/Numerics/Float/Rounding.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `fnearest` | `[WasmFloat N] → BitVec N → Set (BitVec N)` | `Set` | Round to nearest, ties-to-even |
| `fceil` | `[WasmFloat N] → BitVec N → Set (BitVec N)` | `Set` | Round toward +∞ |
| `ffloor` | `[WasmFloat N] → BitVec N → Set (BitVec N)` | `Set` | Round toward -∞ |
| `ftrunc` | `[WasmFloat N] → BitVec N → Set (BitVec N)` | `Set` | Round toward zero |

All return `Set` due to NaN propagation.

---

## Float Sign

> **Source**: `WasmNum/Numerics/Float/Sign.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `fabs` | `BitVec N → BitVec N` | deterministic | Clear sign bit |
| `fneg` | `BitVec N → BitVec N` | deterministic | Toggle sign bit |
| `fcopysign` | `BitVec N → BitVec N → BitVec N` | deterministic | Copy sign of second operand to magnitude of first |

These are pure bitwise operations — no IEEE 754 interpretation needed.

---

## Float Compare

> **Source**: `WasmNum/Numerics/Float/Compare.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `feq` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | Equal (+0 == -0 → 1, NaN → 0) |
| `fne` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | Not equal (NaN → 1) |
| `flt` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | Less than (NaN → 0) |
| `fgt` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | Greater than (NaN → 0) |
| `fle` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | Less or equal (NaN → 0) |
| `fge` | `[WasmFloat N] → BitVec N → BitVec N → I32` | `I32` | Greater or equal (NaN → 0) |

All return `I32` (0 or 1). NaN operands compare as unordered.

---

## Float PseudoMinMax

> **Source**: `WasmNum/Numerics/Float/PseudoMinMax.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `fpmin` | `[WasmFloat N] → BitVec N → BitVec N → BitVec N` | deterministic | `if b < a then b else a` |
| `fpmax` | `[WasmFloat N] → BitVec N → BitVec N → BitVec N` | deterministic | `if a < b then b else a` |

No NaN propagation — NaN returns first operand (unordered comparison). Used by SIMD.

---

## Integer Arithmetic

> **Source**: `WasmNum/Numerics/Integer/Arithmetic.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `iadd` | `BitVec N → BitVec N → BitVec N` | deterministic | Modular addition |
| `isub` | `BitVec N → BitVec N → BitVec N` | deterministic | Modular subtraction |
| `imul` | `BitVec N → BitVec N → BitVec N` | deterministic | Modular multiplication |
| `idiv_u` | `BitVec N → BitVec N → Option (BitVec N)` | `Option` | Unsigned division (none on div/0) |
| `idiv_s` | `BitVec N → BitVec N → Option (BitVec N)` | `Option` | Signed division (none on div/0 or INT_MIN/-1) |
| `irem_u` | `BitVec N → BitVec N → Option (BitVec N)` | `Option` | Unsigned remainder (none on div/0) |
| `irem_s` | `BitVec N → BitVec N → Option (BitVec N)` | `Option` | Signed remainder, sign of dividend (none on div/0) |

---

## Integer Bitwise

> **Source**: `WasmNum/Numerics/Integer/Bitwise.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `iand` | `BitVec N → BitVec N → BitVec N` | Bitwise AND |
| `ior` | `BitVec N → BitVec N → BitVec N` | Bitwise OR |
| `ixor` | `BitVec N → BitVec N → BitVec N` | Bitwise XOR |
| `inot` | `BitVec N → BitVec N` | Bitwise complement |
| `iandnot` | `BitVec N → BitVec N → BitVec N` | `a AND (NOT b)` |

---

## Integer Shift

> **Source**: `WasmNum/Numerics/Integer/Shift.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `ishl` | `BitVec N → BitVec N → BitVec N` | Shift left by `(k mod N)` bits |
| `ishr_u` | `BitVec N → BitVec N → BitVec N` | Logical shift right by `(k mod N)` |
| `ishr_s` | `BitVec N → BitVec N → BitVec N` | Arithmetic shift right by `(k mod N)` |
| `irotl` | `BitVec N → BitVec N → BitVec N` | Rotate left |
| `irotr` | `BitVec N → BitVec N → BitVec N` | Rotate right |

Shift amount is always taken modulo bit width N.

---

## Integer Compare

> **Source**: `WasmNum/Numerics/Integer/Compare.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `ieqz` | `BitVec N → I32` | Test if zero |
| `ieq` | `BitVec N → BitVec N → I32` | Equal |
| `ine` | `BitVec N → BitVec N → I32` | Not equal |
| `ilt_u` / `ilt_s` | `BitVec N → BitVec N → I32` | Less than (unsigned / signed) |
| `igt_u` / `igt_s` | `BitVec N → BitVec N → I32` | Greater than |
| `ile_u` / `ile_s` | `BitVec N → BitVec N → I32` | Less or equal |
| `ige_u` / `ige_s` | `BitVec N → BitVec N → I32` | Greater or equal |

All return `I32` (0 or 1).

---

## Integer Bits

> **Source**: `WasmNum/Numerics/Integer/Bits.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `iclz` | `BitVec N → BitVec N` | Count leading zeros |
| `ictz` | `BitVec N → BitVec N` | Count trailing zeros |
| `ipopcnt` | `BitVec N → BitVec N` | Population count (number of set bits) |

---

## Integer Ext

> **Source**: `WasmNum/Numerics/Integer/Ext.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `iextend_s` | `(fromWidth : Nat) → BitVec N → BitVec N` | Sign-extend low `fromWidth` bits to full N-bit width |

---

## Integer Saturating

> **Source**: `WasmNum/Numerics/Integer/Saturating.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `sat_s` | `(N : Nat) → Int → BitVec N` | Clamp integer to signed N-bit range |
| `sat_u` | `(N : Nat) → Int → BitVec N` | Clamp integer to unsigned N-bit range |
| `iadd_sat_s` | `BitVec N → BitVec N → BitVec N` | Signed saturating addition |
| `iadd_sat_u` | `BitVec N → BitVec N → BitVec N` | Unsigned saturating addition |
| `isub_sat_s` | `BitVec N → BitVec N → BitVec N` | Signed saturating subtraction |
| `isub_sat_u` | `BitVec N → BitVec N → BitVec N` | Unsigned saturating subtraction |

---

## Integer MinMax

> **Source**: `WasmNum/Numerics/Integer/MinMax.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `imin_u` / `imin_s` | `BitVec N → BitVec N → BitVec N` | Minimum (unsigned / signed) |
| `imax_u` / `imax_s` | `BitVec N → BitVec N → BitVec N` | Maximum (unsigned / signed) |

---

## Integer Misc

> **Source**: `WasmNum/Numerics/Integer/Misc.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `iabs` | `BitVec N → BitVec N` | Absolute value (signed interpretation) |
| `ineg` | `BitVec N → BitVec N` | Two's complement negation |
| `iavgr_u` | `BitVec N → BitVec N → BitVec N` | Unsigned rounding average: `(a + b + 1) / 2` |
| `iq15mulr_sat_s` | `BitVec 16 → BitVec 16 → BitVec 16` | Q15 saturating rounding multiply (16-bit only) |

---

## Integer Bitselect

> **Source**: `WasmNum/Numerics/Integer/Bitselect.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `ibitselect` | `BitVec N → BitVec N → BitVec N → BitVec N` | `(a AND mask) OR (b AND NOT mask)` |

---

## Conversion TruncPartial

> **Source**: `WasmNum/Numerics/Conversion/TruncPartial.lean`

Trapping conversions — return `none` on NaN, infinity, or out-of-range:

| Function | From → To | Description |
|----------|-----------|-------------|
| `truncToIntS` | `float N → Option (BitVec M)` | Generic signed trunc |
| `truncToIntU` | `float N → Option (BitVec M)` | Generic unsigned trunc |
| `truncF32ToI32S` | `F32 → Option I32` | f32 → i32 (signed) |
| `truncF32ToI32U` | `F32 → Option I32` | f32 → i32 (unsigned) |
| `truncF64ToI32S` | `F64 → Option I32` | f64 → i32 (signed) |
| `truncF64ToI32U` | `F64 → Option I32` | f64 → i32 (unsigned) |
| `truncF32ToI64S` | `F32 → Option I64` | f32 → i64 (signed) |
| `truncF32ToI64U` | `F32 → Option I64` | f32 → i64 (unsigned) |
| `truncF64ToI64S` | `F64 → Option I64` | f64 → i64 (signed) |
| `truncF64ToI64U` | `F64 → Option I64` | f64 → i64 (unsigned) |

---

## Conversion TruncSat

> **Source**: `WasmNum/Numerics/Conversion/TruncSat.lean`

Saturating conversions — NaN→0, -Inf→min, +Inf→max, out-of-range→clamp:

| Function | From → To | Description |
|----------|-----------|-------------|
| `truncSatToIntS` | `float N → BitVec M` | Generic signed saturating trunc |
| `truncSatToIntU` | `float N → BitVec M` | Generic unsigned saturating trunc |
| `truncSatF32ToI32S` | `F32 → I32` | f32 → i32 (signed, saturating) |
| `truncSatF32ToI32U` | `F32 → I32` | f32 → i32 (unsigned, saturating) |
| `truncSatF64ToI32S` | `F64 → I32` | Same pattern for all 8 combinations |
| ... | ... | ... |

---

## Conversion PromoteDemote

> **Source**: `WasmNum/Numerics/Conversion/PromoteDemote.lean`

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `promoteF32` | `F32 → Set F64` | `Set` | f32 → f64 (exact, NaN canonical/arithmetic) |
| `demoteF64` | `F64 → Set F32` | `Set` | f64 → f32 (lossy, may round, NaN handling) |

---

## Conversion ConvertIntFloat

> **Source**: `WasmNum/Numerics/Conversion/ConvertIntFloat.lean`

| Function | From → To | Description |
|----------|-----------|-------------|
| `convertI32SToF32` | `I32 → F32` | Signed i32 → f32 (round ties-to-even) |
| `convertI32UToF32` | `I32 → F32` | Unsigned i32 → f32 |
| `convertI32SToF64` | `I32 → F64` | Signed i32 → f64 (exact) |
| `convertI32UToF64` | `I32 → F64` | Unsigned i32 → f64 (exact) |
| `convertI64SToF32` | `I64 → F32` | Signed i64 → f32 |
| `convertI64UToF32` | `I64 → F32` | Unsigned i64 → f32 |
| `convertI64SToF64` | `I64 → F64` | Signed i64 → f64 |
| `convertI64UToF64` | `I64 → F64` | Unsigned i64 → f64 |

---

## Conversion Reinterpret

> **Source**: `WasmNum/Numerics/Conversion/Reinterpret.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `reinterpretF32AsI32` | `F32 → I32` | Identity (same BitVec 32) |
| `reinterpretI32AsF32` | `I32 → F32` | Identity |
| `reinterpretF64AsI64` | `F64 → I64` | Identity (same BitVec 64) |
| `reinterpretI64AsF64` | `I64 → F64` | Identity |

These are no-ops because integers and floats share the same `BitVec N` representation.

---

## Conversion IntWidth

> **Source**: `WasmNum/Numerics/Conversion/IntWidth.lean`

| Function | Signature | Description |
|----------|-----------|-------------|
| `wrapI64` | `I64 → I32` | Truncate to low 32 bits |
| `extendI32S` | `I32 → I64` | Sign-extend i32 to i64 |
| `extendI32U` | `I32 → I64` | Zero-extend i32 to i64 |
| `extendI32From8S` | `I32 → I32` | Sign-extend low 8 bits |
| `extendI32From16S` | `I32 → I32` | Sign-extend low 16 bits |
| `extendI64From8S` | `I64 → I64` | Sign-extend low 8 bits |
| `extendI64From16S` | `I64 → I64` | Sign-extend low 16 bits |
| `extendI64From32S` | `I64 → I64` | Sign-extend low 32 bits |

## Related

- [Foundation API](foundation.md)
- [SIMD API](simd.md) — uses integer/float ops lanewise
- [Integration API](integration.md) — deterministic wrappers
- [ADR-003: Non-determinism as Sets](../../design/adr/0003-nondeterminism-as-sets.md)
