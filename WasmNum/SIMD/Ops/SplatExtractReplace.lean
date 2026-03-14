import WasmNum.SIMD.V128.Lanes

/-!
# Splat / Extract / Replace Lane

SIMD lane extraction and replacement at the instruction level.
These wrap the core `V128.lane` / `V128.replaceLane` / `V128.splat`
with the correct sign/zero-extension and truncation for each shape.

Wasm spec: SIMD proposal
- FR-307: Splat / Extract / Replace Lane
-/

namespace WasmNum.SIMD.Ops

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

-- === Extract Lane (Integer) ===

/-- Extract a lane from an integer shape and sign-extend to I32.
    Valid for i8x16, i16x8.
    Wasm spec: `iNxM.extract_lane_s` (N < 32) -/
def extractLaneS (s : Shape) (v : V128) (i : Fin s.laneCount) : I32 :=
  (V128.lane s v i).signExtend 32

/-- Extract a lane from an integer shape and zero-extend to I32.
    Valid for i8x16, i16x8.
    Wasm spec: `iNxM.extract_lane_u` (N < 32) -/
def extractLaneU (s : Shape) (v : V128) (i : Fin s.laneCount) : I32 :=
  (V128.lane s v i).zeroExtend 32

/-- Extract a lane from i32x4.
    Wasm spec: `i32x4.extract_lane` -/
def extractLane_i32x4 (v : V128) (i : Fin 4) : I32 :=
  V128.lane Shape.i32x4 v i

/-- Extract a lane from i64x2.
    Wasm spec: `i64x2.extract_lane` -/
def extractLane_i64x2 (v : V128) (i : Fin 2) : I64 :=
  V128.lane Shape.i64x2 v i

-- === Extract Lane (Float) ===

/-- Extract a lane from f32x4.
    Wasm spec: `f32x4.extract_lane` -/
def extractLane_f32x4 (v : V128) (i : Fin 4) : F32 :=
  V128.lane Shape.f32x4 v i

/-- Extract a lane from f64x2.
    Wasm spec: `f64x2.extract_lane` -/
def extractLane_f64x2 (v : V128) (i : Fin 2) : F64 :=
  V128.lane Shape.f64x2 v i

-- === Replace Lane (Integer) ===

/-- Replace a lane in i8x16 or i16x8 by truncating an I32 to lane width.
    Wasm spec: `iNxM.replace_lane` (N < 32, value truncated) -/
def replaceLaneInt (s : Shape) (v : V128) (i : Fin s.laneCount) (val : I32) : V128 :=
  V128.replaceLane s v i (val.truncate s.laneWidth)

/-- Replace a lane in i32x4.
    Wasm spec: `i32x4.replace_lane` -/
def replaceLane_i32x4 (v : V128) (i : Fin 4) (val : I32) : V128 :=
  V128.replaceLane Shape.i32x4 v i val

/-- Replace a lane in i64x2.
    Wasm spec: `i64x2.replace_lane` -/
def replaceLane_i64x2 (v : V128) (i : Fin 2) (val : I64) : V128 :=
  V128.replaceLane Shape.i64x2 v i val

-- === Replace Lane (Float) ===

/-- Replace a lane in f32x4.
    Wasm spec: `f32x4.replace_lane` -/
def replaceLane_f32x4 (v : V128) (i : Fin 4) (val : F32) : V128 :=
  V128.replaceLane Shape.f32x4 v i val

/-- Replace a lane in f64x2.
    Wasm spec: `f64x2.replace_lane` -/
def replaceLane_f64x2 (v : V128) (i : Fin 2) (val : F64) : V128 :=
  V128.replaceLane Shape.f64x2 v i val

-- === Splat ===

/-- Splat an I32 to all i8x16 lanes (truncated to 8 bits).
    Wasm spec: `i8x16.splat` -/
def splat_i8x16 (val : I32) : V128 :=
  V128.splat Shape.i8x16 (val.truncate 8)

/-- Splat an I32 to all i16x8 lanes (truncated to 16 bits).
    Wasm spec: `i16x8.splat` -/
def splat_i16x8 (val : I32) : V128 :=
  V128.splat Shape.i16x8 (val.truncate 16)

/-- Splat an I32 to all i32x4 lanes.
    Wasm spec: `i32x4.splat` -/
def splat_i32x4 (val : I32) : V128 :=
  V128.splat Shape.i32x4 val

/-- Splat an I64 to all i64x2 lanes.
    Wasm spec: `i64x2.splat` -/
def splat_i64x2 (val : I64) : V128 :=
  V128.splat Shape.i64x2 val

/-- Splat an F32 to all f32x4 lanes.
    Wasm spec: `f32x4.splat` -/
def splat_f32x4 (val : F32) : V128 :=
  V128.splat Shape.f32x4 val

/-- Splat an F64 to all f64x2 lanes.
    Wasm spec: `f64x2.splat` -/
def splat_f64x2 (val : F64) : V128 :=
  V128.splat Shape.f64x2 val

end WasmNum.SIMD.Ops
