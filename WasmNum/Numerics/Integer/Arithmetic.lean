import WasmNum.Foundation

/-!
# Integer Arithmetic

Modular arithmetic operations for Wasm integers.
Division and remainder are partial (return `Option`) since division by zero traps.

Wasm spec: Section 4.3.2 "Integer Operations"
- FR-151: iadd, isub, imul, idiv, irem
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Wasm iadd: modular addition.
    Wasm spec: `iadd(i1, i2)` -/
def iadd (a b : BitVec N) : BitVec N := a + b

/-- Wasm isub: modular subtraction.
    Wasm spec: `isub(i1, i2)` -/
def isub (a b : BitVec N) : BitVec N := a - b

/-- Wasm imul: modular multiplication.
    Wasm spec: `imul(i1, i2)` -/
def imul (a b : BitVec N) : BitVec N := a * b

/-- Wasm idiv_u: unsigned division. Traps on division by zero.
    Wasm spec: `idiv_u(i1, i2)` -/
def idiv_u (a b : BitVec N) : Option (BitVec N) :=
  if b = 0#N then none
  else some (a / b)

/-- Wasm idiv_s: signed division. Traps on division by zero
    or signed overflow (min_int / -1).
    Wasm spec: `idiv_s(i1, i2)` -/
def idiv_s (a b : BitVec N) : Option (BitVec N) :=
  if b = 0#N then none
  else
    let sa := a.toInt
    let sb := b.toInt
    let q := sa / sb
    -- Signed overflow: INT_MIN / -1 = INT_MAX + 1
    if q < -(2 ^ (N - 1)) || q ≥ 2 ^ (N - 1) then none
    else some (BitVec.ofInt N q)

/-- Wasm irem_u: unsigned remainder. Traps on division by zero.
    Wasm spec: `irem_u(i1, i2)` -/
def irem_u (a b : BitVec N) : Option (BitVec N) :=
  if b = 0#N then none
  else some (a % b)

/-- Wasm irem_s: signed remainder. Traps on division by zero.
    The result has the sign of the dividend.
    Wasm spec: `irem_s(i1, i2)` -/
def irem_s (a b : BitVec N) : Option (BitVec N) :=
  if b = 0#N then none
  else
    let sa := a.toInt
    let sb := b.toInt
    some (BitVec.ofInt N (sa % sb))

end WasmNum.Numerics.Integer
