import WasmNum.Memory.Core.FlatMemory

/-!
# memory.copy

Copy a region of bytes within the same memory.
Correctly handles overlapping source and destination regions
by choosing copy direction based on address comparison.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `memory.copy`: copy `n` bytes from `s` to `d`
- When `d ≤ s`: copy forward (low to high)
- When `d > s`: copy backward (high to low)
- Trap if either region exceeds memory bounds
- FR-516: Memory Copy
-/

set_option autoImplicit false

namespace WasmNum.Memory.Ops

open WasmNum
open WasmNum.Memory

private theorem byteArray_size_set' (a : ByteArray) (i : Nat) (v : UInt8)
    (h : i < a.size) : (a.set i v h).size = a.size := by
  unfold ByteArray.set ByteArray.size
  simp [Array.size_set]

/-- Copy `remaining` bytes forward (low to high) within a byte array,
    from `srcOff` to `dstOff`. -/
def copyForward {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstOff srcOff : Nat) : Nat → Option (FlatMemory addrWidth)
  | 0 => some mem
  | remaining + 1 =>
    if hs : srcOff < mem.data.size then
      if hd : dstOff < mem.data.size then
        let byte := mem.data.get srcOff hs
        let mem' : FlatMemory addrWidth := { mem with
          data := mem.data.set dstOff byte hd
          inv_dataSize := by rw [byteArray_size_set']; exact mem.inv_dataSize }
        copyForward mem' (dstOff + 1) (srcOff + 1) remaining
      else none
    else none

/-- Copy `remaining` bytes backward (high to low) within a byte array.
    `dstEnd` and `srcEnd` point one past the last byte to copy. -/
def copyBackward {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstEnd srcEnd : Nat) : Nat → Option (FlatMemory addrWidth)
  | 0 => some mem
  | remaining + 1 =>
    let si := srcEnd - 1
    let di := dstEnd - 1
    if hs : si < mem.data.size then
      if hd : di < mem.data.size then
        let byte := mem.data.get si hs
        let mem' : FlatMemory addrWidth := { mem with
          data := mem.data.set di byte hd
          inv_dataSize := by rw [byteArray_size_set']; exact mem.inv_dataSize }
        copyBackward mem' (dstEnd - 1) (srcEnd - 1) remaining
      else none
    else none

/-- `memory.copy`: copy `len` bytes from `src` to `dst`.
    Handles overlapping regions correctly.
    Returns `none` (trap) if either region exceeds memory bounds.
    Wasm spec: `memory.copy` instruction -/
def copy {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst src : BitVec addrWidth) (len : BitVec addrWidth)
    : Option (FlatMemory addrWidth) :=
  let d := dst.toNat
  let s := src.toNat
  let n := len.toNat
  if d + n ≤ mem.data.size ∧ s + n ≤ mem.data.size then
    if d ≤ s then
      copyForward mem d s n
    else
      copyBackward mem (d + n) (s + n) n
  else
    none

end WasmNum.Memory.Ops
