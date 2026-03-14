import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes

/-!
# Relaxed SIMD Q15 Multiply

Relaxed Q15 fixed-point saturating rounding multiply.
The non-determinism arises from the rounding/saturation behavior
when the intermediate product overflows the Q15 range.

Wasm spec: Relaxed SIMD proposal
- FR-405: Relaxed Q15 Multiply
-/

namespace WasmNum.SIMD.Relaxed

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Relaxed Q15 saturating rounding multiply on i16x8 lanes.
    For the edge case where both inputs are -32768 (INT16_MIN), the result
    may be either 32767 (saturated) or -32768 (wrapped).
    Wasm spec: `i16x8.relaxed_q15mulr_s` -/
def q15mulrS (a b : V128) : Set V128 :=
  let s := Shape.i16x8
  { r | ∀ (i : Fin 8),
    let aLane := V128.lane s a i
    let bLane := V128.lane s b i
    let product := aLane.toInt * bLane.toInt
    -- Use Int division (truncation toward zero), matching the deterministic iq15mulr_sat_s
    let shifted := (product + 0x4000) / (2 ^ 15 : Int)
    let saturated := BitVec.ofInt 16 (min (max shifted (-32768)) 32767)
    -- The edge case: both lanes are -32768 → result may wrap instead of saturate
    let wrapped := BitVec.ofInt 16 shifted
    V128.lane s r i = saturated ∨ V128.lane s r i = wrapped }

end WasmNum.SIMD.Relaxed
