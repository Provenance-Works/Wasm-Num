import WasmNum.Foundation

/-!
# V128 Type

V128 is `BitVec 128`, the Wasm 128-bit SIMD vector type.
This module re-exports the type alias from Foundation and provides
basic constants.

Wasm spec: SIMD proposal
- FR-301: V128 Core Type
-/

namespace WasmNum.SIMD.V128

open WasmNum

/-- The zero V128 vector (all bits 0) -/
def zero : WasmNum.V128 := 0#128

/-- The all-ones V128 vector (all bits 1) -/
def allOnes : WasmNum.V128 := ~~~(0#128)

end WasmNum.SIMD.V128
