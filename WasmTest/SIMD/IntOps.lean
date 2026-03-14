import WasmTest.Helpers

/-!
# SIMD Integer Lanewise Operation Tests

Tests for IntLanewise.lean operations: arithmetic, saturating, shifts,
comparisons, min/max, abs, avgr, popcnt, q15mulr.
-/

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128
open WasmNum.SIMD.Ops
open WasmNum.SIMD.Ops.IntLanewise
open WasmTest

#eval do
  let mut r := TestResult.empty

  -- ================================================================
  -- i32x4 Arithmetic
  -- ================================================================

  let a4 := V128.ofLanes Shape.i32x4 (fun i =>
    match i.val with | 0 => 10#32 | 1 => 20#32 | 2 => 30#32 | _ => 40#32)
  let b4 := V128.ofLanes Shape.i32x4 (fun i =>
    match i.val with | 0 => 1#32 | 1 => 2#32 | 2 => 3#32 | _ => 4#32)

  let sum := add Shape.i32x4 a4 b4
  r := r ++ assertEqual "i32x4.add [0]" (V128.lane Shape.i32x4 sum ⟨0, by native_decide⟩) (11 : BitVec 32)
  r := r ++ assertEqual "i32x4.add [3]" (V128.lane Shape.i32x4 sum ⟨3, by native_decide⟩) (44 : BitVec 32)

  let diff := sub Shape.i32x4 a4 b4
  r := r ++ assertEqual "i32x4.sub [0]" (V128.lane Shape.i32x4 diff ⟨0, by native_decide⟩) (9 : BitVec 32)
  r := r ++ assertEqual "i32x4.sub [2]" (V128.lane Shape.i32x4 diff ⟨2, by native_decide⟩) (27 : BitVec 32)

  let prod := mul Shape.i32x4 a4 b4
  r := r ++ assertEqual "i32x4.mul [0]" (V128.lane Shape.i32x4 prod ⟨0, by native_decide⟩) (10 : BitVec 32)
  r := r ++ assertEqual "i32x4.mul [3]" (V128.lane Shape.i32x4 prod ⟨3, by native_decide⟩) (160 : BitVec 32)

  -- neg
  let negV := neg Shape.i32x4 b4
  -- neg of 1 = 0xFFFFFFFF
  r := r ++ assertEqual "i32x4.neg [0] of 1" (V128.lane Shape.i32x4 negV ⟨0, by native_decide⟩) (0xFFFFFFFF : BitVec 32)

  -- ================================================================
  -- i8x16 Arithmetic & Saturation
  -- ================================================================

  let a8 := V128.splat Shape.i8x16 (100 : BitVec 8)
  let b8 := V128.splat Shape.i8x16 (100 : BitVec 8)

  -- Unsigned add wraps: 100+100=200 (no wrap for u8)
  let sum8 := add Shape.i8x16 a8 b8
  r := r ++ assertEqual "i8x16.add 100+100" (V128.lane Shape.i8x16 sum8 ⟨0, by native_decide⟩) (200 : BitVec 8)

  -- Saturating unsigned add
  let sat_a := V128.splat Shape.i8x16 (200 : BitVec 8)
  let sat_b := V128.splat Shape.i8x16 (200 : BitVec 8)
  let satU := addSatU Shape.i8x16 sat_a sat_b
  r := r ++ assertEqual "i8x16.add_sat_u 200+200=255" (V128.lane Shape.i8x16 satU ⟨0, by native_decide⟩) (255 : BitVec 8)

  -- Saturating signed add: 100+100 (signed: both positive, result 200>127 ↁEclamp to 127)
  let satS := addSatS Shape.i8x16 a8 b8
  r := r ++ assertEqual "i8x16.add_sat_s 100+100=127" (V128.lane Shape.i8x16 satS ⟨0, by native_decide⟩) (127 : BitVec 8)

  -- subSatU: 50-100 ↁE0
  let sub_a := V128.splat Shape.i8x16 (50 : BitVec 8)
  let sub_b := V128.splat Shape.i8x16 (100 : BitVec 8)
  let subSU := subSatU Shape.i8x16 sub_a sub_b
  r := r ++ assertEqual "i8x16.sub_sat_u 50-100=0" (V128.lane Shape.i8x16 subSU ⟨0, by native_decide⟩) (0 : BitVec 8)

  -- ================================================================
  -- i16x8 Saturating
  -- ================================================================

  let a16 := V128.splat Shape.i16x8 (30000 : BitVec 16)
  let b16 := V128.splat Shape.i16x8 (30000 : BitVec 16)
  let satS16 := addSatS Shape.i16x8 a16 b16
  r := r ++ assertEqual "i16x8.add_sat_s 30000+30000=32767" (V128.lane Shape.i16x8 satS16 ⟨0, by native_decide⟩) (0x7FFF : BitVec 16)

  let satU16 := addSatU Shape.i16x8 (V128.splat Shape.i16x8 (60000 : BitVec 16)) (V128.splat Shape.i16x8 (60000 : BitVec 16))
  r := r ++ assertEqual "i16x8.add_sat_u 60000+60000=65535" (V128.lane Shape.i16x8 satU16 ⟨0, by native_decide⟩) (0xFFFF : BitVec 16)

  -- ================================================================
  -- Shifts (i32x4)
  -- ================================================================

  let shVec := V128.splat Shape.i32x4 (1 : BitVec 32)
  let shifted := shl Shape.i32x4 shVec (8 : I32)
  r := r ++ assertEqual "i32x4.shl 1<<8" (V128.lane Shape.i32x4 shifted ⟨0, by native_decide⟩) (256 : BitVec 32)

  -- shl with mod: shift count mod 32
  let shifted2 := shl Shape.i32x4 shVec (33 : I32)
  r := r ++ assertEqual "i32x4.shl mod 32" (V128.lane Shape.i32x4 shifted2 ⟨0, by native_decide⟩) (2 : BitVec 32)

  -- shrU
  let shrVec := V128.splat Shape.i32x4 (256 : BitVec 32)
  let shrResult := shrU Shape.i32x4 shrVec (4 : I32)
  r := r ++ assertEqual "i32x4.shr_u" (V128.lane Shape.i32x4 shrResult ⟨0, by native_decide⟩) (16 : BitVec 32)

  -- shrS (signed)
  let shrSVec := V128.splat Shape.i32x4 (0x80000000 : BitVec 32)
  let shrSResult := shrS Shape.i32x4 shrSVec (1 : I32)
  r := r ++ assertEqual "i32x4.shr_s" (V128.lane Shape.i32x4 shrSResult ⟨0, by native_decide⟩) (0xC0000000 : BitVec 32)

  -- ================================================================
  -- Comparisons (i32x4)
  -- ================================================================

  let cmpA := V128.ofLanes Shape.i32x4 (fun i =>
    match i.val with | 0 => 10#32 | 1 => 20#32 | 2 => 20#32 | _ => 30#32)
  let cmpB := V128.ofLanes Shape.i32x4 (fun _ => (20 : BitVec 32))

  let eqResult := eqLane Shape.i32x4 cmpA cmpB
  r := r ++ assertEqual "i32x4.eq [0] (10≠20)" (V128.lane Shape.i32x4 eqResult ⟨0, by native_decide⟩) (0 : BitVec 32)
  r := r ++ assertEqual "i32x4.eq [1] (20=20)" (V128.lane Shape.i32x4 eqResult ⟨1, by native_decide⟩) (0xFFFFFFFF : BitVec 32)

  let neResult := neLane Shape.i32x4 cmpA cmpB
  r := r ++ assertEqual "i32x4.ne [0]" (V128.lane Shape.i32x4 neResult ⟨0, by native_decide⟩) (0xFFFFFFFF : BitVec 32)
  r := r ++ assertEqual "i32x4.ne [1]" (V128.lane Shape.i32x4 neResult ⟨1, by native_decide⟩) (0 : BitVec 32)

  let ltUResult := ltULane Shape.i32x4 cmpA cmpB
  r := r ++ assertEqual "i32x4.lt_u [0] (10<20)" (V128.lane Shape.i32x4 ltUResult ⟨0, by native_decide⟩) (0xFFFFFFFF : BitVec 32)
  r := r ++ assertEqual "i32x4.lt_u [3] (30≮20)" (V128.lane Shape.i32x4 ltUResult ⟨3, by native_decide⟩) (0 : BitVec 32)

  -- ================================================================
  -- Min / Max (i32x4)
  -- ================================================================

  let minResult := minU Shape.i32x4 cmpA cmpB
  r := r ++ assertEqual "i32x4.min_u [0]" (V128.lane Shape.i32x4 minResult ⟨0, by native_decide⟩) (10 : BitVec 32)
  r := r ++ assertEqual "i32x4.min_u [1]" (V128.lane Shape.i32x4 minResult ⟨1, by native_decide⟩) (20 : BitVec 32)

  let maxResult := maxU Shape.i32x4 cmpA cmpB
  r := r ++ assertEqual "i32x4.max_u [3]" (V128.lane Shape.i32x4 maxResult ⟨3, by native_decide⟩) (30 : BitVec 32)

  -- ================================================================
  -- Abs (i32x4)
  -- ================================================================

  let absVec := V128.ofLanes Shape.i32x4 (fun i =>
    match i.val with | 0 => 42#32 | 1 => BitVec.ofInt 32 (-42) | _ => 0#32)
  let absResult := IntLanewise.abs Shape.i32x4 absVec
  r := r ++ assertEqual "i32x4.abs positive" (V128.lane Shape.i32x4 absResult ⟨0, by native_decide⟩) (42 : BitVec 32)
  r := r ++ assertEqual "i32x4.abs negative" (V128.lane Shape.i32x4 absResult ⟨1, by native_decide⟩) (42 : BitVec 32)
  r := r ++ assertEqual "i32x4.abs zero" (V128.lane Shape.i32x4 absResult ⟨2, by native_decide⟩) (0 : BitVec 32)

  -- ================================================================
  -- avgr_u (i8x16)
  -- ================================================================

  let avga := V128.splat Shape.i8x16 (10 : BitVec 8)
  let avgb := V128.splat Shape.i8x16 (20 : BitVec 8)
  let avgResult := avgRU Shape.i8x16 avga avgb
  r := r ++ assertEqual "i8x16.avgr_u 10,20" (V128.lane Shape.i8x16 avgResult ⟨0, by native_decide⟩) (15 : BitVec 8)
  -- odd: (11+20+1)/2 = 16
  let avga2 := V128.splat Shape.i8x16 (11 : BitVec 8)
  let avgResult2 := avgRU Shape.i8x16 avga2 avgb
  r := r ++ assertEqual "i8x16.avgr_u 11,20 rounds" (V128.lane Shape.i8x16 avgResult2 ⟨0, by native_decide⟩) (16 : BitVec 8)

  -- ================================================================
  -- popcnt (i8x16 only)
  -- ================================================================

  let pcVec := V128.ofLanes Shape.i8x16 (fun i =>
    match i.val with | 0 => 0xFF#8 | 1 => 0x00#8 | 2 => 0x0F#8 | _ => 0xAA#8)
  let pcResult := popcnt_i8x16 pcVec
  r := r ++ assertEqual "popcnt 0xFF=8" (V128.lane Shape.i8x16 pcResult ⟨0, by native_decide⟩) (8 : BitVec 8)
  r := r ++ assertEqual "popcnt 0x00=0" (V128.lane Shape.i8x16 pcResult ⟨1, by native_decide⟩) (0 : BitVec 8)
  r := r ++ assertEqual "popcnt 0x0F=4" (V128.lane Shape.i8x16 pcResult ⟨2, by native_decide⟩) (4 : BitVec 8)
  r := r ++ assertEqual "popcnt 0xAA=4" (V128.lane Shape.i8x16 pcResult ⟨3, by native_decide⟩) (4 : BitVec 8)

  IO.println (r.summary "SIMD Integer Lanewise")
  if r.failed > 0 then throw (IO.Error.userError "SIMD IntOps tests failed")
