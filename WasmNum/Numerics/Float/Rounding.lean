import WasmNum.Foundation
import WasmNum.Numerics.NaN.Propagation

/-!
# Float Rounding Operations

Wasm rounding operations: fnearest, fceil, ffloor, ftrunc.
Each wraps the corresponding `WasmFloat` round-to-integral primitive
with Wasm NaN propagation.
Results are `Set (BitVec N)` due to NaN non-determinism (ADR-003).

Wasm spec: Section 4.3.3 "Floating-Point Operations"
- FR-103: fnearest
- FR-104: fceil, ffloor, ftrunc
-/

namespace WasmNum.Numerics.Float

open WasmNum

variable {N : Nat}

/-- Wasm fnearest: round to nearest integer with ties-to-even.
    NaN and infinity are preserved. Zero sign is preserved.
    Wasm spec: `fnearest(z)` -/
def fnearest [WasmFloat N] (a : BitVec N) : Set (BitVec N) :=
  NaN.propagateNaN₁ WasmFloat.nearestInt a

/-- Wasm fceil: round toward +Infinity.
    NaN and infinity are preserved. Zero sign is preserved.
    Wasm spec: `fceil(z)` -/
def fceil [WasmFloat N] (a : BitVec N) : Set (BitVec N) :=
  NaN.propagateNaN₁ WasmFloat.ceilInt a

/-- Wasm ffloor: round toward -Infinity.
    NaN and infinity are preserved. Zero sign is preserved.
    Wasm spec: `ffloor(z)` -/
def ffloor [WasmFloat N] (a : BitVec N) : Set (BitVec N) :=
  NaN.propagateNaN₁ WasmFloat.floorInt a

/-- Wasm ftrunc: round toward zero.
    NaN and infinity are preserved. Zero sign is preserved.
    Wasm spec: `ftrunc(z)` -/
def ftrunc [WasmFloat N] (a : BitVec N) : Set (BitVec N) :=
  NaN.propagateNaN₁ WasmFloat.truncInt a

end WasmNum.Numerics.Float
