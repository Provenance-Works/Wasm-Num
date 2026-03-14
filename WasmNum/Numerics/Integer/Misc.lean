import WasmNum.Foundation

/-!
# Integer Miscellaneous Operations

Absolute value, negation, unsigned rounding average, and Q15 multiply.

Wasm spec: Section 4.3.2 "Integer Operations" (SIMD addendum)
- FR-155: iabs, ineg, iavgr_u, iq15mulr_sat_s
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Wasm iabs: absolute value (signed interpretation).
    Wasm spec: `iN.abs` (SIMD) -/
def iabs (a : BitVec N) : BitVec N :=
  if a.toInt < 0 then 0#N - a else a

/-- Wasm ineg: two's complement negation.
    Wasm spec: `iN.neg` (SIMD) -/
def ineg (a : BitVec N) : BitVec N := 0#N - a

/-- Wasm iavgr_u: unsigned rounding average.
    `avgr_u(a, b) = (a + b + 1) / 2` (no overflow in wider arithmetic).
    Wasm spec: `iN.avgr_u` (SIMD, i8x16 and i16x8) -/
def iavgr_u (a b : BitVec N) : BitVec N :=
  BitVec.ofNat N ((a.toNat + b.toNat + 1) / 2)

/-- Wasm iq15mulr_sat_s: Q15 saturating rounding multiply.
    `q15mulr_sat_s(a, b) = sat_s((a * b + 0x4000) >> 15)`
    Wasm spec: `i16x8.q15mulr_sat_s` — only valid for 16-bit lanes -/
def iq15mulr_sat_s (a b : BitVec 16) : BitVec 16 :=
  let lo : Int := -(2 ^ 15 : Int)
  let hi : Int := 2 ^ 15 - 1
  let product := a.toInt * b.toInt + (2 ^ 14 : Int)
  let result := product / (2 ^ 15 : Int)
  if result < lo then BitVec.ofInt 16 lo
  else if result > hi then BitVec.ofInt 16 hi
  else BitVec.ofInt 16 result

end WasmNum.Numerics.Integer
