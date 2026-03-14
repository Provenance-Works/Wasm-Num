import WasmNum.SIMD.Ops.IntLanewise
import WasmNum.SIMD.Ops.FloatLanewise
import WasmNum.SIMD.Ops.Bitmask
import WasmNum.Proofs.SIMD.V128.LanesRoundtrip
import Mathlib.Tactic

/-!
# SIMD Lanewise Proofs

Proofs that SIMD lanewise operations produce per-lane results
identical to applying the corresponding scalar operation to each lane.

Covers both integer (Phase 7) and deterministic float (Phase 8) operations.

Wasm spec: SIMD proposal (semantic consistency)
- FR-303: lanewise = per-lane scalar
- FR-304: float lanewise = per-lane float scalar
- FR-603: SIMD Correctness Proofs
-/

namespace WasmNum.SIMD.Ops.Proofs

open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.SIMD.V128.Proofs
open WasmNum.SIMD.Ops
open WasmNum.SIMD.Ops.IntLanewise

-- === Arithmetic ===

/-- Lane `i` of lanewise add equals the sum of corresponding input lanes. -/
theorem add_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.add s a b) i =
    V128.lane s a i + V128.lane s b i := by
  simp only [IntLanewise.add, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise sub equals the difference of corresponding input lanes. -/
theorem sub_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.sub s a b) i =
    V128.lane s a i - V128.lane s b i := by
  simp only [IntLanewise.sub, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise neg equals the negation of the input lane. -/
theorem neg_lane (s : Shape) (a : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.neg s a) i =
    0#s.laneWidth - V128.lane s a i := by
  simp only [IntLanewise.neg, V128.mapLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise mul equals the product of corresponding input lanes. -/
theorem mul_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.mul s a b) i =
    V128.lane s a i * V128.lane s b i := by
  simp only [IntLanewise.mul, V128.zipLanes]
  exact ofLanes_lane s _ i

-- === Saturating Arithmetic ===

/-- Lane `i` of lanewise addSatS equals the scalar iadd_sat_s of corresponding lanes. -/
theorem addSatS_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.addSatS s a b) i =
    WasmNum.Numerics.Integer.iadd_sat_s (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.addSatS, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise addSatU equals the scalar iadd_sat_u of corresponding lanes. -/
theorem addSatU_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.addSatU s a b) i =
    WasmNum.Numerics.Integer.iadd_sat_u (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.addSatU, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise subSatS equals the scalar isub_sat_s of corresponding lanes. -/
theorem subSatS_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.subSatS s a b) i =
    WasmNum.Numerics.Integer.isub_sat_s (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.subSatS, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise subSatU equals the scalar isub_sat_u of corresponding lanes. -/
theorem subSatU_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.subSatU s a b) i =
    WasmNum.Numerics.Integer.isub_sat_u (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.subSatU, V128.zipLanes]
  exact ofLanes_lane s _ i

-- === Min / Max ===

/-- Lane `i` of lanewise minS equals the scalar imin_s of corresponding lanes. -/
theorem minS_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.minS s a b) i =
    WasmNum.Numerics.Integer.imin_s (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.minS, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise minU equals the scalar imin_u of corresponding lanes. -/
theorem minU_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.minU s a b) i =
    WasmNum.Numerics.Integer.imin_u (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.minU, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise maxS equals the scalar imax_s of corresponding lanes. -/
theorem maxS_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.maxS s a b) i =
    WasmNum.Numerics.Integer.imax_s (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.maxS, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise maxU equals the scalar imax_u of corresponding lanes. -/
theorem maxU_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.maxU s a b) i =
    WasmNum.Numerics.Integer.imax_u (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.maxU, V128.zipLanes]
  exact ofLanes_lane s _ i

-- === Shifts ===

/-- Lane `i` of lanewise shl equals shifting the input lane. -/
theorem shl_lane (s : Shape) (a : V128) (count : I32) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.shl s a count) i =
    V128.lane s a i <<< (count.toNat % s.laneWidth) := by
  simp only [IntLanewise.shl, V128.mapLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise shrS equals arithmetic right shift of the input lane. -/
theorem shrS_lane (s : Shape) (a : V128) (count : I32) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.shrS s a count) i =
    BitVec.sshiftRight (V128.lane s a i) (count.toNat % s.laneWidth) := by
  simp only [IntLanewise.shrS, V128.mapLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise shrU equals logical right shift of the input lane. -/
theorem shrU_lane (s : Shape) (a : V128) (count : I32) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.shrU s a count) i =
    V128.lane s a i >>> (count.toNat % s.laneWidth) := by
  simp only [IntLanewise.shrU, V128.mapLanes]
  exact ofLanes_lane s _ i

