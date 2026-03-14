import WasmNum.SIMD.V128.Lanes

/-!
# V128 Bitwise Operations

Shape-independent 128-bit bitwise operations and bitselect.

Wasm spec: SIMD proposal
- FR-305: v128.not, v128.and, v128.andnot, v128.or, v128.xor,
          v128.bitselect, v128.any_true
-/

namespace WasmNum.SIMD.Ops

open WasmNum

/-- v128.not: bitwise complement.
    Wasm spec: `v128.not` -/
def v128_not (a : WasmNum.V128) : WasmNum.V128 := ~~~a

/-- v128.and: bitwise AND.
    Wasm spec: `v128.and` -/
def v128_and (a b : WasmNum.V128) : WasmNum.V128 := a &&& b

/-- v128.andnot: `a AND (NOT b)`.
    Wasm spec: `v128.andnot` -/
def v128_andnot (a b : WasmNum.V128) : WasmNum.V128 := a &&& ~~~b

/-- v128.or: bitwise OR.
    Wasm spec: `v128.or` -/
def v128_or (a b : WasmNum.V128) : WasmNum.V128 := a ||| b

/-- v128.xor: bitwise XOR.
    Wasm spec: `v128.xor` -/
def v128_xor (a b : WasmNum.V128) : WasmNum.V128 := a ^^^ b

/-- v128.bitselect: for each bit, select from `a` (mask=1) or `b` (mask=0).
    Wasm spec: `v128.bitselect` -/
def v128_bitselect (a b mask : WasmNum.V128) : WasmNum.V128 :=
  (a &&& mask) ||| (b &&& ~~~mask)

/-- v128.any_true: returns 1 if any bit is set, 0 otherwise.
    Wasm spec: `v128.any_true` -/
def v128_any_true (v : WasmNum.V128) : I32 :=
  if v = 0#128 then 0#32 else 1#32

/-- Convert a boolean to a lane mask: all-1s (true) or all-0s (false).
    Shared helper used by integer and float lanewise comparison operations. -/
def boolToMask (n : Nat) (b : Bool) : BitVec n :=
  if b then ~~~(0#n) else 0#n

end WasmNum.SIMD.Ops
