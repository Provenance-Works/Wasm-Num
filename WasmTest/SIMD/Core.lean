import WasmTest.Helpers

/-!
# SIMD Core Tests

Tests for V128 type, lane operations, bitwise operations, splat/extract/replace.
-/

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.SIMD.Ops
open WasmTest

#eval do
  let mut r := TestResult.empty

  -- ================================================================
  -- V128 Constants
  -- ================================================================

  r := r ++ assertEqual "V128.zero" V128.zero (0#128)
  r := r ++ assertEqual "V128.allOnes" V128.allOnes (~~~(0#128))

  -- ================================================================
  -- Lane Extract / Replace
  -- ================================================================

  -- i32x4: create a vector with 4 known lanes
  let v1 := V128.ofLanes Shape.i32x4 (fun i =>
    match i.val with | 0 => 10#32 | 1 => 20#32 | 2 => 30#32 | _ => 40#32)
  r := r ++ assertEqual "lane i32x4 [0]" (V128.lane Shape.i32x4 v1 ⟨0, by native_decide⟩) (10 : BitVec 32)
  r := r ++ assertEqual "lane i32x4 [1]" (V128.lane Shape.i32x4 v1 ⟨1, by native_decide⟩) (20 : BitVec 32)
  r := r ++ assertEqual "lane i32x4 [2]" (V128.lane Shape.i32x4 v1 ⟨2, by native_decide⟩) (30 : BitVec 32)
  r := r ++ assertEqual "lane i32x4 [3]" (V128.lane Shape.i32x4 v1 ⟨3, by native_decide⟩) (40 : BitVec 32)

  -- replaceLane
  let v2 := V128.replaceLane Shape.i32x4 v1 ⟨1, by native_decide⟩ (99 : BitVec 32)
  r := r ++ assertEqual "replaceLane [1]=99" (V128.lane Shape.i32x4 v2 ⟨1, by native_decide⟩) (99 : BitVec 32)
  r := r ++ assertEqual "replaceLane preserves [0]" (V128.lane Shape.i32x4 v2 ⟨0, by native_decide⟩) (10 : BitVec 32)

  -- splat
  let v3 := V128.splat Shape.i32x4 (42 : BitVec 32)
  r := r ++ assertEqual "splat i32x4 42 [0]" (V128.lane Shape.i32x4 v3 ⟨0, by native_decide⟩) (42 : BitVec 32)
  r := r ++ assertEqual "splat i32x4 42 [3]" (V128.lane Shape.i32x4 v3 ⟨3, by native_decide⟩) (42 : BitVec 32)

  -- i8x16 lane access
  let v4 := V128.splat Shape.i8x16 (0xAB : BitVec 8)
  r := r ++ assertEqual "splat i8x16 0xAB [0]" (V128.lane Shape.i8x16 v4 ⟨0, by native_decide⟩) (0xAB : BitVec 8)
  r := r ++ assertEqual "splat i8x16 0xAB [15]" (V128.lane Shape.i8x16 v4 ⟨15, by native_decide⟩) (0xAB : BitVec 8)

  -- i64x2 lanes
  let v5 := V128.ofLanes Shape.i64x2 (fun i =>
    match i.val with | 0 => 0xDEADBEEF#64 | _ => 0xCAFEBABE#64)
  r := r ++ assertEqual "lane i64x2 [0]" (V128.lane Shape.i64x2 v5 ⟨0, by native_decide⟩) (0xDEADBEEF : BitVec 64)
  r := r ++ assertEqual "lane i64x2 [1]" (V128.lane Shape.i64x2 v5 ⟨1, by native_decide⟩) (0xCAFEBABE : BitVec 64)

  -- mapLanes
  let v6 := V128.mapLanes Shape.i32x4 (· + 1) v1
  r := r ++ assertEqual "mapLanes +1 [0]" (V128.lane Shape.i32x4 v6 ⟨0, by native_decide⟩) (11 : BitVec 32)
  r := r ++ assertEqual "mapLanes +1 [3]" (V128.lane Shape.i32x4 v6 ⟨3, by native_decide⟩) (41 : BitVec 32)

  -- zipLanes
  let va := V128.splat Shape.i32x4 (10 : BitVec 32)
  let vb := V128.splat Shape.i32x4 (5 : BitVec 32)
  let v7 := V128.zipLanes Shape.i32x4 (· + ·) va vb
  r := r ++ assertEqual "zipLanes + [0]" (V128.lane Shape.i32x4 v7 ⟨0, by native_decide⟩) (15 : BitVec 32)

  -- ================================================================
  -- V128 Bitwise Operations
  -- ================================================================

  let allOnes := V128.allOnes
  let zeros := V128.zero

  r := r ++ assertEqual "v128_not zeros" (v128_not zeros) allOnes
  r := r ++ assertEqual "v128_not allOnes" (v128_not allOnes) zeros
  r := r ++ assertEqual "v128_and" (v128_and allOnes zeros) zeros
  r := r ++ assertEqual "v128_and self" (v128_and allOnes allOnes) allOnes
  r := r ++ assertEqual "v128_or" (v128_or allOnes zeros) allOnes
  r := r ++ assertEqual "v128_xor self" (v128_xor allOnes allOnes) zeros
  r := r ++ assertEqual "v128_andnot" (v128_andnot allOnes zeros) allOnes -- allOnes AND (NOT 0)
  r := r ++ assertEqual "v128_andnot rev" (v128_andnot allOnes allOnes) zeros -- allOnes AND (NOT allOnes)

  -- v128_bitselect
  r := r ++ assertEqual "bitselect all a" (v128_bitselect allOnes zeros allOnes) allOnes
  r := r ++ assertEqual "bitselect all b" (v128_bitselect allOnes zeros zeros) zeros

  -- v128_any_true
  r := r ++ assertEqual "any_true zeros" (v128_any_true zeros) (0 : I32)
  r := r ++ assertEqual "any_true allOnes" (v128_any_true allOnes) (1 : I32)
  r := r ++ assertEqual "any_true one bit" (v128_any_true (1#128)) (1 : I32)

  -- ================================================================
  -- Splat / Extract / Replace (SplatExtractReplace.lean)
  -- ================================================================

  -- splat_i32x4
  let s1 := splat_i32x4 (0xABCD : I32)
  r := r ++ assertEqual "splat_i32x4 [0]" (extractLane_i32x4 s1 ⟨0, by native_decide⟩) (0xABCD : I32)
  r := r ++ assertEqual "splat_i32x4 [3]" (extractLane_i32x4 s1 ⟨3, by native_decide⟩) (0xABCD : I32)

  -- splat_i64x2
  let s2 := splat_i64x2 (0x12345678 : I64)
  r := r ++ assertEqual "splat_i64x2 [0]" (extractLane_i64x2 s2 ⟨0, by native_decide⟩) (0x12345678 : I64)
  r := r ++ assertEqual "splat_i64x2 [1]" (extractLane_i64x2 s2 ⟨1, by native_decide⟩) (0x12345678 : I64)

  -- splat_i8x16: truncates I32 to 8 bits
  let s3 := splat_i8x16 (0x1FF : I32)  -- should keep only 0xFF
  r := r ++ assertEqual "splat_i8x16 truncates" (extractLaneU Shape.i8x16 s3 ⟨0, by native_decide⟩) (0xFF : I32)

  -- replaceLane_i32x4
  let r1 := replaceLane_i32x4 s1 ⟨2, by native_decide⟩ (0x9999 : I32)
  r := r ++ assertEqual "replaceLane_i32x4 [2]" (extractLane_i32x4 r1 ⟨2, by native_decide⟩) (0x9999 : I32)
  r := r ++ assertEqual "replaceLane_i32x4 preserves [0]" (extractLane_i32x4 r1 ⟨0, by native_decide⟩) (0xABCD : I32)

  -- extractLaneS for i8x16: sign-extends to I32
  let sx := V128.splat Shape.i8x16 (0x80 : BitVec 8)
  r := r ++ assertEqual "extractLaneS i8x16 0x80" (extractLaneS Shape.i8x16 sx ⟨0, by native_decide⟩) (0xFFFFFF80 : I32)
  -- extractLaneU: zero-extends
  r := r ++ assertEqual "extractLaneU i8x16 0x80" (extractLaneU Shape.i8x16 sx ⟨0, by native_decide⟩) (0x80 : I32)

  -- ================================================================
  -- AllTrue / Bitmask
  -- ================================================================

  r := r ++ assertEqual "allTrue i32x4 zeros" (allTrue Shape.i32x4 zeros) (0 : I32)
  let allTrueVec := V128.splat Shape.i32x4 (1 : BitVec 32)
  r := r ++ assertEqual "allTrue i32x4 nonzero" (allTrue Shape.i32x4 allTrueVec) (1 : I32)
  -- one zero lane
  let oneZero := V128.replaceLane Shape.i32x4 allTrueVec ⟨1, by native_decide⟩ (0 : BitVec 32)
  r := r ++ assertEqual "allTrue with one zero" (allTrue Shape.i32x4 oneZero) (0 : I32)

  -- bitmask i32x4: MSBs
  let bm1 := V128.ofLanes Shape.i32x4 (fun i =>
    match i.val with | 0 => 0x80000000#32 | 1 => 0#32 | 2 => 0x80000000#32 | _ => 0#32)
  r := r ++ assertEqual "bitmask i32x4 [1,0,1,0]" (bitmask Shape.i32x4 bm1) (0b0101 : I32)
  r := r ++ assertEqual "bitmask i32x4 zeros" (bitmask Shape.i32x4 zeros) (0 : I32)
  r := r ++ assertEqual "bitmask i32x4 allOnes" (bitmask Shape.i32x4 allOnes) (0b1111 : I32)

  IO.println (r.summary "SIMD Core Operations")
  if r.failed > 0 then throw (IO.Error.userError "SIMD Core tests failed")
