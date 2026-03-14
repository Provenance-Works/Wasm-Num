import WasmNum.Foundation.Defs

/-!
# Data Segment Type and Drop

Data segment state for `memory.init` and `data.drop` instructions.

Wasm spec: Section 4.5.5 "Data Instances"
- FR-504: Data Segments
-/

set_option autoImplicit false

namespace WasmNum.Memory

/-- Data segment state: either available with data, or dropped.
    Wasm spec: Section 4.5.5 "Data Instances" -/
inductive DataSegment where
  /-- Passive segment with data available for `memory.init` -/
  | available : ByteArray → DataSegment
  /-- Segment has been dropped via `data.drop` -/
  | dropped : DataSegment

/-- Drop a data segment: mark as dropped so it can no longer be used.
    Wasm spec: `data.drop` instruction -/
def dataDrop (_ : DataSegment) : DataSegment := .dropped

/-- Get the bytes of a data segment, if still available -/
def DataSegment.bytes : DataSegment → Option ByteArray
  | .available data => some data
  | .dropped => none

/-- Check if a data segment has been dropped -/
def DataSegment.isDropped : DataSegment → Bool
  | .available _ => false
  | .dropped => true

end WasmNum.Memory
