import WasmTest.Helpers

/-!
# Integer Operation Tests

Comprehensive tests for all scalar integer operations (Phase 5.5).
-/

open WasmNum
open WasmNum.Numerics.Integer
open WasmTest

#eval do
  let mut r := TestResult.empty

  -- ================================================================
  -- Arithmetic (Arithmetic.lean)
  -- ================================================================

  -- iadd
  r := r ++ assertEqual "iadd 32: 42+58" (iadd (42 : I32) 58) (100 : I32)
  r := r ++ assertEqual "iadd 32: overflow" (iadd (0xFFFFFFFF : I32) 1) (0 : I32)
  r := r ++ assertEqual "iadd 64: large" (iadd (1000000 : I64) 2000000) (3000000 : I64)
  r := r ++ assertEqual "iadd 32: 0+0" (iadd (0 : I32) 0) (0 : I32)

  -- isub
  r := r ++ assertEqual "isub 32: 100-30" (isub (100 : I32) 30) (70 : I32)
  r := r ++ assertEqual "isub 32: underflow" (isub (0 : I32) 1) (0xFFFFFFFF : I32)
  r := r ++ assertEqual "isub 64: basic" (isub (50 : I64) 25) (25 : I64)

  -- imul
  r := r ++ assertEqual "imul 32: 6*7" (imul (6 : I32) 7) (42 : I32)
  r := r ++ assertEqual "imul 32: overflow" (imul (0x10000 : I32) 0x10000) (0 : I32)
  r := r ++ assertEqual "imul 32: 0*x" (imul (0 : I32) 12345) (0 : I32)
  r := r ++ assertEqual "imul 64: large" (imul (100000 : I64) 100000) (10000000000 : I64)

  -- idiv_u
  r := r ++ assertSome "idiv_u: 10/3" (idiv_u (10 : I32) 3) (3 : I32)
  r := r ++ assertSome "idiv_u: 7/1" (idiv_u (7 : I32) 1) (7 : I32)
  r := r ++ assertNone "idiv_u: div by 0" (idiv_u (10 : I32) 0)
  r := r ++ assertSome "idiv_u 64: 100/10" (idiv_u (100 : I64) 10) (10 : I64)

  -- idiv_s
  r := r ++ assertNone "idiv_s: div by 0" (idiv_s (10 : I32) 0)
  -- INT_MIN / -1 trap (signed overflow)
  r := r ++ assertNone "idiv_s: INT_MIN/-1" (idiv_s (0x80000000 : I32) (0xFFFFFFFF : I32))
  -- Normal signed division
  r := r ++ assertSome "idiv_s: -6/3" (idiv_s (BitVec.ofInt 32 (-6)) (3 : I32)) (BitVec.ofInt 32 (-2))

  -- irem_u
  r := r ++ assertSome "irem_u: 10%3" (irem_u (10 : I32) 3) (1 : I32)
  r := r ++ assertNone "irem_u: div by 0" (irem_u (10 : I32) 0)

  -- irem_s
  r := r ++ assertSome "irem_s: 7%2" (irem_s (7 : I32) 2) (1 : I32)
  r := r ++ assertNone "irem_s: div by 0" (irem_s (10 : I32) 0)
  -- irem_s: sign of dividend
  -- Note: Lean's Int.% is Euclidean remainder (always non-negative)
  r := r ++ assertSome "irem_s: -7%2" (irem_s (BitVec.ofInt 32 (-7)) (2 : I32)) (1 : I32)

  -- ================================================================
  -- Bitwise (Bitwise.lean)
  -- ================================================================

  r := r ++ assertEqual "iand" (iand (0xFF00 : I32) 0x0FF0) (0x0F00 : I32)
  r := r ++ assertEqual "ior" (ior (0xFF00 : I32) 0x00FF) (0xFFFF : I32)
  r := r ++ assertEqual "ixor" (ixor (0xFF00 : I32) 0xF0F0) (0x0FF0 : I32)
  r := r ++ assertEqual "inot" (inot (0 : I32)) (0xFFFFFFFF : I32)
  r := r ++ assertEqual "iandnot" (iandnot (0xFF00 : I32) 0x0F00) (0xF000 : I32)
  r := r ++ assertEqual "iand 64" (iand (0xFF00FF00 : I64) 0x00FF00FF) (0x00000000 : I64)

  -- ================================================================
  -- Shift/Rotate (Shift.lean)
  -- ================================================================

  r := r ++ assertEqual "ishl 1<<8" (ishl (1 : I32) 8) (256 : I32)
  r := r ++ assertEqual "ishl mod 32" (ishl (1 : I32) 33) (2 : I32)  -- 33 % 32 = 1
  r := r ++ assertEqual "ishr_u" (ishr_u (256 : I32) 4) (16 : I32)
  r := r ++ assertEqual "ishr_s negative" (ishr_s (0x80000000 : I32) 1) (0xC0000000 : I32)
  r := r ++ assertEqual "ishr_s positive" (ishr_s (0x40000000 : I32) 1) (0x20000000 : I32)
  r := r ++ assertEqual "irotl" (irotl (0x80000001 : I32) 1) (0x00000003 : I32)
  r := r ++ assertEqual "irotr" (irotr (0x80000001 : I32) 1) (0xC0000000 : I32)
  r := r ++ assertEqual "ishl 64" (ishl (1 : I64) 32) (0x100000000 : I64)

  -- ================================================================
  -- Comparisons (Compare.lean)
  -- ================================================================

  r := r ++ assertEqual "ieqz: 0" (ieqz (0 : I32)) (1 : I32)
  r := r ++ assertEqual "ieqz: nonzero" (ieqz (42 : I32)) (0 : I32)
  r := r ++ assertEqual "ieq" (ieq (42 : I32) 42) (1 : I32)
  r := r ++ assertEqual "ieq: neq" (ieq (42 : I32) 43) (0 : I32)
  r := r ++ assertEqual "ine" (ine (42 : I32) 43) (1 : I32)
  r := r ++ assertEqual "ilt_u" (ilt_u (10 : I32) 20) (1 : I32)
  r := r ++ assertEqual "ilt_u: equal" (ilt_u (10 : I32) 10) (0 : I32)
  r := r ++ assertEqual "ilt_s: neg < pos" (ilt_s (0xFFFFFFFF : I32) 1) (1 : I32)
  r := r ++ assertEqual "ilt_s: pos not < neg" (ilt_s (1 : I32) 0xFFFFFFFF) (0 : I32)
  r := r ++ assertEqual "igt_u" (igt_u (20 : I32) 10) (1 : I32)
  r := r ++ assertEqual "igt_s" (igt_s (1 : I32) 0xFFFFFFFF) (1 : I32)
  r := r ++ assertEqual "ile_u" (ile_u (10 : I32) 10) (1 : I32)
  r := r ++ assertEqual "ile_s" (ile_s (0xFFFFFFFF : I32) 0xFFFFFFFF) (1 : I32)
  r := r ++ assertEqual "ige_u" (ige_u (20 : I32) 10) (1 : I32)
  r := r ++ assertEqual "ige_s" (ige_s (1 : I32) 0xFFFFFFFF) (1 : I32)

  -- ================================================================
  -- Bit Counting (Bits.lean)
  -- ================================================================

  r := r ++ assertEqual "iclz: 0" (iclz (0 : I32)) (32 : I32)
  r := r ++ assertEqual "iclz: 1" (iclz (1 : I32)) (31 : I32)
  r := r ++ assertEqual "iclz: MSB set" (iclz (0x80000000 : I32)) (0 : I32)
  r := r ++ assertEqual "iclz: 0x0F" (iclz (0x0F : I32)) (28 : I32)
  r := r ++ assertEqual "ictz: 0" (ictz (0 : I32)) (32 : I32)
  r := r ++ assertEqual "ictz: 1" (ictz (1 : I32)) (0 : I32)
  r := r ++ assertEqual "ictz: 0x100" (ictz (0x100 : I32)) (8 : I32)
  r := r ++ assertEqual "ipopcnt: 0" (ipopcnt (0 : I32)) (0 : I32)
  r := r ++ assertEqual "ipopcnt: 0xFF" (ipopcnt (0xFF : I32)) (8 : I32)
  r := r ++ assertEqual "ipopcnt: max" (ipopcnt (0xFFFFFFFF : I32)) (32 : I32)
  r := r ++ assertEqual "ipopcnt: 0xAAAAAAAA" (ipopcnt (0xAAAAAAAA : I32)) (16 : I32)
  -- 64-bit
  r := r ++ assertEqual "iclz 64: 0" (iclz (0 : I64)) (64 : I64)
  r := r ++ assertEqual "ictz 64: 0x100" (ictz (0x100 : I64)) (8 : I64)

  -- ================================================================
  -- Sign Extension (Ext.lean)
  -- ================================================================

  r := r ++ assertEqual "iextend_s 8: 0x80" (iextend_s 8 (0x80 : I32)) (0xFFFFFF80 : I32)
  r := r ++ assertEqual "iextend_s 8: 0x7F" (iextend_s 8 (0x7F : I32)) (0x0000007F : I32)
  r := r ++ assertEqual "iextend_s 16: 0x8000" (iextend_s 16 (0x8000 : I32)) (0xFFFF8000 : I32)
  r := r ++ assertEqual "iextend_s 16: 0x7FFF" (iextend_s 16 (0x7FFF : I32)) (0x00007FFF : I32)

  -- ================================================================
  -- Saturating Arithmetic (Saturating.lean)
  -- ================================================================

  -- 8-bit signed saturation: range [-128, 127]
  r := r ++ assertEqual "iadd_sat_s 8: no sat" (iadd_sat_s (10 : BitVec 8) 20) (30 : BitVec 8)
  r := r ++ assertEqual "iadd_sat_s 8: saturate high" (iadd_sat_s (100 : BitVec 8) 100) (0x7F : BitVec 8) -- 127
  r := r ++ assertEqual "isub_sat_s 8: no sat" (isub_sat_s (50 : BitVec 8) 30) (20 : BitVec 8)

  -- 8-bit unsigned saturation: range [0, 255]
  r := r ++ assertEqual "iadd_sat_u 8: no sat" (iadd_sat_u (100 : BitVec 8) 100) (200 : BitVec 8)
  r := r ++ assertEqual "iadd_sat_u 8: saturate" (iadd_sat_u (200 : BitVec 8) 200) (255 : BitVec 8)
  r := r ++ assertEqual "isub_sat_u 8: no sat" (isub_sat_u (100 : BitVec 8) 50) (50 : BitVec 8)
  r := r ++ assertEqual "isub_sat_u 8: floor 0" (isub_sat_u (50 : BitVec 8) 100) (0 : BitVec 8)

  -- 16-bit
  r := r ++ assertEqual "iadd_sat_s 16: saturate" (iadd_sat_s (30000 : BitVec 16) 30000) (0x7FFF : BitVec 16)
  r := r ++ assertEqual "iadd_sat_u 16: saturate" (iadd_sat_u (60000 : BitVec 16) 60000) (0xFFFF : BitVec 16)

  -- ================================================================
  -- Min/Max (MinMax.lean)
  -- ================================================================

  r := r ++ assertEqual "imin_u" (imin_u (10 : I32) 20) (10 : I32)
  r := r ++ assertEqual "imax_u" (imax_u (10 : I32) 20) (20 : I32)
  r := r ++ assertEqual "imin_s: neg vs pos" (imin_s (0xFFFFFFFF : I32) 1) (0xFFFFFFFF : I32)
  r := r ++ assertEqual "imax_s: neg vs pos" (imax_s (0xFFFFFFFF : I32) 1) (1 : I32)
  r := r ++ assertEqual "imin_u: equal" (imin_u (42 : I32) 42) (42 : I32)

  -- ================================================================
  -- Miscellaneous (Misc.lean)
  -- ================================================================

  r := r ++ assertEqual "iabs: positive" (iabs (42 : I32)) (42 : I32)
  r := r ++ assertEqual "iabs: negative" (iabs (BitVec.ofInt 32 (-42))) (42 : I32)
  r := r ++ assertEqual "iabs: 0" (iabs (0 : I32)) (0 : I32)
  r := r ++ assertEqual "ineg: 42" (ineg (42 : I32)) (BitVec.ofInt 32 (-42))
  r := r ++ assertEqual "ineg: 0" (ineg (0 : I32)) (0 : I32)
  r := r ++ assertEqual "iavgr_u: 10,20" (iavgr_u (10 : BitVec 8) 20) (15 : BitVec 8)
  r := r ++ assertEqual "iavgr_u: 11,20 rounds" (iavgr_u (11 : BitVec 8) 20) (16 : BitVec 8) -- (11+20+1)/2 = 16
  r := r ++ assertEqual "iq15mulr_sat_s: basic" (iq15mulr_sat_s (0x4000 : BitVec 16) (0x4000 : BitVec 16)) (0x2000 : BitVec 16)

  -- ================================================================
  -- Bitselect (Bitselect.lean)
  -- ================================================================

  r := r ++ assertEqual "ibitselect: all mask" (ibitselect (0xFF : I32) (0x00 : I32) (0xFFFFFFFF : I32)) (0xFF : I32)
  r := r ++ assertEqual "ibitselect: no mask" (ibitselect (0xFF : I32) (0x00 : I32) (0 : I32)) (0x00 : I32)
  r := r ++ assertEqual "ibitselect: half" (ibitselect (0xFF00 : I32) (0x00FF : I32) (0xFFFF0000 : I32)) (0x00FF : I32)

  IO.println (r.summary "Integer Operations")
  if r.failed > 0 then throw (IO.Error.userError "Integer tests failed")
