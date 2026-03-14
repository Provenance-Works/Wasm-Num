import WasmNum.SIMD.V128.Lanes

/-!
# Bitmask and AllTrue

Shape-aware `allTrue` and `bitmask` operations.

Wasm spec: SIMD proposal
- FR-303: allTrue, bitmask
-/

namespace WasmNum.SIMD.Ops

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Test whether all lanes are non-zero.
    Returns 1 if all lanes are non-zero, 0 otherwise.
    Wasm spec: `iNxM.all_true` -/
def allTrue (s : Shape) (v : V128) : I32 :=
  if (List.finRange s.laneCount).all (fun i => V128.lane s v i != 0#s.laneWidth)
  then 1#32 else 0#32

/-- Extract the most significant bit of each lane and pack into I32.
    Lane 0's MSB becomes bit 0 of the result.
    Wasm spec: `iNxM.bitmask` -/
def bitmask (s : Shape) (v : V128) : I32 :=
  (List.finRange s.laneCount).foldl
    (fun acc i =>
      let msb := (V128.lane s v i).getLsbD (s.laneWidth - 1)
      if msb then acc ||| (1#32 <<< i.val)
      else acc)
    (0#32)

end WasmNum.SIMD.Ops
