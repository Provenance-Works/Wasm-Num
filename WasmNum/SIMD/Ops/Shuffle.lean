import WasmNum.SIMD.V128.Lanes

/-!
# Shuffle

`i8x16.shuffle`: static byte rearrangement using compile-time indices.
Indices 0-15 select from `a`, indices 16-31 select from `b`.

Wasm spec: SIMD proposal
- FR-306: shuffle
-/

namespace WasmNum.SIMD.Ops

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Static byte-level shuffle across two V128 inputs.
    Each index in `indices` selects a byte from the concatenation `a ++ b`
    (0-15 from `a`, 16-31 from `b`).
    Wasm spec: `i8x16.shuffle` -/
def shuffle (a b : V128) (indices : Vector (Fin 32) 16) : V128 :=
  let s := Shape.i8x16
  V128.ofLanes s (fun (i : Fin 16) =>
    let j := (indices.get i).val
    if h : j < 16 then
      V128.lane s a ⟨j, h⟩
    else
      have h2 : j - 16 < 16 := by omega
      V128.lane s b ⟨j - 16, h2⟩)

end WasmNum.SIMD.Ops
