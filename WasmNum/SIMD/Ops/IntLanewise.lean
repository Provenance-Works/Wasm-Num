import WasmNum.SIMD.V128.Lanes
import WasmNum.SIMD.Ops.Bitwise
import WasmNum.Numerics.Integer.Arithmetic
import WasmNum.Numerics.Integer.Saturating
import WasmNum.Numerics.Integer.MinMax
import WasmNum.Numerics.Integer.Shift
import WasmNum.Numerics.Integer.Compare
import WasmNum.Numerics.Integer.Bits
import WasmNum.Numerics.Integer.Misc

/-!
# SIMD Integer Lanewise Operations

Integer SIMD operations applied lanewise via `V128.mapLanes` / `V128.zipLanes`.
Shift amounts are `I32`, taken modulo lane width.
Comparison results are all-1s or all-0s per lane.

Wasm spec: SIMD proposal
- FR-303: Integer SIMD Operations (Lanewise)
-/

namespace WasmNum.SIMD.Ops.IntLanewise

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.SIMD.Ops
open WasmNum.Numerics.Integer

-- === Arithmetic ===

/-- Lanewise integer addition.
    Wasm spec: `iNxM.add` -/
def add (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (· + ·) a b

/-- Lanewise integer subtraction.
    Wasm spec: `iNxM.sub` -/
def sub (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (· - ·) a b

/-- Lanewise integer negation.
    Wasm spec: `iNxM.neg` -/
def neg (s : Shape) (a : V128) : V128 :=
  V128.mapLanes s (fun x => 0#s.laneWidth - x) a

/-- Lanewise integer multiplication.
    Wasm spec: `iNxM.mul` (i16x8, i32x4, i64x2) -/
def mul (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (· * ·) a b

-- === Saturating arithmetic ===

/-- Lanewise signed saturating addition.
    Wasm spec: `iNxM.add_sat_s` (i8x16, i16x8) -/
def addSatS (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s iadd_sat_s a b

/-- Lanewise unsigned saturating addition.
    Wasm spec: `iNxM.add_sat_u` (i8x16, i16x8) -/
def addSatU (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s iadd_sat_u a b

/-- Lanewise signed saturating subtraction.
    Wasm spec: `iNxM.sub_sat_s` (i8x16, i16x8) -/
def subSatS (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s isub_sat_s a b

/-- Lanewise unsigned saturating subtraction.
    Wasm spec: `iNxM.sub_sat_u` (i8x16, i16x8) -/
def subSatU (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s isub_sat_u a b

-- === Min / Max ===

/-- Lanewise signed minimum.
    Wasm spec: `iNxM.min_s` -/
def minS (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s imin_s a b

/-- Lanewise unsigned minimum.
    Wasm spec: `iNxM.min_u` -/
def minU (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s imin_u a b

/-- Lanewise signed maximum.
    Wasm spec: `iNxM.max_s` -/
def maxS (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s imax_s a b

/-- Lanewise unsigned maximum.
    Wasm spec: `iNxM.max_u` -/
def maxU (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s imax_u a b

-- === Shifts ===

/-- Lanewise shift left. Shift amount is I32, taken modulo lane width.
    Wasm spec: `iNxM.shl` -/
def shl (s : Shape) (a : V128) (count : I32) : V128 :=
  let shift := count.toNat % s.laneWidth
  V128.mapLanes s (· <<< shift) a

/-- Lanewise arithmetic (signed) shift right. Shift amount is I32, taken modulo lane width.
    Wasm spec: `iNxM.shr_s` -/
def shrS (s : Shape) (a : V128) (count : I32) : V128 :=
  let shift := count.toNat % s.laneWidth
  V128.mapLanes s (fun x => BitVec.sshiftRight x shift) a

/-- Lanewise logical (unsigned) shift right. Shift amount is I32, taken modulo lane width.
    Wasm spec: `iNxM.shr_u` -/
def shrU (s : Shape) (a : V128) (count : I32) : V128 :=
  let shift := count.toNat % s.laneWidth
  V128.mapLanes s (· >>> shift) a

-- === Comparisons ===

/-- Lanewise equality. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.eq` -/
def eqLane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x == y)) a b

/-- Lanewise inequality. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.ne` -/
def neLane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x != y)) a b

/-- Lanewise signed less-than. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.lt_s` -/
def ltSLane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x.toInt < y.toInt)) a b

/-- Lanewise unsigned less-than. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.lt_u` -/
def ltULane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x.toNat < y.toNat)) a b

/-- Lanewise signed less-or-equal. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.le_s` -/
def leSLane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x.toInt ≤ y.toInt)) a b

/-- Lanewise unsigned less-or-equal. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.le_u` -/
def leULane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x.toNat ≤ y.toNat)) a b

/-- Lanewise signed greater-than. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.gt_s` -/
def gtSLane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x.toInt > y.toInt)) a b

/-- Lanewise unsigned greater-than. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.gt_u` -/
def gtULane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x.toNat > y.toNat)) a b

/-- Lanewise signed greater-or-equal. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.ge_s` -/
def geSLane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x.toInt ≥ y.toInt)) a b

/-- Lanewise unsigned greater-or-equal. Result: all-1s or all-0s per lane.
    Wasm spec: `iNxM.ge_u` -/
def geULane (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => boolToMask s.laneWidth (x.toNat ≥ y.toNat)) a b

-- === Miscellaneous ===

/-- Lanewise absolute value (signed interpretation).
    Wasm spec: `iNxM.abs` -/
def abs (s : Shape) (a : V128) : V128 :=
  V128.mapLanes s iabs a

/-- Lanewise unsigned rounding average.
    Wasm spec: `iNxM.avgr_u` (i8x16, i16x8) -/
def avgRU (s : Shape) (a b : V128) : V128 :=
  V128.zipLanes s iavgr_u a b

/-- Lanewise population count (i8x16 only).
    Wasm spec: `i8x16.popcnt` -/
def popcnt_i8x16 (v : V128) : V128 :=
  V128.mapLanes Shape.i8x16 ipopcnt v

/-- Lanewise Q15 saturating rounding multiply (i16x8 only).
    Wasm spec: `i16x8.q15mulr_sat_s` -/
def q15mulrSatS (a b : V128) : V128 :=
  V128.zipLanes Shape.i16x8 iq15mulr_sat_s a b

end WasmNum.SIMD.Ops.IntLanewise
