import WasmNum.Foundation

/-!
# Integer Saturating Arithmetic

Saturating add/sub for SIMD lane operations.
Also provides generic saturation helpers.

Wasm spec: Section 4.3.2 "Integer Operations" (SIMD addendum)
- FR-155: iadd_sat_u/s, isub_sat_u/s
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Signed saturate: clamp integer to signed N-bit range. -/
def sat_s (N : Nat) (i : Int) : BitVec N :=
  let lo : Int := -(2 ^ (N - 1))
  let hi : Int := 2 ^ (N - 1) - 1
  if i < lo then BitVec.ofInt N lo
  else if i > hi then BitVec.ofInt N hi
  else BitVec.ofInt N i

/-- Unsigned saturate: clamp natural to unsigned N-bit range. -/
def sat_u (N : Nat) (i : Int) : BitVec N :=
  if i < 0 then 0#N
  else if i > (2 ^ N - 1 : Int) then BitVec.ofNat N (2 ^ N - 1)
  else BitVec.ofInt N i

/-- Wasm iadd_sat_s: signed saturating addition.
    Wasm spec: `iN.add_sat_s` (SIMD) -/
def iadd_sat_s (a b : BitVec N) : BitVec N :=
  sat_s N (a.toInt + b.toInt)

/-- Wasm iadd_sat_u: unsigned saturating addition.
    Wasm spec: `iN.add_sat_u` (SIMD) -/
def iadd_sat_u (a b : BitVec N) : BitVec N :=
  sat_u N (a.toNat + b.toNat : Int)

/-- Wasm isub_sat_s: signed saturating subtraction.
    Wasm spec: `iN.sub_sat_s` (SIMD) -/
def isub_sat_s (a b : BitVec N) : BitVec N :=
  sat_s N (a.toInt - b.toInt)

/-- Wasm isub_sat_u: unsigned saturating subtraction.
    Wasm spec: `iN.sub_sat_u` (SIMD) -/
def isub_sat_u (a b : BitVec N) : BitVec N :=
  sat_u N (a.toNat - b.toNat : Int)

end WasmNum.Numerics.Integer
