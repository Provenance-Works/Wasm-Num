import WasmNum.Memory.Ops.Fill

/-!
# Memory Fill Proofs

Formal proofs about memory fill operation.

Wasm spec: Section 4.4.7 "Memory Instructions"
- FR-515: Memory fill correctness proofs
-/

set_option autoImplicit false
set_option maxRecDepth 2048

namespace WasmNum.Memory.Proofs

open WasmNum
open WasmNum.Memory
open WasmNum.Memory.Ops

private theorem ba_size_set (a : ByteArray) (i : Nat) (v : UInt8)
    (h : i < a.size) : (a.set i v h).size = a.size := by
  unfold ByteArray.set ByteArray.size; simp [Array.size_set]

/-- Fill traps when the region exceeds memory bounds. -/
theorem fill_none_of_oob {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst : BitVec addrWidth) (val : BitVec 8) (len : BitVec addrWidth)
    (h : dst.toNat + len.toNat > mem.data.size) :
    fill mem dst val len = none := by
  unfold fill
  simp only
  split
  · omega
  · rfl

-- Helper: the intermediate FlatMemory from writing one byte
private def writtenMem {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : UInt8) (hlt : offset < mem.data.size) :
    FlatMemory addrWidth :=
  { mem with
    data := mem.data.set offset val hlt
    inv_dataSize := by rw [ba_size_set]; exact mem.inv_dataSize }

private theorem writtenMem_data {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : UInt8) (hlt : offset < mem.data.size) :
    (writtenMem mem offset val hlt).data = mem.data.set offset val hlt := by
  rfl

private theorem writtenMem_data_size {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : UInt8) (hlt : offset < mem.data.size) :
    (writtenMem mem offset val hlt).data.size = mem.data.size := by
  simp [writtenMem, ba_size_set]

private theorem fillBytesAux_step {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : UInt8) (remaining : Nat)
    (hlt : offset < mem.data.size) :
    fillBytesAux mem offset val (remaining + 1) =
      fillBytesAux (writtenMem mem offset val hlt) (offset + 1) val remaining := by
  simp [fillBytesAux, hlt, writtenMem]

-- Helper: reading a byte outside the fill range is unchanged
private theorem readByte_fillBytesAux_outside {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (offset : Nat) (val : UInt8) (j : Nat) :
    (remaining : Nat) → (result : FlatMemory addrWidth) →
    (j < offset ∨ offset + remaining ≤ j) →
    offset + remaining ≤ mem.data.size →
    fillBytesAux mem offset val remaining = some result →
    result.readByte j = mem.readByte j
  | 0, result, _, _, h => by simp [fillBytesAux] at h; subst h; rfl
  | remaining + 1, result, hout, hbound, h => by
    have hlt : offset < mem.data.size := by omega
    rw [fillBytesAux_step mem offset val remaining hlt] at h
    have hne : Not (offset = j) := by omega
    have hdsz := writtenMem_data_size mem offset val hlt
    have hbound' : (offset + 1) + remaining ≤ (writtenMem mem offset val hlt).data.size := by
      rw [hdsz]; omega
    rw [readByte_fillBytesAux_outside (writtenMem mem offset val hlt) (offset + 1) val j
      remaining result (by omega) hbound' h]
    simp only [FlatMemory.readByte, writtenMem_data]
    by_cases hjlt : j < mem.data.size
    · have hszSet := ba_size_set mem.data offset val hlt
      simp only [hszSet, hjlt, dite_true]
      unfold ByteArray.get ByteArray.set ByteArray.size
      simp [Array.getElem_set, hne]
    · have hjlt' : ¬(j < (mem.data.set offset val hlt).size) := by
        rw [ba_size_set]; omega
      simp only [hjlt, hjlt', dite_false]

-- Helper: reading a byte at an offset written by fillBytesAux yields the fill value
private theorem readByte_fillBytesAux_inside {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (offset : Nat) (val : UInt8) (k : Nat) :
    (remaining : Nat) → (result : FlatMemory addrWidth) →
    k < remaining →
    offset + remaining ≤ mem.data.size →
    fillBytesAux mem offset val remaining = some result →
    result.readByte (offset + k) = some (BitVec.ofNat 8 val.toNat)
  | 0, _, hk, _, _ => absurd hk (by omega)
  | remaining + 1, result, hk, hbound, h => by
    have hlt : offset < mem.data.size := by omega
    rw [fillBytesAux_step mem offset val remaining hlt] at h
    have hdsz := writtenMem_data_size mem offset val hlt
    have hbound' : (offset + 1) + remaining ≤ (writtenMem mem offset val hlt).data.size := by
      rw [hdsz]; omega
    match k with
    | 0 =>
      rw [show offset + 0 = offset from by omega]
      rw [readByte_fillBytesAux_outside (writtenMem mem offset val hlt) (offset + 1) val offset
        remaining result (by omega) hbound' h]
      simp only [FlatMemory.readByte, writtenMem_data]
      have hlt' : offset < (mem.data.set offset val hlt).size := by
        rw [ba_size_set]; omega
      simp only [hlt', dite_true]
      unfold ByteArray.get ByteArray.set ByteArray.size
      simp
    | k' + 1 =>
      rw [show offset + (k' + 1) = (offset + 1) + k' from by omega]
      exact readByte_fillBytesAux_inside (writtenMem mem offset val hlt) (offset + 1) val k'
        remaining result (by omega) hbound' h

/-- **Fill correctness**: after fill, every byte in the range has the fill value.
    Wasm spec: FR-515 -/
theorem fill_correct {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (dst : BitVec addrWidth)
    (val : BitVec 8) (len : BitVec addrWidth) (mem' : FlatMemory addrWidth)
    (hfill : fill mem dst val len = some mem')
    (k : Nat) (hk : k < len.toNat) :
    mem'.readByte (dst.toNat + k) = some val := by
  unfold fill at hfill
  simp only at hfill
  split at hfill
  next hbound =>
    have := readByte_fillBytesAux_inside mem dst.toNat val.toNat.toUInt8 k
      len.toNat mem' hk (by omega) hfill
    rw [this]
    simp [BitVec.ofNat_toNat, BitVec.setWidth_eq, Nat.toUInt8, UInt8.toNat]
  next => simp at hfill

end WasmNum.Memory.Proofs
