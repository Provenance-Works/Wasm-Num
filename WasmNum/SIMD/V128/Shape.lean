import WasmNum.Foundation

/-!
# Shape System

V128 lane configuration types for SIMD operations.
A Shape specifies lane width, lane count, and lane type,
with a type-level proof that `laneWidth * laneCount = 128` (ADR-004).

Wasm spec: SIMD proposal
- FR-302: Shape System
-/

namespace WasmNum.SIMD

/-- Lane element type: integer or float. -/
inductive LaneType where
  | int
  | float
  deriving DecidableEq, Repr

/-- SIMD shape: a valid lane configuration for V128.
    Carries proofs that width * count = 128 and width is a power of 2 in [8, 64]. -/
structure Shape where
  /-- Bit width of each lane -/
  laneWidth : Nat
  /-- Number of lanes -/
  laneCount : Nat
  /-- Element type (integer or float) -/
  laneType : LaneType
  /-- Width * count = 128 -/
  valid : laneWidth * laneCount = 128
  /-- Width is a power of 2 in {8, 16, 32, 64} -/
  widthPow2 : ∃ k, laneWidth = 2 ^ k ∧ 3 ≤ k ∧ k ≤ 6

namespace Shape

/-- `i8x16`: 16 lanes of 8-bit integers -/
@[reducible] def i8x16 : Shape := ⟨8, 16, .int, by omega, ⟨3, by omega, by omega, by omega⟩⟩

/-- `i16x8`: 8 lanes of 16-bit integers -/
@[reducible] def i16x8 : Shape := ⟨16, 8, .int, by omega, ⟨4, by omega, by omega, by omega⟩⟩

/-- `i32x4`: 4 lanes of 32-bit integers -/
@[reducible] def i32x4 : Shape := ⟨32, 4, .int, by omega, ⟨5, by omega, by omega, by omega⟩⟩

/-- `i64x2`: 2 lanes of 64-bit integers -/
@[reducible] def i64x2 : Shape := ⟨64, 2, .int, by omega, ⟨6, by omega, by omega, by omega⟩⟩

/-- `f32x4`: 4 lanes of 32-bit floats -/
@[reducible] def f32x4 : Shape := ⟨32, 4, .float, by omega, ⟨5, by omega, by omega, by omega⟩⟩

/-- `f64x2`: 2 lanes of 64-bit floats -/
@[reducible] def f64x2 : Shape := ⟨64, 2, .float, by omega, ⟨6, by omega, by omega, by omega⟩⟩

/-- All valid Wasm SIMD shapes -/
def all : List Shape := [i8x16, i16x8, i32x4, i64x2, f32x4, f64x2]

end Shape

end WasmNum.SIMD
