import WasmNum.Foundation

/-!
# Integer Bitwise Operations

Bitwise operations for Wasm integers.

Wasm spec: Section 4.3.2 "Integer Operations"
- FR-152: iand, ior, ixor, inot, iandnot
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Wasm iand: bitwise AND.
    Wasm spec: `iand(i1, i2)` -/
def iand (a b : BitVec N) : BitVec N := a &&& b

/-- Wasm ior: bitwise OR.
    Wasm spec: `ior(i1, i2)` -/
def ior (a b : BitVec N) : BitVec N := a ||| b

/-- Wasm ixor: bitwise XOR.
    Wasm spec: `ixor(i1, i2)` -/
def ixor (a b : BitVec N) : BitVec N := a ^^^ b

/-- Bitwise NOT (complement). Used internally for SIMD.
    Not a direct Wasm instruction but used by v128.not and iandnot. -/
def inot (a : BitVec N) : BitVec N := ~~~a

/-- Wasm iandnot: `a AND (NOT b)`. Used by v128.andnot and SIMD.
    Wasm spec: `v128.andnot` -/
def iandnot (a b : BitVec N) : BitVec N := a &&& ~~~b

end WasmNum.Numerics.Integer
