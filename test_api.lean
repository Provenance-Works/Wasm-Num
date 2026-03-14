import WasmNum

/-!
# API Smoke Tests

`#eval` tests for deterministic operations and instruction-level wrappers.
These verify that core operations compute correctly at runtime.
-/

open WasmNum
open WasmNum.Memory
open WasmNum.Memory.Load
open WasmNum.Memory.Store
open WasmNum.Memory.Ops
open WasmNum.Integration

-- === memory.size on empty memory ===
#eval
  let mem := FlatMemory.empty 32
  if memorySizeInstr mem == 0 then "memory.size on empty: OK"
  else "FAIL: memory.size"

-- === FlatMemory.empty invariants ===
#eval
  let mem := FlatMemory.empty 32
  if mem.data.size == 0 && mem.pageCount == 0 then "empty memory invariants: OK"
  else "FAIL: empty invariants"

-- === effectiveAddr: no overflow ===
#eval
  let base : BitVec 32 := 100
  match effectiveAddr base 50 with
  | some addr => if addr.toNat == 150 then "effectiveAddr 100+50=150: OK" else "FAIL"
  | none => "FAIL: effectiveAddr returned none"

-- === effectiveAddr: overflow traps ===
#eval
  let base : BitVec 32 := BitVec.ofNat 32 (2^32 - 1)
  match effectiveAddr base 1 with
  | some _ => "FAIL: should have overflowed"
  | none => "effectiveAddr overflow trap: OK"

