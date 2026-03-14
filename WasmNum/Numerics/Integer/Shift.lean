import WasmNum.Foundation

/-!
# Integer Shift and Rotate Operations

Shift amounts are taken modulo the bit width N.

Wasm spec: Section 4.3.2 "Integer Operations"
- FR-153: ishl, ishr_u, ishr_s, irotl, irotr
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Wasm ishl: shift left by (k mod N) bits.
    Wasm spec: `ishl(i1, i2)` -/
def ishl (a : BitVec N) (k : BitVec N) : BitVec N :=
  a <<< (k.toNat % N)

/-- Wasm ishr_u: unsigned (logical) shift right by (k mod N) bits.
    Wasm spec: `ishr_u(i1, i2)` -/
def ishr_u (a : BitVec N) (k : BitVec N) : BitVec N :=
  a >>> (k.toNat % N)

/-- Wasm ishr_s: signed (arithmetic) shift right by (k mod N) bits.
    Wasm spec: `ishr_s(i1, i2)` -/
def ishr_s (a : BitVec N) (k : BitVec N) : BitVec N :=
  BitVec.sshiftRight a (k.toNat % N)

/-- Wasm irotl: rotate left by (k mod N) bits.
    Wasm spec: `irotl(i1, i2)` -/
def irotl (a : BitVec N) (k : BitVec N) : BitVec N :=
  let s := k.toNat % N
  (a <<< s) ||| (a >>> (N - s))

/-- Wasm irotr: rotate right by (k mod N) bits.
    Wasm spec: `irotr(i1, i2)` -/
def irotr (a : BitVec N) (k : BitVec N) : BitVec N :=
  let s := k.toNat % N
  (a >>> s) ||| (a <<< (N - s))

end WasmNum.Numerics.Integer
