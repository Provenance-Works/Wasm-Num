import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes
import WasmNum.Numerics.Float.Sign

/-!
# Relaxed SIMD Fused Multiply-Add

`relaxed_madd` and `relaxed_nmadd`: the result per lane may be either
the fused (`fma`) or unfused (`mul` then `add`) computation.
Returns `Set V128` modeling implementation-defined behavior (ADR-003).

Wasm spec: Relaxed SIMD proposal
- FR-401: Relaxed Floating-Point
-/

namespace WasmNum.SIMD.Relaxed

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Relaxed fused multiply-add: per lane, the result is either
    `fma(a, b, c)` or `a * b + c` (unfused).
    Wasm spec: `fNxM.relaxed_madd` -/
def madd (s : Shape) [WasmFloat s.laneWidth] (a b c : V128) : Set V128 :=
  { v | ∀ i : Fin s.laneCount,
    let ai := V128.lane s a i
    let bi := V128.lane s b i
    let ci := V128.lane s c i
    V128.lane s v i = WasmFloat.fma ai bi ci ∨
    V128.lane s v i = WasmFloat.add (WasmFloat.mul ai bi) ci }

/-- Relaxed negative fused multiply-add: per lane, the result is either
    `fma(-a, b, c)` or `-a * b + c` (unfused).
    Wasm spec: `fNxM.relaxed_nmadd` -/
def nmadd (s : Shape) [WasmFloat s.laneWidth] (a b c : V128) : Set V128 :=
  { v | ∀ i : Fin s.laneCount,
    let ai := V128.lane s a i
    let bi := V128.lane s b i
    let ci := V128.lane s c i
    let negA := Numerics.Float.fneg ai
    V128.lane s v i = WasmFloat.fma negA bi ci ∨
    V128.lane s v i = WasmFloat.add (WasmFloat.mul negA bi) ci }

end WasmNum.SIMD.Relaxed
