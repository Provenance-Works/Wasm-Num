import Mathlib.Data.Set.Basic
import WasmNum.SIMD.V128.Lanes

/-!
# Relaxed SIMD Swizzle

Relaxed swizzle: out-of-range indices may return 0 or the source byte
at `idx mod 16` (implementation-defined).

Wasm spec: Relaxed SIMD proposal
- FR-403: Relaxed Swizzle
-/

namespace WasmNum.SIMD.Relaxed

open WasmNum
open WasmNum.SIMD
open WasmNum.SIMD.V128

/-- Relaxed swizzle: for out-of-range indices (>= 16), the result byte
    may be 0 or `v[idx mod 16]`.
    In-range indices always return `v[idx]`.
    Wasm spec: `i8x16.relaxed_swizzle` -/
def swizzle (v idx : V128) : Set V128 :=
  let s := Shape.i8x16
  { r | ∀ (i : Fin 16),
    let j := (V128.lane s idx i).toNat
    if h : j < 16 then
      V128.lane s r i = V128.lane s v ⟨j, h⟩
    else
      V128.lane s r i = 0#8 ∨
      V128.lane s r i = V128.lane s v ⟨j % 16, Nat.mod_lt j (by omega)⟩ }

end WasmNum.SIMD.Relaxed
