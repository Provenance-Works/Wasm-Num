import WasmTest.Helpers

/-!
# Memory Core Tests

Tests for FlatMemory creation, byte read/write, address calculation, bounds checking.
-/

open WasmNum
open WasmNum.Memory
open WasmTest

#eval do
  let mut r := TestResult.empty

  -- ================================================================
  -- FlatMemory.empty
  -- ================================================================

  let empty := FlatMemory.empty 32
  r := r ++ assertEqual "empty.sizePages" empty.sizePages 0
  r := r ++ assertEqual "empty.byteSize" empty.byteSize 0

  -- ================================================================
  -- testMem32 (1 page = 65536 bytes)
  -- ================================================================

  let mem := testMem32
  r := r ++ assertEqual "testMem32.sizePages" mem.sizePages 1
  r := r ++ assertEqual "testMem32.byteSize" mem.byteSize 65536

  -- ================================================================
  -- readByte / writeByte
  -- ================================================================

  -- All zeros initially
  r := r ++ assertSome "readByte 0 = 0" (mem.readByte 0) (0 : BitVec 8)
  r := r ++ assertSome "readByte 100 = 0" (mem.readByte 100) (0 : BitVec 8)

  -- Write then read
  match mem.writeByte 42 (0xAB : BitVec 8) with
  | none => r := r ++ TestResult.fail "writeByte 42" "returned none"
  | some mem2 =>
    r := r ++ TestResult.ok "writeByte 42 succeeded"
    r := r ++ assertSome "readByte 42 after write" (mem2.readByte 42) (0xAB : BitVec 8)
    -- Other bytes unchanged
    r := r ++ assertSome "readByte 0 unchanged" (mem2.readByte 0) (0 : BitVec 8)
    r := r ++ assertSome "readByte 43 unchanged" (mem2.readByte 43) (0 : BitVec 8)

  -- Out of bounds
  r := r ++ assertNone "readByte OOB" (mem.readByte 65536)
  r := r ++ assertNone "writeByte OOB" (mem.writeByte 65536 (1 : BitVec 8))

  -- Last valid byte
  r := r ++ assertSome "readByte last valid" (mem.readByte 65535) (0 : BitVec 8)

  -- ================================================================
  -- readLittleEndian / writeLittleEndian
  -- ================================================================

  -- Write 32-bit value at offset 0, then read back
  match mem.writeLittleEndian 0 32 (by omega) (0xDEADBEEF : BitVec 32) with
  | none => r := r ++ TestResult.fail "writeLittleEndian 32" "returned none"
  | some mem3 =>
    r := r ++ TestResult.ok "writeLittleEndian 32 succeeded"
    match mem3.readLittleEndian 0 32 (by omega) with
    | none => r := r ++ TestResult.fail "readLittleEndian 32" "returned none"
    | some val =>
      r := r ++ assertEqual "readLittleEndian 32 roundtrip" val (0xDEADBEEF : BitVec 32)
      -- Verify individual bytes (little-endian):
      -- 0xEF at offset 0, 0xBE at 1, 0xAD at 2, 0xDE at 3
      r := r ++ assertSome "LE byte[0]=0xEF" (mem3.readByte 0) (0xEF : BitVec 8)
      r := r ++ assertSome "LE byte[1]=0xBE" (mem3.readByte 1) (0xBE : BitVec 8)
      r := r ++ assertSome "LE byte[2]=0xAD" (mem3.readByte 2) (0xAD : BitVec 8)
      r := r ++ assertSome "LE byte[3]=0xDE" (mem3.readByte 3) (0xDE : BitVec 8)

  -- 64-bit write/read roundtrip
  match mem.writeLittleEndian 100 64 (by omega) (0x0123456789ABCDEF : BitVec 64) with
  | none => r := r ++ TestResult.fail "writeLittleEndian 64" "returned none"
  | some mem4 =>
    match mem4.readLittleEndian 100 64 (by omega) with
    | none => r := r ++ TestResult.fail "readLittleEndian 64" "returned none"
    | some val =>
      r := r ++ assertEqual "readLittleEndian 64 roundtrip" val (0x0123456789ABCDEF : BitVec 64)

  -- OOB write
  match mem.writeLittleEndian 65535 32 (by omega) (0 : BitVec 32) with
  | none => r := r ++ TestResult.ok "writeLittleEndian OOB ↁEnone"
  | some _ => r := r ++ TestResult.fail "writeLittleEndian OOB" "should have trapped"

  -- ================================================================
  -- effectiveAddr
  -- ================================================================

  r := r ++ assertSome "effectiveAddr basic" (effectiveAddr (100 : BitVec 32) 200) (300 : BitVec 32)
  r := r ++ assertSome "effectiveAddr 0+0" (effectiveAddr (0 : BitVec 32) 0) (0 : BitVec 32)
  -- Overflow
  r := r ++ assertNone "effectiveAddr overflow" (effectiveAddr (0xFFFFFFFF : BitVec 32) 1)
  -- Edge: max valid
  r := r ++ assertSome "effectiveAddr max valid" (effectiveAddr (0xFFFFFFFE : BitVec 32) 1) (0xFFFFFFFF : BitVec 32)

  -- ================================================================
  -- inBoundsB
  -- ================================================================

  r := r ++ assertTrue "inBoundsB: addr 0, 4 bytes" (inBoundsB mem (0 : BitVec 32) 4)
  r := r ++ assertTrue "inBoundsB: last 1 byte" (inBoundsB mem (65535 : BitVec 32) 1)
  r := r ++ assertFalse "inBoundsB: 1 past end" (inBoundsB mem (65536 : BitVec 32) 1)
  r := r ++ assertFalse "inBoundsB: last 2 bytes OOB" (inBoundsB mem (65535 : BitVec 32) 2)
  r := r ++ assertTrue "inBoundsB: 0 bytes always ok" (inBoundsB mem (65536 : BitVec 32) 0)

  -- ================================================================
  -- effectiveInBoundsB
  -- ================================================================

  r := r ++ assertTrue "effectiveInBoundsB: basic" (effectiveInBoundsB mem (0 : BitVec 32) 0 4)
  r := r ++ assertFalse "effectiveInBoundsB: OOB" (effectiveInBoundsB mem (0 : BitVec 32) 65536 1)
  r := r ++ assertFalse "effectiveInBoundsB: overflow" (effectiveInBoundsB mem (0xFFFFFFFF : BitVec 32) 1 1)

  IO.println (r.summary "Memory Core")
  if r.failed > 0 then throw (IO.Error.userError "Memory Core tests failed")
