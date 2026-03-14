import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes
import WasmNum.Numerics.Conversion.TruncSat
import WasmNum.Numerics.Conversion.ConvertIntFloat
import WasmNum.Numerics.Conversion.PromoteDemote
import WasmNum.Numerics.NaN.Propagation

/-!
# SIMD Conversions

SIMD type conversion operations: integer-float conversions (lanewise),
truncation with saturation, and promotion/demotion.

Wasm spec: SIMD proposal
- FR-309: SIMD Conversions
-/

namespace WasmNum.SIMD.Ops.Convert

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.Numerics.Conversion

-- === f32x4 <-> i32x4 ===

/-- Convert i32x4 lanes to f32x4 (signed interpretation).
    Wasm spec: `f32x4.convert_i32x4_s` -/
def convertI32x4S [WasmFloat 32] (v : V128) : V128 :=
  let i32 := Shape.i32x4
  V128.ofLanes i32 (fun (i : Fin 4) =>
    WasmFloat.convertFromInt (V128.lane i32 v i).toInt)

/-- Convert i32x4 lanes to f32x4 (unsigned interpretation).
    Wasm spec: `f32x4.convert_i32x4_u` -/
def convertI32x4U [WasmFloat 32] (v : V128) : V128 :=
  let i32 := Shape.i32x4
  V128.ofLanes i32 (fun (i : Fin 4) =>
    WasmFloat.convertFromNat (V128.lane i32 v i).toNat)

/-- Truncate f32x4 lanes to i32x4 with signed saturation.
    Wasm spec: `i32x4.trunc_sat_f32x4_s` -/
def truncSatF32x4S [WasmFloat 32] (v : V128) : V128 :=
  let f32 := Shape.f32x4
  let i32 := Shape.i32x4
  V128.ofLanes i32 (fun (i : Fin 4) =>
    truncSatToIntS 32 32 (V128.lane f32 v i))

/-- Truncate f32x4 lanes to i32x4 with unsigned saturation.
    Wasm spec: `i32x4.trunc_sat_f32x4_u` -/
def truncSatF32x4U [WasmFloat 32] (v : V128) : V128 :=
  let f32 := Shape.f32x4
  let i32 := Shape.i32x4
  V128.ofLanes i32 (fun (i : Fin 4) =>
    truncSatToIntU 32 32 (V128.lane f32 v i))

-- === f64x2 <-> i32x4 (low half / zero-padded) ===

/-- Convert low 2 lanes of i32x4 to f64x2 (signed).
    Wasm spec: `f64x2.convert_low_i32x4_s` -/
def convertLowI32x4S [WasmFloat 64] (v : V128) : V128 :=
  let i32 := Shape.i32x4
  let f64 := Shape.f64x2
  V128.ofLanes f64 (fun (i : Fin 2) =>
    have h : i.val < 4 := by omega
    WasmFloat.convertFromInt (V128.lane i32 v ⟨i.val, h⟩).toInt)

/-- Convert low 2 lanes of i32x4 to f64x2 (unsigned).
    Wasm spec: `f64x2.convert_low_i32x4_u` -/
def convertLowI32x4U [WasmFloat 64] (v : V128) : V128 :=
  let i32 := Shape.i32x4
  let f64 := Shape.f64x2
  V128.ofLanes f64 (fun (i : Fin 2) =>
    have h : i.val < 4 := by omega
    WasmFloat.convertFromNat (V128.lane i32 v ⟨i.val, h⟩).toNat)

/-- Truncate f64x2 to i32x4 (signed saturation), zero-extending high lanes.
    Wasm spec: `i32x4.trunc_sat_f64x2_s_zero` -/
def truncSatF64x2SZero [WasmFloat 64] (v : V128) : V128 :=
  let f64 := Shape.f64x2
  let i32 := Shape.i32x4
  V128.ofLanes i32 (fun (i : Fin 4) =>
    if h : i.val < 2 then
      truncSatToIntS 64 32 (V128.lane f64 v ⟨i.val, h⟩)
    else
      0#32)

/-- Truncate f64x2 to i32x4 (unsigned saturation), zero-extending high lanes.
    Wasm spec: `i32x4.trunc_sat_f64x2_u_zero` -/
def truncSatF64x2UZero [WasmFloat 64] (v : V128) : V128 :=
  let f64 := Shape.f64x2
  let i32 := Shape.i32x4
  V128.ofLanes i32 (fun (i : Fin 4) =>
    if h : i.val < 2 then
      truncSatToIntU 64 32 (V128.lane f64 v ⟨i.val, h⟩)
    else
      0#32)

-- === f32x4 <-> f64x2 (promotion / demotion) ===

/-- Promote low 2 lanes of f32x4 to f64x2.
    Returns Set V128 due to NaN non-determinism in promotion.
    Wasm spec: `f64x2.promote_low_f32x4` -/
def promoteLowF32x4 [WasmFloat 32] [WasmFloat 64] [WasmFloatPromote]
    (v : V128) : Set V128 :=
  let f32 := Shape.f32x4
  let f64 := Shape.f64x2
  { r | ∀ (i : Fin 2),
    have h : i.val < 4 := by omega
    V128.lane f64 r i ∈ promoteF32 (V128.lane f32 v ⟨i.val, h⟩) }

/-- Demote f64x2 to f32x4 with zero-extended high lanes.
    Returns Set V128 due to NaN non-determinism in demotion.
    Wasm spec: `f32x4.demote_f64x2_zero` -/
def demoteF64x2Zero [WasmFloat 32] [WasmFloat 64] [WasmFloatDemote]
    (v : V128) : Set V128 :=
  let f64 := Shape.f64x2
  let f32 := Shape.f32x4
  { r | (∀ (i : Fin 2),
    have h : i.val < 4 := by omega
    V128.lane f32 r ⟨i.val, h⟩ ∈ demoteF64 (V128.lane f64 v i)) ∧
    (∀ (i : Fin 4), 2 ≤ i.val → V128.lane f32 r i = 0#32) }

end WasmNum.SIMD.Ops.Convert
