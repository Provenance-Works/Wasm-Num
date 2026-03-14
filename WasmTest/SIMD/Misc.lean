import WasmTest.Helpers

/-!
# SIMD Miscellaneous Operations Tests

Tests for dot product, swizzle, shuffle, narrow, and extend operations.
-/

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.SIMD.Ops
open WasmTest

#eval do
  let mut r := TestResult.empty

  -- ================================================================
  -- Dot Product (i32x4.dot_i16x8_s)
  -- ================================================================

  -- a = [1, 2, 3, 4, 5, 6, 7, 8] as i16x8
  -- b = [1, 1, 1, 1, 1, 1, 1, 1] as i16x8
  -- result[0] = 1*1 + 2*1 = 3
  -- result[1] = 3*1 + 4*1 = 7
  -- result[2] = 5*1 + 6*1 = 11
  -- result[3] = 7*1 + 8*1 = 15
  let dotA := V128.ofLanes Shape.i16x8 (fun i =>
    BitVec.ofNat 16 (i.val + 1))
  let dotB := V128.splat Shape.i16x8 (1 : BitVec 16)
  let dotResult := dot_i16x8_i32x4 dotA dotB
  r := r ++ assertEqual "dot [0]=3" (V128.lane Shape.i32x4 dotResult ⟨0, by native_decide⟩) (3 : BitVec 32)
  r := r ++ assertEqual "dot [1]=7" (V128.lane Shape.i32x4 dotResult ⟨1, by native_decide⟩) (7 : BitVec 32)
  r := r ++ assertEqual "dot [2]=11" (V128.lane Shape.i32x4 dotResult ⟨2, by native_decide⟩) (11 : BitVec 32)
  r := r ++ assertEqual "dot [3]=15" (V128.lane Shape.i32x4 dotResult ⟨3, by native_decide⟩) (15 : BitVec 32)

  -- ================================================================
  -- Swizzle (i8x16.swizzle)
  -- ================================================================

  -- v = [10, 20, 30, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  let swzV := V128.ofLanes Shape.i8x16 (fun i =>
    match i.val with | 0 => 10#8 | 1 => 20#8 | 2 => 30#8 | 3 => 40#8 | _ => 0#8)
  -- idx = [3, 2, 1, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  let swzIdx := V128.ofLanes Shape.i8x16 (fun i =>
    match i.val with | 0 => 3#8 | 1 => 2#8 | 2 => 1#8 | 3 => 0#8 | 4 => 255#8 | _ => 0#8)
  let swzResult := swizzle swzV swzIdx
  r := r ++ assertEqual "swizzle [0]=v[3]" (V128.lane Shape.i8x16 swzResult ⟨0, by native_decide⟩) (40 : BitVec 8)
  r := r ++ assertEqual "swizzle [1]=v[2]" (V128.lane Shape.i8x16 swzResult ⟨1, by native_decide⟩) (30 : BitVec 8)
  r := r ++ assertEqual "swizzle [2]=v[1]" (V128.lane Shape.i8x16 swzResult ⟨2, by native_decide⟩) (20 : BitVec 8)
  r := r ++ assertEqual "swizzle [3]=v[0]" (V128.lane Shape.i8x16 swzResult ⟨3, by native_decide⟩) (10 : BitVec 8)
  r := r ++ assertEqual "swizzle OOB=0" (V128.lane Shape.i8x16 swzResult ⟨4, by native_decide⟩) (0 : BitVec 8)

  -- ================================================================
  -- Shuffle (i8x16.shuffle)
  -- ================================================================

  let shufA := V128.ofLanes Shape.i8x16 (fun i => BitVec.ofNat 8 (i.val + 1))   -- [1..16]
  let shufB := V128.ofLanes Shape.i8x16 (fun i => BitVec.ofNat 8 (i.val + 17))  -- [17..32]
  -- indices: [0, 16, 1, 17, ...]
  let indices : Vector (Fin 32) 16 := ⟨#[⟨0, by native_decide⟩, ⟨16, by native_decide⟩,
    ⟨1, by native_decide⟩, ⟨17, by native_decide⟩, ⟨2, by native_decide⟩, ⟨18, by native_decide⟩,
    ⟨3, by native_decide⟩, ⟨19, by native_decide⟩, ⟨4, by native_decide⟩, ⟨20, by native_decide⟩,
    ⟨5, by native_decide⟩, ⟨21, by native_decide⟩, ⟨6, by native_decide⟩, ⟨22, by native_decide⟩,
    ⟨7, by native_decide⟩, ⟨23, by native_decide⟩], by decide⟩
  let shufResult := shuffle shufA shufB indices
  r := r ++ assertEqual "shuffle [0]=a[0]" (V128.lane Shape.i8x16 shufResult ⟨0, by native_decide⟩) (1 : BitVec 8)
  r := r ++ assertEqual "shuffle [1]=b[0]" (V128.lane Shape.i8x16 shufResult ⟨1, by native_decide⟩) (17 : BitVec 8)
  r := r ++ assertEqual "shuffle [2]=a[1]" (V128.lane Shape.i8x16 shufResult ⟨2, by native_decide⟩) (2 : BitVec 8)
  r := r ++ assertEqual "shuffle [3]=b[1]" (V128.lane Shape.i8x16 shufResult ⟨3, by native_decide⟩) (18 : BitVec 8)

  -- ================================================================
  -- Narrowing (i16x8 ↁEi8x16)
  -- ================================================================

  -- Signed narrow: values in range [-128, 127] pass through
  let narA := V128.ofLanes Shape.i16x8 (fun i =>
    match i.val with | 0 => 100#16 | 1 => BitVec.ofInt 16 (-100) | 2 => 200#16 | _ => 0#16)
  let narB := V128.splat Shape.i16x8 (50 : BitVec 16)
  let narSResult := narrow_i16x8_to_i8x16_s narA narB
  -- 100 in range ↁE100
  r := r ++ assertEqual "narrow_s [0]=100" (V128.lane Shape.i8x16 narSResult ⟨0, by native_decide⟩) (100 : BitVec 8)
  -- -100 in range ↁE-100 (as unsigned 0x9C = 156)
  r := r ++ assertEqual "narrow_s [1]=-100" (V128.lane Shape.i8x16 narSResult ⟨1, by native_decide⟩) (BitVec.ofInt 8 (-100))
  -- 200 > 127 ↁEsaturate to 127
  r := r ++ assertEqual "narrow_s [2]=127 (sat)" (V128.lane Shape.i8x16 narSResult ⟨2, by native_decide⟩) (127 : BitVec 8)
  -- high half from B: 50
  r := r ++ assertEqual "narrow_s [8]=50 (B)" (V128.lane Shape.i8x16 narSResult ⟨8, by native_decide⟩) (50 : BitVec 8)

  -- Unsigned narrow
  let narUResult := narrow_i16x8_to_i8x16_u narA narB
  -- 100 ↁE100
  r := r ++ assertEqual "narrow_u [0]=100" (V128.lane Shape.i8x16 narUResult ⟨0, by native_decide⟩) (100 : BitVec 8)
  -- -100 (0xFF9C) ↁEsaturate to 0 (negative)
  r := r ++ assertEqual "narrow_u [1]=0 (negↁE)" (V128.lane Shape.i8x16 narUResult ⟨1, by native_decide⟩) (0 : BitVec 8)
  -- 200 ↁE200 (within 0..255)
  r := r ++ assertEqual "narrow_u [2]=200" (V128.lane Shape.i8x16 narUResult ⟨2, by native_decide⟩) (200 : BitVec 8)

  -- ================================================================
  -- Extend Operations
  -- ================================================================

  -- extendLowS i8x16→i16x8: low 8 bytes, sign-extend
  let extVec := V128.ofLanes Shape.i8x16 (fun i =>
    match i.val with | 0 => 42#8 | 1 => 0x80#8 | _ => 0#8) -- [42, -128, 0, ...]
  let extLowS := extendLowS_i8x16_i16x8 extVec
  r := r ++ assertEqual "extendLowS [0]=42" (V128.lane Shape.i16x8 extLowS ⟨0, by native_decide⟩) (42 : BitVec 16)
  r := r ++ assertEqual "extendLowS [1]=-128" (V128.lane Shape.i16x8 extLowS ⟨1, by native_decide⟩) (BitVec.ofInt 16 (-128))

  -- extendLowU i8x16→i16x8: low 8 bytes, zero-extend
  let extLowU := extendLowU_i8x16_i16x8 extVec
  r := r ++ assertEqual "extendLowU [0]=42" (V128.lane Shape.i16x8 extLowU ⟨0, by native_decide⟩) (42 : BitVec 16)
  r := r ++ assertEqual "extendLowU [1]=128" (V128.lane Shape.i16x8 extLowU ⟨1, by native_decide⟩) (128 : BitVec 16)

  -- extAddPairwiseU i8x16→i16x8: adjacent unsigned pairs summed
  let pairVec := V128.ofLanes Shape.i8x16 (fun i =>
    BitVec.ofNat 8 (i.val + 1))  -- [1,2,3,4,...,16]
  let pairResult := extAddPairwiseU_i8x16_i16x8 pairVec
  -- Pair sums: (1+2)=3, (3+4)=7, (5+6)=11, (7+8)=15, ...
  r := r ++ assertEqual "extAddPairwiseU [0]=3" (V128.lane Shape.i16x8 pairResult ⟨0, by native_decide⟩) (3 : BitVec 16)
  r := r ++ assertEqual "extAddPairwiseU [1]=7" (V128.lane Shape.i16x8 pairResult ⟨1, by native_decide⟩) (7 : BitVec 16)
  r := r ++ assertEqual "extAddPairwiseU [3]=15" (V128.lane Shape.i16x8 pairResult ⟨3, by native_decide⟩) (15 : BitVec 16)

  -- extMulLowU i8x16→i16x8
  let mulVecA := V128.splat Shape.i8x16 (10 : BitVec 8)
  let mulVecB := V128.splat Shape.i8x16 (20 : BitVec 8)
  let extMulResult := extMulLowU_i8x16_i16x8 mulVecA mulVecB
  r := r ++ assertEqual "extMulLowU [0]=200" (V128.lane Shape.i16x8 extMulResult ⟨0, by native_decide⟩) (200 : BitVec 16)

  IO.println (r.summary "SIMD Misc Operations")
  if r.failed > 0 then throw (IO.Error.userError "SIMD Misc tests failed")
