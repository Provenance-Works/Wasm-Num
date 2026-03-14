import WasmNum.SIMD.V128.Lanes
import WasmNum.Proofs.SIMD.V128.LanesRoundtrip
import Mathlib.Tactic

/-!
# V128 Lanes Bijection Proofs

Proofs establishing the bijection between V128 and lane-tuple representations:
- Two V128 values with identical lanes are equal.
- Splat produces the same value in every lane.

Wasm spec: SIMD proposal (semantic consistency)
- FR-303: Lane bijection
-/

namespace WasmNum.SIMD.V128.Proofs

open WasmNum.SIMD
open WasmNum.SIMD.V128

private theorem shape_laneWidth_pos (s : Shape) : 0 < s.laneWidth := by
  obtain ⟨e, he, he3, _⟩ := s.widthPow2
  interval_cases e <;> simp_all

/-- Two V128 values with identical lanes are equal (lane faithfulness).
    If `lane s a i = lane s b i` for all `i`, then `a = b`. -/
theorem ext_lanes (s : Shape) (a b : WasmNum.V128)
    (h : ∀ i : Fin s.laneCount, lane s a i = lane s b i) : a = b := by
  apply BitVec.eq_of_getLsbD_eq
  intro p hp
  have hlw := shape_laneWidth_pos s
  have hv : s.laneCount * s.laneWidth = 128 := by
    rw [Nat.mul_comm]; exact s.valid
  have hlc : p / s.laneWidth < s.laneCount := by
    rw [Nat.div_lt_iff_lt_mul hlw]; omega
  have hmod : p % s.laneWidth < s.laneWidth := Nat.mod_lt p hlw
  have hdivmod : p / s.laneWidth * s.laneWidth + p % s.laneWidth = p := by
    have := Nat.div_add_mod p s.laneWidth
    rw [Nat.mul_comm] at this; exact this
  have ha : a.getLsbD p = (lane s a ⟨p / s.laneWidth, hlc⟩).getLsbD (p % s.laneWidth) := by
    simp only [lane, BitVec.getLsbD_extractLsb', hmod, decide_true, Bool.true_and]
    congr 1; exact hdivmod.symm
  have hb : b.getLsbD p = (lane s b ⟨p / s.laneWidth, hlc⟩).getLsbD (p % s.laneWidth) := by
    simp only [lane, BitVec.getLsbD_extractLsb', hmod, decide_true, Bool.true_and]
    congr 1; exact hdivmod.symm
  rw [ha, h ⟨p / s.laneWidth, hlc⟩, ← hb]

/-- Splat extracts to the splatted value in every lane. -/
theorem splat_lane (s : Shape) (val : BitVec s.laneWidth)
    (i : Fin s.laneCount) : lane s (splat s val) i = val := by
  simp only [splat]
  exact ofLanes_lane s (fun _ => val) i

/-- Roundtrip: constructing from extracted lanes recovers the original. -/
theorem ofLanes_lane_id (s : Shape) (v : WasmNum.V128) :
    ofLanes s (fun i => lane s v i) = v := by
  apply ext_lanes s
  intro i
  exact ofLanes_lane s (fun j => lane s v j) i

end WasmNum.SIMD.V128.Proofs
