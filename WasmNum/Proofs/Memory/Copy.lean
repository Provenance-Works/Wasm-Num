import WasmNum.Memory.Ops.Copy

/-!
# Memory Copy Proofs

Formal proofs about memory copy operation.

Wasm spec: Section 4.4.7 "Memory Instructions"
- FR-516: Memory copy correctness proofs
-/

set_option autoImplicit false
set_option maxRecDepth 2048

namespace WasmNum.Memory.Proofs

open WasmNum
open WasmNum.Memory
open WasmNum.Memory.Ops

/-- Copy traps when destination region is out of bounds. -/
theorem copy_none_of_dst_oob {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst src : BitVec addrWidth) (len : BitVec addrWidth)
    (h : dst.toNat + len.toNat > mem.data.size) :
    copy mem dst src len = none := by
  unfold copy
  simp only
  split
  · rename_i hb; exact absurd hb.1 (by omega)
  · rfl

/-- Copy traps when source region is out of bounds. -/
theorem copy_none_of_src_oob {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst src : BitVec addrWidth) (len : BitVec addrWidth)
    (h : src.toNat + len.toNat > mem.data.size) :
    copy mem dst src len = none := by
  unfold copy
  simp only
  split
  · rename_i hb; exact absurd hb.2 (by omega)
  · rfl

private theorem ba_size_set (a : ByteArray) (i : Nat) (v : UInt8)
    (h : i < a.size) : (a.set i v h).size = a.size := by
  unfold ByteArray.set ByteArray.size; simp [Array.size_set]

-- Helper: the intermediate memory from writing one byte in copyForward
private def copyWrittenMem {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstOff srcOff : Nat) (hs : srcOff < mem.data.size) (hd : dstOff < mem.data.size)
    : FlatMemory addrWidth :=
  { mem with
    data := mem.data.set dstOff (mem.data.get srcOff hs) hd
    inv_dataSize := by rw [ba_size_set]; exact mem.inv_dataSize }

private theorem copyWrittenMem_data_size {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstOff srcOff : Nat) (hs : srcOff < mem.data.size) (hd : dstOff < mem.data.size) :
    (copyWrittenMem mem dstOff srcOff hs hd).data.size = mem.data.size := by
  simp [copyWrittenMem, ba_size_set]

-- Helper: readByte of copyWrittenMem at the write index returns the source byte
private theorem readByte_copyWrittenMem_same {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstOff srcOff : Nat) (hs : srcOff < mem.data.size) (hd : dstOff < mem.data.size) :
    (copyWrittenMem mem dstOff srcOff hs hd).readByte dstOff = mem.readByte srcOff := by
  simp only [FlatMemory.readByte, copyWrittenMem, ba_size_set, hd, hs, dite_true]
  congr 1
  show BitVec.ofNat 8 (ByteArray.get (mem.data.set dstOff (mem.data.get srcOff hs) hd) dstOff (by rw [ba_size_set]; omega)).toNat =
       BitVec.ofNat 8 (ByteArray.get mem.data srcOff hs).toNat
  unfold ByteArray.get ByteArray.set
  simp [Array.getElem_set]

