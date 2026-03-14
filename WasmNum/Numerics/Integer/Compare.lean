import WasmNum.Foundation

/-!
# Integer Comparison Operations

Comparison operations returning I32 (0 or 1).

Wasm spec: Section 4.3.2 "Integer Operations"
- FR-154: ieqz, ieq, ine, ilt, igt, ile, ige
-/

namespace WasmNum.Numerics.Integer

open WasmNum

variable {N : Nat}

/-- Wasm ieqz: test if zero.
    Wasm spec: `ieqz(i)` -/
def ieqz (a : BitVec N) : I32 :=
  if a = 0#N then 1#32 else 0#32

/-- Wasm ieq: equality.
    Wasm spec: `ieq(i1, i2)` -/
def ieq (a b : BitVec N) : I32 :=
  if a = b then 1#32 else 0#32

/-- Wasm ine: inequality.
    Wasm spec: `ine(i1, i2)` -/
def ine (a b : BitVec N) : I32 :=
  if a = b then 0#32 else 1#32

/-- Wasm ilt_u: unsigned less-than.
    Wasm spec: `ilt_u(i1, i2)` -/
def ilt_u (a b : BitVec N) : I32 :=
  if a.toNat < b.toNat then 1#32 else 0#32

/-- Wasm ilt_s: signed less-than.
    Wasm spec: `ilt_s(i1, i2)` -/
def ilt_s (a b : BitVec N) : I32 :=
  if a.toInt < b.toInt then 1#32 else 0#32

/-- Wasm igt_u: unsigned greater-than.
    Wasm spec: `igt_u(i1, i2)` -/
def igt_u (a b : BitVec N) : I32 :=
  if a.toNat > b.toNat then 1#32 else 0#32

/-- Wasm igt_s: signed greater-than.
    Wasm spec: `igt_s(i1, i2)` -/
def igt_s (a b : BitVec N) : I32 :=
  if a.toInt > b.toInt then 1#32 else 0#32

/-- Wasm ile_u: unsigned less-or-equal.
    Wasm spec: `ile_u(i1, i2)` -/
def ile_u (a b : BitVec N) : I32 :=
  if a.toNat ≤ b.toNat then 1#32 else 0#32

/-- Wasm ile_s: signed less-or-equal.
    Wasm spec: `ile_s(i1, i2)` -/
def ile_s (a b : BitVec N) : I32 :=
  if a.toInt ≤ b.toInt then 1#32 else 0#32

/-- Wasm ige_u: unsigned greater-or-equal.
    Wasm spec: `ige_u(i1, i2)` -/
def ige_u (a b : BitVec N) : I32 :=
  if a.toNat ≥ b.toNat then 1#32 else 0#32

/-- Wasm ige_s: signed greater-or-equal.
    Wasm spec: `ige_s(i1, i2)` -/
def ige_s (a b : BitVec N) : I32 :=
  if a.toInt ≥ b.toInt then 1#32 else 0#32

end WasmNum.Numerics.Integer
