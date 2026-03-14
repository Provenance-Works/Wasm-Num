import WasmTest.Helpers

/-!
# Memory Load/Store Tests

Tests for scalar and packed load/store operations, including roundtrip verification.
-/

open WasmNum
open WasmNum.Memory
open WasmNum.Memory.Load
open WasmNum.Memory.Store
open WasmTest

#eval do
  let mut r := TestResult.empty
  let mem := testMem32

  -- ================================================================
  -- i32 Store ↁELoad Roundtrip
  -- ================================================================

  match i32Store mem (0 : BitVec 32) (0xDEADBEEF : I32) with
  | none => r := r ++ TestResult.fail "i32Store" "returned none"
  | some mem1 =>
    r := r ++ assertSome "i32 store→load" (i32Load mem1 (0 : BitVec 32)) (0xDEADBEEF : I32)
    -- Non-overlapping store
    match i32Store mem1 (4 : BitVec 32) (0xCAFEBABE : I32) with
    | none => r := r ++ TestResult.fail "i32Store 2nd" "returned none"
    | some mem2 =>
      r := r ++ assertSome "i32 load 2nd" (i32Load mem2 (4 : BitVec 32)) (0xCAFEBABE : I32)
      r := r ++ assertSome "i32 1st still intact" (i32Load mem2 (0 : BitVec 32)) (0xDEADBEEF : I32)

  -- ================================================================
  -- i64 Store ↁELoad Roundtrip
  -- ================================================================

  match i64Store mem (16 : BitVec 32) (0x0123456789ABCDEF : I64) with
  | none => r := r ++ TestResult.fail "i64Store" "returned none"
  | some mem3 =>
    r := r ++ assertSome "i64 store→load" (i64Load mem3 (16 : BitVec 32)) (0x0123456789ABCDEF : I64)

  -- ================================================================
  -- f32 Store ↁELoad Roundtrip
  -- ================================================================

  match f32Store mem (32 : BitVec 32) (0x3F800000 : F32) with  -- 1.0f
  | none => r := r ++ TestResult.fail "f32Store" "returned none"
  | some mem4 =>
    r := r ++ assertSome "f32 store→load" (f32Load mem4 (32 : BitVec 32)) (0x3F800000 : F32)

  -- ================================================================
  -- f64 Store ↁELoad Roundtrip
  -- ================================================================

  match f64Store mem (48 : BitVec 32) (0x3FF0000000000000 : F64) with  -- 1.0
  | none => r := r ++ TestResult.fail "f64Store" "returned none"
  | some mem5 =>
    r := r ++ assertSome "f64 store→load" (f64Load mem5 (48 : BitVec 32)) (0x3FF0000000000000 : F64)

  -- ================================================================
  -- Packed Loads (i32)
  -- ================================================================

  -- Write 0x80 at byte 0 (sign bit set for 8-bit)
  match mem.writeByte 0 (0x80 : BitVec 8) with
  | none => r := r ++ TestResult.fail "writeByte for packed" "returned none"
  | some memP =>
    -- i32.load8_s: sign-extend 0x80 ↁE0xFFFFFF80
    r := r ++ assertSome "i32Load8S 0x80" (i32Load8S memP (0 : BitVec 32)) (0xFFFFFF80 : I32)
    -- i32.load8_u: zero-extend 0x80 ↁE0x00000080
    r := r ++ assertSome "i32Load8U 0x80" (i32Load8U memP (0 : BitVec 32)) (0x00000080 : I32)

  -- 16-bit packed: write 0x8000
  match mem.writeLittleEndian 0 16 (by omega) (0x8000 : BitVec 16) with
  | none => r := r ++ TestResult.fail "writeLittleEndian 16" "returned none"
  | some memP2 =>
    r := r ++ assertSome "i32Load16S 0x8000" (i32Load16S memP2 (0 : BitVec 32)) (0xFFFF8000 : I32)
    r := r ++ assertSome "i32Load16U 0x8000" (i32Load16U memP2 (0 : BitVec 32)) (0x00008000 : I32)

  -- ================================================================
  -- Packed Stores (i32.store8, i32.store16)
  -- ================================================================

  -- i32.store8: stores low 8 bits
  match i32Store8 mem (0 : BitVec 32) (0xABCD : I32) with
  | none => r := r ++ TestResult.fail "i32Store8" "returned none"
  | some memS8 =>
    r := r ++ assertSome "i32Store8 reads back" (i32Load8U memS8 (0 : BitVec 32)) (0xCD : I32) -- low 8 = 0xCD

  match i32Store16 mem (0 : BitVec 32) (0x1234ABCD : I32) with
  | none => r := r ++ TestResult.fail "i32Store16" "returned none"
  | some memS16 =>
    r := r ++ assertSome "i32Store16 reads back" (i32Load16U memS16 (0 : BitVec 32)) (0xABCD : I32) -- low 16

  -- ================================================================
  -- i64 packed loads
  -- ================================================================

  -- Write 0x80 at offset 200
  match mem.writeByte 200 (0x80 : BitVec 8) with
  | none => r := r ++ TestResult.fail "writeByte 200" "returned none"
  | some memP3 =>
    r := r ++ assertSome "i64Load8S 0x80" (i64Load8S memP3 (200 : BitVec 32)) (0xFFFFFFFFFFFFFF80 : I64)
    r := r ++ assertSome "i64Load8U 0x80" (i64Load8U memP3 (200 : BitVec 32)) (0x80 : I64)

  -- ================================================================
  -- Out-of-bounds traps
  -- ================================================================

  -- i32 load at end of memory (need 4 bytes, only 1 left)
  r := r ++ assertNone "i32Load OOB" (i32Load mem (65535 : BitVec 32))
  -- i32 load exactly past end
  r := r ++ assertNone "i32Load past end" (i32Load mem (65536 : BitVec 32))
  -- Store OOB
  r := r ++ assertNone "i32Store OOB" (i32Store mem (65535 : BitVec 32) (0 : I32))
  -- Edge: last valid 4-byte position
  r := r ++ assertSome "i32Load last valid" (i32Load mem (65532 : BitVec 32)) (0 : I32)

  IO.println (r.summary "Memory Load/Store")
  if r.failed > 0 then throw (IO.Error.userError "Memory Load/Store tests failed")
