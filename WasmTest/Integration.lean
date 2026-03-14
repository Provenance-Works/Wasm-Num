import WasmTest.Helpers

/-!
# Integration Runtime Tests

Tests for instruction-level wrappers that compose effective address
calculation with bounds checking and load/store operations.
-/

open WasmNum
open WasmNum.Memory
open WasmNum.Integration
open WasmTest

#eval do
  let mut r := TestResult.empty
  let mem := testMem32

  -- ================================================================
  -- memorySizeInstr
  -- ================================================================

  r := r ++ assertEqual "memorySizeInstr" (memorySizeInstr mem) 1

  -- ================================================================
  -- i32 Store ↁELoad via instruction wrappers (base + offset)
  -- ================================================================

  -- Store at base=0, offset=0
  match i32StoreInstr mem (0 : BitVec 32) 0 (0xDEADBEEF : I32) with
  | none => r := r ++ TestResult.fail "i32StoreInstr" "returned none"
  | some mem1 =>
    r := r ++ assertSome "i32LoadInstr roundtrip" (i32LoadInstr mem1 (0 : BitVec 32) 0) (0xDEADBEEF : I32)
    -- base + offset composition
    r := r ++ assertSome "i32LoadInstr with offset" (i32LoadInstr mem1 (0 : BitVec 32) 0) (0xDEADBEEF : I32)

  -- Store with non-zero offset
  match i32StoreInstr mem (10 : BitVec 32) 20 (0xCAFEBABE : I32) with
  | none => r := r ++ TestResult.fail "i32StoreInstr offset" "returned none"
  | some mem2 =>
    -- effective addr = 10 + 20 = 30
    r := r ++ assertSome "i32LoadInstr base+offset" (i32LoadInstr mem2 (10 : BitVec 32) 20) (0xCAFEBABE : I32)
    -- Same address via different base/offset combinations
    r := r ++ assertSome "i32LoadInstr alt base" (i32LoadInstr mem2 (30 : BitVec 32) 0) (0xCAFEBABE : I32)
    r := r ++ assertSome "i32LoadInstr alt offset" (i32LoadInstr mem2 (0 : BitVec 32) 30) (0xCAFEBABE : I32)

  -- ================================================================
  -- i64 instruction wrappers
  -- ================================================================

  match i64StoreInstr mem (100 : BitVec 32) 0 (0x0123456789ABCDEF : I64) with
  | none => r := r ++ TestResult.fail "i64StoreInstr" "returned none"
  | some mem3 =>
    r := r ++ assertSome "i64LoadInstr roundtrip" (i64LoadInstr mem3 (100 : BitVec 32) 0) (0x0123456789ABCDEF : I64)

  -- ================================================================
  -- Packed load/store instruction wrappers
  -- ================================================================

  -- i32.store8 + i32.load8_s/u
  match i32Store8Instr mem (200 : BitVec 32) 0 (0x80 : I32) with
  | none => r := r ++ TestResult.fail "i32Store8Instr" "returned none"
  | some memP =>
    r := r ++ assertSome "i32Load8SInstr 0x80" (i32Load8SInstr memP (200 : BitVec 32) 0) (0xFFFFFF80 : I32)
    r := r ++ assertSome "i32Load8UInstr 0x80" (i32Load8UInstr memP (200 : BitVec 32) 0) (0x80 : I32)

  -- i32.store16 + i32.load16_s/u
  match i32Store16Instr mem (300 : BitVec 32) 0 (0x8000 : I32) with
  | none => r := r ++ TestResult.fail "i32Store16Instr" "returned none"
  | some memP2 =>
    r := r ++ assertSome "i32Load16SInstr 0x8000" (i32Load16SInstr memP2 (300 : BitVec 32) 0) (0xFFFF8000 : I32)
    r := r ++ assertSome "i32Load16UInstr 0x8000" (i32Load16UInstr memP2 (300 : BitVec 32) 0) (0x8000 : I32)

  -- i64 packed: i64.store8 + i64.load8_s/u
  match i64Store8Instr mem (400 : BitVec 32) 0 (0x80 : I64) with
  | none => r := r ++ TestResult.fail "i64Store8Instr" "returned none"
  | some memP3 =>
    r := r ++ assertSome "i64Load8SInstr" (i64Load8SInstr memP3 (400 : BitVec 32) 0) (0xFFFFFFFFFFFFFF80 : I64)
    r := r ++ assertSome "i64Load8UInstr" (i64Load8UInstr memP3 (400 : BitVec 32) 0) (0x80 : I64)

  -- ================================================================
  -- Address overflow traps
  -- ================================================================

  r := r ++ assertNone "i32LoadInstr addr overflow" (i32LoadInstr mem (0xFFFFFFFF : BitVec 32) 1)
  r := r ++ assertNone "i32StoreInstr addr overflow" (i32StoreInstr mem (0xFFFFFFFF : BitVec 32) 1 (0 : I32))
  r := r ++ assertNone "i64LoadInstr addr overflow" (i64LoadInstr mem (0xFFFFFFFF : BitVec 32) 1)
  r := r ++ assertNone "i64StoreInstr addr overflow" (i64StoreInstr mem (0xFFFFFFFF : BitVec 32) 1 (0 : I64))

  -- ================================================================
  -- Out-of-bounds traps
  -- ================================================================

  r := r ++ assertNone "i32LoadInstr OOB" (i32LoadInstr mem (65535 : BitVec 32) 0)
  r := r ++ assertNone "i64LoadInstr OOB" (i64LoadInstr mem (65530 : BitVec 32) 0)
  r := r ++ assertNone "i32StoreInstr OOB" (i32StoreInstr mem (65535 : BitVec 32) 0 (0 : I32))

  -- ================================================================
  -- v128 Store ↁELoad roundtrip
  -- ================================================================

  match v128StoreInstr mem (500 : BitVec 32) 0 (0xDEADBEEFCAFEBABE0123456789ABCDEF : V128) with
  | none => r := r ++ TestResult.fail "v128StoreInstr" "returned none"
  | some memV =>
    r := r ++ assertSome "v128LoadInstr roundtrip" (v128LoadInstr memV (500 : BitVec 32) 0) (0xDEADBEEFCAFEBABE0123456789ABCDEF : V128)

  IO.println (r.summary "Integration Runtime")
  if r.failed > 0 then throw (IO.Error.userError "Integration tests failed")
