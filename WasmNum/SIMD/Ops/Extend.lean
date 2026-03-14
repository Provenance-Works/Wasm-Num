import WasmNum.SIMD.V128.Lanes

/-!
# Widening / Extension Operations

Extend lanes from a narrower shape to a wider shape (low/high halves),
extended add pairwise, and extended multiply.

Precondition: `narrow.laneCount = 2 * wide.laneCount` (the narrow shape
has twice as many lanes as the wide shape). This ensures the low/high
half split is well-defined.

Valid Wasm shape pairs: (i8x16 → i16x8), (i16x8 → i32x4), (i32x4 → i64x2).

Wasm spec: SIMD proposal
- FR-303: extend_low/high, extadd_pairwise, extmul
-/

namespace WasmNum.SIMD.Ops

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

-- === Extend Low / High ===

/-- Widen low half lanes with sign extension.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extend_low_iN'xM'_s` -/
def extendLowS (narrow wide : Shape) (v : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    have h : i.val < narrow.laneCount := by omega
    (V128.lane narrow v ⟨i.val, h⟩).signExtend wide.laneWidth)

/-- Widen low half lanes with zero extension.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extend_low_iN'xM'_u` -/
def extendLowU (narrow wide : Shape) (v : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    have h : i.val < narrow.laneCount := by omega
    (V128.lane narrow v ⟨i.val, h⟩).zeroExtend wide.laneWidth)

/-- Widen high half lanes with sign extension.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extend_high_iN'xM'_s` -/
def extendHighS (narrow wide : Shape) (v : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    let srcIdx := i.val + wide.laneCount
    have h : srcIdx < narrow.laneCount := by omega
    (V128.lane narrow v ⟨srcIdx, h⟩).signExtend wide.laneWidth)

/-- Widen high half lanes with zero extension.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extend_high_iN'xM'_u` -/
def extendHighU (narrow wide : Shape) (v : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    let srcIdx := i.val + wide.laneCount
    have h : srcIdx < narrow.laneCount := by omega
    (V128.lane narrow v ⟨srcIdx, h⟩).zeroExtend wide.laneWidth)

-- === Extended Add Pairwise ===

/-- Add pairs of adjacent narrow lanes (signed) to produce wider lanes.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extadd_pairwise_iN'xM'_s` -/
def extAddPairwiseS (narrow wide : Shape) (v : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    let lo := i.val * 2
    let hi := lo + 1
    have hlo : lo < narrow.laneCount := by omega
    have hhi : hi < narrow.laneCount := by omega
    let a := (V128.lane narrow v ⟨lo, hlo⟩).signExtend wide.laneWidth
    let b := (V128.lane narrow v ⟨hi, hhi⟩).signExtend wide.laneWidth
    a + b)

/-- Add pairs of adjacent narrow lanes (unsigned) to produce wider lanes.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extadd_pairwise_iN'xM'_u` -/
def extAddPairwiseU (narrow wide : Shape) (v : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    let lo := i.val * 2
    let hi := lo + 1
    have hlo : lo < narrow.laneCount := by omega
    have hhi : hi < narrow.laneCount := by omega
    let a := (V128.lane narrow v ⟨lo, hlo⟩).zeroExtend wide.laneWidth
    let b := (V128.lane narrow v ⟨hi, hhi⟩).zeroExtend wide.laneWidth
    a + b)

-- === Extended Multiply ===

/-- Extended multiply: low half, signed.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extmul_low_iN'xM'_s` -/
def extMulLowS (narrow wide : Shape) (a b : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    have h : i.val < narrow.laneCount := by omega
    let aVal := (V128.lane narrow a ⟨i.val, h⟩).signExtend wide.laneWidth
    let bVal := (V128.lane narrow b ⟨i.val, h⟩).signExtend wide.laneWidth
    aVal * bVal)

/-- Extended multiply: low half, unsigned.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extmul_low_iN'xM'_u` -/
def extMulLowU (narrow wide : Shape) (a b : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    have h : i.val < narrow.laneCount := by omega
    let aVal := (V128.lane narrow a ⟨i.val, h⟩).zeroExtend wide.laneWidth
    let bVal := (V128.lane narrow b ⟨i.val, h⟩).zeroExtend wide.laneWidth
    aVal * bVal)