-- === Miscellaneous ===

/-- Lane `i` of lanewise abs equals the scalar iabs of the input lane. -/
theorem abs_lane (s : Shape) (a : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.abs s a) i =
    WasmNum.Numerics.Integer.iabs (V128.lane s a i) := by
  simp only [IntLanewise.abs, V128.mapLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise avgRU equals the scalar iavgr_u of corresponding lanes. -/
theorem avgRU_lane (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.avgRU s a b) i =
    WasmNum.Numerics.Integer.iavgr_u (V128.lane s a i) (V128.lane s b i) := by
  simp only [IntLanewise.avgRU, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of popcnt_i8x16 equals the scalar ipopcnt of the input lane. -/
theorem popcnt_i8x16_lane (v : V128) (i : Fin 16) :
    V128.lane Shape.i8x16 (IntLanewise.popcnt_i8x16 v) i =
    WasmNum.Numerics.Integer.ipopcnt (V128.lane Shape.i8x16 v i) := by
  simp only [IntLanewise.popcnt_i8x16, V128.mapLanes]
  exact ofLanes_lane Shape.i8x16 _ i

/-- Lane `i` of q15mulrSatS equals the scalar iq15mulr_sat_s of corresponding lanes. -/
theorem q15mulrSatS_lane (a b : V128) (i : Fin 8) :
    V128.lane Shape.i16x8 (IntLanewise.q15mulrSatS a b) i =
    WasmNum.Numerics.Integer.iq15mulr_sat_s
      (V128.lane Shape.i16x8 a i) (V128.lane Shape.i16x8 b i) := by
  simp only [IntLanewise.q15mulrSatS, V128.zipLanes]
  exact ofLanes_lane Shape.i16x8 _ i

-- === Comparisons ===

/-- Lane `i` of lanewise eq equals the boolToMask of equality. -/
theorem eqLane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.eqLane s a b) i =
    boolToMask s.laneWidth (V128.lane s a i == V128.lane s b i) := by
  simp only [IntLanewise.eqLane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise ne equals the boolToMask of inequality. -/
theorem neLane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.neLane s a b) i =
    boolToMask s.laneWidth (V128.lane s a i != V128.lane s b i) := by
  simp only [IntLanewise.neLane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise lt_s equals the boolToMask of signed less-than. -/
theorem ltSLane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.ltSLane s a b) i =
    boolToMask s.laneWidth ((V128.lane s a i).toInt < (V128.lane s b i).toInt) := by
  simp only [IntLanewise.ltSLane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise lt_u equals the boolToMask of unsigned less-than. -/
theorem ltULane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.ltULane s a b) i =
    boolToMask s.laneWidth ((V128.lane s a i).toNat < (V128.lane s b i).toNat) := by
  simp only [IntLanewise.ltULane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise le_s equals the boolToMask of signed less-or-equal. -/
theorem leSLane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.leSLane s a b) i =
    boolToMask s.laneWidth ((V128.lane s a i).toInt ≤ (V128.lane s b i).toInt) := by
  simp only [IntLanewise.leSLane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise le_u equals the boolToMask of unsigned less-or-equal. -/
theorem leULane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.leULane s a b) i =
    boolToMask s.laneWidth ((V128.lane s a i).toNat ≤ (V128.lane s b i).toNat) := by
  simp only [IntLanewise.leULane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise gt_s equals the boolToMask of signed greater-than. -/
theorem gtSLane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.gtSLane s a b) i =
    boolToMask s.laneWidth ((V128.lane s a i).toInt > (V128.lane s b i).toInt) := by
  simp only [IntLanewise.gtSLane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise gt_u equals the boolToMask of unsigned greater-than. -/
theorem gtULane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.gtULane s a b) i =
    boolToMask s.laneWidth ((V128.lane s a i).toNat > (V128.lane s b i).toNat) := by
  simp only [IntLanewise.gtULane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise ge_s equals the boolToMask of signed greater-or-equal. -/
theorem geSLane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.geSLane s a b) i =
    boolToMask s.laneWidth ((V128.lane s a i).toInt ≥ (V128.lane s b i).toInt) := by
  simp only [IntLanewise.geSLane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise ge_u equals the boolToMask of unsigned greater-or-equal. -/
theorem geULane_spec (s : Shape) (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (IntLanewise.geULane s a b) i =
    boolToMask s.laneWidth ((V128.lane s a i).toNat ≥ (V128.lane s b i).toNat) := by
  simp only [IntLanewise.geULane, V128.zipLanes]
  exact ofLanes_lane s _ i

end WasmNum.SIMD.Ops.Proofs

-- === Float Lanewise Proofs (deterministic operations only) ===

namespace WasmNum.SIMD.Ops.FloatLanewise.Proofs

open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.SIMD.V128.Proofs
open WasmNum.SIMD.Ops
open WasmNum.SIMD.Ops.FloatLanewise

/-- Lane `i` of lanewise fabs equals fabs of the input lane. -/
theorem fabsLane_spec (s : Shape) (a : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fabsLane s a) i =
    WasmNum.Numerics.Float.fabs (V128.lane s a i) := by
  simp only [FloatLanewise.fabsLane, V128.mapLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise fneg equals fneg of the input lane. -/
theorem fnegLane_spec (s : Shape) (a : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fnegLane s a) i =
    WasmNum.Numerics.Float.fneg (V128.lane s a i) := by
  simp only [FloatLanewise.fnegLane, V128.mapLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise fpmin equals fpmin of corresponding lanes. -/
theorem fpminLane_spec (s : Shape) [WasmFloat s.laneWidth] (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fpminLane s a b) i =
    WasmNum.Numerics.Float.fpmin (V128.lane s a i) (V128.lane s b i) := by
  simp only [FloatLanewise.fpminLane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise fpmax equals fpmax of corresponding lanes. -/
theorem fpmaxLane_spec (s : Shape) [WasmFloat s.laneWidth] (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fpmaxLane s a b) i =
    WasmNum.Numerics.Float.fpmax (V128.lane s a i) (V128.lane s b i) := by
  simp only [FloatLanewise.fpmaxLane, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise feq equals the lane mask of float equality. -/
theorem feqLane_spec (s : Shape) [WasmFloat s.laneWidth] (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.feqLane s a b) i =
    boolToMask s.laneWidth (WasmNum.Numerics.Float.feq (V128.lane s a i) (V128.lane s b i) == 1#32) := by
  simp only [FloatLanewise.feqLane, FloatLanewise.cmpToMask, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise fne equals the lane mask of float inequality. -/
theorem fneLane_spec (s : Shape) [WasmFloat s.laneWidth] (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fneLane s a b) i =
    boolToMask s.laneWidth (WasmNum.Numerics.Float.fne (V128.lane s a i) (V128.lane s b i) == 1#32) := by
  simp only [FloatLanewise.fneLane, FloatLanewise.cmpToMask, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise flt equals the lane mask of float less-than. -/
theorem fltLane_spec (s : Shape) [WasmFloat s.laneWidth] (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fltLane s a b) i =
    boolToMask s.laneWidth (WasmNum.Numerics.Float.flt (V128.lane s a i) (V128.lane s b i) == 1#32) := by
  simp only [FloatLanewise.fltLane, FloatLanewise.cmpToMask, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise fle equals the lane mask of float less-or-equal. -/
theorem fleLane_spec (s : Shape) [WasmFloat s.laneWidth] (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fleLane s a b) i =
    boolToMask s.laneWidth (WasmNum.Numerics.Float.fle (V128.lane s a i) (V128.lane s b i) == 1#32) := by
  simp only [FloatLanewise.fleLane, FloatLanewise.cmpToMask, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise fgt equals the lane mask of float greater-than. -/
theorem fgtLane_spec (s : Shape) [WasmFloat s.laneWidth] (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fgtLane s a b) i =
    boolToMask s.laneWidth (WasmNum.Numerics.Float.fgt (V128.lane s a i) (V128.lane s b i) == 1#32) := by
  simp only [FloatLanewise.fgtLane, FloatLanewise.cmpToMask, V128.zipLanes]
  exact ofLanes_lane s _ i

/-- Lane `i` of lanewise fge equals the lane mask of float greater-or-equal. -/
theorem fgeLane_spec (s : Shape) [WasmFloat s.laneWidth] (a b : V128) (i : Fin s.laneCount) :
    V128.lane s (FloatLanewise.fgeLane s a b) i =
    boolToMask s.laneWidth (WasmNum.Numerics.Float.fge (V128.lane s a i) (V128.lane s b i) == 1#32) := by
  simp only [FloatLanewise.fgeLane, FloatLanewise.cmpToMask, V128.zipLanes]
  exact ofLanes_lane s _ i

end WasmNum.SIMD.Ops.FloatLanewise.Proofs
