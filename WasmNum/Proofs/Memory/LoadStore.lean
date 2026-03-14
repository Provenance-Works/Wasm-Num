import WasmNum.Memory.Load.Scalar
import WasmNum.Memory.Store.Scalar

/-!
# Load/Store Correctness Proofs

Formal proofs relating load and store operations.
Key properties: store preserves memory structure,
and loads/stores succeed when bounds are satisfied.

Wasm spec: memory semantics correctness
- FR-512: Load/Store roundtrip, disjointness
-/

set_option autoImplicit false

namespace WasmNum.Memory.Proofs

open WasmNum
open WasmNum.Memory
open WasmNum.Memory.Load
open WasmNum.Memory.Store

/-- If storeN succeeds, the resulting memory has the same data size. -/
theorem storeN_preserves_dataSize {addrWidth N : Nat}
    (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : BitVec N) (hN : N % 8 = 0) (mem' : FlatMemory addrWidth)
    (h : storeN mem addr val hN = some mem') :
    mem'.data.size = mem.data.size := by
  unfold storeN at h
  exact FlatMemory.writeLittleEndian_dataSize mem addr.toNat N hN val mem' h

/-- `loadN` succeeds when the access is in bounds. -/
theorem loadN_some_of_inBounds {addrWidth N : Nat}
    (mem : FlatMemory addrWidth) (addr : BitVec addrWidth) (hN : N % 8 = 0)
    (h : inBounds mem addr (N / 8)) :
    ∃ v, loadN mem addr N hN = some v := by
  simp only [loadN, FlatMemory.readLittleEndian]
  have ⟨bs, hbs⟩ : ∃ bs, mem.readBytes addr.toNat (N / 8) = some bs := by
    unfold FlatMemory.readBytes
    split
    · exact ⟨_, rfl⟩
    · exact absurd h (by unfold inBounds; omega)
  simp only [hbs]
  exact ⟨_, rfl⟩

end WasmNum.Memory.Proofs

/-! ### Byte assembly roundtrip helpers -/

set_option maxRecDepth 4096

namespace WasmNum.Memory.Proofs

open WasmNum
open WasmNum.Memory
open WasmNum.Memory.Load
open WasmNum.Memory.Store

-- Helper: foldl_or on Nat distributes testBit over OR
private theorem foldl_or_testBit {n : Nat} (xs : List (Fin n))
    (f : Fin n → Nat) (init : Nat) (k : Nat) :
    (xs.foldl (fun acc i => acc ||| f i) init).testBit k =
    (init.testBit k || xs.any (fun i => (f i).testBit k)) := by
  induction xs generalizing init with
  | nil => simp
  | cons x xs ih =>
    simp only [List.foldl_cons, List.any_cons]
    rw [ih]
    simp only [Nat.testBit_or, Bool.or_assoc]

-- Helper: only the byte containing bit k contributes
private theorem byte_at_bit (N : Nat) (_hN : N % 8 = 0) (val : BitVec N)
    (k : Nat) (_hk : k < N) :
    (((val >>> (k / 8 * 8)).truncate 8).toNat <<< (k / 8 * 8)).testBit k =
    val.toNat.testBit k := by
  rw [Nat.testBit_shiftLeft]
  have hge : k ≥ k / 8 * 8 := Nat.div_mul_le_self k 8
  simp only [show k ≥ k / 8 * 8 from hge, decide_true, Bool.true_and]
  simp only [BitVec.truncate, BitVec.toNat_setWidth, BitVec.toNat_ushiftRight]
  rw [Nat.testBit_mod_two_pow]
  have hmod : k - k / 8 * 8 < 8 := by omega
  simp only [hmod, decide_true, Bool.true_and]
  rw [Nat.testBit_shiftRight]
  congr 1
  omega

-- Helper: bytes at other positions don't contribute
private theorem other_byte_bit (N : Nat) (_hN : N % 8 = 0) (val : BitVec N)
    (k : Nat) (_hk : k < N) (j : Fin (N / 8)) (hj : j.val ≠ k / 8) :
    (((val >>> (j.val * 8)).truncate 8).toNat <<< (j.val * 8)).testBit k = false := by
  rw [Nat.testBit_shiftLeft]
  by_cases hge : k ≥ j.val * 8
  · have hge_dec : (decide (k ≥ j.val * 8)) = true := by simp [hge]
    rw [hge_dec, Bool.true_and]
    simp only [BitVec.truncate, BitVec.toNat_setWidth, BitVec.toNat_ushiftRight]
    rw [Nat.testBit_mod_two_pow]
    have hlt_false : ¬(k - j.val * 8 < 8) := by
      intro h; exact hj (by omega)
    have hlt_dec : (decide (k - j.val * 8 < 8)) = false := by simp [hlt_false]
    rw [hlt_dec, Bool.false_and]
  · have hge_dec : (decide (k ≥ j.val * 8)) = false := by simp [hge]
    rw [hge_dec, Bool.false_and]

-- Main assembly roundtrip: byte decomp → foldl OR/shift → original value
private theorem byte_assembly_roundtrip (N : Nat) (hN : N % 8 = 0) (val : BitVec N) :
    (BitVec.ofNat N
      ((List.finRange (N / 8)).foldl
        (fun acc (idx : Fin (N / 8)) =>
          acc ||| (((val >>> (idx.val * 8)).truncate 8).toNat <<< (idx.val * 8)))
        0)) = val := by
  apply BitVec.eq_of_getLsbD_eq
  intro k hk
  simp only [BitVec.getLsbD, BitVec.toNat_ofNat]
  rw [Nat.testBit_mod_two_pow]
  simp only [show k < N from hk, decide_true, Bool.true_and]
  rw [foldl_or_testBit]
  simp only [Nat.zero_testBit, Bool.false_or]
  have hbyteIdx : k / 8 < N / 8 := by omega
  rw [Bool.eq_iff_iff, List.any_eq_true]
  constructor
  · intro ⟨⟨j, hj⟩, _, hjk⟩
    by_cases hje : j = k / 8
    · subst hje; rwa [← byte_at_bit N hN val k hk]
    · rw [other_byte_bit N hN val k hk ⟨j, hj⟩ hje] at hjk
      exact absurd hjk (by decide)
  · intro hval
    exact ⟨⟨k / 8, hbyteIdx⟩, List.mem_finRange _,
      by rw [byte_at_bit N hN val k hk]; exact hval⟩

-- Helper: Vector.ofFn f then .get gives back f
private theorem vector_ofFn_get {α : Type} {n : Nat} (f : Fin n → α) (idx : Fin n) :
    (Vector.ofFn f).get idx = f idx := by
  simp [Vector.get, Vector.ofFn]

-- Helper: the foldl with Vector.ofFn .get is the same as foldl with f directly
private theorem foldl_vector_ofFn_get {N : Nat} (val : BitVec N) :
    (List.finRange (N / 8)).foldl
      (fun acc (idx : Fin (N / 8)) =>
        acc ||| ((Vector.ofFn (fun (i : Fin (N / 8)) =>
          (val >>> (↑i * 8)).truncate 8)).get idx).toNat <<< (↑idx * 8))
      0 =
    (List.finRange (N / 8)).foldl
      (fun acc (idx : Fin (N / 8)) =>
        acc ||| ((val >>> (↑idx * 8)).truncate 8).toNat <<< (↑idx * 8))
      0 := by
  have : (fun acc (idx : Fin (N / 8)) =>
        acc ||| ((Vector.ofFn (fun (i : Fin (N / 8)) =>
          (val >>> (↑i * 8)).truncate 8)).get idx).toNat <<< (↑idx * 8)) =
      (fun acc (idx : Fin (N / 8)) =>
        acc ||| ((val >>> (↑idx * 8)).truncate 8).toNat <<< (↑idx * 8)) := by
    funext acc idx
    rw [vector_ofFn_get]
  rw [this]

/-- **Load-Store roundtrip**: storing a value and loading it back yields the original.
    Wasm spec: FR-512 -/
theorem load_store_same {addrWidth N : Nat}
    (mem : FlatMemory addrWidth) (addr : BitVec addrWidth)
    (val : BitVec N) (hN : N % 8 = 0) (mem' : FlatMemory addrWidth)
    (hstore : storeN mem addr val hN = some mem') :
    loadN mem' addr N hN = some val := by
  unfold storeN at hstore
  unfold loadN
  simp only [FlatMemory.readLittleEndian]
  have hbytes := FlatMemory.readBytes_writeLittleEndian mem addr.toNat N hN val mem' hstore
  rw [hbytes]
  simp only [Option.some.injEq]
  rw [foldl_vector_ofFn_get]
  exact byte_assembly_roundtrip N hN val

/-- **Load-Store disjointness**: storing at one address doesn't affect loads at disjoint addresses.
    Wasm spec: FR-512 -/
theorem load_store_disjoint {addrWidth N M : Nat}
    (mem : FlatMemory addrWidth)
    (wAddr rAddr : BitVec addrWidth)
    (val : BitVec N) (hN : N % 8 = 0) (hM : M % 8 = 0)
    (mem' : FlatMemory addrWidth)
    (hstore : storeN mem wAddr val hN = some mem')
    (hdisjoint : wAddr.toNat + N / 8 ≤ rAddr.toNat ∨ rAddr.toNat + M / 8 ≤ wAddr.toNat) :
    loadN mem' rAddr M hM = loadN mem rAddr M hM := by
  unfold storeN at hstore
  unfold loadN
  simp only [FlatMemory.readLittleEndian]
  rw [FlatMemory.readBytes_writeLittleEndian_disjoint mem wAddr.toNat rAddr.toNat N (M / 8) hN val mem' hstore hdisjoint]

end WasmNum.Memory.Proofs
