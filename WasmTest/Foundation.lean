import WasmTest.Helpers

/-!
# Foundation Tests

Tests for Types, BitVec utilities, and basic definitions.
-/

open WasmNum
open WasmTest

#eval do
  let mut r := TestResult.empty

  -- === Type aliases (basic sanity) ===
  r := r ++ assertEqual "I32 zero" (0 : I32) (BitVec.ofNat 32 0)
  r := r ++ assertEqual "I64 zero" (0 : I64) (BitVec.ofNat 64 0)
  r := r ++ assertEqual "I32 max" (0xFFFFFFFF : I32) (BitVec.ofNat 32 (2^32 - 1))
  r := r ++ assertEqual "I64 literal" (42 : I64) (BitVec.ofNat 64 42)
  r := r ++ assertEqual "Byte 0xFF" (0xFF : Byte) (BitVec.ofNat 8 255)

  -- === pageSize ===
  r := r ++ assertEqual "pageSize" pageSize 65536

  -- === BitVec utilities ===
  -- getByte
  let v32 : BitVec 32 := 0xDEADBEEF
  r := r ++ assertEqual "getByte 0" (BitVecOps.getByte v32 0) (0xEF : Byte)
  r := r ++ assertEqual "getByte 1" (BitVecOps.getByte v32 1) (0xBE : Byte)
  r := r ++ assertEqual "getByte 2" (BitVecOps.getByte v32 2) (0xAD : Byte)
  r := r ++ assertEqual "getByte 3" (BitVecOps.getByte v32 3) (0xDE : Byte)

  -- toLittleEndian / fromLittleEndian roundtrip
  let v16 : BitVec 16 := 0x0102
  let bytes16 := BitVecOps.toLittleEndian v16 (by decide)
  let reconstructed16 := BitVecOps.fromLittleEndian bytes16
  r := r ++ assertEqual "LE roundtrip 16-bit" reconstructed16 v16

  let v32le : BitVec 32 := 0x04030201
  let bytes32 := BitVecOps.toLittleEndian v32le (by decide)
  let reconstructed32 := BitVecOps.fromLittleEndian bytes32
  r := r ++ assertEqual "LE roundtrip 32-bit" reconstructed32 v32le

  -- toBytes / fromBytes roundtrip
  let v64 : BitVec 64 := 0x0807060504030201
  let bytes64 := BitVecOps.toBytes v64 (by decide)
  let reconstructed64 := BitVecOps.fromBytes bytes64
  r := r ++ assertEqual "bytes roundtrip 64-bit" reconstructed64 v64

  -- signExtend
  let small : BitVec 8 := 0x80  -- -128 in signed 8-bit
  let extended := BitVecOps.signExtend (N := 32) small (by omega)
  r := r ++ assertEqual "signExtend 0x80 to 32" extended (0xFFFFFF80 : BitVec 32)

  let pos : BitVec 8 := 0x7F  -- 127 in signed 8-bit
  let extPos := BitVecOps.signExtend (N := 32) pos (by omega)
  r := r ++ assertEqual "signExtend 0x7F to 32" extPos (0x0000007F : BitVec 32)

  -- zeroExtend
  let zext := BitVecOps.zeroExtend (N := 32) small (by omega)
  r := r ++ assertEqual "zeroExtend 0x80 to 32" zext (0x00000080 : BitVec 32)

  -- concat
  let low : BitVec 8 := 0xAB
  let high : BitVec 8 := 0xCD
  let combined := BitVecOps.concat high low
  r := r ++ assertEqual "concat 0xCD ++ 0xAB" combined (0xCDAB : BitVec 16)

  IO.println (r.summary "Foundation")
  if r.failed > 0 then throw (IO.Error.userError "Foundation tests failed")
