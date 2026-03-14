import WasmNum.SIMD.V128.Lanes
import Mathlib.Tactic

/-!
# V128 Lanes Roundtrip Proofs

Proofs that lane extraction and construction form a roundtrip:
- Extracting lane `i` from `ofLanes` recovers the original value.
- Replacing then extracting the same lane recovers the inserted value.
- Replacing a lane doesn't affect other lanes.

Wasm spec: SIMD proposal (semantic consistency)
- FR-303: Lane roundtrip correctness
-/

namespace WasmNum.SIMD.V128.Proofs

open WasmNum.SIMD
open WasmNum.SIMD.V128

private theorem shape_bound (s : Shape) (i : Fin s.laneCount) (k : Nat)
    (hk : k < s.laneWidth) : i.val * s.laneWidth + k < 128 := by
  obtain ⟨e, he, he3, he6⟩ := s.widthPow2
  have hv := s.valid
  have hi := i.isLt
  interval_cases e <;> simp_all <;> omega

private theorem shape_laneWidth_pos (s : Shape) : 0 < s.laneWidth := by
  obtain ⟨e, he, he3, _⟩ := s.widthPow2
  interval_cases e <;> simp_all

private theorem foldl_or_getLsbD {α : Type} {n : Nat} (xs : List α)
    (f : α → BitVec n) (init : BitVec n) (j : Nat) :
    (xs.foldl (fun acc i => acc ||| f i) init).getLsbD j =
    (init.getLsbD j || xs.any (fun i => (f i).getLsbD j)) := by
  induction xs generalizing init with
  | nil => simp
  | cons x xs ih =>
    simp only [List.foldl_cons, List.any_cons]
    rw [ih]
    simp only [BitVec.getLsbD_or, Bool.or_assoc]

private theorem getLsbD_false_of_ge {w : Nat} (x : BitVec w) {m : Nat}
    (h : w ≤ m) : x.getLsbD m = false := by
  unfold BitVec.getLsbD
  apply Nat.testBit_lt_two_pow
  exact lt_of_lt_of_le x.isLt (Nat.pow_le_pow_right (by omega) h)

private theorem shifted_lane_self (s : Shape) (val : BitVec s.laneWidth)
    (j : Fin s.laneCount) (k : Nat) (hk : k < s.laneWidth) :
    ((BitVec.zeroExtend 128 val) <<< (j.val * s.laneWidth)).getLsbD
      (j.val * s.laneWidth + k) = val.getLsbD k := by
  have hbound := shape_bound s j k hk
  simp only [BitVec.getLsbD_shiftLeft, hbound, decide_true, Bool.true_and,
    show ¬(j.val * s.laneWidth + k < j.val * s.laneWidth) from by omega,
    decide_false, Bool.not_false, Bool.true_and,
    show j.val * s.laneWidth + k - j.val * s.laneWidth = k from by omega,
    BitVec.getLsbD_setWidth,
    show k < 128 from by omega, decide_true, Bool.true_and]

private theorem shifted_lane_other (s : Shape) (f : Fin s.laneCount → BitVec s.laneWidth)
    (i j : Fin s.laneCount) (k : Nat) (hk : k < s.laneWidth) (hij : i ≠ j) :
    ((BitVec.zeroExtend 128 (f j)) <<< (j.val * s.laneWidth)).getLsbD
      (i.val * s.laneWidth + k) = false := by
  have hbound := shape_bound s i k hk
  simp only [BitVec.getLsbD_shiftLeft, hbound, decide_true, Bool.true_and]
  have hne : i.val ≠ j.val := fun h_eq => hij (Fin.ext h_eq)
  by_cases hlt : i.val * s.laneWidth + k < j.val * s.laneWidth
  · simp [hlt]
  · push_neg at hlt
    have hji : j.val < i.val := by
      by_contra hc; push_neg at hc
      have hmul := Nat.mul_le_mul_right s.laneWidth (show i.val + 1 ≤ j.val by omega)
      rw [Nat.add_mul, Nat.one_mul] at hmul; omega
    have hmul := Nat.mul_le_mul_right s.laneWidth (show j.val + 1 ≤ i.val by omega)
    rw [Nat.add_mul, Nat.one_mul] at hmul
    simp only [show ¬(i.val * s.laneWidth + k < j.val * s.laneWidth) from by omega,
      decide_false, Bool.not_false, Bool.true_and,
      BitVec.getLsbD_setWidth,
      show i.val * s.laneWidth + k - j.val * s.laneWidth < 128 from by omega,
      decide_true, Bool.true_and]
    exact getLsbD_false_of_ge (f j) (by omega)

private theorem any_finRange_unique {n : Nat} (g : Fin n → Bool) (i : Fin n)
    (h : ∀ j : Fin n, j ≠ i → g j = false) :
    (List.finRange n).any g = g i := by
  cases hgi : g i
  · rw [List.any_eq_false]
    intro j hj
    by_cases hji : j = i
    · subst hji; simp [hgi]
    · simp [h j hji]
  · rw [List.any_eq_true]
    exact ⟨i, List.mem_finRange i, hgi⟩

