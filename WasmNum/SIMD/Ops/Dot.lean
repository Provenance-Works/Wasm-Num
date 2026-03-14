import WasmNum.SIMD.V128.Lanes

/-!
# Dot Product

`i32x4.dot_i16x8_s`: pairwise multiply i16 lanes and sum pairs into i32 lanes.

Wasm spec: SIMD proposal
- FR-303: dot product
-/

namespace WasmNum.SIMD.Ops

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Signed dot product: multiply pairs of i16 lanes and accumulate into i32 lanes.
    For each i32 output lane `i`:
      result[i] = a_i16[2*i] * b_i16[2*i] + a_i16[2*i+1] * b_i16[2*i+1]
    (signed interpretation, result fits in i32).
    Wasm spec: `i32x4.dot_i16x8_s` -/
def dot_i16x8_i32x4 (a b : V128) : V128 :=
  let i16 := Shape.i16x8
  let i32 := Shape.i32x4
  V128.ofLanes i32 (fun (i : Fin 4) =>
    let lo := i.val * 2
    let hi := lo + 1
    have hlo : lo < 8 := by omega
    have hhi : hi < 8 := by omega
    let aLo := (V128.lane i16 a ⟨lo, hlo⟩).toInt
    let bLo := (V128.lane i16 b ⟨lo, hlo⟩).toInt
    let aHi := (V128.lane i16 a ⟨hi, hhi⟩).toInt
    let bHi := (V128.lane i16 b ⟨hi, hhi⟩).toInt
    BitVec.ofInt 32 (aLo * bLo + aHi * bHi))

end WasmNum.SIMD.Ops
