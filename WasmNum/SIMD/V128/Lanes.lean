import WasmNum.SIMD.V128.Shape
import WasmNum.SIMD.V128.Type

/-!
# V128 Lane Operations

Lane extraction, replacement, construction, and higher-order lane operations.
These are the fundamental building blocks for all lanewise SIMD operations.

Wasm spec: SIMD proposal
- FR-301: lanes, ofLanes, replaceLane, splat
- FR-307: Splat / Extract / Replace Lane
-/

namespace WasmNum.SIMD.V128

open WasmNum
open WasmNum.SIMD

/-- Extract lane `i` from V128 interpreted as shape `s`.
    Lane 0 is at the least significant bits.
    Wasm spec: `extract_lane` -/
def lane (s : Shape) (v : WasmNum.V128) (i : Fin s.laneCount) : BitVec s.laneWidth :=
  v.extractLsb' (i.val * s.laneWidth) s.laneWidth

/-- Replace lane `i` in V128 interpreted as shape `s`.
    Wasm spec: `replace_lane` -/
def replaceLane (s : Shape) (v : WasmNum.V128) (i : Fin s.laneCount)
    (val : BitVec s.laneWidth) : WasmNum.V128 :=
  let lo := i.val * s.laneWidth
  let mask := ~~~((BitVec.ofNat 128 (2 ^ s.laneWidth - 1)) <<< lo)
  let inserted := (BitVec.zeroExtend 128 val) <<< lo
  (v &&& mask) ||| inserted

/-- Construct V128 from individual lane values.
    Lane 0 occupies the least significant bits.
    Wasm spec: construction from lanes -/
def ofLanes (s : Shape) (lanes : Fin s.laneCount → BitVec s.laneWidth) : WasmNum.V128 :=
  (List.finRange s.laneCount).foldl
    (fun acc i => acc ||| ((BitVec.zeroExtend 128 (lanes i)) <<< (i.val * s.laneWidth)))
    (0#128)

/-- Broadcast a single value to all lanes.
    Wasm spec: `splat` -/
def splat (s : Shape) (val : BitVec s.laneWidth) : WasmNum.V128 :=
  ofLanes s (fun _ => val)

/-- Apply a unary function to each lane independently.
    Used by lanewise SIMD operations. -/
def mapLanes (s : Shape) (f : BitVec s.laneWidth → BitVec s.laneWidth)
    (v : WasmNum.V128) : WasmNum.V128 :=
  ofLanes s (fun i => f (lane s v i))

/-- Apply a binary function to corresponding lanes.
    Used by lanewise binary SIMD operations. -/
def zipLanes (s : Shape)
    (f : BitVec s.laneWidth → BitVec s.laneWidth → BitVec s.laneWidth)
    (a b : WasmNum.V128) : WasmNum.V128 :=
  ofLanes s (fun i => f (lane s a i) (lane s b i))

/-- Apply a ternary function to corresponding lanes. -/
def zipLanes3 (s : Shape)
    (f : BitVec s.laneWidth → BitVec s.laneWidth → BitVec s.laneWidth → BitVec s.laneWidth)
    (a b c : WasmNum.V128) : WasmNum.V128 :=
  ofLanes s (fun i => f (lane s a i) (lane s b i) (lane s c i))

end WasmNum.SIMD.V128
