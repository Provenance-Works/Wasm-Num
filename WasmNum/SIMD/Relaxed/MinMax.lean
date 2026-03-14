import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes

/-!
# Relaxed SIMD Min/Max

Relaxed min and max: when either operand is NaN or both are zero,
the result per lane may be either operand or a canonical NaN.

Wasm spec: Relaxed SIMD proposal
- FR-401: Relaxed Floating-Point
-/

namespace WasmNum.SIMD.Relaxed

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Relaxed min: for NaN or signed-zero edge cases, the result per lane
    may be either operand or a canonical NaN.
    For normal values, returns the IEEE minimum.
    Wasm spec: `fNxM.relaxed_min` -/
def min (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : Set V128 :=
  { v | ∀ i : Fin s.laneCount,
    let ai := V128.lane s a i
    let bi := V128.lane s b i
    if WasmFloat.isNaN ai || WasmFloat.isNaN bi then
      V128.lane s v i = ai ∨
      V128.lane s v i = bi ∨
      WasmFloat.isCanonicalNaN (V128.lane s v i) = true
    else if WasmFloat.isZero ai && WasmFloat.isZero bi then
      V128.lane s v i = ai ∨ V128.lane s v i = bi
    else
      V128.lane s v i = (if WasmFloat.lt ai bi then ai else bi) }

/-- Relaxed max: for NaN or signed-zero edge cases, the result per lane
    may be either operand or a canonical NaN.
    For normal values, returns the IEEE maximum.
    Wasm spec: `fNxM.relaxed_max` -/
def max (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : Set V128 :=
  { v | ∀ i : Fin s.laneCount,
    let ai := V128.lane s a i
    let bi := V128.lane s b i
    if WasmFloat.isNaN ai || WasmFloat.isNaN bi then
      V128.lane s v i = ai ∨
      V128.lane s v i = bi ∨
      WasmFloat.isCanonicalNaN (V128.lane s v i) = true
    else if WasmFloat.isZero ai && WasmFloat.isZero bi then
      V128.lane s v i = ai ∨ V128.lane s v i = bi
    else
      V128.lane s v i = (if WasmFloat.lt bi ai then ai else bi) }

end WasmNum.SIMD.Relaxed
