import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes
import WasmNum.SIMD.Ops.Bitwise

/-!
# Relaxed SIMD Lane Select

Relaxed lane select: may use either MSB-based selection or full
bitwise-based selection (v128.bitselect).

Wasm spec: Relaxed SIMD proposal
- FR-402: Relaxed Integer (laneselect)
-/

namespace WasmNum.SIMD.Relaxed

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Helper: MSB-based lane select per lane.
    If mask lane MSB is 1, select from `a`; otherwise select from `b`. -/
private def msbSelect (s : Shape) (a b mask : V128) : V128 :=
  V128.ofLanes s (fun i =>
    let m := V128.lane s mask i
    if m.getLsbD (s.laneWidth - 1) then V128.lane s a i
    else V128.lane s b i)

/-- Relaxed lane select: the result per lane may be either
    MSB-based selection or full bitwise selection (v128.bitselect).
    Wasm spec: `iNxM.relaxed_laneselect` -/
def laneselect (s : Shape) (a b mask : V128) : Set V128 :=
  { v | v = msbSelect s a b mask ∨
        v = Ops.v128_bitselect a b mask }

end WasmNum.SIMD.Relaxed
