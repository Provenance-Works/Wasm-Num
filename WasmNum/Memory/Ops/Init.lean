import WasmNum.Memory.Core.FlatMemory
import WasmNum.Memory.Ops.DataDrop

/-!
# memory.init

Copy data from a passive data segment into linear memory.
Traps if the source or destination region exceeds bounds,
or if the data segment has been dropped.

Wasm spec: Section 4.4.7 "Memory Instructions"
- `memory.init`: copy from data segment to memory
- Trap if segment is dropped, or if regions exceed bounds
- FR-517: Memory Init
-/

set_option autoImplicit false

namespace WasmNum.Memory.Ops

open WasmNum
open WasmNum.Memory

private theorem byteArray_size_set_init (a : ByteArray) (i : Nat) (v : UInt8)
    (h : i < a.size) : (a.set i v h).size = a.size := by
  unfold ByteArray.set ByteArray.size
  simp [Array.size_set]

/-- Copy `remaining` bytes from `segment` starting at `srcOff` into memory at `dstOff`. -/
private def copyFromSegment {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dstOff : Nat) (segment : ByteArray) (srcOff : Nat)
    : Nat → Option (FlatMemory addrWidth)
  | 0 => some mem
  | remaining + 1 =>
    if hs : srcOff < segment.size then
      if hd : dstOff < mem.data.size then
        let byte := segment.get srcOff hs
        let mem' : FlatMemory addrWidth := { mem with
          data := mem.data.set dstOff byte hd
          inv_dataSize := by rw [byteArray_size_set_init]; exact mem.inv_dataSize }
        copyFromSegment mem' (dstOff + 1) segment (srcOff + 1) remaining
      else none
    else none

/-- `memory.init`: copy `len` bytes from data segment at `srcOffset` to memory at `dst`.
    Returns `none` (trap) if:
    - The data segment has been dropped
    - `dst + len > mem.data.size`
    - `srcOffset + len > segment.size`
    Wasm spec: `memory.init` instruction -/
def init {addrWidth : Nat} (mem : FlatMemory addrWidth)
    (dst : BitVec addrWidth) (seg : DataSegment) (srcOffset : Nat) (len : Nat)
    : Option (FlatMemory addrWidth) :=
  match seg.bytes with
  | none => none  -- segment has been dropped
  | some segData =>
    let d := dst.toNat
    if d + len ≤ mem.data.size ∧ srcOffset + len ≤ segData.size then
      copyFromSegment mem d segData srcOffset len
    else
      none

end WasmNum.Memory.Ops
