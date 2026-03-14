# TODO — wasm-num Implementation Plan

## Phase 1: Project Scaffolding
- [x] Initialize Lean 4 lake project (`lake init wasm-num`)
- [x] Configure `lean-toolchain` (target: `leanprover/lean4:v4.29.0-rc6` via Mathlib)
- [x] Configure `lakefile.toml` with Mathlib dependency
- [x] Create module hierarchy (empty files with correct imports)
- [x] Verify build with `lake build`
- [x] Set up CI (lean4-action / lean_action_ci.yml)

## Phase 2: Foundation Layer
- [x] `WasmNum/Foundation/Types.lean` — Type aliases (I32, I64, F32, F64, V128, Byte, etc.)
- [x] `WasmNum/Foundation/BitVec.lean` — BitVec utilities (toBytes, fromBytes, signExtend, zeroExtend, toLittleEndian, fromLittleEndian)
- [x] `WasmNum/Foundation/WasmFloat.lean` — WasmFloat typeclass definition (round-to-integral primitives + NaN payload predicates included)
- [x] `WasmNum/Foundation/Profile.lean` — NaNProfile, WasmProfile structures (RelaxedProfile deferred to Phase 9)
- [x] `WasmNum/Foundation/Defs.lean` — Basic definitions (page size, limits, etc.)
- [x] `WasmNum/Foundation/WasmFloat/Default.lean` — Default/stub WasmFloat instance for testing

## Phase 3: Numerics — NaN Propagation
- [x] `WasmNum/Numerics/NaN/Propagation.lean` — nans, canonicalNans, arithmeticNans sets
- [x] `WasmNum/Numerics/NaN/Propagation.lean` — propagateNaN₁, propagateNaN₂ functions
- [x] `WasmNum/Numerics/NaN/Deterministic.lean` — Deterministic NaN propagation via NaNProfile
- [x] `WasmNum/Proofs/Numerics/NaN/Propagation.lean` — NaN propagation correctness proofs
- [x] `WasmNum/Proofs/Numerics/NaN/Deterministic.lean` — Deterministic NaN specialization proofs (membership + singleton)

## Phase 4: Numerics — Float Operations
- [x] `WasmNum/Numerics/Float/MinMax.lean` — fmin, fmax (non-deterministic, Set-returning)
- [x] `WasmNum/Numerics/Float/Rounding.lean` — fnearest, fceil, ffloor, ftrunc
- [x] `WasmNum/Numerics/Float/Sign.lean` — fabs, fneg, fcopysign (deterministic bit ops)
- [x] `WasmNum/Numerics/Float/Compare.lean` — feq, flt, fgt, fle, fge, fne (comparisons)
- [x] `WasmNum/Numerics/Float/PseudoMinMax.lean` — fpmin, fpmax (SIMD)
- [x] `WasmNum/Proofs/Numerics/Float/MinMax.lean` — fmin/fmax spec compliance proofs

## Phase 5: Numerics — Conversions
- [x] `WasmNum/Numerics/Conversion/TruncPartial.lean` — Trapping conversions: trunc_u, trunc_s (Option)
- [x] `WasmNum/Numerics/Conversion/TruncSat.lean` — Saturating conversions: trunc_sat variants (8 total)
- [x] `WasmNum/Numerics/Conversion/PromoteDemote.lean` — promote/demote (f32↔f64)
- [x] `WasmNum/Numerics/Conversion/ConvertIntFloat.lean` — convert (integer→float, 8 variants)
- [x] `WasmNum/Numerics/Conversion/Reinterpret.lean` — reinterpret (4 variants, identity)
- [x] `WasmNum/Numerics/Conversion/IntWidth.lean` — Integer width: wrap, extend_s, extend_u, extend_from_8/16/32
- [x] `WasmNum/Proofs/Numerics/Conversion/TruncPartial.lean` — Partial trunc range proofs
- [x] `WasmNum/Proofs/Numerics/Conversion/TruncSat.lean` — Saturation correctness proofs

