import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes
import WasmNum.Numerics.Conversion.TruncSat

/-!
# Relaxed SIMD Truncation

Relaxed truncation: for NaN and out-of-range inputs, the result per lane
is implementation-defined. The set includes the saturating result and
the per-lane INT_MIN / 0 alternatives.

Wasm spec: Relaxed SIMD proposal
- FR-404: Relaxed Truncation
-/

namespace WasmNum.SIMD.Relaxed

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.Numerics.Conversion

/-- Relaxed trunc f32x4 to i32x4 (signed).
    For NaN/out-of-range, result may be sat value or INT_MIN or 0.
    Wasm spec: `i32x4.relaxed_trunc_f32x4_s` -/
def truncF32x4S [WasmFloat 32] (v : V128) : Set V128 :=
  let f32 := Shape.f32x4
  let i32 := Shape.i32x4
  { r | ∀ (i : Fin 4),
    let fi := V128.lane f32 v i
    let sat := truncSatToIntS 32 32 fi
    if WasmFloat.isNaN fi then
      V128.lane i32 r i = 0#32 ∨
      V128.lane i32 r i = sat ∨
      V128.lane i32 r i = BitVec.ofInt 32 (-(2 ^ 31))
    else
      V128.lane i32 r i = sat }

/-- Relaxed trunc f32x4 to i32x4 (unsigned).
    For NaN/out-of-range, result may be sat value, 0, or UINT_MAX.
    Wasm spec: `i32x4.relaxed_trunc_f32x4_u` -/
def truncF32x4U [WasmFloat 32] (v : V128) : Set V128 :=
  let f32 := Shape.f32x4
  let i32 := Shape.i32x4
  { r | ∀ (i : Fin 4),
    let fi := V128.lane f32 v i
    let sat := truncSatToIntU 32 32 fi
    if WasmFloat.isNaN fi then
      V128.lane i32 r i = 0#32 ∨
      V128.lane i32 r i = sat ∨
      V128.lane i32 r i = ~~~(0#32)
    else
      V128.lane i32 r i = sat }

/-- Relaxed trunc f64x2 to i32x4 (signed), zero-padded high lanes.
    Wasm spec: `i32x4.relaxed_trunc_f64x2_s_zero` -/
def truncF64x2SZero [WasmFloat 64] (v : V128) : Set V128 :=
  let f64 := Shape.f64x2
  let i32 := Shape.i32x4
  { r | (∀ (i : Fin 2),
    have h : i.val < 4 := by omega
    let fi := V128.lane f64 v i
    let sat := truncSatToIntS 64 32 fi
    if WasmFloat.isNaN fi then
      V128.lane i32 r ⟨i.val, h⟩ = 0#32 ∨
      V128.lane i32 r ⟨i.val, h⟩ = sat ∨
      V128.lane i32 r ⟨i.val, h⟩ = BitVec.ofInt 32 (-(2 ^ 31))
    else
      V128.lane i32 r ⟨i.val, h⟩ = sat) ∧
    (∀ (i : Fin 4), 2 ≤ i.val → V128.lane i32 r i = 0#32) }

/-- Relaxed trunc f64x2 to i32x4 (unsigned), zero-padded high lanes.
    Wasm spec: `i32x4.relaxed_trunc_f64x2_u_zero` -/
def truncF64x2UZero [WasmFloat 64] (v : V128) : Set V128 :=
  let f64 := Shape.f64x2
  let i32 := Shape.i32x4
  { r | (∀ (i : Fin 2),
    have h : i.val < 4 := by omega
    let fi := V128.lane f64 v i
    let sat := truncSatToIntU 64 32 fi
    if WasmFloat.isNaN fi then
      V128.lane i32 r ⟨i.val, h⟩ = 0#32 ∨
      V128.lane i32 r ⟨i.val, h⟩ = sat ∨
      V128.lane i32 r ⟨i.val, h⟩ = ~~~(0#32)
    else
      V128.lane i32 r ⟨i.val, h⟩ = sat) ∧
    (∀ (i : Fin 4), 2 ≤ i.val → V128.lane i32 r i = 0#32) }

end WasmNum.SIMD.Relaxed
