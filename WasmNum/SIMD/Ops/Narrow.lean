import WasmNum.SIMD.V128.Lanes
import WasmNum.Numerics.Integer.Saturating

/-!
# Narrowing Operations

Narrow two vectors of wider lanes into one vector of narrower lanes
with signed or unsigned saturation.

Precondition: `narrow.laneCount = 2 * wide.laneCount` (the narrow shape
has twice as many lanes as the wide shape). This ensures every output
lane has a corresponding source lane from `a` (low half) or `b` (high half).

Valid Wasm shape pairs: (i16x8 → i8x16), (i32x4 → i16x8).

Wasm spec: SIMD proposal
- FR-303: narrow_s, narrow_u
-/

namespace WasmNum.SIMD.Ops

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.Numerics.Integer

/-- Signed narrowing: saturate each wide lane to signed narrow range.
    Low half from `a`, high half from `b`.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.narrow_iN'xM'_s` (e.g. i8x16.narrow_i16x8_s) -/
def narrowS (wide narrow : Shape) (a b : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes narrow (fun (i : Fin narrow.laneCount) =>
    let srcVec := if i.val < wide.laneCount then a else b
    let srcIdx := if i.val < wide.laneCount then i.val else i.val - wide.laneCount
    have h_bound : srcIdx < wide.laneCount := by
      simp only [srcIdx]
      split <;> omega
    sat_s narrow.laneWidth (V128.lane wide srcVec ⟨srcIdx, h_bound⟩).toInt)

/-- Unsigned narrowing: saturate each wide lane (signed interpretation)
    to unsigned narrow range. Low half from `a`, high half from `b`.
    Requires `narrow.laneCount = 2 * wide.laneCount`.
    Wasm spec: `iNxM.narrow_iN'xM'_u` (e.g. i8x16.narrow_i16x8_u) -/
def narrowU (wide narrow : Shape) (a b : V128)
    (h_pair : narrow.laneCount = 2 * wide.laneCount) : V128 :=
  V128.ofLanes narrow (fun (i : Fin narrow.laneCount) =>
    let srcVec := if i.val < wide.laneCount then a else b
    let srcIdx := if i.val < wide.laneCount then i.val else i.val - wide.laneCount
    have h_bound : srcIdx < wide.laneCount := by
      simp only [srcIdx]
      split <;> omega
    sat_u narrow.laneWidth (V128.lane wide srcVec ⟨srcIdx, h_bound⟩).toInt)

-- === Concrete shape-fixed wrappers ===

/-- i8x16.narrow_i16x8_s: narrow i16x8 to i8x16 with signed saturation.
    Wasm spec: `i8x16.narrow_i16x8_s` -/
def narrow_i16x8_to_i8x16_s (a b : V128) : V128 :=
  narrowS Shape.i16x8 Shape.i8x16 a b (by decide)

/-- i8x16.narrow_i16x8_u: narrow i16x8 to i8x16 with unsigned saturation.
    Wasm spec: `i8x16.narrow_i16x8_u` -/
def narrow_i16x8_to_i8x16_u (a b : V128) : V128 :=
  narrowU Shape.i16x8 Shape.i8x16 a b (by decide)

/-- i16x8.narrow_i32x4_s: narrow i32x4 to i16x8 with signed saturation.
    Wasm spec: `i16x8.narrow_i32x4_s` -/
def narrow_i32x4_to_i16x8_s (a b : V128) : V128 :=
  narrowS Shape.i32x4 Shape.i16x8 a b (by decide)

/-- i16x8.narrow_i32x4_u: narrow i32x4 to i16x8 with unsigned saturation.
    Wasm spec: `i16x8.narrow_i32x4_u` -/
def narrow_i32x4_to_i16x8_u (a b : V128) : V128 :=
  narrowU Shape.i32x4 Shape.i16x8 a b (by decide)

end WasmNum.SIMD.Ops