-- Helper: readByte of copyWrittenMem at a different index is unchanged
private theorem readByte_copyWrittenMem_ne {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstOff srcOff j : Nat) (hs : srcOff < mem.data.size) (hd : dstOff < mem.data.size)
    (hne : Not (dstOff = j)) :
    (copyWrittenMem mem dstOff srcOff hs hd).readByte j = mem.readByte j := by
  simp only [FlatMemory.readByte, copyWrittenMem]
  by_cases hjlt : j < mem.data.size
  · have hszSet := ba_size_set mem.data dstOff (mem.data.get srcOff hs) hd
    simp only [hszSet, hjlt, dite_true]
    unfold ByteArray.get ByteArray.set ByteArray.size
    simp [Array.getElem_set, hne]
  · have hjlt' : ¬(j < (mem.data.set dstOff (mem.data.get srcOff hs) hd).size) := by
      rw [ba_size_set]; omega
    simp only [hjlt, hjlt', dite_false]

private theorem copyForward_step {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstOff srcOff remaining : Nat)
    (hs : srcOff < mem.data.size) (hd : dstOff < mem.data.size) :
    copyForward mem dstOff srcOff (remaining + 1) =
      copyForward (copyWrittenMem mem dstOff srcOff hs hd) (dstOff + 1) (srcOff + 1) remaining := by
  simp [copyForward, hs, hd, copyWrittenMem]

-- Reading a byte outside the copyForward destination range is unchanged
private theorem readByte_copyForward_outside {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (dstOff srcOff : Nat) (j : Nat) :
    (remaining : Nat) → (result : FlatMemory addrWidth) →
    (j < dstOff ∨ dstOff + remaining ≤ j) →
    dstOff + remaining ≤ mem.data.size →
    srcOff + remaining ≤ mem.data.size →
    copyForward mem dstOff srcOff remaining = some result →
    result.readByte j = mem.readByte j
  | 0, result, _, _, _, h => by simp [copyForward] at h; subst h; rfl
  | remaining + 1, result, hout, hdbound, hsbound, h => by
    have hs : srcOff < mem.data.size := by omega
    have hd : dstOff < mem.data.size := by omega
    rw [copyForward_step mem dstOff srcOff remaining hs hd] at h
    have hne : Not (dstOff = j) := by omega
    have hdsz := copyWrittenMem_data_size mem dstOff srcOff hs hd
    have hdbound' : (dstOff + 1) + remaining ≤ (copyWrittenMem mem dstOff srcOff hs hd).data.size := by
      rw [hdsz]; omega
    have hsbound' : (srcOff + 1) + remaining ≤ (copyWrittenMem mem dstOff srcOff hs hd).data.size := by
      rw [hdsz]; omega
    rw [readByte_copyForward_outside (copyWrittenMem mem dstOff srcOff hs hd) (dstOff + 1) (srcOff + 1) j
      remaining result (by omega) hdbound' hsbound' h]
    exact readByte_copyWrittenMem_ne mem dstOff srcOff j hs hd hne

-- The main forward copy spec: byte at dst+k equals original byte at src+k
-- Requires d ≤ s (forward direction) for non-overlapping reads from original
private theorem readByte_copyForward_inside {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (dstOff srcOff : Nat)
    (hds : dstOff ≤ srcOff) (k : Nat) :
    (remaining : Nat) → (result : FlatMemory addrWidth) →
    k < remaining →
    dstOff + remaining ≤ mem.data.size →
    srcOff + remaining ≤ mem.data.size →
    copyForward mem dstOff srcOff remaining = some result →
    result.readByte (dstOff + k) = mem.readByte (srcOff + k)
  | 0, _, hk, _, _, _ => absurd hk (by omega)
  | remaining + 1, result, hk, hdbound, hsbound, h => by
    have hs : srcOff < mem.data.size := by omega
    have hd : dstOff < mem.data.size := by omega
    rw [copyForward_step mem dstOff srcOff remaining hs hd] at h
    have hdsz := copyWrittenMem_data_size mem dstOff srcOff hs hd
    have hdbound' : (dstOff + 1) + remaining ≤ (copyWrittenMem mem dstOff srcOff hs hd).data.size := by
      rw [hdsz]; omega
    have hsbound' : (srcOff + 1) + remaining ≤ (copyWrittenMem mem dstOff srcOff hs hd).data.size := by
      rw [hdsz]; omega
    match k with
    | 0 =>
      rw [show dstOff + 0 = dstOff from by omega]
      rw [readByte_copyForward_outside (copyWrittenMem mem dstOff srcOff hs hd) (dstOff + 1) (srcOff + 1) dstOff
        remaining result (by omega) hdbound' hsbound' h]
      rw [show srcOff + 0 = srcOff from by omega]
      exact readByte_copyWrittenMem_same mem dstOff srcOff hs hd
    | k' + 1 =>
      rw [show dstOff + (k' + 1) = (dstOff + 1) + k' from by omega]
      have hds' : dstOff + 1 ≤ srcOff + 1 := by omega
      rw [readByte_copyForward_inside (copyWrittenMem mem dstOff srcOff hs hd) (dstOff + 1) (srcOff + 1)
        hds' k' remaining result (by omega) hdbound' hsbound' h]
      rw [show srcOff + (k' + 1) = srcOff + 1 + k' from by omega]
      exact readByte_copyWrittenMem_ne mem dstOff srcOff (srcOff + 1 + k') hs hd (by omega)

-- Helper: the intermediate memory from writing one byte in copyBackward
private def copyBackWrittenMem {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstEnd srcEnd : Nat) (hs : srcEnd - 1 < mem.data.size) (hd : dstEnd - 1 < mem.data.size)
    : FlatMemory addrWidth :=
  { mem with
    data := mem.data.set (dstEnd - 1) (mem.data.get (srcEnd - 1) hs) hd
    inv_dataSize := by rw [ba_size_set]; exact mem.inv_dataSize }

private theorem copyBackWrittenMem_data_size {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstEnd srcEnd : Nat) (hs : srcEnd - 1 < mem.data.size) (hd : dstEnd - 1 < mem.data.size) :
    (copyBackWrittenMem mem dstEnd srcEnd hs hd).data.size = mem.data.size := by
  simp [copyBackWrittenMem, ba_size_set]

-- Helper: readByte of copyBackWrittenMem at the write index returns the source byte
private theorem readByte_copyBackWrittenMem_same {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstEnd srcEnd : Nat) (hs : srcEnd - 1 < mem.data.size) (hd : dstEnd - 1 < mem.data.size) :
    (copyBackWrittenMem mem dstEnd srcEnd hs hd).readByte (dstEnd - 1) = mem.readByte (srcEnd - 1) := by
  simp only [FlatMemory.readByte, copyBackWrittenMem, ba_size_set, hd, hs, dite_true]
  congr 1
  show BitVec.ofNat 8 (ByteArray.get (mem.data.set (dstEnd - 1) (mem.data.get (srcEnd - 1) hs) hd) (dstEnd - 1) (by rw [ba_size_set]; omega)).toNat =
       BitVec.ofNat 8 (ByteArray.get mem.data (srcEnd - 1) hs).toNat
  unfold ByteArray.get ByteArray.set
  simp [Array.getElem_set]

-- Helper: readByte of copyBackWrittenMem at a different index is unchanged
private theorem readByte_copyBackWrittenMem_ne {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstEnd srcEnd j : Nat) (hs : srcEnd - 1 < mem.data.size) (hd : dstEnd - 1 < mem.data.size)
    (hne : Not (dstEnd - 1 = j)) :
    (copyBackWrittenMem mem dstEnd srcEnd hs hd).readByte j = mem.readByte j := by
  simp only [FlatMemory.readByte, copyBackWrittenMem]
  by_cases hjlt : j < mem.data.size
  · have hszSet := ba_size_set mem.data (dstEnd - 1) (mem.data.get (srcEnd - 1) hs) hd
    simp only [hszSet, hjlt, dite_true]
    unfold ByteArray.get ByteArray.set ByteArray.size
    simp [Array.getElem_set, hne]
  · have hjlt' : ¬(j < (mem.data.set (dstEnd - 1) (mem.data.get (srcEnd - 1) hs) hd).size) := by
      rw [ba_size_set]; omega
    simp only [hjlt, hjlt', dite_false]

private theorem copyBackward_step {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstEnd srcEnd remaining : Nat)
    (hs : srcEnd - 1 < mem.data.size) (hd : dstEnd - 1 < mem.data.size) :
    copyBackward mem dstEnd srcEnd (remaining + 1) =
      copyBackward (copyBackWrittenMem mem dstEnd srcEnd hs hd) (dstEnd - 1) (srcEnd - 1) remaining := by
  simp [copyBackward, hs, hd, copyBackWrittenMem]

-- Reading a byte outside the copyBackward range is unchanged
private theorem readByte_copyBackward_outside {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (dstEnd srcEnd : Nat) (j : Nat) :
    (remaining : Nat) → (result : FlatMemory addrWidth) →
    (j < dstEnd - remaining ∨ dstEnd ≤ j) →
    dstEnd ≤ mem.data.size →
    srcEnd ≤ mem.data.size →
    remaining ≤ dstEnd →
    remaining ≤ srcEnd →
    copyBackward mem dstEnd srcEnd remaining = some result →
    result.readByte j = mem.readByte j
  | 0, result, _, _, _, _, _, h => by simp [copyBackward] at h; subst h; rfl
  | remaining + 1, result, hout, hdbound, hsbound, hrd, hrs, h => by
    have hs : srcEnd - 1 < mem.data.size := by omega
    have hd : dstEnd - 1 < mem.data.size := by omega
    rw [copyBackward_step mem dstEnd srcEnd remaining hs hd] at h
    have hne : Not (dstEnd - 1 = j) := by omega
    have hdsz := copyBackWrittenMem_data_size mem dstEnd srcEnd hs hd
    have hdbound' : dstEnd - 1 ≤ (copyBackWrittenMem mem dstEnd srcEnd hs hd).data.size := by
      rw [hdsz]; omega
    have hsbound' : srcEnd - 1 ≤ (copyBackWrittenMem mem dstEnd srcEnd hs hd).data.size := by
      rw [hdsz]; omega
    rw [readByte_copyBackward_outside (copyBackWrittenMem mem dstEnd srcEnd hs hd)
      (dstEnd - 1) (srcEnd - 1) j remaining result (by omega) hdbound' hsbound'
      (by omega) (by omega) h]
    exact readByte_copyBackWrittenMem_ne mem dstEnd srcEnd j hs hd hne

-- The main backward copy spec: byte at (dstEnd-remaining+k) equals original byte at (srcEnd-remaining+k)
-- Requires srcEnd ≤ dstEnd (backward direction)
private theorem readByte_copyBackward_inside {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (dstEnd srcEnd : Nat)
    (hds : srcEnd ≤ dstEnd) (k : Nat) :
    (remaining : Nat) → (result : FlatMemory addrWidth) →
    k < remaining →
    dstEnd ≤ mem.data.size →
    srcEnd ≤ mem.data.size →
    remaining ≤ dstEnd →
    remaining ≤ srcEnd →
    copyBackward mem dstEnd srcEnd remaining = some result →
    result.readByte (dstEnd - remaining + k) = mem.readByte (srcEnd - remaining + k)
  | 0, _, hk, _, _, _, _, _ => absurd hk (by omega)
  | remaining + 1, result, hk, hdbound, hsbound, hrd, hrs, h => by
    have hs : srcEnd - 1 < mem.data.size := by omega
    have hd : dstEnd - 1 < mem.data.size := by omega
    rw [copyBackward_step mem dstEnd srcEnd remaining hs hd] at h
    have hdsz := copyBackWrittenMem_data_size mem dstEnd srcEnd hs hd
    have hdbound' : dstEnd - 1 ≤ (copyBackWrittenMem mem dstEnd srcEnd hs hd).data.size := by
      rw [hdsz]; omega
    have hsbound' : srcEnd - 1 ≤ (copyBackWrittenMem mem dstEnd srcEnd hs hd).data.size := by
      rw [hdsz]; omega
    by_cases hkeq : k = remaining
    · -- k = remaining: the highest byte, written in the first step, not touched by recursion
      rw [show dstEnd - (remaining + 1) + k = dstEnd - 1 from by omega]
      rw [show srcEnd - (remaining + 1) + k = srcEnd - 1 from by omega]
      rw [readByte_copyBackward_outside (copyBackWrittenMem mem dstEnd srcEnd hs hd)
        (dstEnd - 1) (srcEnd - 1) (dstEnd - 1) remaining result
        (by omega) hdbound' hsbound' (by omega) (by omega) h]
      exact readByte_copyBackWrittenMem_same mem dstEnd srcEnd hs hd
    · -- k < remaining: handled by the recursive call
      have hk' : k < remaining := by omega
      rw [show dstEnd - (remaining + 1) + k = dstEnd - 1 - remaining + k from by omega]
      rw [show srcEnd - (remaining + 1) + k = srcEnd - 1 - remaining + k from by omega]
      rw [readByte_copyBackward_inside (copyBackWrittenMem mem dstEnd srcEnd hs hd)
        (dstEnd - 1) (srcEnd - 1) (by omega) k remaining result hk'
        hdbound' hsbound' (by omega) (by omega) h]
      exact readByte_copyBackWrittenMem_ne mem dstEnd srcEnd (srcEnd - 1 - remaining + k) hs hd (by omega)

/-- **Copy correctness**: after copy, the destination range contains the original source bytes.
    Wasm spec: FR-516 -/
theorem copy_correct {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (dst src : BitVec addrWidth)
    (len : BitVec addrWidth) (mem' : FlatMemory addrWidth)
    (hcopy : copy mem dst src len = some mem')
    (k : Nat) (hk : k < len.toNat) :
    mem'.readByte (dst.toNat + k) = mem.readByte (src.toNat + k) := by
  unfold copy at hcopy
  simp only at hcopy
  split at hcopy
  next hbounds =>
    split at hcopy
    next hds =>
      -- Forward case: d ≤ s
      exact readByte_copyForward_inside mem dst.toNat src.toNat hds k len.toNat mem'
        hk (by omega) (by omega) hcopy
    next hds =>
      -- Backward case: d > s, so s < d, i.e., src < dst
      have hds' : src.toNat < dst.toNat := by omega
      -- copyBackward mem (d + n) (s + n) n = some mem'
      -- We need: mem'.readByte (d + k) = mem.readByte (s + k)
      -- readByte_copyBackward_inside: result.readByte ((d+n) - n + k) = mem.readByte ((s+n) - n + k)
      -- i.e., result.readByte (d + k) = mem.readByte (s + k) ✓
      have := readByte_copyBackward_inside mem (dst.toNat + len.toNat) (src.toNat + len.toNat)
        (by omega) k len.toNat mem' hk (by omega) (by omega) (by omega) (by omega) hcopy
      rwa [show dst.toNat + len.toNat - len.toNat + k = dst.toNat + k from by omega,
           show src.toNat + len.toNat - len.toNat + k = src.toNat + k from by omega] at this
  next => simp at hcopy

end WasmNum.Memory.Proofs