## Phase 5.5: Numerics — Scalar Integer Operations
- [x] `WasmNum/Numerics/Integer/Arithmetic.lean` — iadd, isub, imul, idiv, irem
- [x] `WasmNum/Numerics/Integer/Bitwise.lean` — iand, ior, ixor, inot, iandnot
- [x] `WasmNum/Numerics/Integer/Shift.lean` — ishl, ishr_u, ishr_s, irotl, irotr
- [x] `WasmNum/Numerics/Integer/Compare.lean` — ieq, ine, ilt, igt, ile, ige (signed/unsigned)
- [x] `WasmNum/Numerics/Integer/Bits.lean` — iclz, ictz, ipopcnt
- [x] `WasmNum/Numerics/Integer/Ext.lean` — iextend_s
- [x] `WasmNum/Numerics/Integer/Saturating.lean` — iadd_sat, isub_sat, sat_u, sat_s
- [x] `WasmNum/Numerics/Integer/MinMax.lean` — imin, imax (signed/unsigned)
- [x] `WasmNum/Numerics/Integer/Misc.lean` — iabs, ineg, iavgr_u, iq15mulr_sat_s
- [x] `WasmNum/Numerics/Integer/Bitselect.lean` — ibitselect

## Phase 6: SIMD — Core
- [x] `WasmNum/SIMD/V128/Shape.lean` — LaneType, Shape structure, concrete shapes
- [x] `WasmNum/SIMD/V128/Type.lean` — V128 type definition (BitVec 128)
- [x] `WasmNum/SIMD/V128/Lanes.lean` — lane, replaceLane, ofLanes, splat, mapLanes, zipLanes
- [x] `WasmNum/SIMD/Ops/Bitwise.lean` — v128.not, and, andnot, or, xor, bitselect, anyTrue
- [x] `WasmNum/Proofs/SIMD/V128/LanesRoundtrip.lean` — Lane roundtrip proofs
- [x] `WasmNum/Proofs/SIMD/V128/LanesBijection.lean` — Lanes bijection proofs, splat proofs

## Phase 7: SIMD — Integer Operations
- [x] `WasmNum/SIMD/Ops/IntLanewise.lean` — Arithmetic: add, sub, neg, mul
- [x] `WasmNum/SIMD/Ops/IntLanewise.lean` — Saturating: addSatS/U, subSatS/U
- [x] `WasmNum/SIMD/Ops/IntLanewise.lean` — Min/max: minS/U, maxS/U
- [x] `WasmNum/SIMD/Ops/IntLanewise.lean` — Shifts: shl, shrS, shrU
- [x] `WasmNum/SIMD/Ops/IntLanewise.lean` — Comparisons: eq, ne, lt/le/gt/ge (signed/unsigned)
- [x] `WasmNum/SIMD/Ops/Bitmask.lean` — allTrue, bitmask
- [x] `WasmNum/SIMD/Ops/IntLanewise.lean` — abs, avgRU, popcnt
- [x] `WasmNum/SIMD/Ops/Narrow.lean` — Narrowing: narrowS, narrowU
- [x] `WasmNum/SIMD/Ops/Extend.lean` — Widening: extendLow/High (S/U), extAddPairwise, extMul
- [x] `WasmNum/SIMD/Ops/Dot.lean` — dot_i16x8_i32x4
- [x] `WasmNum/SIMD/Ops/Swizzle.lean` — swizzle
- [x] `WasmNum/SIMD/Ops/Shuffle.lean` — shuffle
- [x] `WasmNum/SIMD/Ops/SplatExtractReplace.lean` — splat, extractLane, replaceLane
- [x] `WasmNum/Proofs/SIMD/Ops/Lanewise.lean` — Integer SIMD: lanewise = per-lane scalar

## Phase 8: SIMD — Float Operations
- [x] `WasmNum/SIMD/Ops/FloatLanewise.lean` — Arithmetic: add, sub, mul, div, sqrt (Set-returning)
- [x] `WasmNum/SIMD/Ops/FloatLanewise.lean` — min, max, pmin, pmax
- [x] `WasmNum/SIMD/Ops/FloatLanewise.lean` — Rounding: ceil, floor, trunc, nearest
- [x] `WasmNum/SIMD/Ops/FloatLanewise.lean` — abs, neg (bitwise)
- [x] `WasmNum/SIMD/Ops/FloatLanewise.lean` — Comparisons: eq, ne, lt, le, gt, ge
- [x] `WasmNum/SIMD/Ops/Convert.lean` — SIMD conversions: convertI32x4, truncSatF32x4, promote/demote

