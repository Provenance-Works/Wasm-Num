import WasmNum.Foundation

/-!
# Integer Bit Counting Operations

Count leading zeros, trailing zeros, and population count.

Wasm spec: Section 4.3.2 "Integer Operations"
- FR-152: iclz, ictz, ipopcnt
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Count leading zeros by iterating from MSB.
    Helper for `iclz`. -/
private def countLeadingZerosAux (v : BitVec N) (i : Nat) (acc : Nat) : Nat :=
  if i = 0 then acc
  else if v.getLsbD (i - 1) then acc
  else countLeadingZerosAux v (i - 1) (acc + 1)
termination_by i

/-- Wasm iclz: count leading zeros.
    Wasm spec: `iclz(i)` -/
def iclz (a : BitVec N) : BitVec N :=
  BitVec.ofNat N (countLeadingZerosAux a N 0)

/-- Count trailing zeros by iterating from LSB.
    Helper for `ictz`. -/
private def countTrailingZerosAux (v : BitVec N) (i : Nat) (acc : Nat) : Nat :=
  if i ≥ N then acc
  else if v.getLsbD i then acc
  else countTrailingZerosAux v (i + 1) (acc + 1)
termination_by N - i

/-- Wasm ictz: count trailing zeros.
    Wasm spec: `ictz(i)` -/
def ictz (a : BitVec N) : BitVec N :=
  BitVec.ofNat N (countTrailingZerosAux a 0 0)

/-- Count set bits.
    Helper for `ipopcnt`. -/
private def popCountAux (v : BitVec N) (i : Nat) (acc : Nat) : Nat :=
  if i ≥ N then acc
  else popCountAux v (i + 1) (acc + if v.getLsbD i then 1 else 0)
termination_by N - i

/-- Wasm ipopcnt: population count (number of set bits).
    Wasm spec: `ipopcnt(i)` -/
def ipopcnt (a : BitVec N) : BitVec N :=
  BitVec.ofNat N (popCountAux a 0 0)

end WasmNum.Numerics.Integer
