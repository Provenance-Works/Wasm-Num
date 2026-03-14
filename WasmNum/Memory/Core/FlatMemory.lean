import WasmNum.Memory.Core.Page

/-!
# FlatMemory

Core memory structure parameterized by address width (ADR-005).
A `FlatMemory addrWidth` represents a linear byte-addressable memory with
page-based allocation and four invariants ensuring consistency.

Supports both Memory32 (`addrWidth = 32`) and Memory64 (`addrWidth = 64`).

Wasm spec: Section 4.5.3 "Memory Instances"
- FR-502: FlatMemory Structure
-/

set_option autoImplicit false

namespace WasmNum.Memory

open WasmNum

/-- Core memory type: a linear byte array with page-based allocation.
    Parameterized by address width to support both Memory32 and Memory64.

    Invariants:
    - `inv_dataSize`:  `data.size` is exactly `pageCount * pageSize`
    - `inv_maxValid`:  if a max is set, `pageCount ≤ max`
    - `inv_addrFits`:  allocated bytes fit in the address space
    - `inv_maxFits`:   max limit (if set) fits in the address space

    Wasm spec: Section 4.5.3 "Memory Instances" -/
structure FlatMemory (addrWidth : Nat) where
  /-- The raw byte storage -/
  data : ByteArray
  /-- Current number of allocated pages -/
  pageCount : Nat
  /-- Optional maximum page limit from the memory type -/
  maxLimit : Option Nat
  /-- Data size equals pageCount * pageSize -/
  inv_dataSize : data.size = pageCount * pageSize
  /-- Page count respects the maximum limit -/
  inv_maxValid : ∀ (max : Nat), maxLimit = some max → pageCount ≤ max
  /-- Allocated bytes fit in the address space -/
  inv_addrFits : pageCount * pageSize ≤ 2 ^ addrWidth
  /-- Max limit fits in the address space -/
  inv_maxFits : ∀ (max : Nat), maxLimit = some max → max * pageSize ≤ 2 ^ addrWidth

/-- Memory32: 32-bit addressed memory -/
abbrev Memory32 := FlatMemory 32

/-- Memory64: 64-bit addressed memory -/
abbrev Memory64 := FlatMemory 64

/-- Create an empty memory with 0 pages.
    Wasm spec: initial memory with no data -/
def FlatMemory.empty (addrWidth : Nat) (maxLimit : Option Nat := none)
    (h_maxFits : ∀ (max : Nat), maxLimit = some max → max * pageSize ≤ 2 ^ addrWidth := by
      intro max hmax; simp_all) : FlatMemory addrWidth where
  data := ByteArray.empty
  pageCount := 0
  maxLimit := maxLimit
  inv_dataSize := ByteArray.size_empty
  inv_maxValid := by intro max _; omega
  inv_addrFits := Nat.zero_le _
  inv_maxFits := h_maxFits

/-- Current size in bytes -/
def FlatMemory.byteSize {addrWidth : Nat} (mem : FlatMemory addrWidth) : Nat :=
  mem.data.size

/-- Current size in pages (for `memory.size` instruction).
    Wasm spec: `memory.size` returns page count -/
def FlatMemory.sizePages {addrWidth : Nat} (mem : FlatMemory addrWidth) : Nat :=
  mem.pageCount

set_option maxRecDepth 1024 in
private theorem byteArray_size_set (a : ByteArray) (i : Nat) (v : UInt8)
    (h : i < a.size) : (a.set i v h).size = a.size := by
  unfold ByteArray.set ByteArray.size
  simp [Array.size_set]

/-- Read a single byte at a natural number offset.
    Returns `none` if out of bounds. -/
def FlatMemory.readByte {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) : Option (BitVec 8) :=
  if h : offset < mem.data.size then
    some (BitVec.ofNat 8 (mem.data.get offset h).toNat)
  else
    none

/-- Read `count` bytes starting at `offset` in little-endian order.
    Returns `none` if any byte is out of bounds. -/
