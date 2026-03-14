import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes

/-!
# Relaxed SIMD Dot Product

Relaxed integer dot product operations:
- `i16x8.relaxed_dot_i8x16_i7x16_s`: dot product of i8 lanes
- `i32x4.relaxed_dot_i8x16_i7x16_add_s`: dot product with accumulate

The non-determinism arises from whether the `b` operand lanes are treated
as signed i8 or unsigned i7 (the spec guarantees `b` values fit in i7).

Wasm spec: Relaxed SIMD proposal
- FR-405: Relaxed Dot Product
-/

namespace WasmNum.SIMD.Relaxed

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Relaxed dot product: multiply pairs of i8 lanes and accumulate into i16.
    For each i16 output lane, the result is the sum of two products of
    adjacent i8 lane pairs. The `b` lanes may be treated as signed or unsigned.
    Wasm spec: `i16x8.relaxed_dot_i8x16_i7x16_s` -/
def dot_i8x16_i7x16_s (a b : V128) : Set V128 :=
  let i8 := Shape.i8x16
  let i16 := Shape.i16x8
  { r | ∀ (i : Fin 8),
    let lo := i.val * 2
    let hi := lo + 1
    have hlo : lo < 16 := by omega
    have hhi : hi < 16 := by omega
    let aLo := (V128.lane i8 a ⟨lo, hlo⟩).toInt
    let bLo := (V128.lane i8 b ⟨lo, hlo⟩).toInt
    let aHi := (V128.lane i8 a ⟨hi, hhi⟩).toInt
    let bHi := (V128.lane i8 b ⟨hi, hhi⟩).toInt
    let bLoU := (V128.lane i8 b ⟨lo, hlo⟩).toNat
    let bHiU := (V128.lane i8 b ⟨hi, hhi⟩).toNat
    -- Result may use signed or unsigned interpretation of b
    V128.lane i16 r i = BitVec.ofInt 16 (aLo * bLo + aHi * bHi) ∨
    V128.lane i16 r i = BitVec.ofInt 16 (aLo * (↑bLoU : Int) + aHi * (↑bHiU : Int)) }

/-- Relaxed dot product with accumulate: same as `dot_i8x16_i7x16_s` but
    further accumulated into i32x4 lanes with an addend vector.
    Wasm spec: `i32x4.relaxed_dot_i8x16_i7x16_add_s` -/
def dot_i8x16_i7x16_add_s (a b c : V128) : Set V128 :=
  let i8 := Shape.i8x16
  let i32 := Shape.i32x4
  { r | ∀ (i : Fin 4),
    let base := i.val * 4
    have h0 : base < 16 := by omega
    have h1 : base + 1 < 16 := by omega
    have h2 : base + 2 < 16 := by omega
    have h3 : base + 3 < 16 := by omega
    let a0 := (V128.lane i8 a ⟨base, h0⟩).toInt
    let a1 := (V128.lane i8 a ⟨base + 1, h1⟩).toInt
    let a2 := (V128.lane i8 a ⟨base + 2, h2⟩).toInt
    let a3 := (V128.lane i8 a ⟨base + 3, h3⟩).toInt
    let b0 := (V128.lane i8 b ⟨base, h0⟩).toInt
    let b1 := (V128.lane i8 b ⟨base + 1, h1⟩).toInt
    let b2 := (V128.lane i8 b ⟨base + 2, h2⟩).toInt
    let b3 := (V128.lane i8 b ⟨base + 3, h3⟩).toInt
    let accum := (V128.lane i32 c i).toInt
    let dotSigned := a0 * b0 + a1 * b1 + a2 * b2 + a3 * b3 + accum
    let b0u := (V128.lane i8 b ⟨base, h0⟩).toNat
    let b1u := (V128.lane i8 b ⟨base + 1, h1⟩).toNat
    let b2u := (V128.lane i8 b ⟨base + 2, h2⟩).toNat
    let b3u := (V128.lane i8 b ⟨base + 3, h3⟩).toNat
    let dotUnsigned := a0 * (↑b0u : Int) + a1 * (↑b1u : Int) + a2 * (↑b2u : Int) + a3 * (↑b3u : Int) + accum
    V128.lane i32 r i = BitVec.ofInt 32 dotSigned ∨
    V128.lane i32 r i = BitVec.ofInt 32 dotUnsigned }

end WasmNum.SIMD.Relaxed
