import WasmNum.SIMD.V128.Lanes

/-!
# Swizzle

`i8x16.swizzle`: byte-level rearrangement using an index vector.
Out-of-range indices (>= 16) produce 0.

Wasm spec: SIMD proposal
- FR-306: swizzle
-/

namespace WasmNum.SIMD.Ops

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Byte-level swizzle using index vector.
    For each byte lane `i`, if `idx[i] < 16` then `result[i] = v[idx[i]]`,
    otherwise `result[i] = 0`.
    Wasm spec: `i8x16.swizzle` -/
def swizzle (v idx : V128) : V128 :=
  let s := Shape.i8x16
  V128.ofLanes s (fun (i : Fin 16) =>
    let j := (V128.lane s idx i).toNat
    if h : j < 16 then
      V128.lane s v ⟨j, h⟩
    else
      0#8)

end WasmNum.SIMD.Ops