## Phase 9: SIMD — Relaxed Operations
- [x] `WasmNum/SIMD/Relaxed/Madd.lean` — relaxed_madd, relaxed_nmadd (Set-returning)
- [x] `WasmNum/SIMD/Relaxed/MinMax.lean` — relaxed min, max
- [x] `WasmNum/SIMD/Relaxed/Swizzle.lean` — relaxed swizzle
- [x] `WasmNum/SIMD/Relaxed/Trunc.lean` — relaxed trunc variants
- [x] `WasmNum/SIMD/Relaxed/Laneselect.lean` — relaxed laneselect
- [x] `WasmNum/SIMD/Relaxed/Dot.lean` — relaxed dot
- [x] `WasmNum/SIMD/Relaxed/Q15.lean` — relaxed q15mulr
- [x] `WasmNum/Foundation/Profile.lean` — RelaxedProfile selector fields (incl. f64x2 madd/nmadd)
- [x] `WasmNum/Integration/Profile.lean` — DeterministicWasmProfile membership obligations (incl. min/max)
- [x] `WasmNum/Proofs/SIMD/Relaxed/DetIsSpecialCase.lean` — Deterministic ⊆ Non-deterministic

## Phase 10: Memory — Core
- [x] `WasmNum/Memory/Core/Page.lean` — Page model, page size constant
- [x] `WasmNum/Memory/Core/FlatMemory.lean` — FlatMemory structure with invariants, empty, byteSize, size
- [x] `WasmNum/Memory/Core/Address.lean` — Address types, effective address calculation
- [x] `WasmNum/Memory/Core/Bounds.lean` — Bounds checking, in-bounds predicate
- [x] Internal helpers: readLittleEndian, writeLittleEndian

## Phase 11: Memory — Load/Store
- [x] `WasmNum/Memory/Load/Scalar.lean` — Scalar loads: i32Load, i64Load, f32Load, f64Load
- [x] `WasmNum/Memory/Load/Packed.lean` — Packed loads: i32Load8S/U, i32Load16S/U, i64Load8/16/32 S/U
- [x] `WasmNum/Memory/Store/Scalar.lean` — Scalar stores: i32Store, i64Store, f32Store, f64Store
- [x] `WasmNum/Memory/Store/Packed.lean` — Packed stores: i32Store8, i32Store16, i64Store8/16/32
- [x] `WasmNum/Memory/Load/SIMD.lean` — v128.load, load_splat, load_lane, load_ext
- [x] `WasmNum/Memory/Store/SIMD.lean` — v128.store, store_lane
- [x] `WasmNum/Proofs/Memory/Bounds.lean` — In-bounds access safety proofs
- [x] `WasmNum/Proofs/Memory/LoadStore.lean` — load-store correctness proofs (storeN_preserves_dataSize, loadN_some_of_inBounds)
  - [x] load_store_same (roundtrip: store then load returns original value)
  - [x] load_store_disjoint (store at one address doesn't affect load at another)

## Phase 12: Memory — Operations
- [x] `WasmNum/Memory/Ops/Size.lean` — memory.size
- [x] `WasmNum/Memory/Ops/Grow.lean` — memory.grow (Set-based for non-determinism)
- [x] `WasmNum/Memory/Ops/Fill.lean` — memory.fill
- [x] `WasmNum/Memory/Ops/Copy.lean` — memory.copy (with overlap handling)
- [x] `WasmNum/Memory/Ops/Init.lean` — memory.init (from data segment)
- [x] `WasmNum/Memory/Ops/DataDrop.lean` — DataSegment type, dataDrop
- [x] `WasmNum/Memory/MultiMemory.lean` — MemoryStore (multi-memory)
- [x] `WasmNum/Memory/Memory64.lean` — 64-bit address space support
- [x] `WasmNum/Proofs/Memory/Grow.lean` — Growth: pageCount, maxLimit, dataSize, data preservation, zero init
- [x] `WasmNum/Proofs/Memory/Copy.lean` — Copy trap proofs (src/dst OOB)
  - [x] copy_correct (overlap correctness, snapshot-based)
- [x] `WasmNum/Proofs/Memory/Fill.lean` — Fill trap proof (OOB)
  - [x] fill_correct (bytes in range set to given value)

## Phase 13: Top-Level API & Integration
- [x] `WasmNum.lean` — Root import file (definitions only)
- [x] `WasmNumProofs.lean` — Root import file (definitions + proofs)
- [x] `WasmNum/Integration/Runtime.lean` — Deterministic wrappers for Set-returning numerics/SIMD operations
- [x] API review: ensure all Wasm instructions are covered
- [x] Documentation: module-level doc comments

## Phase 14: Validation
- [x] `#eval` tests for deterministic operations and deterministic wrappers (test_api.lean)
- [x] Cross-reference with Wasm spec operation list for completeness
- [x] Axiom audit: list all axioms used, verify against budget
- [x] Build clean with zero warnings
- [x] Review proof coverage: every definition has corresponding proof module
