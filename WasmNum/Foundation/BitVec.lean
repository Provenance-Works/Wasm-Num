import WasmNum.Foundation.Types

/-!
# BitVec Utilities

Wasm-specific BitVec extensions beyond Lean's standard BitVec.
Provides byte-level operations, endianness conversion, and convenience wrappers.

Dependencies: Lean stdlib BitVec
-/

namespace WasmNum.BitVecOps

variable {N n m : Nat}

/-- Extract the i-th byte (0-indexed from LSB) from a BitVec -/
def getByte (v : BitVec N) (i : Nat) : WasmNum.Byte :=
  BitVec.extractLsb' (i * 8) 8 v

/-- Decompose a BitVec into bytes in little-endian order.
    Byte 0 is the least significant byte (Wasm is always little-endian). -/
def toLittleEndian (v : BitVec N) (_ : N % 8 = 0) : Vector WasmNum.Byte (N / 8) :=
  Vector.ofFn fun i => getByte v i.val

/-- Recompose bytes in little-endian order into a BitVec.
    Byte 0 is placed at the least significant position. -/
def fromLittleEndian (bytes : Vector WasmNum.Byte n) : BitVec (n * 8) :=
  .ofNat (n * 8) <| (List.finRange n).foldl
    (fun acc (i : Fin n) => acc ||| ((bytes.get i).toNat <<< (i.val * 8))) 0

/-- toBytes is toLittleEndian (Wasm is always little-endian) -/
def toBytes (v : BitVec N) (h : N % 8 = 0) : Vector WasmNum.Byte (N / 8) :=
  toLittleEndian v h

/-- fromBytes is fromLittleEndian (Wasm is always little-endian) -/
def fromBytes (bytes : Vector WasmNum.Byte n) : BitVec (n * 8) :=
  fromLittleEndian bytes

/-- Sign extension with proof of width constraint.
    Wraps Lean's BitVec.signExtend. -/
def signExtend (v : BitVec m) (_ : m ≤ N) : BitVec N :=
  _root_.BitVec.signExtend N v

/-- Zero extension with proof of width constraint.
    Wraps Lean's BitVec.zeroExtend. -/
def zeroExtend (v : BitVec m) (_ : m ≤ N) : BitVec N :=
  _root_.BitVec.zeroExtend N v

/-- Extract a range of bits. Convenience wrapper for extractLsb'. -/
def extractBits (v : BitVec N) (lo width : Nat)
    (_ : lo + width ≤ N := by omega) : BitVec width :=
  BitVec.extractLsb' lo width v

/-- Concatenation. Wrapper for BitVec.append (++). -/
def concat (a : BitVec m) (b : BitVec n) : BitVec (m + n) :=
  a ++ b

end WasmNum.BitVecOps
