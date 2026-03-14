import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes
import WasmNum.SIMD.Ops.Bitwise
import WasmNum.Numerics.Float.MinMax
import WasmNum.Numerics.Float.Rounding
import WasmNum.Numerics.Float.Sign
import WasmNum.Numerics.Float.Compare
import WasmNum.Numerics.Float.PseudoMinMax
import WasmNum.Numerics.NaN.Propagation

/-!
# SIMD Float Lanewise Operations

Float SIMD operations applied lanewise. Arithmetic operations that involve
NaN propagation return `Set V128` (ADR-003): the result set contains all
V128s where each lane is independently chosen from its per-lane result set.
Deterministic operations (abs, neg, pmin, pmax, comparisons) return `V128`.

Wasm spec: SIMD proposal
- FR-304: Float SIMD Operations (Lanewise)
-/

namespace WasmNum.SIMD.Ops.FloatLanewise

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.SIMD.Ops
open WasmNum.Numerics.NaN
open WasmNum.Numerics.Float

-- === Set-returning helpers ===

/-- Lift a unary Set-returning per-lane operation to V128.
    The result set contains all V128s where each lane independently
    belongs to its per-lane result set. -/
private def mapLanesSet (s : Shape) [WasmFloat s.laneWidth]
    (f : BitVec s.laneWidth → Set (BitVec s.laneWidth))
    (v : V128) : Set V128 :=
  { r | ∀ i : Fin s.laneCount, V128.lane s r i ∈ f (V128.lane s v i) }

/-- Lift a binary Set-returning per-lane operation to V128. -/
private def zipLanesSet (s : Shape) [WasmFloat s.laneWidth]
    (f : BitVec s.laneWidth → BitVec s.laneWidth → Set (BitVec s.laneWidth))
    (a b : V128) : Set V128 :=
  { r | ∀ i : Fin s.laneCount,
    V128.lane s r i ∈ f (V128.lane s a i) (V128.lane s b i) }

-- === Arithmetic (Set-returning due to NaN) ===

/-- Lanewise float addition with NaN propagation.
    Wasm spec: `fNxM.add` -/
def fadd (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : Set V128 :=
  zipLanesSet s (propagateNaN₂ WasmFloat.add) a b

/-- Lanewise float subtraction with NaN propagation.
    Wasm spec: `fNxM.sub` -/
def fsub (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : Set V128 :=
  zipLanesSet s (propagateNaN₂ WasmFloat.sub) a b

/-- Lanewise float multiplication with NaN propagation.
    Wasm spec: `fNxM.mul` -/
def fmul (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : Set V128 :=
  zipLanesSet s (propagateNaN₂ WasmFloat.mul) a b

/-- Lanewise float division with NaN propagation.
    Wasm spec: `fNxM.div` -/
def fdiv (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : Set V128 :=
  zipLanesSet s (propagateNaN₂ WasmFloat.div) a b

/-- Lanewise float square root with NaN propagation.
    Wasm spec: `fNxM.sqrt` -/
def fsqrt (s : Shape) [WasmFloat s.laneWidth] (a : V128) : Set V128 :=
  mapLanesSet s (propagateNaN₁ WasmFloat.sqrt) a

-- === Min / Max ===

/-- Lanewise Wasm fmin with NaN propagation (Set-returning).
    Wasm spec: `fNxM.min` -/
def fminLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : Set V128 :=
  zipLanesSet s Numerics.Float.fmin a b

/-- Lanewise Wasm fmax with NaN propagation (Set-returning).
    Wasm spec: `fNxM.max` -/
def fmaxLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : Set V128 :=
  zipLanesSet s Numerics.Float.fmax a b

/-- Lanewise pseudo-minimum (deterministic, no NaN propagation).
    Wasm spec: `fNxM.pmin` -/
def fpminLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : V128 :=
  V128.zipLanes s fpmin a b

/-- Lanewise pseudo-maximum (deterministic, no NaN propagation).
    Wasm spec: `fNxM.pmax` -/
def fpmaxLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : V128 :=
  V128.zipLanes s fpmax a b

-- === Rounding (Set-returning) ===

/-- Lanewise ceil with NaN propagation.
    Wasm spec: `fNxM.ceil` -/
def fceilLane (s : Shape) [WasmFloat s.laneWidth] (a : V128) : Set V128 :=
  mapLanesSet s Numerics.Float.fceil a

/-- Lanewise floor with NaN propagation.
    Wasm spec: `fNxM.floor` -/
def ffloorLane (s : Shape) [WasmFloat s.laneWidth] (a : V128) : Set V128 :=
  mapLanesSet s Numerics.Float.ffloor a

/-- Lanewise trunc with NaN propagation.
    Wasm spec: `fNxM.trunc` -/
def ftruncLane (s : Shape) [WasmFloat s.laneWidth] (a : V128) : Set V128 :=
  mapLanesSet s Numerics.Float.ftrunc a

/-- Lanewise nearest with NaN propagation.
    Wasm spec: `fNxM.nearest` -/
def fnearestLane (s : Shape) [WasmFloat s.laneWidth] (a : V128) : Set V128 :=
  mapLanesSet s Numerics.Float.fnearest a

-- === Bitwise (deterministic, no NaN propagation) ===
-- Note: fabsLane/fnegLane do NOT require [WasmFloat s.laneWidth] because
-- fabs/fneg are pure bitwise operations (clear/flip sign bit) that work
-- on raw BitVec without IEEE 754 interpretation.

/-- Lanewise float abs (clear sign bit).
    Wasm spec: `fNxM.abs` -/
def fabsLane (s : Shape) (a : V128) : V128 :=
  V128.mapLanes s Numerics.Float.fabs a

/-- Lanewise float neg (flip sign bit).
    Wasm spec: `fNxM.neg` -/
def fnegLane (s : Shape) (a : V128) : V128 :=
  V128.mapLanes s Numerics.Float.fneg a

-- === Comparisons (deterministic, result: all-1s or all-0s per lane) ===

/-- Helper: convert float comparison result (I32 0/1) to lane mask,
    using the shared `boolToMask` from `WasmNum.SIMD.Ops`. -/
def cmpToMask (n : Nat) (result : I32) : BitVec n :=
  boolToMask n (result == 1#32)

/-- Lanewise float equality comparison.
    Wasm spec: `fNxM.eq` -/
def feqLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => cmpToMask s.laneWidth (Numerics.Float.feq x y)) a b

/-- Lanewise float inequality comparison.
    Wasm spec: `fNxM.ne` -/
def fneLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => cmpToMask s.laneWidth (Numerics.Float.fne x y)) a b

/-- Lanewise float less-than comparison.
    Wasm spec: `fNxM.lt` -/
def fltLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => cmpToMask s.laneWidth (Numerics.Float.flt x y)) a b

/-- Lanewise float less-or-equal comparison.
    Wasm spec: `fNxM.le` -/
def fleLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => cmpToMask s.laneWidth (Numerics.Float.fle x y)) a b

/-- Lanewise float greater-than comparison.
    Wasm spec: `fNxM.gt` -/
def fgtLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => cmpToMask s.laneWidth (Numerics.Float.fgt x y)) a b

/-- Lanewise float greater-or-equal comparison.
    Wasm spec: `fNxM.ge` -/
def fgeLane (s : Shape) [WasmFloat s.laneWidth] (a b : V128) : V128 :=
  V128.zipLanes s (fun x y => cmpToMask s.laneWidth (Numerics.Float.fge x y)) a b

end WasmNum.SIMD.Ops.FloatLanewise
