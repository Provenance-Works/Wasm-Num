import WasmNum.Memory.Core.FlatMemory

/-!
# memory.fill

Fill a region of memory with a constant byte value.
Traps if the destination region exceeds memory bounds.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `memory.fill`: set `n` bytes starting at `d` to value `val`
- Trap if `d + n > mem.data.size`
- FR-515: Memory Fill
-/

set_option autoImplicit false

namespace WasmNum.Memory.Ops

open WasmNum
open WasmNum.Memory

/-- Fill `remaining` bytes in memory starting at `offset` with `val`.
    Recursive helper. -/
def fillBytesAux {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (offset : Nat) (val : UInt8) : Nat → Option (FlatMemory addrWidth)
  | 0 => some mem
  | remaining + 1 =>
    if h : offset < mem.data.size then
      let mem' : FlatMemory addrWidth := { mem with
        data := mem.data.set offset val h
        inv_dataSize := by
          rw [byteArray_size_set]; exact mem.inv_dataSize }
      fillBytesAux mem' (offset + 1) val remaining
    else
      none
where
  byteArray_size_set (a : ByteArray) (i : Nat) (v : UInt8)
      (h : i < a.size) : (a.set i v h).size = a.size := by
    unfold ByteArray.set ByteArray.size
    simp [Array.size_set]

/-- `memory.fill`: fill `len` bytes starting at `dst` with `val`.
    Returns `none` (trap) if `dst + len > mem.data.size`.
    Wasm spec: `memory.fill` instruction -/
def fill {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst : BitVec addrWidth) (val : BitVec 8) (len : BitVec addrWidth)
    : Option (FlatMemory addrWidth) :=
  let d := dst.toNat
  let n := len.toNat
  if d + n ≤ mem.data.size then
    fillBytesAux mem d val.toNat.toUInt8 n
  else
    none

end WasmNum.Memory.Ops