-- === dataDrop ===
#eval
  let seg := DataSegment.available (ByteArray.mk #[1, 2, 3])
  let seg' := dataDrop seg
  if !seg.isDropped && seg'.isDropped && seg'.bytes == none
  then "dataDrop: OK"
  else "FAIL: dataDrop"

-- === Integer arithmetic (scalar) ===
#eval
  let a : I32 := 42
  let b : I32 := 58
  let sum := WasmNum.Numerics.Integer.iadd a b
  if sum == (100 : I32) then "iadd 42+58=100: OK" else "FAIL: iadd"

#eval
  let a : I32 := 100
  let b : I32 := 30
  let diff := WasmNum.Numerics.Integer.isub a b
  if diff == (70 : I32) then "isub 100-30=70: OK" else "FAIL: isub"

-- === Integer bitwise ===
#eval
  let a : I32 := 0xFF00
  let b : I32 := 0x0FF0
  let result := WasmNum.Numerics.Integer.iand a b
  if result == (0x0F00 : I32) then "iand: OK" else "FAIL: iand"

-- === Integer shift ===
#eval
  let a : I32 := 1
  let result := WasmNum.Numerics.Integer.ishl a 8
  if result == (256 : I32) then "ishl 1<<8=256: OK" else "FAIL: ishl"

-- === Integer comparison ===
#eval
  let a : I32 := 10
  let b : I32 := 20
  if WasmNum.Numerics.Integer.ilt_u a b == (1 : I32) &&
     WasmNum.Numerics.Integer.ilt_u b a == (0 : I32)
  then "ilt_u: OK"
  else "FAIL: ilt_u"

-- === Conversion: wrap i64 to i32 ===
#eval
  let a : I64 := 0x1_0000_002A
  let result := WasmNum.Numerics.Conversion.wrapI64 a
  if result == (0x2A : I32) then "wrap i64 to i32: OK" else "FAIL: wrap"

-- === Conversion: extend_u i32 to i64 ===
#eval
  let a : I32 := 42
  let result := WasmNum.Numerics.Conversion.extendI32U a
  if result == (42 : I64) then "extend_u i32 to i64: OK" else "FAIL: extend_u"

-- === Reinterpret: i32 / f32 roundtrip ===
#eval
  let a : I32 := 0x40490FDB
  let f := WasmNum.Numerics.Conversion.reinterpretI32AsF32 a
  let b := WasmNum.Numerics.Conversion.reinterpretF32AsI32 f
  if a == b then "reinterpret i32/f32 roundtrip: OK" else "FAIL: reinterpret"

-- Helper: create a 1-page memory for testing
private def testMem : FlatMemory 32 :=
  {
    data := ByteArray.mk (Array.mk (List.replicate 65536 (0 : UInt8)))
    pageCount := 1
    maxLimit := none
    inv_dataSize := by native_decide
    inv_maxValid := by intro m hm; simp at hm
    inv_addrFits := by native_decide
    inv_maxFits := by intro m hm; simp at hm
  }

-- === Store → Load roundtrip ===
#eval do
  let mem := testMem
  let addr : BitVec 32 := 100
  let val : I32 := 0xDEADBEEF
  match i32Store mem addr val with
  | none => return "FAIL: i32Store returned none"
  | some mem' =>
    match i32Load mem' addr with
    | none => return "FAIL: i32Load returned none"
    | some loaded =>
      if loaded == val then return "store→load i32 roundtrip: OK"
      else return s!"FAIL: store→load got {loaded}"

-- === Memory fill ===
#eval do
  let mem := testMem
  let dst : BitVec 32 := 10
  let val : BitVec 8 := 0xAB
  let len : BitVec 32 := 4
  match fill mem dst val len with
  | none => return "FAIL: fill returned none"
  | some mem' =>
    match mem'.readByte 10, mem'.readByte 11, mem'.readByte 12, mem'.readByte 13 with
    | some b0, some b1, some b2, some b3 =>
      if b0 == (0xAB : BitVec 8) && b1 == (0xAB : BitVec 8) &&
         b2 == (0xAB : BitVec 8) && b3 == (0xAB : BitVec 8)
      then return "memory.fill: OK"
      else return "FAIL: fill bytes wrong"
    | _, _, _, _ => return "FAIL: readByte returned none"

-- === Memory copy ===
#eval do
  let mem := testMem
  -- First fill [0..3] with distinct bytes using store
  let addr : BitVec 32 := 0
  let val : I32 := 0x04030201
  match i32Store mem addr val with
  | none => return "FAIL: initial store"
  | some mem' =>
    -- Copy 4 bytes from offset 0 to offset 100
    let src : BitVec 32 := 0
    let dst : BitVec 32 := 100
    let len : BitVec 32 := 4
    match copy mem' dst src len with
    | none => return "FAIL: copy returned none"
    | some mem'' =>
      match i32Load mem'' dst with
      | none => return "FAIL: load after copy"
      | some loaded =>
        if loaded == val then return "memory.copy: OK"
        else return s!"FAIL: copy got {loaded}"

-- === SIMD: splat and extract lane ===
#eval
  open WasmNum.SIMD in
  open WasmNum.SIMD.V128 in
  open WasmNum.SIMD.Ops in
  let v := splat_i32x4 42
  let l0 := extractLane_i32x4 v ⟨0, by omega⟩
  let l1 := extractLane_i32x4 v ⟨1, by omega⟩
  let l2 := extractLane_i32x4 v ⟨2, by omega⟩
  let l3 := extractLane_i32x4 v ⟨3, by omega⟩
  if l0 == (42 : I32) && l1 == (42 : I32) && l2 == (42 : I32) && l3 == (42 : I32)
  then "SIMD splat_i32x4 + extract: OK"
  else "FAIL: SIMD splat"

-- === SIMD: replace lane ===
#eval
  open WasmNum.SIMD in
  open WasmNum.SIMD.V128 in
  open WasmNum.SIMD.Ops in
  let v := splat_i32x4 0
  let v' := replaceLane_i32x4 v ⟨2, by omega⟩ 99
  let l0 := extractLane_i32x4 v' ⟨0, by omega⟩
  let l2 := extractLane_i32x4 v' ⟨2, by omega⟩
  if l0 == (0 : I32) && l2 == (99 : I32)
  then "SIMD replaceLane_i32x4: OK"
  else "FAIL: SIMD replaceLane"