def FlatMemory.readBytes {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (count : Nat) : Option (Vector (BitVec 8) count) :=
  if h : offset + count ≤ mem.data.size then
    some (Vector.ofFn fun (i : Fin count) =>
      BitVec.ofNat 8 (mem.data.get (offset + i.val) (by omega)).toNat)
  else
    none

/-- Read N bits from memory at `offset` in little-endian byte order.
    Returns `none` if out of bounds.
    Requires N to be a multiple of 8. -/
def FlatMemory.readLittleEndian {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (N : Nat) (_hN : N % 8 = 0) : Option (BitVec N) :=
  let byteCount := N / 8
  match mem.readBytes offset byteCount with
  | none => none
  | some bytes =>
    -- Assemble bytes in little-endian: byte 0 is least significant
    let result := (List.finRange byteCount).foldl
      (fun (acc : Nat) (idx : Fin byteCount) =>
        acc ||| ((bytes.get idx).toNat <<< (idx.val * 8)))
      0
    some (BitVec.ofNat N result)

/-- Write a single byte at a natural number offset.
    Returns `none` if out of bounds. -/
def FlatMemory.writeByte {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : BitVec 8) : Option (FlatMemory addrWidth) :=
  if h : offset < mem.data.size then
    some { mem with
      data := mem.data.set offset val.toNat.toUInt8 h
      inv_dataSize := by
        rw [byteArray_size_set]; exact mem.inv_dataSize }
  else
    none

/-- Write bytes sequentially in little-endian order.
    Recursive helper for `writeLittleEndian`, terminating on `remaining`. -/
private def FlatMemory.writeBytesLE {addrWidth N : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : BitVec N) (byteIdx : Nat) : Nat → Option (FlatMemory addrWidth)
  | 0 => some mem
  | remaining + 1 =>
    let byte := (val >>> (byteIdx * 8)).truncate 8
    match mem.writeByte (offset + byteIdx) byte with
    | none => none
    | some mem' => mem'.writeBytesLE offset val (byteIdx + 1) remaining

/-- Write N bits to memory at `offset` in little-endian byte order.
    Returns `none` if out of bounds.
    Requires N to be a multiple of 8.
    Checks bounds once upfront, then writes each byte sequentially. -/
def FlatMemory.writeLittleEndian {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (N : Nat) (_hN : N % 8 = 0) (val : BitVec N)
    : Option (FlatMemory addrWidth) :=
  let byteCount := N / 8
  if offset + byteCount > mem.data.size then
    none
  else
    mem.writeBytesLE offset val 0 byteCount

/-- Writing a byte preserves the data size. -/
theorem FlatMemory.writeByte_dataSize {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : BitVec 8) (mem' : FlatMemory addrWidth)
    (h : mem.writeByte offset val = some mem') : mem'.data.size = mem.data.size := by
  unfold writeByte at h
  split at h
  · case isTrue hlt =>
    simp only [Option.some.injEq] at h
    rw [← h]
    exact byteArray_size_set mem.data offset val.toNat.toUInt8 hlt
  · simp at h

/-- If the offset is in bounds, writeByte succeeds. -/
theorem FlatMemory.writeByte_some_of_lt {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : BitVec 8) (h : offset < mem.data.size) :
    ∃ mem', mem.writeByte offset val = some mem' ∧ mem'.data.size = mem.data.size := by
  unfold writeByte
  simp only [h, dite_true]
  exact ⟨_, rfl, byteArray_size_set mem.data offset val.toNat.toUInt8 h⟩

/-- writeBytesLE preserves data size when it succeeds. -/
private theorem FlatMemory.writeBytesLE_dataSize {addrWidth N : Nat}
    (mem : FlatMemory addrWidth) (offset : Nat) (val : BitVec N)
    (byteIdx : Nat) : ∀ (remaining : Nat) (result : FlatMemory addrWidth),
    mem.writeBytesLE offset val byteIdx remaining = some result →
    result.data.size = mem.data.size
  | 0, result, h => by
    simp [writeBytesLE] at h; subst h; rfl
  | remaining + 1, result, h => by
    simp only [writeBytesLE] at h
    generalize hbyte : (val >>> (byteIdx * 8)).truncate 8 = byte at h
    cases h_wb : mem.writeByte (offset + byteIdx) byte with
    | none => simp [h_wb] at h
    | some memMid =>
      simp [h_wb] at h
      have h_step := writeByte_dataSize mem _ _ memMid h_wb
      have h_rest := writeBytesLE_dataSize memMid offset val (byteIdx + 1) remaining result h
      omega

/-- Writing in little-endian preserves data size when it succeeds. -/
theorem FlatMemory.writeLittleEndian_dataSize {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (offset N : Nat) (hN : N % 8 = 0)
    (val : BitVec N) (result : FlatMemory addrWidth)
    (h : mem.writeLittleEndian offset N hN val = some result) :
    result.data.size = mem.data.size := by
  simp only [writeLittleEndian] at h
  split at h
  · simp at h
  · exact writeBytesLE_dataSize mem offset val 0 (N / 8) result h

end WasmNum.Memory

/-! ### Read-after-write lemmas -/

set_option maxRecDepth 2048

namespace WasmNum.Memory

/-- Reading a byte at the same offset that was just written returns the written value. -/
theorem FlatMemory.readByte_writeByte_same {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : BitVec 8) (mem' : FlatMemory addrWidth)
    (hw : mem.writeByte offset val = some mem') :
    mem'.readByte offset = some val := by
  unfold writeByte at hw
  split at hw
  next hlt =>
    simp only [Option.some.injEq] at hw; subst hw
    simp only [readByte, byteArray_size_set, hlt, dite_true]
    simp only [ByteArray.get, ByteArray.set, Array.getElem_set,
      BitVec.ofNat_toNat, BitVec.setWidth_eq, Nat.toUInt8, UInt8.toNat]
    simp
  next => simp at hw

/-- Reading a byte at a different offset from a write is unchanged. -/
theorem FlatMemory.readByte_writeByte_ne {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (i j : Nat) (val : BitVec 8) (mem' : FlatMemory addrWidth)
    (hw : mem.writeByte i val = some mem') (hne : Not (i = j)) :
    mem'.readByte j = mem.readByte j := by
  unfold writeByte at hw
  split at hw
  next hlt =>
    simp only [Option.some.injEq] at hw; subst hw
    simp only [readByte, byteArray_size_set]
    unfold ByteArray.get ByteArray.set ByteArray.size
    simp [Array.getElem_set, hne]
  next => simp at hw

/-- writeBytesLE succeeds when there's enough room. -/
private theorem FlatMemory.writeBytesLE_some {addrWidth N : Nat}
    (mem : FlatMemory addrWidth) (offset : Nat) (val : BitVec N)
    (byteIdx : Nat) : (remaining : Nat) →
    offset + byteIdx + remaining ≤ mem.data.size →
    ∃ result, mem.writeBytesLE offset val byteIdx remaining = some result
  | 0, _ => ⟨mem, rfl⟩
  | remaining + 1, hbound => by
    simp only [writeBytesLE]
    have hlt : offset + byteIdx < mem.data.size := by omega
    obtain ⟨mem', hmem', hsize'⟩ := writeByte_some_of_lt mem (offset + byteIdx)
      ((val >>> (byteIdx * 8)).truncate 8) hlt
    simp [hmem']
    exact writeBytesLE_some mem' offset val (byteIdx + 1) remaining (by omega)

/-- Reading at offset j (outside the write range) is unchanged after writeBytesLE. -/
private theorem FlatMemory.readByte_writeBytesLE_outside {addrWidth N : Nat}
    (mem : FlatMemory addrWidth) (offset : Nat) (val : BitVec N)
    (byteIdx j : Nat) :
    (remaining : Nat) → (result : FlatMemory addrWidth) →
    (j < offset + byteIdx ∨ offset + byteIdx + remaining ≤ j) →
    mem.writeBytesLE offset val byteIdx remaining = some result →
    result.readByte j = mem.readByte j
  | 0, result, _, h => by simp [writeBytesLE] at h; subst h; rfl
  | remaining + 1, result, hout, h => by
    simp only [writeBytesLE] at h
    generalize hbyte : (val >>> (byteIdx * 8)).truncate 8 = byte at h
    cases h_wb : mem.writeByte (offset + byteIdx) byte with
    | none => simp [h_wb] at h
    | some memMid =>
      simp [h_wb] at h
      have hne : Not (offset + byteIdx = j) := by omega
      rw [readByte_writeBytesLE_outside memMid offset val (byteIdx + 1) j
        remaining result (by omega) h]
      exact readByte_writeByte_ne mem _ j byte memMid h_wb hne

/-- After writeBytesLE, reading byte k within the write range returns the corresponding byte. -/
private theorem FlatMemory.readByte_writeBytesLE_inside {addrWidth N : Nat}
    (mem : FlatMemory addrWidth) (offset : Nat) (val : BitVec N)
    (byteIdx k : Nat) :
    (remaining : Nat) → (result : FlatMemory addrWidth) →
    k < remaining →
    offset + byteIdx + remaining ≤ mem.data.size →
    mem.writeBytesLE offset val byteIdx remaining = some result →
    result.readByte (offset + byteIdx + k) =
      some ((val >>> ((byteIdx + k) * 8)).truncate 8)
  | 0, _, hk, _, _ => absurd hk (by omega)
  | remaining + 1, result, hk, hbound, h => by
    simp only [writeBytesLE] at h
    generalize hbyte : (val >>> (byteIdx * 8)).truncate 8 = byte at h
    cases h_wb : mem.writeByte (offset + byteIdx) byte with
    | none => simp [h_wb] at h
    | some memMid =>
      simp [h_wb] at h
      have hsize := writeByte_dataSize mem _ _ memMid h_wb
      match k with
      | 0 =>
        rw [show offset + byteIdx + 0 = offset + byteIdx from by omega]
        rw [show byteIdx + 0 = byteIdx from by omega]
        rw [readByte_writeBytesLE_outside memMid offset val (byteIdx + 1)
          (offset + byteIdx) remaining result (by omega) h]
        rw [readByte_writeByte_same mem _ byte memMid h_wb, ← hbyte]
      | k' + 1 =>
        rw [show offset + byteIdx + (k' + 1) = offset + (byteIdx + 1) + k' from by omega]
        rw [show byteIdx + (k' + 1) = (byteIdx + 1) + k' from by omega]
        exact readByte_writeBytesLE_inside memMid offset val (byteIdx + 1) k'
          remaining result (by omega) (by omega) h

/-- After writeLittleEndian, readBytes returns the byte decomposition of the written value. -/
theorem FlatMemory.readBytes_writeLittleEndian {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (offset N : Nat) (hN : N % 8 = 0)
    (val : BitVec N) (result : FlatMemory addrWidth)
    (hwrite : mem.writeLittleEndian offset N hN val = some result) :
    result.readBytes offset (N / 8) =
      some (Vector.ofFn fun (i : Fin (N / 8)) =>
        (val >>> (i.val * 8)).truncate 8) := by
  have hresSize := writeLittleEndian_dataSize mem offset N hN val result hwrite
  simp only [writeLittleEndian] at hwrite
  split at hwrite
  next => simp at hwrite
  next hbound =>
    simp only [Nat.not_lt] at hbound
    unfold readBytes
    have hbound' : offset + N / 8 ≤ result.data.size := by omega
    simp only [hbound', dite_true, Option.some.injEq]
    apply Vector.ext
    intro i
    intro hi
    simp only [Vector.getElem_ofFn]
    have hread := readByte_writeBytesLE_inside mem offset val 0 i
      (N / 8) result (by omega) (by omega) hwrite
    simp only [Nat.zero_add] at hread
    simp only [Nat.add_zero] at hread
    unfold readByte at hread
    split at hread
    next => simp only [Option.some.injEq] at hread; exact hread
    next => simp at hread

/-- Reading bytes at an offset disjoint from the write range is unchanged. -/
theorem FlatMemory.readBytes_writeLittleEndian_disjoint {addrWidth : Nat}
    (mem : FlatMemory addrWidth) (wOffset rOffset N M : Nat) (hN : N % 8 = 0)
    (val : BitVec N) (result : FlatMemory addrWidth)
    (hwrite : mem.writeLittleEndian wOffset N hN val = some result)
    (hdisjoint : wOffset + N / 8 ≤ rOffset ∨ rOffset + M ≤ wOffset) :
    result.readBytes rOffset M = mem.readBytes rOffset M := by
  have hresSize := writeLittleEndian_dataSize mem wOffset N hN val result hwrite
  simp only [writeLittleEndian] at hwrite
  split at hwrite
  next => simp at hwrite
  next hbound =>
    simp only [Nat.not_lt] at hbound
    unfold readBytes
    simp only [hresSize]
    split
    next hm =>
      congr 1
      apply Vector.ext
      intro i
      intro hi
      simp only [Vector.getElem_ofFn]
      have hout' : rOffset + i < wOffset + 0 ∨ wOffset + 0 + (N / 8) ≤ rOffset + i := by omega
      have hread := readByte_writeBytesLE_outside mem wOffset val 0 (rOffset + i)
        (N / 8) result hout' hwrite
      -- hread : result.readByte (rOffset + i) = mem.readByte (rOffset + i)
      -- Goal: BitVec.ofNat 8 (result.data.get (rOffset + i) _).toNat =
      --       BitVec.ofNat 8 (mem.data.get (rOffset + i) _).toNat
      -- We need to extract the byte from readByte
      unfold readByte at hread
      have hlt_res : rOffset + i < result.data.size := by omega
      have hlt_mem : rOffset + i < mem.data.size := by omega
      simp only [hlt_res, hlt_mem, dite_true, Option.some.injEq] at hread
      exact hread
    next => rfl

end WasmNum.Memory
