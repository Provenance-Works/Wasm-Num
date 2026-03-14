import WasmNum.Foundation
import WasmNum.Numerics.NaN.Propagation

/-!
# Float Promotion and Demotion

Conversions between f32 and f64.
- Promotion (f32 → f64) is exact for non-NaN values.
- Demotion (f64 → f32) may round.
Both have NaN handling: canonical NaN → canonical NaN,
non-canonical NaN → arithmetic NaN (non-deterministic).

Wasm spec: Section 4.4 "Conversions"
- FR-203: promote / demote
-/

namespace WasmNum.Numerics.Conversion

open WasmNum
open WasmNum.Numerics.NaN

/-- f64.promote_f32: exact widening with NaN handling.
    - Canonical NaN f32 → canonical NaN f64 set
    - Non-canonical NaN f32 → arithmetic NaN f64 set
    - Non-NaN: exact promotion (singleton)
    Wasm spec: `f64.promote_f32` -/
def promoteF32 [WasmFloat 32] [WasmFloat 64] [WasmFloatPromote]
    (v : F32) : Set F64 :=
  if WasmFloat.isNaN v then
    if WasmFloat.isCanonicalNaN v then
      canonicalNans 64
    else
      arithmeticNans 64
  else
    {WasmFloatPromote.promote v}

/-- f32.demote_f64: lossy narrowing with NaN handling and rounding.
    - Canonical NaN f64 → canonical NaN f32 set
    - Non-canonical NaN f64 → arithmetic NaN f32 set
    - Non-NaN: demoted with rounding (singleton)
    Wasm spec: `f32.demote_f64` -/
def demoteF64 [WasmFloat 32] [WasmFloat 64] [WasmFloatDemote]
    (v : F64) : Set F32 :=
  if WasmFloat.isNaN v then
    if WasmFloat.isCanonicalNaN v then
      canonicalNans 32
    else
      arithmeticNans 32
  else
    {WasmFloatDemote.demote v}

end WasmNum.Numerics.Conversion