/-- Extracting lane `i` from `ofLanes` recovers the original value.
    `lane s (ofLanes s f) i = f i` -/
theorem ofLanes_lane (s : Shape) (f : Fin s.laneCount → BitVec s.laneWidth)
    (i : Fin s.laneCount) : lane s (ofLanes s f) i = f i := by
  apply BitVec.eq_of_getLsbD_eq
  intro k hk
  simp only [lane, ofLanes]
  have hbound := shape_bound s i k hk
  simp only [BitVec.getLsbD_extractLsb', hk, decide_true, Bool.true_and]
  rw [foldl_or_getLsbD]
  simp only [BitVec.getLsbD_zero, Bool.false_or]
  rw [any_finRange_unique _ i]
  · exact shifted_lane_self s (f i) i k hk
  · intro j hji
    exact shifted_lane_other s f i j k hk (fun h_eq => hji h_eq.symm)

/-- Replacing lane `i` then extracting lane `i` gives the inserted value. -/
theorem replaceLane_lane_eq (s : Shape) (v : WasmNum.V128)
    (i : Fin s.laneCount) (val : BitVec s.laneWidth) :
    lane s (replaceLane s v i val) i = val := by
  apply BitVec.eq_of_getLsbD_eq
  intro k hk
  simp only [lane, replaceLane]
  have hbound := shape_bound s i k hk
  simp only [BitVec.getLsbD_extractLsb', hk, decide_true, Bool.true_and,
    BitVec.getLsbD_or, BitVec.getLsbD_and, BitVec.getLsbD_not,
    BitVec.getLsbD_shiftLeft, BitVec.getLsbD_setWidth, BitVec.getLsbD_ofNat,
    Nat.testBit_two_pow_sub_one, hbound]
  have h1 : ¬(i.val * s.laneWidth + k < i.val * s.laneWidth) := by omega
  have h2 : i.val * s.laneWidth + k - i.val * s.laneWidth = k := by omega
  have h3 : k < 128 := by omega
  simp only [h1, decide_false, Bool.not_false, Bool.true_and, h2, h3, hk,
    decide_true, Bool.not_true, Bool.and_false, Bool.false_or]

/-- Replacing lane `i` does not affect other lanes. -/
theorem replaceLane_lane_ne (s : Shape) (v : WasmNum.V128)
    (i j : Fin s.laneCount) (val : BitVec s.laneWidth) (h : i ≠ j) :
    lane s (replaceLane s v i val) j = lane s v j := by
  apply BitVec.eq_of_getLsbD_eq
  intro k hk
  simp only [lane, replaceLane]
  have hbound_j := shape_bound s j k hk
  simp only [BitVec.getLsbD_extractLsb', hk, decide_true, Bool.true_and,
    BitVec.getLsbD_or, BitVec.getLsbD_and, BitVec.getLsbD_not,
    BitVec.getLsbD_shiftLeft, BitVec.getLsbD_setWidth, BitVec.getLsbD_ofNat,
    Nat.testBit_two_pow_sub_one, hbound_j]
  have hne : i.val ≠ j.val := fun h_eq => h (Fin.ext h_eq)
  by_cases hij : j.val < i.val
  · have hmul := Nat.mul_le_mul_right s.laneWidth (show j.val + 1 ≤ i.val by omega)
    rw [Nat.add_mul, Nat.one_mul] at hmul
    have hlt : j.val * s.laneWidth + k < i.val * s.laneWidth := by omega
    simp only [hlt, decide_true, Bool.not_true, Bool.false_and, Bool.or_false,
      Bool.not_false, Bool.and_true]
  · have hgt : i.val < j.val := by omega
    have hmul := Nat.mul_le_mul_right s.laneWidth (show i.val + 1 ≤ j.val by omega)
    rw [Nat.add_mul, Nat.one_mul] at hmul
    have hnlt : ¬(j.val * s.laneWidth + k < i.val * s.laneWidth) := by omega
    have hdiff_ge : s.laneWidth ≤ j.val * s.laneWidth + k - i.val * s.laneWidth := by omega
    have hoob : ¬(j.val * s.laneWidth + k - i.val * s.laneWidth < s.laneWidth) := by omega
    have hdiff128 : j.val * s.laneWidth + k - i.val * s.laneWidth < 128 := by omega
    simp only [hnlt, decide_false, Bool.not_false, Bool.true_and,
      hdiff128, decide_true, hoob, Bool.and_false,
      Bool.and_true]
    have hval_false : val.getLsbD (j.val * s.laneWidth + k - i.val * s.laneWidth) = false := by
      unfold BitVec.getLsbD
      apply Nat.testBit_lt_two_pow
      exact lt_of_lt_of_le val.isLt (Nat.pow_le_pow_right (by omega) hdiff_ge)
    simp [hval_false]

end WasmNum.SIMD.V128.Proofs