/-- Extended multiply: high half, signed.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extmul_high_iN'xM'_s` -/
def extMulHighS (narrow wide : Shape) (a b : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    let srcIdx := i.val + wide.laneCount
    have h : srcIdx < narrow.laneCount := by omega
    let aVal := (V128.lane narrow a ⟨srcIdx, h⟩).signExtend wide.laneWidth
    let bVal := (V128.lane narrow b ⟨srcIdx, h⟩).signExtend wide.laneWidth
    aVal * bVal)

/-- Extended multiply: high half, unsigned.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.extmul_high_iN'xM'_u` -/
def extMulHighU (narrow wide : Shape) (a b : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes wide (fun (i : Fin wide.laneCount) =>
    let srcIdx := i.val + wide.laneCount
    have h : srcIdx < narrow.laneCount := by omega
    let aVal := (V128.lane narrow a ⟨srcIdx, h⟩).zeroExtend wide.laneWidth
    let bVal := (V128.lane narrow b ⟨srcIdx, h⟩).zeroExtend wide.laneWidth
    aVal * bVal)

-- === Concrete shape-fixed wrappers for common Wasm shape pairs ===
-- Valid Wasm shape pairs: (i8x16 → i16x8), (i16x8 → i32x4), (i32x4 → i64x2)

private theorem i8x16_i16x8_pair : Shape.i8x16.laneCount = 2 * Shape.i16x8.laneCount := by decide
private theorem i16x8_i32x4_pair : Shape.i16x8.laneCount = 2 * Shape.i32x4.laneCount := by decide
private theorem i32x4_i64x2_pair : Shape.i32x4.laneCount = 2 * Shape.i64x2.laneCount := by decide

/-- `i16x8.extend_low_i8x16_s` -/
def extendLowS_i8x16_i16x8 (v : V128) : V128 := extendLowS Shape.i8x16 Shape.i16x8 v i8x16_i16x8_pair
/-- `i16x8.extend_low_i8x16_u` -/
def extendLowU_i8x16_i16x8 (v : V128) : V128 := extendLowU Shape.i8x16 Shape.i16x8 v i8x16_i16x8_pair
/-- `i16x8.extend_high_i8x16_s` -/
def extendHighS_i8x16_i16x8 (v : V128) : V128 := extendHighS Shape.i8x16 Shape.i16x8 v i8x16_i16x8_pair
/-- `i16x8.extend_high_i8x16_u` -/
def extendHighU_i8x16_i16x8 (v : V128) : V128 := extendHighU Shape.i8x16 Shape.i16x8 v i8x16_i16x8_pair
/-- `i32x4.extend_low_i16x8_s` -/
def extendLowS_i16x8_i32x4 (v : V128) : V128 := extendLowS Shape.i16x8 Shape.i32x4 v i16x8_i32x4_pair
/-- `i32x4.extend_low_i16x8_u` -/
def extendLowU_i16x8_i32x4 (v : V128) : V128 := extendLowU Shape.i16x8 Shape.i32x4 v i16x8_i32x4_pair
/-- `i32x4.extend_high_i16x8_s` -/
def extendHighS_i16x8_i32x4 (v : V128) : V128 := extendHighS Shape.i16x8 Shape.i32x4 v i16x8_i32x4_pair
/-- `i32x4.extend_high_i16x8_u` -/
def extendHighU_i16x8_i32x4 (v : V128) : V128 := extendHighU Shape.i16x8 Shape.i32x4 v i16x8_i32x4_pair
/-- `i64x2.extend_low_i32x4_s` -/
def extendLowS_i32x4_i64x2 (v : V128) : V128 := extendLowS Shape.i32x4 Shape.i64x2 v i32x4_i64x2_pair
/-- `i64x2.extend_low_i32x4_u` -/
def extendLowU_i32x4_i64x2 (v : V128) : V128 := extendLowU Shape.i32x4 Shape.i64x2 v i32x4_i64x2_pair
/-- `i64x2.extend_high_i32x4_s` -/
def extendHighS_i32x4_i64x2 (v : V128) : V128 := extendHighS Shape.i32x4 Shape.i64x2 v i32x4_i64x2_pair
/-- `i64x2.extend_high_i32x4_u` -/
def extendHighU_i32x4_i64x2 (v : V128) : V128 := extendHighU Shape.i32x4 Shape.i64x2 v i32x4_i64x2_pair

-- === Extended Add Pairwise wrappers ===

/-- `i16x8.extadd_pairwise_i8x16_s` -/
def extAddPairwiseS_i8x16_i16x8 (v : V128) : V128 := extAddPairwiseS Shape.i8x16 Shape.i16x8 v i8x16_i16x8_pair
/-- `i16x8.extadd_pairwise_i8x16_u` -/
def extAddPairwiseU_i8x16_i16x8 (v : V128) : V128 := extAddPairwiseU Shape.i8x16 Shape.i16x8 v i8x16_i16x8_pair
/-- `i32x4.extadd_pairwise_i16x8_s` -/
def extAddPairwiseS_i16x8_i32x4 (v : V128) : V128 := extAddPairwiseS Shape.i16x8 Shape.i32x4 v i16x8_i32x4_pair
/-- `i32x4.extadd_pairwise_i16x8_u` -/
def extAddPairwiseU_i16x8_i32x4 (v : V128) : V128 := extAddPairwiseU Shape.i16x8 Shape.i32x4 v i16x8_i32x4_pair

-- === Extended Multiply wrappers ===

/-- `i16x8.extmul_low_i8x16_s` -/
def extMulLowS_i8x16_i16x8 (a b : V128) : V128 := extMulLowS Shape.i8x16 Shape.i16x8 a b i8x16_i16x8_pair
/-- `i16x8.extmul_low_i8x16_u` -/
def extMulLowU_i8x16_i16x8 (a b : V128) : V128 := extMulLowU Shape.i8x16 Shape.i16x8 a b i8x16_i16x8_pair
/-- `i16x8.extmul_high_i8x16_s` -/
def extMulHighS_i8x16_i16x8 (a b : V128) : V128 := extMulHighS Shape.i8x16 Shape.i16x8 a b i8x16_i16x8_pair
/-- `i16x8.extmul_high_i8x16_u` -/
def extMulHighU_i8x16_i16x8 (a b : V128) : V128 := extMulHighU Shape.i8x16 Shape.i16x8 a b i8x16_i16x8_pair
/-- `i32x4.extmul_low_i16x8_s` -/
def extMulLowS_i16x8_i32x4 (a b : V128) : V128 := extMulLowS Shape.i16x8 Shape.i32x4 a b i16x8_i32x4_pair
/-- `i32x4.extmul_low_i16x8_u` -/
def extMulLowU_i16x8_i32x4 (a b : V128) : V128 := extMulLowU Shape.i16x8 Shape.i32x4 a b i16x8_i32x4_pair
/-- `i32x4.extmul_high_i16x8_s` -/
def extMulHighS_i16x8_i32x4 (a b : V128) : V128 := extMulHighS Shape.i16x8 Shape.i32x4 a b i16x8_i32x4_pair
/-- `i32x4.extmul_high_i16x8_u` -/
def extMulHighU_i16x8_i32x4 (a b : V128) : V128 := extMulHighU Shape.i16x8 Shape.i32x4 a b i16x8_i32x4_pair
/-- `i64x2.extmul_low_i32x4_s` -/
def extMulLowS_i32x4_i64x2 (a b : V128) : V128 := extMulLowS Shape.i32x4 Shape.i64x2 a b i32x4_i64x2_pair
/-- `i64x2.extmul_low_i32x4_u` -/
def extMulLowU_i32x4_i64x2 (a b : V128) : V128 := extMulLowU Shape.i32x4 Shape.i64x2 a b i32x4_i64x2_pair
/-- `i64x2.extmul_high_i32x4_s` -/
def extMulHighS_i32x4_i64x2 (a b : V128) : V128 := extMulHighS Shape.i32x4 Shape.i64x2 a b i32x4_i64x2_pair
/-- `i64x2.extmul_high_i32x4_u` -/
def extMulHighU_i32x4_i64x2 (a b : V128) : V128 := extMulHighU Shape.i32x4 Shape.i64x2 a b i32x4_i64x2_pair

end WasmNum.SIMD.Ops
